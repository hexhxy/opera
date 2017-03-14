#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
local cmd1 = 'juju status | grep '
local try=10
local duration=120
set +x
while
    if [[ $try eq 0 ]]; then
        log_error "Clearwater does not start within the given time"
        exit 1
    fi
    exec_cmd_on_client $cmd1
    if [[ $? eq 0 ]]; then
        echo "Clearwater has started"
    else
        let try-=1
        sleep $duration
    fi
do :;done
set -x
