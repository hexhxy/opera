#!/usr/bin/env python
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import argparse
import sys
import os
import time
import requests
import json
from pprint import pprint
from openo_connect import RaiseError
from openo_connect import request_get
from openo_connect import request_post
from openo_connect import get_vim_id

def upload_csar(msb_ip, package):
    csar_url = 'http://' + msb_ip + '/openoapi/catalog/v1/csars'
    files = {'file': open(package, 'rb')}
    res = requests.post(csar_url, files=files)
    if res.status_code != 200:
        pprint(res.json())
        raise Exception('Error with uploading csar package: %s' % package)

def delete_csars(msb_ip):
    csar_url = 'http://' + msb_ip + '/openoapi/catalog/v1/csars/'
    csars = request_get(csar_url)
    for csar in csars:
        csarId = csar["csarId"]
        request_delete(csar_url + csarId)
        pprint("csar %s is deleted" % csarId)

def package_onboard(msb_ip):
    csar_url = 'http://' + msb_ip + '/openoapi/catalog/v1/csars'
    vnf_url = 'http://' + msb_ip + '/openoapi/nslcm/v1/vnfpackage'
    ns_url = 'http://' + msb_ip + '/openoapi/nslcm/v1/nspackage'
    headers = {'Content-Type': 'application/json'}
    get_csar = request_get(csar_url)
    vnf_csarId = ''
    ns_csarId = ''
    for i in get_csar:
        if i["type"] == "NFAR":
            vnf_csarId = i["csarId"]
        if i["type"] == "NSAR":
            ns_csarId = i["csarId"]

    if vnf_csarId is None:
        raise RaiseError("vnf package not found")
    if ns_csarId is None:
        raise RaiseError("ns package not found")

    vnf_data = {"csarId": vnf_csarId}
    ns_data = {"csarId": ns_csarId}
    request_post(vnf_url, vnf_data, headers)
    time.sleep(5)
    request_post(ns_url, ns_data, headers)

def create_service(msb_ip, ns_name, description, nsdId):
    service_url = 'http://' + msb_ip + '/openoapi/servicegateway/v1/services'
    headers = {'Content-Type': 'application/json'}
    data1 = {"nsdId": nsdId,
            "nsName": ns_name,
            "description": description,
            "gatewayUri":"/openoapi/nslcm/v1/ns"}
    vimId = get_vim_id(msb_ip, "openstack")
    resp = request_post(service_url, data1, headers)
    instance_id = resp["serviceId"]
    data2 = {"gatewayUri":"/openoapi/nslcm/v1/ns/" + instance_id + "/instantiate",
             "nsInstanceId":instance_id,
             "additionalParamForNs":{
             "location":vimId[0],
             "sdncontroller":"select"}
            }
    request_post(service_url, data2, headers)

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--application", action='store', default='', help="app name")
    parser.add_argument("--msb_ip", action='store', help="common_services_msb ip")
    parser.add_argument("--ns_pkg", action='store', default='', help="ns package")
    parser.add_argument("--vnf_pkg", action='store', default='', help="vnf package")

    args = parser.parse_args()
    application = args.application
    msb_ip = args.msb_ip
    ns_pkg = args.ns_pkg
    vnf_pkg = args.vnf_pkg

    if application == 'clearwater':
        delete_csars(msb_ip)
        upload_csar(msb_ip, vnf_pkg)
        upload_csar(msb_ip, ns_pkg)
        package_onboard(msb_ip)
        create_service(msb_ip, application, 'vIMS', 'ns_cw_2016')
