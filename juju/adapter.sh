#!/bin/bash
##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function generate_compass_openrc()
{
    ssh_options="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    MGMT_IP=192.168.200.2
    exec_command="sshpass -p root ssh $ssh_options root@$MGMT_IP"

    RUN_DIR=$(eval "$exec_command ls /var/ansible/run")

    cmd="cat /var/ansible/run/$RUN_DIR/group_vars/all | grep -A 3 public_vip: | sed -n '2p' | sed -e 's/  ip: //g'"
    PUBLIC_VIP=$(eval "$exec_command $cmd")

    echo -e "export OS_PASSWORD=console \n\
export OS_PROJECT_NAME=admin \n\
export OS_AUTH_URL=http://$PUBLIC_VIP:5000/v2.0 \n\
export OS_USERNAME=admin \n\
export OS_VOLUME_API_VERSION=2 \n\
export OS_REGION_NAME=RegionOne " > $WORK_DIR/admin-openrc.sh

}
