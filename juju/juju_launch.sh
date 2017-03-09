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
        nova boot --flavor m1.small --image xenial_x86_64 --nic net-id=$NET_ID \
                  --key-name jump-key --security-group default juju-client-vm
        if [ $? -ne 0 ]; then
            log_error "boot juju-client-vm fail"
            exit 1
        fi
    fi

    if [[ ! $(nova list | grep juju-metadata-vm) ]]; then
        nova boot --flavor m1.small --image xenial_x86_64 --nic net-id=$NET_ID \
                  --key-name jump-key --security-group default juju-metadata-vm
        if [ $? -ne 0 ]; then
            log_error "boot juju-metadata-vm fail"
            exit 1
        fi
    fi

    local count=300
    set +x
    while
        local state1=$(nova list | grep juju-client-vm | awk '{print $6}')
        local state2=$(nova list | grep juju-metadata-vm | awk '{print $6}')
        if [[ $state1 == "ERROR" || $state2 == "ERROR" || $count == 0 ]]; then
            log_error "launch juju vm error"
            exit 1
        fi
        let count-=1
        sleep 2
        [[ $state1 != "ACTIVE" || $state2 != "ACTIVE" ]]
    do :;done
    set -x

    if [ ! $(nova list | grep juju-client-vm | awk '{print $14}') ]; then
        floating_ip_client=$(neutron floatingip-create ext-net | grep floating_ip_address | awk '{print $4}')
        nova floating-ip-associate juju-client-vm $floating_ip_client
    else
        floating_ip_client=$(nova list | grep juju-client-vm | awk '{print $13}')
    fi

    if [ ! $(nova list | grep juju-metadata-vm | awk '{print $14}') ]; then
        floating_ip_metadata=$(neutron floatingip-create ext-net | grep floating_ip_address | awk '{print $4}')
        nova floating-ip-associate juju-metadata-vm $floating_ip_metadata
    else
        floating_ip_metadata=$(nova list | grep juju-metadata-vm | awk '{print $13}')
    fi

    local wait=120
    set +x
    while
        if [[ $wait == 0 ]]; then
            log_error "launch juju vm can't access"
            exit 1
        fi
        exec_cmd_on_client exit 2>null
        local ready1=$?
        exec_cmd_on_metadata exit 2>null
        local ready2=$?
        let wait-=1
        sleep 2
        [[ $ready1 != 0 || $ready2 != 0 ]]
    do :;done
    set -x

    export floating_ip_client=$floating_ip_client
    export floating_ip_metadata=$floating_ip_metadata
}

function juju_metadata_prepare()
{
    local cmd="sudo apt update -y; \
         sudo apt-get install nginx -y"
    exec_cmd_on_metadata $cmd

    if [[ ! $(exec_cmd_on_metadata sudo ps -aux | grep nginx) ]]; then
        log_error "juju-metadata nginx error"
        exit 1
    fi
}

function juju_client_prepare()
{
    local cmd1="sudo add-apt-repository ppa:juju/stable; \
         sudo apt update -y; \
         sudo apt install juju zfsutils-linux -y"
    exec_cmd_on_client $cmd1

    exec_cmd_on_client "echo 'clouds:
    openstack:
        type: openstack
        auth-types: [access-key, userpass]
        regions:
            $OS_REGION_NAME:
                endpoint: $OS_AUTH_URL' > clouds.yaml"

    local cmd2="juju add-cloud openstack clouds.yaml --replace"
    exec_cmd_on_client $cmd2

    if [[ ! $(exec_cmd_on_client "juju list-clouds | grep openstack") ]]; then
        log_error "juju-client add cloud error"
        exit 1
    fi

    local cmd3="echo -e \'n\\n\'|ssh-keygen -q -t rsa -N \"\" -f /home/ubuntu/.ssh/id_rsa 1>/dev/null"
    exec_cmd_on_client $cmd3

    local client_key=`exec_cmd_on_client sudo cat /home/ubuntu/.ssh/id_rsa.pub`
    local cmd4="echo $client_key >> /home/ubuntu/.ssh/authorized_keys"
    exec_cmd_on_metadata $cmd4

    exec_cmd_on_client "echo 'credentials:
    openstack:
        openstack:
            auth-type: userpass
            password: $OS_PASSWORD
            tenant-name: $OS_PROJECT_NAME
            username: $OS_USERNAME' > os-creds.yaml"

    local cmd5="juju add-credential openstack -f os-creds.yaml --replace"
    exec_cmd_on_client $cmd5
}

function juju_generate_metadata()
{
    exec_cmd_on_client mkdir -p mt

    for((i=0;i<${#JUJU_IMG_NAME[@]};i++))
    do
        IMAGE_ID=$(glance image-list | grep ${JUJU_IMG_NAME[i]} | awk '{print $2}')
        cmd="juju metadata generate-image -s ${JUJU_IMG_NAME[i]%%_*} -i $IMAGE_ID \
             -r $OS_REGION_NAME -d mt -u $OS_AUTH_URL"
        exec_cmd_on_client $cmd
    done

    local cmd1="juju metadata generate-tools -d mt"
    exec_cmd_on_client $cmd1

    local cmd2="rsync -e 'ssh -o StrictHostKeyChecking=no' -av mt ubuntu@$floating_ip_metadata:~/"
    exec_cmd_on_client $cmd2

    local cmd3="sudo cp -a mt/tools/ /var/www/html; \
          sudo cp -a mt/images/ /var/www/html; \
          sudo chmod a+rx /var/www/html/ -R"
    exec_cmd_on_metadata $cmd3

    wget -O - http://$floating_ip_metadata/images/streams/v1/index.json
    if [ $? -ne 0 ]; then
        log_error "juju metadata generate error"
        exit 1
    fi
}

function bootstrap_juju_controller()
{
    local cmd="juju controllers | grep openstack"
    exec_cmd_on_client $cmd
    if [[ $? != 0 ]];then
        local cmd1="juju bootstrap openstack openstack \
            --config image-metadata-url=http://$floating_ip_metadata/images \
            --config network=juju-net --config use-floating-ip=True \
            --config use-default-secgroup=True \
            --constraints 'mem=4G root-disk=40G' \
            --verbose --debug"
        exec_cmd_on_client $cmd1
    fi
}

function launch_juju()
{
    log_info "launch_juju enter"

    launch_juju_vm
    juju_metadata_prepare
    juju_client_prepare
    juju_generate_metadata
    bootstrap_juju_controller
}
