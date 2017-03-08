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
    # until docker pull openoint/sdno-driver-ct-te:1.0.0
    # do
    #     echo "Try again"
    # done
    until docker pull openoint/common-services-auth:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-drivermanager:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-extsys:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-msb:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-protocolstack:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-services-wso2ext:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-tosca-catalog:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-tosca-inventory:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/common-tosca-modeldesigner:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/gso-service-gateway:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/gso-service-manager:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-dac:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-sdnc-zte:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vim:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vnfm-huawei:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vnfm-juju
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-driver-vnfm-zte:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-lcm:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-resmanagement:1.0.0
    do
        echo "Try again"
    done
    until docker pull openoint/nfvo-umc:1.0.0
    do
        echo "Try again"
    done
    # until docker pull openoint/sdno-driver-huawei-l3vpn:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-huawei-openstack:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-huawei-overlay:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-huawei-servicechain:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-driver-zte-sptn:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-brs:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-ipsec:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-l2vpn:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-l3vpn:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-mss:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-nslcm:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-overlayvpn:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-servicechain:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-vpc:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-service-vxlan:1.0.0
    # do
    #     echo "Try again"
    # done
    until docker pull openoint/common-tosca-aria:1.0.0
    do
        echo "Try again"
    done
    # until docker pull openoint/sdno-monitoring:1.0.0
    # do
    #     echo "Try again"
    # done
    # until docker pull openoint/sdno-vsitemgr:1.0.0
    # do
    #     echo "Try again"
    # done
    until docker pull openoint/gso-gui-portal:1.0.0
    do
        echo "Try again"
    done
}

function docker_run()
{
    msb_ip=$OPENO_VM_IP:$COMMON_SERVICES_MSB_PORT
    echo "OPEN-O MSB:$msb_ip"
    docker run -d --name common-services-msb -p $COMMON_SERVICES_MSB_PORT:80 openoint/common-services-msb:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --add-host controller:127.0.0.1 --name common-services-auth openoint/common-services-auth:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-drivermanager openoint/common-services-drivermanager:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-extsys openoint/common-services-extsys:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-protocolstack openoint/common-services-protocolstack:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name common-services-wso2ext openoint/common-services-wso2ext:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-catalog openoint/common-tosca-catalog:1.0.0
    tosca_inventory_id=$(docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-inventory openoint/common-tosca-inventory:1.0.0)
    tosca_inventory_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $tosca_inventory_id)
    docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-modeldesigner openoint/common-tosca-modeldesigner:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name gso-service-gateway openoint/gso-service-gateway:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip -e MYSQL_ADDR=$tosca_inventory_ip:3306 --name gso-service-manager openoint/gso-service-manager:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-dac openoint/nfvo-dac:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-sdnc-zte openoint/nfvo-driver-sdnc-zte:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vim openoint/nfvo-driver-vim:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vnfm-huawei openoint/nfvo-driver-vnfm-huawei:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vnfm-juju -p $NFVO_DRIVER_VNFM_JUJU_PORT:8483 -p 3306:3306 openoint/nfvo-driver-vnfm-juju
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-driver-vnfm-zte openoint/nfvo-driver-vnfm-zte:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip -e MYSQL_ADDR=$tosca_inventory_ip:3306 --name nfvo-lcm -p 8403:8403 openoint/nfvo-lcm:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-resmanagement openoint/nfvo-resmanagement:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name nfvo-umc openoint/nfvo-umc:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-l3vpn openoint/sdno-driver-huawei-l3vpn:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-openstack openoint/sdno-driver-huawei-openstack:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-overlay openoint/sdno-driver-huawei-overlay:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-huawei-servicechain openoint/sdno-driver-huawei-servicechain:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-zte-sptn openoint/sdno-driver-zte-sptn:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-brs openoint/sdno-service-brs:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-ipsec openoint/sdno-service-ipsec:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-l2vpn openoint/sdno-service-l2vpn:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-l3vpn openoint/sdno-service-l3vpn:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-mss openoint/sdno-service-mss:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip -e MYSQL_ADDR=$tosca_inventory_ip:3306 --name sdno-service-nslcm openoint/sdno-service-nslcm:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-overlayvpn openoint/sdno-service-overlayvpn:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-servicechain openoint/sdno-service-servicechain:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-vpc openoint/sdno-service-vpc:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-service-vxlan openoint/sdno-service-vxlan:1.0.0
    tosca_id=$(docker run -d -e MSB_ADDR=$msb_ip --name common-tosca-aria -p $COMMON_TOSCA_ARIA_PORT:8204 openoint/common-tosca-aria:1.0.0)
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-driver-ct-te openoint/sdno-driver-ct-te:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-monitoring openoint/sdno-monitoring:1.0.0
    # docker run -d -e MSB_ADDR=$msb_ip --name sdno-vsitemgr openoint/sdno-vsitemgr:1.0.0
    docker run -d -e MSB_ADDR=$msb_ip --name gso-gui-portal openoint/gso-gui-portal:1.0.0
}

function clean() {
    docker ps -a | grep openoint | awk '{print $1}' | xargs docker rm -f
}


function deploy_openo() {
    # docker_pull
    clean
    docker_run

    if [[ $(docker ps -q | wc -l) == 22 ]];then
        echo -e "\n\033[32mOpen-O Installed!\033[0m\n"
    fi
}

