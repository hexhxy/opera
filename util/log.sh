#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function log_info() {
    echo -e "\033[32m$*\033[0m"
}

function log_warn() {
    echo -e "\033[33m$*\033[0m"
}

function log_error() {
    echo -e "\033[31m$*\033[0m"
}

function log_progress() {
    echo -en "\033[33m$*\r\033[0m"
}
