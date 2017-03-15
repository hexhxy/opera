#!/bin/bash -ex
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function docker_pull()
{
    # until docker pull openoint/sdno-driver-ct-te:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    until docker pull openoint/common-services-auth:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-drivermanager:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-extsys:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-msb:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-protocolstack:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-wso2ext:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-tosca-catalog:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-tosca-inventory:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/common-tosca-modeldesigner:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/gso-service-gateway:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/gso-service-manager:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-dac:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-sdnc-zte:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vim:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vnfm-huawei:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull huangxiangyu/nfvo-driver-vnfm-juju
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vnfm-zte:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-lcm:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-resmanagement:$OPENO_VERSION
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-umc:$OPENO_VERSION
    do
        echo "Try again"
    done
    # until docker pull openoint/sdno-driver-huawei-l3vpn:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-huawei-openstack:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-huawei-overlay:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-huawei-servicechain:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-zte-sptn:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-brs:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-ipsec:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-l2vpn:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-l3vpn:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-mss:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-nslcm:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-overlayvpn:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-servicechain:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-vpc:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-vxlan:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    until docker pull openoint/common-tosca-aria:$OPENO_VERSION
    do
        echo "Try again"
    done
    # until docker pull openoint/sdno-monitoring:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-vsitemgr:$OPENO_VERSION
    # do
    #     echo "Try again"
    # done
    until docker pull openoint/gso-gui-portal:$OPENO_VERSION
    do
        echo "Try again"
    done
}

function docker_run()
{
    msb_ip=$OPENO_IP:$COMMON_SERVICES_MSB_PORT
    docker run -d --name common-services-msb -p $OPENO_IP:$COMMON_SERVICES_MSB_PORT:80 openoint/common-services-msb:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --add-host controller:127.0.0.1 --name common-services-auth openoint/common-services-auth:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-drivermanager openoint/common-services-drivermanager:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-extsys openoint/common-services-extsys:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-protocolstack openoint/common-services-protocolstack:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-wso2ext openoint/common-services-wso2ext:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-catalog openoint/common-tosca-catalog:$OPENO_VERSION
    tosca_inventory_id=$(docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-inventory openoint/common-tosca-inventory:$OPENO_VERSION)
    tosca_inventory_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $tosca_inventory_id)
    docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-modeldesigner openoint/common-tosca-modeldesigner:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name gso-service-gateway openoint/gso-service-gateway:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip -e MYSQL_ADDR=$tosca_inventory_ip:3306 --name gso-service-manager openoint/gso-service-manager:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-dac openoint/nfvo-dac:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-sdnc-zte openoint/nfvo-driver-sdnc-zte:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vim openoint/nfvo-driver-vim:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vnfm-huawei openoint/nfvo-driver-vnfm-huawei:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vnfm-juju -p $OPENO_IP:$NFVO_DRIVER_VNFM_JUJU_PORT:8483 -p $OPENO_IP:$NFVO_DRIVER_VNFM_JUJU_MYSQL_PORT:3306 huangxiangyu/nfvo-driver-vnfm-juju
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vnfm-zte openoint/nfvo-driver-vnfm-zte:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip -e MYSQL_ADDR=$tosca_inventory_ip:3306 --name nfvo-lcm -p $OPENO_IP:8403:8403 openoint/nfvo-lcm:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-resmanagement openoint/nfvo-resmanagement:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-umc openoint/nfvo-umc:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-l3vpn openoint/sdno-driver-huawei-l3vpn:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-openstack openoint/sdno-driver-huawei-openstack:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-overlay openoint/sdno-driver-huawei-overlay:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-servicechain openoint/sdno-driver-huawei-servicechain:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-zte-sptn openoint/sdno-driver-zte-sptn:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-brs openoint/sdno-service-brs:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-ipsec openoint/sdno-service-ipsec:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-l2vpn openoint/sdno-service-l2vpn:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-l3vpn openoint/sdno-service-l3vpn:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-mss openoint/sdno-service-mss:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip -e MYSQL_ADDR=$tosca_inventory_ip:3306 --name sdno-service-nslcm openoint/sdno-service-nslcm:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-overlayvpn openoint/sdno-service-overlayvpn:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-servicechain openoint/sdno-service-servicechain:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-vpc openoint/sdno-service-vpc:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-vxlan openoint/sdno-service-vxlan:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-aria -p $OPENO_IP:$COMMON_TOSCA_ARIA_PORT:8204 openoint/common-tosca-aria:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-ct-te openoint/sdno-driver-ct-te:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-monitoring openoint/sdno-monitoring:$OPENO_VERSION
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-vsitemgr openoint/sdno-vsitemgr:$OPENO_VERSION
    docker run -d -e MSB_ADDR=$msb_ip --name gso-gui-portal openoint/gso-gui-portal:$OPENO_VERSION
}

function clean() {
    docker ps -a | grep openoint | awk '{print $1}' | xargs docker rm -f || true
}


function deploy_openo() {
    docker_pull
    clean
    docker_run

    if [[ $(docker ps -q | grep openoint | wc -l) == 22 ]];then
        echo -e "\n\033[32mOpen-O Installed!\033[0m\n"
    fi
}

