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

class RaiseError(Exception):
    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return repr(self.msg)

def request_get(url):
    try:
        resp = requests.get(url)
        if resp.status_code not in (200,201):
            raise RaiseError('get url: %s fail %d' % (url, resp.status_code))
    except Exception:
        raise

    return resp.json()

def request_post(url, data, headers):
    try:
        resp = requests.post(url, data=json.dumps(data), headers=headers)
        if resp.status_code not in (200,201,202):
            raise RaiseError('post url: %s fail %d' % (url, resp.status_code))
    except Exception:
        raise

def request_delete(url):
    try:
        resp = requests.delete(url)
        if resp.status_code not in (200,201,204):
            raise RaiseError('delete url: %s fail %d' % (url, resp.status_code))
    except Exception:
        raise

def add_common_tosca_aria(msb_ip, tosca_aria_ip):
    url = 'http://' + msb_ip + '/openoapi/microservices/v1/apiRoute'
    headers = {'Content-Type': 'application/json'}
    data = {"serviceName":"tosca",
            "version":"v1",
            "url":"/openoapi/tosca/v1",
            "metricsUrl":"/admin/metrics",
            "apiJson":"/swagger.json",
            "apiJsonType":"1",
            "control":"0",
            "status":"1",
            "servers":[{"ip":tosca_aria_ip,"port":"8204","weight":0}]}
    request_post(url, data, headers)

def add_openo_vim(msb_ip, auth_url):
    vim_url = 'http://' + msb_ip + '/openoapi/extsys/v1/vims/'
    vnfm_url = 'http://' + msb_ip + '/openoapi/extsys/v1/vnfms/'
    headers = {'Content-Type': 'application/json'}
    data = {"name":"openstack",
            "url":auth_url,
            "userName":"admin",
            "password":"console",
            "tenant":"admin",
            "domain":"",
            "vendor":"openstack",
            "version":"newton",
            "description":"",
            "type":"openstack"}
    get_vim = request_get(vim_url)
    get_vnfm = request_get(vnfm_url)
    for i in get_vim:
        if i["type"] == "openstack":
            for j in get_vnfm:
                if j["vimId"] == i["vimId"]:
                    request_delete(vnfm_url + j["vnfmId"])
            request_delete(vim_url + i["vimId"])

    request_post(vim_url, data, headers)

def add_openo_vnfm(msb_ip, juju_client_ip):
    vim_url = 'http://' + msb_ip + '/openoapi/extsys/v1/vims/'
    vnfm_url = 'http://' + msb_ip + '/openoapi/extsys/v1/vnfms/'
    headers = {'Content-Type': 'application/json'}
    get_vim = request_get(vim_url)
    vimId = ''
    for i in get_vim:
        if i["type"] == "openstack":
            vimId = i['vimId']

    if vimId is None:
        raise RaiseError("vim openstack not found")

    get_vnfm = request_get(vnfm_url)
    for i in get_vnfm:
        if i["vimId"] == vimId:
            request_delete(vnfm_url + i["vnfmId"])

    data = {"name":"Juju-VNFM",
            "vimId":vimId,
            "vendor":"jujuvnfm",
            "version":"jujuvnfm",
            "type":"jujuvnfm",
            "description":"",
            "certificateUrl":"",
            "url":"http://" + juju_client_ip + ":8483",
            "userName":"",
            "password":""}
    request_post(vnfm_url, data, headers)

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
    data = {"nsdId": nsdId,
            "nsName": ns_name,
            "description": description,
            "gatewayUri":"/openoapi/nslcm/v1/ns"}
    request_post(service_url, data, headers)

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--application", action='store', help="application name")
    parser.add_argument("--msb_ip", action='store', help="common_services_msb ip")
    parser.add_argument("--tosca_aria_ip", action='store', help="common_tosca_aria ip")
    parser.add_argument("--juju_client_ip", action='store', help="juju client ip")
    parser.add_argument("--auth_url", action='store', help="openstack auth url")
    parser.add_argument("--ns_pkg", action='store', help="ns package")
    parser.add_argument("--vnf_pkg", action='store', help="juju package")

    args = parser.parse_args()
    application = args.application
    msb_ip = args.msb_ip
    tosca_aria_ip = args.tosca_aria_ip
    juju_client_ip = args.juju_client_ip
    auth_url = args.auth_url
    ns_pkg = args.ns_pkg
    vnf_pkg = args.vnf_pkg

    if None in (msb_ip, tosca_aria_ip, juju_client_ip, auth_url):
        raise RaiseError('missing parameter')

    add_common_tosca_aria(msb_ip, tosca_aria_ip, tosca_aria_port)
    add_openo_vim(msb_ip, auth_url)
    add_openo_vnfm(msb_ip, juju_client_ip)

    if application == 'clearwater':
        delete_csars(msb_ip)
        upload_csar(msb_ip, vnf_pkg)
        upload_csar(msb_ip, ns_pkg)
        package_onboard(msb_ip)
        create_service(msb_ip, application, 'vIMS', 'ns_cw_2016')
