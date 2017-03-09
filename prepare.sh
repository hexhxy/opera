#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

function generate_conf()
{
    rm -rf ${WORK_DIR}/scripts
    mkdir -p ${WORK_DIR}/scripts
    python ${OPERA_DIR}/process_conf.py ${CONF_DIR}/open-o.yml
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
    docker version &>/dev/null
    if [[ $? != 0 ]];then
        curl -sSL https://experimental.docker.com/ | sh
        service docker start
    fi
}

function network_prepare()
{
    if [[ ! $(ip a | grep openo) ]]; then
        sudo ip tuntap add dev openo mode tap
        sudo ifconfig openo $OPENO_IP up
    fi
}

function get_local_ip()
{
    external_nic=`ip route |grep '^default'|awk '{print $5F}'`
    host_ip=`ifconfig $external_nic | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
    sed -i "s/^\(.*openo_ip:\).*/\1 $host_ip/g" ${CONF_DIR}/open-o.yml
}

function prepare_env()
{
    package_prepare
    get_local_ip
    generate_conf
#    network_prepare
}
