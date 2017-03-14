#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

IMG_DIR=${WORK_DIR}/img
CSAR_DIR=${WORK_DIR}/csar

function juju_env_prepare()
{
    sudo rm -f /root/.ssh/known_hosts
    sudo rm -f /root/.ssh/known_hosts.old

    mkdir -p ${WORK_DIR}/venv
    sudo pip install --upgrade virtualenv
    virtualenv ${WORK_DIR}/venv

    source ${WORK_DIR}/venv/bin/activate
    pip install --upgrade python-openstackclient python-neutronclient
}

function juju_download_img()
{
    if [ ! -e ${IMG_DIR}/${1##*/} ];then
        wget -O ${IMG_DIR}/${1##*/} $1
    fi
}

function juju_download_csar()
{
    if [ ! -e ${CSAR_DIR}/${1##*/} ];then
        wget -O ${CSAR_DIR}/${1##*/} $1
    fi
}

function juju_prepare()
{
    log_info "juju_prepare enter"

    mkdir -p $IMG_DIR
    for((i=0;i<${#JUJU_IMG_NAME[@]};i++))
    do
        juju_download_img ${JUJU_IMG_URL[i]}
        if [[ ! $(glance image-list | grep ${JUJU_IMG_NAME[i]}) ]]; then
            glance image-create --name=${JUJU_IMG_NAME[i]} \
                --disk-format qcow2 --container-format=bare \
                --visibility=public --file ${IMG_DIR}/${JUJU_IMG_URL[i]##*/}
        fi
    done

    juju_download_img $JUJU_VM_IMG_URL
    glance image-create --name=$JUJU_VM_IMG \
        --disk-format qcow2 --container-format=bare \
        --visibility=public --file ${IMG_DIR}/$JUJU_VM_IMG_URL

    mkdir -p $CSAR_DIR
    for((i=0;i<${#CSAR_URL[@]};i++))
    do
        juju_download_csar ${CSAR_NAME[i]}
    done

    if [[ ! $(neutron net-list | grep juju-net) ]]; then
        neutron net-create juju-net
    fi

    if [[ ! $(neutron subnet-list | grep juju-subnet) ]]; then
        neutron subnet-create juju-net $JUJU_NET_CIDR --name juju-subnet --gateway $JUJU_NET_GW \
                                                      --dns_nameservers list=true 8.8.8.8
    fi

    if [[ ! $(neutron router-list | grep juju-router) ]]; then
        neutron router-create juju-router
        neutron router-interface-add juju-router juju-subnet
        neutron router-gateway-set juju-router ext-net
    fi

    local default_secgroup_id=$(nova secgroup-list | grep "Default security group" | awk '{print $2}')

    if [[ ! $(neutron security-group-rule-list | grep default | grep "icmp") ]]; then
        neutron security-group-rule-create --direction ingress --protocol icmp \
                                           --remote-ip-prefix 0.0.0.0/0 $default_secgroup_id
    fi

    if [[ ! $(neutron security-group-rule-list | grep default | grep "icmp") ]]; then
        neutron security-group-rule-create --direction egress --protocol icmp \
                                           --remote-ip-prefix 0.0.0.0/0 $default_secgroup_id
    fi

    if [[ ! $(neutron security-group-rule-list | grep default | grep "tcp") ]]; then
        neutron security-group-rule-create --direction ingress --protocol tcp \
                                           --remote-ip-prefix 0.0.0.0/0 $default_secgroup_id
    fi

    if [[ ! $(neutron security-group-rule-list | grep default | grep "tcp") ]]; then
        neutron security-group-rule-create --direction egress --protocol tcp \
                                           --remote-ip-prefix 0.0.0.0/0 $default_secgroup_id
    fi

    if [[ ! $(neutron security-group-rule-list | grep default | grep "udp") ]]; then
        neutron security-group-rule-create --direction ingress --protocol udp \
                                           --remote-ip-prefix 0.0.0.0/0 $default_secgroup_id
    fi

    if [[ ! $(neutron security-group-rule-list | grep default | grep "udp") ]]; then
        neutron security-group-rule-create --direction egress --protocol udp \
                                           --remote-ip-prefix 0.0.0.0/0 $default_secgroup_id
    fi

    echo -e 'n\n'|ssh-keygen -q -t rsa -N "" -f /root/.ssh/id_rsa 1>/dev/null

    openstack keypair delete jump-key | true
    openstack keypair create --public-key /root/.ssh/id_rsa.pub jump-key

    openstack flavor show m1.tiny   || openstack flavor create --ram 512 --disk 5 --vcpus 1 --public m1.tiny
    openstack flavor show m1.small  || openstack flavor create --ram 1024 --disk 10 --vcpus 1 --public m1.small
    openstack flavor show m1.medium || openstack flavor create --ram 2048 --disk 10 --vcpus 2 --public m1.medium
    openstack flavor show m1.large  || openstack flavor create --ram 3072 --disk 10 --vcpus 2 --public m1.large
    openstack flavor show m1.xlarge || openstack flavor create --ram 8096 --disk 30 --vcpus 4 --public m1.xlarge

    openstack quota set --instances 20 admin
    openstack quota set --core 30 admin
}
