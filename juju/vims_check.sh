#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
source $(pwd)/command.sh
client_ip=$(openstack server list | grep juju-client-vm | awk '{print $9}')
export floating_ip_client=$client_ip

function check_clearwater() {
    check_clearwater_cmd='juju status | grep clearwater &> /dev/null'
    try=10
    duration=120
    clearwater_started=false
    while [[ $try -ge 0 ]]; do
        if [[ $try -eq 0 ]]; then
            log_error "Clearwater does not start within the given time"
            exit 1
        fi
        exec_cmd_on_client $check_clearwater_cmd
        if [[ $? -eq 0 ]]; then
            clearwater_started=true
            break
        else
            let try-=1
            sleep $duration
        fi
    done

    try=10
    duration=120
    check_status_cmd='juju status | grep idle | wc -l'
    while [[ $try -ge 0 ]]; do
        if [[ $try -eq 0 ]]; then
            log_error "Clearwater does not fully start within the given time"
            exit 1
        fi
        exec_cmd_on_client $check_status_cmd
        count=$(exec_cmd_on_client $check_status_cmd)
        if [[ $count -eq 7 ]]; then
            echo "Clearwater has fully started"
            break
        else
            let try-=1
            sleep $duration
        fi
    done

    get_ellis_cmd='juju status | grep clearwater-ellis | grep tcp | awk "{print \$5}"'
    ellis_internal_ip=$(exec_cmd_on_client $get_ellis_cmd)
    ellis_external_ip=$(openstack server list | grep $ellis_internal_ip | awk '{print $9}')

    get_bono_cmd='juju status | grep clearwater-bono | grep tcp | awk "{print \$5}"'
    bono_internal_ip=$(exec_cmd_on_client $get_bono_cmd)
    bono_external_ip=$(openstack server list | grep $bono_internal_ip | awk '{print $9}')

    echo "Ellis: $ellis_external_ip"
    echo "Bono: $bono_external_ip"
}

check_clearwater