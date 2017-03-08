#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -ex
export OPERA_DIR=`cd ${BASH_SOURCE[0]%/*}/;pwd`
CONF_DIR=${OPERA_DIR}/conf
OPENO_DIR=${OPERA_DIR}/open-o
JUJU_DIR=${OPERA_DIR}/juju
WORK_DIR=${OPERA_DIR}/work
UTIL_DIR=${OPERA_DIR}/util

export DEPLOY_FIRST_TIME=${DEPLOY_FIRST_TIME:-"true"}
export DEPLOY_OPENO=${DEPLOY_OPENO:-"true"}
export DEPLOY_JUJU=${DEPLOY_JUJU:-"true"}

source ${OPERA_DIR}/prepare.sh
source ${OPERA_DIR}/conf/download.conf

source ${UTIL_DIR}/log.sh
source ${OPERA_DIR}/command.sh
source ${JUJU_DIR}/adapter.sh
source ${JUJU_DIR}/juju_setup.sh
source ${JUJU_DIR}/juju_launch.sh
source ${JUJU_DIR}/juju_connect.sh

mkdir -p $WORK_DIR

#if [[ "$DEPLOY_FIRST_TIME" == "true" ]]; then
#     package_prepare
#     generate_compass_openrc
#fi

external_nic=`ip route |grep '^default'|awk '{print $5F}'`
host_ip=`ifconfig $external_nic | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
sed -i "s/^\(.*openo_vm_ip:\).*/\1 $host_ip/g" ${CONF_DIR}/network.yml
generate_conf
source ${WORK_DIR}/scripts/network.conf
source ${WORK_DIR}/admin-openrc.sh
source ${OPENO_DIR}/openo_docker.sh
echo "OPENO_VM_IP:$OPENO_VM_IP"
echo "COMMON_SERVICES_MSB_PORT:$COMMON_SERVICES_MSB_PORT"
#sudo sync && sudo sysctl -w vm.drop_caches=3

if [[ "$DEPLOY_OPENO" == "true" ]]; then
    if ! deploy_openo;then
        log_error "deploy_openo failed"
        exit 1
    fi
fi

#sudo sync && sudo sysctl -w vm.drop_caches=3
if [[ "$DEPLOY_JUJU" == "true" ]]; then
    juju_env_prepare

    if ! juju_prepare; then
        log_error "juju_prepare failed"
        exit 1
    fi

    if ! launch_juju; then
        log_error "launch_juju failed"
        exit 1
    fi
    connect_juju_and_openo
fi

figlet -ctf slant Open-O Installed!
set +ex
