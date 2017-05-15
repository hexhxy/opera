#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
SCRIPT_DIR=${WORK_DIR}/scripts

function generate_conf()
{
    rm -rf ${SCRIPT_DIR}
    mkdir -p ${SCRIPT_DIR}
    python ${OPERA_DIR}/process_conf.py ${CONF_DIR}/open-o.yml \
                                        ${CONF_DIR}/vnf.yml
}

function package_prepare()
{
    if [[ $(grep Ubuntu /etc/issue) ]]; then
        sudo apt-get update -y
        sudo apt-get install -y wget python-pip sshpass figlet curl net-tools
    else
        # not test with redhat server yet
        sudo yum update -y
        sudo yum install -y wget python-pip sshpass figlet curl net-tools
    fi
    sudo pip install pyyaml
    sudo docker version &>/dev/null
    if [[ $? != 0 ]];then
        sudo curl -sSL https://experimental.docker.com/ | sh
        sudo service docker start
    fi
}

function network_prepare()
{
    local assigned_ip=`sed -n 's/OPENO_IP=//p' ${SCRIPT_DIR}/open-o.conf`
    echo $assigned_ip
    if [[ $assigned_ip != 'None' ]]; then
        if [[ ! $(ifconfig -a | grep openo) ]]; then
            sudo ip tuntap add dev openo mode tap
        fi
        sudo ifconfig openo $assigned_ip up
    else
        external_nic=`ip route |grep '^default'|awk '{print $5F}'`
        host_ip=`ifconfig $external_nic | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
        sed -i "s/^\(.*OPENO_IP=\).*/\1$host_ip/g" ${SCRIPT_DIR}/open-o.conf
    fi
}

function prepare_env()
{
    package_prepare
    generate_conf
    network_prepare
}
