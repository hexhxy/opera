#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function clear_juju_vm()
{
    servers=$(openstack server list | grep juju | awk '{print $2}')
    if [[ -n $servers ]];then
        openstack server delete $servers
    fi
}

function launch_juju_vm()
{
    local NET_ID=$(neutron net-list | grep juju-net | awk '{print $2}')

    if [[ ! $(nova list | grep juju-client-vm) ]]; then
        nova boot --flavor m1.small --image $JUJU_VM_IMG --nic net-id=$NET_ID \
                  --key-name jump-key --security-group default juju-client-vm
        if [ $? -ne 0 ]; then
            log_error "boot juju-client-vm fail"
            exit 1
        fi
    fi

    local count=300
    set +x
    while
        local state=$(nova list | grep juju-client-vm | awk '{print $6}')
        if [[ $state == "ERROR" || $count == 0 ]]; then
            log_error "launch juju vm error"
            exit 1
        fi
        let count-=1
        sleep 2
        [[ $state != "ACTIVE" ]]
    do :;done
    set -x

    if [ ! $(nova list | grep juju-client-vm | awk '{print $14}') ]; then
        juju_client_ip=$(neutron floatingip-create ext-net | grep floating_ip_address | awk '{print $4}')
        nova floating-ip-associate juju-client-vm $juju_client_ip
    else
        juju_client_ip=$(nova list | grep juju-client-vm | awk '{print $13}')
    fi

    local wait=120
    set +x
    while
        if [[ $wait == 0 ]]; then
            log_error "launch juju vm can't access"
            exit 1
        fi
        exec_cmd_on_client exit 2>/dev/null
        local ready=$?
        let wait-=1
        sleep 2
        [[ $ready != 0 ]]
    do :;done
    set -x

    export juju_client_ip=$juju_client_ip
    log_info "juju client launched!"
}

function juju_client_prepare()
{
    exec_cmd_on_client "echo 'clouds:
    openstack:
        type: openstack
        auth-types: [access-key, userpass]
        regions:
            $OS_REGION_NAME:
                endpoint: $OS_AUTH_URL' > clouds.yaml"

    local cmd1="juju remove-cloud openstack; \
                juju add-cloud openstack clouds.yaml --replace"
    exec_cmd_on_client $cmd1

    if [[ ! $(exec_cmd_on_client "juju list-clouds | grep openstack") ]]; then
        log_error "juju-client add cloud error"
        exit 1
    fi

    local cmd2="juju remove-credential openstack openstack"
    exec_cmd_on_client $cmd2

    scp_to_client ${CONF_DIR}/admin-openrc.sh /home/ubuntu

    local cmd4="cd /home/ubuntu/juju_server; git reset --hard; git pull;"
    exec_cmd_on_client $cmd4
}

function juju_generate_metadata()
{
    exec_cmd_on_client mkdir -p mt

    if [[ ! $(exec_cmd_on_client sudo ps aux | grep nginx) ]]; then
        log_error "juju-metadata nginx is not running"
        exit 1
    fi

    for((i=0;i<${#JUJU_IMG_NAME[@]};i++))
    do
        IMAGE_ID=$(glance image-list | grep ${JUJU_IMG_NAME[i]} | awk '{print $2}')
        cmd="juju metadata generate-image -s ${JUJU_IMG_NAME[i]%%_*} -i $IMAGE_ID \
             -r $OS_REGION_NAME -d mt -u $OS_AUTH_URL"
        exec_cmd_on_client $cmd
    done

    local cmd1="juju metadata generate-tools -d mt"
    exec_cmd_on_client $cmd1

    local cmd2="sudo cp -a mt/tools/ /var/www/html; \
          sudo cp -a mt/images/ /var/www/html; \
          sudo chmod a+rx /var/www/html/ -R"
    exec_cmd_on_client $cmd2

    wget -O - http://$juju_client_ip/images/streams/v1/index.json
    if [ $? -ne 0 ]; then
        log_error "juju metadata generate error"
        exit 1
    fi
}

function bootstrap_juju_controller()
{
    local cmd1="juju controllers | grep openstack"
    exec_cmd_on_client $cmd1
    if [[ $? != 0 ]];then
        local cmd2="source admin-openrc.sh; \
            juju bootstrap openstack openstack \
            --config image-metadata-url=http://$juju_client_ip/images \
            --config network=juju-net --config use-floating-ip=True \
            --config use-default-secgroup=True \
            --constraints 'mem=4G root-disk=40G' \
            --verbose --debug"
        exec_cmd_on_client $cmd2
        exec_cmd_on_client $cmd1
        if [[ $? == 0 ]];then
            log_info "juju controller launched!"
        else
            log_error "launch juju controller fail!"
            exit 1
        fi
    fi
}

function launch_juju()
{
    log_info "launch_juju enter"

    launch_juju_vm
    juju_client_prepare
    juju_generate_metadata
    bootstrap_juju_controller
}
