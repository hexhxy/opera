#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
file1=/home/etc/conf/juju_conf.json
sed -i 's/^\(.*"image-metadata-url":\).*/\1 "http:\/\/REPLACE_JUJU_METADATA_IP\/images"\,/g' $file1
sed -i 's/^\(.*"network":\).*/\1 "juju-net"\,/g' $file1
sed -i 's/^\(.*"use-floating-ip":\).*/\1 "True"\,/g' $file1

file2=/home/etc/csarInfo/csarinfo.json
sed -i 's/^\(.*"csar_file_path":\).*/\1 "\/home\/ubuntu\/csar\/"\,/g' $file2

file3=/home/ROOT/WEB-INF/classes/db.properties
sed -i 's/^\(.*jdbc.url=\).*/\1jdbc:mysql:\/\/REPLACE_JUJU_DRIVER_IP:REPLACE_JUJU_DRIVER_DB_PORT\/jujuvnfmdb/g' $file3

file4=/home/ROOT/WEB-INF/classes/juju-config.properties
sed -i 's/^\(.*charmPath=\).*/\1\/home\/ubuntu\/csar\//g' $file4
sed -i 's/^\(.*grant_jujuvnfm_url=\).*/\1http:\/\/REPLACE_JUJU_DRIVER_IP:REPLACE_JUJU_DRIVER_PORT\//g' $file4

file5=/home/etc/conf/restclient.json
sed -i 's/^\(.*"host":\).*/\1"REPLACE_JUJU_DRIVER_IP"\,/g' $file5
sed -i 's|^\(.*"port":\).*|\1"MSB_PORT"|g' $file5

file6=/home/etc/adapterInfo/jujuadapterinfo.json
sed -i 's/^\(.*"ip":\).*/\1 "REPLACE_JUJU_DRIVER_IP"\,/g' $file6

docker exec gso-service-gateway sed -i 's|^\(.*"port":\).*|\1"MSB_PORT"|g' /service/etc/conf/restclient.json
docker exec nfvo-resmanagement sed -i 's|^\(.*"port":\).*|\1"MSB_PORT"|g' /service/etc/conf/restclient.json
