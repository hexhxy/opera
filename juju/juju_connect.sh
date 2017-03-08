#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

function connect_prepare()
{
    apt-get install -y rsync

    local cmd="sudo apt-get install -y default-jdk; \
               wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz; \
               tar -zxvf apache-tomcat-8.5.9.tar.gz; \
               sudo rm -rf tomcat8 csar; \
               mv apache-tomcat-8.5.9 tomcat8; \
               rm -rf tomcat8/webapps/*; \
               mkdir csar"
    exec_cmd_on_client $cmd
}

function sync_juju_driver_file()
{
    connect_prepare

    docker cp nfvo-driver-vnfm-juju:/service/webapps/ROOT /home/
    docker cp nfvo-driver-vnfm-juju:/service/etc /home/

    cp ${UTIL_DIR}/modify_file.sh /home
    sed -i s/REPLACE_JUJU_DRIVER_IP/$OPENO_VM_IP/ /home/modify_file.sh
    sed -i s/REPLACE_JUJU_METADATA_IP/$floating_ip_metadata/ /home/modify_file.sh
    sed -i s/MSB_PORT/$COMMON_SERVICES_MSB_PORT/ /home/modify_file.sh
    chmod +x /home/modify_file.sh
    /home/modify_file.sh

    rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo rsync' \
                -av /home/etc ubuntu@$floating_ip_client:/home/ubuntu/tomcat8/
    rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo rsync' \
                -av /home/ROOT ubuntu@$floating_ip_client:/home/ubuntu/tomcat8/webapps

    docker cp /home/etc nfvo-driver-vnfm-juju:/service/
    docker cp /home/ROOT nfvo-driver-vnfm-juju:/service/webapps/
}

function start_tomcat()
{
    chmod +x ${UTIL_DIR}/grant_mysql.sh
    docker cp ${UTIL_DIR}/grant_mysql.sh nfvo-driver-vnfm-juju:/service
    docker exec -i nfvo-driver-vnfm-juju /service/grant_mysql.sh

    local cmd1='sed -i s/port=\"8080\"/port=\"8483\"/g /home/ubuntu/tomcat8/conf/server.xml'
    exec_cmd_on_client $cmd1

    local cmd2="ps aux | grep java | awk '{print \"$2\"}' | xargs kill -9; \
                /home/ubuntu/tomcat8/bin/catalina.sh start"
    exec_cmd_on_client $cmd2
}

function add_vim_and_vnfm()
{
    python ${JUJU_DIR}/openo_connect.py --msb_ip "$OPENO_VM_IP:$COMMON_SERVICES_MSB_PORT" \
                                        --tosca_aria_ip $OPENO_VM_IP \
                                        --juju_client_ip $floating_ip_client \
                                        --auth_url $OS_AUTH_URL \
                                        --ns_pkg "${OPERA_DIR}/csar/pop_ns_juju.csar" \
                                        --juju_pkg "${OPERA_DIR}/csar/JUJU_clearwater.csar"
    docker stop nfvo-driver-vnfm-juju
    docker start nfvo-driver-vnfm-juju
    docker stop gso-service-gateway
    docker stop nfvo-resmanagement
    docker start gso-service-gateway
    docker start nfvo-resmanagement
}

function connect_juju_and_openo()
{
    sync_juju_driver_file
    start_tomcat
    add_vim_and_vnfm
}
