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

    local cmd="tar -zxvf apache-tomcat-8.5.9.tar.gz; \
               sudo rm -rf tomcat8 csar; \
               mv apache-tomcat-8.5.9 tomcat8; \
               rm -rf tomcat8/webapps/*; \
               mkdir csar"
    exec_cmd_on_client $cmd
}

function sync_juju_driver_file()
{
    local TOMCAT_DIR=${WORK_DIR}/tomcat
    rm -rf ${TOMCAT_DIR}
    mkdir -p ${TOMCAT_DIR}

    connect_prepare

    docker cp nfvo-driver-vnfm-juju:/service/webapps/ROOT ${TOMCAT_DIR}
    docker cp nfvo-driver-vnfm-juju:/service/etc ${TOMCAT_DIR}

    file1=${TOMCAT_DIR}/etc/conf/juju_conf.json
    sed -i "s/^\(.*\"image-metadata-url\":\).*/\1 \"http:\/\/$floating_ip_metadata\/images\"\,/g" $file1
    sed -i "s/^\(.*\"network\":\).*/\1 \"juju-net\"\,/g" $file1
    sed -i "s/^\(.*\"use-floating-ip\":\).*/\1 \"True\"\,/g" $file1

    file2=${TOMCAT_DIR}/etc/csarInfo/csarinfo.json
    sed -i "s/^\(.*\"csar_file_path\":\).*/\1 \"\/home\/ubuntu\/csar\/\"\,/g" $file2

    file3=${TOMCAT_DIR}/ROOT/WEB-INF/classes/db.properties
    sed -i "s/^\(.*jdbc.url=\).*/\1jdbc:mysql:\/\/$OPENO_IP:$NFVO_DRIVER_VNFM_JUJU_MYSQL_PORT\/jujuvnfmdb/g" $file3

    file4=${TOMCAT_DIR}/ROOT/WEB-INF/classes/juju-config.properties
    sed -i "s/^\(.*charmPath=\).*/\1\/home\/ubuntu\/csar\//g" $file4
    sed -i "s/^\(.*grant_jujuvnfm_url=\).*/\1http:\/\/$OPENO_IP:$NFVO_DRIVER_VNFM_JUJU_PORT\//g" $file4

    file5=${TOMCAT_DIR}/etc/conf/restclient.json
    sed -i "s/^\(.*\"host\":\).*/\1\"$OPENO_IP\"\,/g" $file5
    sed -i "s|^\(.*\"port\":\).*|\1\"$COMMON_SERVICES_MSB_PORT\"|g" $file5

    file6=${TOMCAT_DIR}/etc/adapterInfo/jujuadapterinfo.json
    sed -i "s/^\(.*\"ip\":\).*/\1 \"$OPENO_IP\"\,/g" $file6

    rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo rsync' \
    -av ${TOMCAT_DIR}/etc ubuntu@$floating_ip_client:/home/ubuntu/tomcat8/
    rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo rsync' \
    -av ${TOMCAT_DIR}/ROOT ubuntu@$floating_ip_client:/home/ubuntu/tomcat8/webapps

    docker cp ${TOMCAT_DIR}/etc nfvo-driver-vnfm-juju:/service/
    docker cp ${TOMCAT_DIR}/ROOT nfvo-driver-vnfm-juju:/service/webapps/
}

function start_tomcat()
{
    chmod +x ${UTIL_DIR}/grant_mysql.sh
    docker cp ${UTIL_DIR}/grant_mysql.sh nfvo-driver-vnfm-juju:/service
    docker exec -i nfvo-driver-vnfm-juju /service/grant_mysql.sh

    local cmd1='sed -i s/port=\"8080\"/port=\"8483\"/g /home/ubuntu/tomcat8/conf/server.xml'
    exec_cmd_on_client $cmd1

    local cmd2="pidof java | xargs kill -9; \
                /home/ubuntu/tomcat8/bin/catalina.sh start"

    exec_cmd_on_client $cmd2

    docker stop nfvo-driver-vnfm-juju
    docker start nfvo-driver-vnfm-juju
}

function openo_connect()
{
    python ${JUJU_DIR}/openo_connect.py --application $APPLICATION \
                                        --msb_ip $OPENO_IP:$COMMON_SERVICES_MSB_PORT \
                                        --tosca_aria_ip $OPENO_IP \
                                        --tosca_aria_port $COMMON_TOSCA_ARIA_PORT \
                                        --juju_client_ip $floating_ip_client \
                                        --auth_url $OS_AUTH_URL \
                                        --ns_pkg "${OPERA_DIR}/csar/pop_ns_juju.csar" \
                                        --vnf_pkg "${OPERA_DIR}/csar/JUJU_clearwater.csar"
}

function fix_openo_containers()
{
    docker exec gso-service-gateway sed -i "s|^\(.*\"port\":\).*|\1 \"$COMMON_SERVICES_MSB_PORT\"|g" /service/etc/conf/restclient.json
    docker stop gso-service-gateway
    docker start gso-service-gateway
    docker exec nfvo-resmanagement sed -i "s|^\(.*\"port\":\).*|\1 \"$COMMON_SERVICES_MSB_PORT\"|g" /service/etc/conf/restclient.json
    docker stop nfvo-resmanagement
    docker start nfvo-resmanagement
}

function connect_juju_and_openo()
{
    sync_juju_driver_file
    start_tomcat
    fix_openo_containers
    openo_connect
}
