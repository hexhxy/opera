#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
mysql -uroot -p'rootpass' << EOF
GRANT ALL PRIVILEGES ON *.*  TO 'root'@'%' IDENTIFIED BY 'rootpass' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
