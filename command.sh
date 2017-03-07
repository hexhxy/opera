#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

function exec_cmd_on_client()
{
    local ssh_args="-o StrictHostKeyChecking=no"

    if [ ! $floating_ip_client ]; then
        log_error "juju-client ip not found"
        exit 1
    fi
    ssh $ssh_args ubuntu@$floating_ip_client "$@"
}

function exec_cmd_on_metadata()
{
    local ssh_args="-o StrictHostKeyChecking=no"

    if [ ! $floating_ip_metadata ]; then
        log_error "juju-metadata ip not found"
        exit 1
    fi
    ssh $ssh_args ubuntu@$floating_ip_metadata "$@"
}
