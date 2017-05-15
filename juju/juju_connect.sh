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
    sudo apt-get install -y rsync

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
    sudo rm -rf ${TOMCAT_DIR}
    mkdir -p ${TOMCAT_DIR}

    connect_prepare

    sudo docker cp nfvo-driver-vnfm-juju:/service/webapps/ROOT ${TOMCAT_DIR}
    sudo docker cp nfvo-driver-vnfm-juju:/service/etc ${TOMCAT_DIR}

    file1=${TOMCAT_DIR}/etc/conf/juju_conf.json
    sudo sed -i "s/^\(.*\"image-metadata-url\":\).*/\1 \"http:\/\/$juju_client_ip\/images\"\,/g" $file1
    sudo sed -i "s/^\(.*\"network\":\).*/\1 \"juju-net\"\,/g" $file1
    sudo sed -i "s/^\(.*\"use-floating-ip\":\).*/\1 \"True\"\,/g" $file1

    file2=${TOMCAT_DIR}/etc/csarInfo/csarinfo.json
    sudo sed -i "s/^\(.*\"csar_file_path\":\).*/\1 \"\/home\/ubuntu\/csar\/\"\,/g" $file2

    file3=${TOMCAT_DIR}/ROOT/WEB-INF/classes/db.properties
    sudo sed -i "s/^\(.*jdbc.url=\).*/\1jdbc:mysql:\/\/$OPENO_IP:$NFVO_DRIVER_VNFM_JUJU_MYSQL_PORT\/jujuvnfmdb/g" $file3

    file4=${TOMCAT_DIR}/ROOT/WEB-INF/classes/juju-config.properties
    sudo sed -i "s/^\(.*charmPath=\).*/\1\/home\/ubuntu\/csar\//g" $file4
    sudo sed -i "s/^\(.*grant_jujuvnfm_url=\).*/\1http:\/\/$OPENO_IP:$NFVO_DRIVER_VNFM_JUJU_PORT\//g" $file4

    file5=${TOMCAT_DIR}/etc/conf/restclient.json
    sudo sed -i "s/^\(.*\"host\":\).*/\1\"$OPENO_IP\"\,/g" $file5
    sudo sed -i "s|^\(.*\"port\":\).*|\1\"$COMMON_SERVICES_MSB_PORT\"|g" $file5

    file6=${TOMCAT_DIR}/etc/adapterInfo/jujuadapterinfo.json
    sudo sed -i "s/^\(.*\"ip\":\).*/\1 \"$OPENO_IP\"\,/g" $file6

    rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo rsync' \
    -av ${TOMCAT_DIR}/etc ubuntu@$juju_client_ip:/home/ubuntu/tomcat8/
    rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo rsync' \
    -av ${TOMCAT_DIR}/ROOT ubuntu@$juju_client_ip:/home/ubuntu/tomcat8/webapps

    sudo docker cp ${TOMCAT_DIR}/etc nfvo-driver-vnfm-juju:/service/
    sudo docker cp ${TOMCAT_DIR}/ROOT nfvo-driver-vnfm-juju:/service/webapps/

    sudo rm -rf ${TOMCAT_DIR}
}

function start_tomcat()
{
    chmod +x ${UTIL_DIR}/grant_mysql.sh
    sudo docker cp ${UTIL_DIR}/grant_mysql.sh nfvo-driver-vnfm-juju:/service
    sudo docker exec -i nfvo-driver-vnfm-juju /service/grant_mysql.sh

    local cmd1='sed -i s/port=\"8080\"/port=\"8483\"/g /home/ubuntu/tomcat8/conf/server.xml'
    exec_cmd_on_client $cmd1

    local cmd2="pidof java | xargs kill -9; \
                /home/ubuntu/tomcat8/bin/catalina.sh start"

    exec_cmd_on_client $cmd2

    sudo docker stop nfvo-driver-vnfm-juju
    sudo docker start nfvo-driver-vnfm-juju
    sleep 10
}

function openo_connect()
{
    python ${OPERA_DIR}/opera/openo_connect.py --msb_ip $OPENO_IP:$COMMON_SERVICES_MSB_PORT \
                                        --tosca_aria_ip $OPENO_IP \
                                        --tosca_aria_port $COMMON_TOSCA_ARIA_PORT \
                                        --juju_client_ip $juju_client_ip \
                                        --auth_url $OS_AUTH_URL \
                                        --ns_pkg "${CSAR_DIR}/${NS_PKG}" \
                                        --vnf_pkg "${CSAR_DIR}/${VNF_PKG}"
}

function deploy_vnf()
{
    python ${OPERA_DIR}/opera/deploy_vnf.py --msb_ip $OPENO_IP:$COMMON_SERVICES_MSB_PORT \
                                     --vnf $VNF_TYPE \
                                     --nsdId $NSDID
}

function fix_openo_containers()
{
    sudo docker exec gso-service-gateway sed -i "s|^\(.*\"port\":\).*|\1 \"$COMMON_SERVICES_MSB_PORT\"|g" /service/etc/conf/restclient.json
    sudo docker stop gso-service-gateway
    sudo docker start gso-service-gateway
    sudo docker exec nfvo-resmanagement sed -i "s|^\(.*\"port\":\).*|\1 \"$COMMON_SERVICES_MSB_PORT\"|g" /service/etc/conf/restclient.json
    sudo docker stop nfvo-resmanagement
    sudo docker start nfvo-resmanagement
    sleep 10
}

function connect_juju_and_openo()
{
    log_info "connect_juju_and_openo enter"

    sync_juju_driver_file
    start_tomcat
    fix_openo_containers
    openo_connect
}
