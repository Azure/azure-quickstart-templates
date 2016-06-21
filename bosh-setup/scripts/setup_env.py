#!/usr/bin/env python

import json
import netaddr
import os
import random
import re
import requests
import sys
from azure.storage.blob import AppendBlobService
from azure.storage.table import TableService
import azure.mgmt.network
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.network import NetworkManagementClient, NetworkManagementClientConfiguration

def prepare_storage(settings):
    default_storage_account_name = settings["DEFAULT_STORAGE_ACCOUNT_NAME"]
    storage_access_key = settings["STORAGE_ACCESS_KEY"]
    endpoint_suffix = settings["SERVICE_HOST_BASE"]

    blob_service = AppendBlobService(account_name=default_storage_account_name, account_key=storage_access_key, endpoint_suffix=endpoint_suffix)
    blob_service.create_container('bosh')
    blob_service.create_container(
        container_name='stemcell',
        public_access='blob'
    )

    # Prepare the table for storing meta datas of storage account and stemcells
    table_service = TableService(account_name=default_storage_account_name, account_key=storage_access_key, endpoint_suffix=endpoint_suffix)
    table_service.create_table('stemcells')

def render_bosh_manifest(settings):
    with open('bosh.pub', 'r') as tmpfile:
        ssh_public_key = tmpfile.read()

    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_BOSH'])
    gateway_ip = str(ip[1])
    bosh_director_ip = str(ip[4])

    ntp_servers_maps = {
        "AzureCloud": "0.north-america.pool.ntp.org",
        "AzureChinaCloud": "1.cn.pool.ntp.org, 1.asia.pool.ntp.org, 0.asia.pool.ntp.org"
    }
    environment = settings["ENVIRONMENT"]
    ntp_servers = ntp_servers_maps[environment]

    # Render the manifest for bosh-init
    bosh_template = 'bosh.yml'
    if os.path.exists(bosh_template):
        with open(bosh_template, 'r') as tmpfile:
            contents = tmpfile.read()
        keys = [
            "SUBNET_ADDRESS_RANGE_FOR_BOSH",
            "VNET_NAME",
            "SUBNET_NAME_FOR_BOSH",
            "SUBSCRIPTION_ID",
            "DEFAULT_STORAGE_ACCOUNT_NAME",
            "RESOURCE_GROUP_NAME",
            "KEEP_UNREACHABLE_VMS",
            "TENANT_ID",
            "CLIENT_ID",
            "CLIENT_SECRET",
            "BOSH_PUBLIC_IP",
            "NSG_NAME_FOR_BOSH",
            "BOSH_RELEASE_URL",
            "BOSH_RELEASE_SHA1",
            "BOSH_AZURE_CPI_RELEASE_URL",
            "BOSH_AZURE_CPI_RELEASE_SHA1",
            "STEMCELL_URL",
            "STEMCELL_SHA1",
            "ENVIRONMENT"
        ]
        for k in keys:
            v = settings[k]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(k))).sub(str(v), contents)
        contents = re.compile(re.escape("REPLACE_WITH_SSH_PUBLIC_KEY")).sub(ssh_public_key, contents)
        contents = re.compile(re.escape("REPLACE_WITH_GATEWAY_IP")).sub(gateway_ip, contents)
        contents = re.compile(re.escape("REPLACE_WITH_BOSH_DIRECTOR_IP")).sub(bosh_director_ip, contents)
        contents = re.compile(re.escape("REPLACE_WITH_NTP_SERVERS")).sub(ntp_servers, contents)
        with open(bosh_template, 'w') as tmpfile:
            tmpfile.write(contents)

    return bosh_director_ip

def get_cloud_foundry_configuration(scenario, settings):
    config = {}
    for key in ["SUBNET_ADDRESS_RANGE_FOR_CLOUD_FOUNDRY", "VNET_NAME", "SUBNET_NAME_FOR_CLOUD_FOUNDRY", "CLOUD_FOUNDRY_PUBLIC_IP", "NSG_NAME_FOR_CLOUD_FOUNDRY"]:
        config[key] = settings[key]

    with open('cloudfoundry.cert', 'r') as tmpfile:
        ssl_cert = tmpfile.read()
    with open('cloudfoundry.key', 'r') as tmpfile:
        ssl_key = tmpfile.read()
    ssl_cert_and_key = "{0}{1}".format(ssl_cert, ssl_key)
    indentation = " " * 8
    ssl_cert_and_key = ("\n"+indentation).join([line for line in ssl_cert_and_key.split('\n')])
    config["SSL_CERT_AND_KEY"] = ssl_cert_and_key

    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_CLOUD_FOUNDRY'])
    config["GATEWAY_IP"] = str(ip[1])
    config["RESERVED_IP_FROM"] = str(ip[2])
    config["RESERVED_IP_TO"] = str(ip[3])
    config["CLOUD_FOUNDRY_INTERNAL_IP"] = str(ip[4])
    config["SYSTEM_DOMAIN"] = "{0}.xip.io".format(settings["CLOUD_FOUNDRY_PUBLIC_IP"])

    if scenario == "single-vm-cf":
        config["STATIC_IP"] = str(ip[4])
    elif scenario == "multiple-vm-cf":
        config["STATIC_IP_FROM"] = str(ip[4])
        config["STATIC_IP_TO"] = str(ip[100])
        config["HAPROXY_IP"] = str(ip[4])
        config["POSTGRES_IP"] = str(ip[11])
        config["ROUTER_IP"] = str(ip[12])
        config["NATS_IP"] = str(ip[13])
        config["ETCD_IP"] = str(ip[14])
        config["NFS_IP"] = str(ip[15])
        config["CONSUL_IP"] = str(ip[16])

    return config

def render_cloud_foundry_manifest(settings):
    for scenario in ["single-vm-cf", "multiple-vm-cf"]:
        cloudfoundry_template = "{0}.yml".format(scenario)
        if os.path.exists(cloudfoundry_template):
            with open(cloudfoundry_template, 'r') as tmpfile:
                contents = tmpfile.read()
            config = get_cloud_foundry_configuration(scenario, settings)
            for key in config:
                value = config[key]
                contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(value, contents)
            with open(cloudfoundry_template, 'w') as tmpfile:
                tmpfile.write(contents)

def render_cloud_foundry_deployment_cmd(settings):
    cloudfoundry_deployment_cmd = "deploy_cloudfoundry.sh"
    if os.path.exists(cloudfoundry_deployment_cmd):
        with open(cloudfoundry_deployment_cmd, 'r') as tmpfile:
            contents = tmpfile.read()
        keys = ["CF_RELEASE_URL", "STEMCELL_URL"]
        for key in keys:
            value = settings[key]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(value, contents)
        with open(cloudfoundry_deployment_cmd, 'w') as tmpfile:
            tmpfile.write(contents)

def get_settings():
    settings = dict()
    config_file = sys.argv[4]
    with open(config_file) as f:
        settings = json.load(f)["runtimeSettings"][0]["handlerSettings"]["publicSettings"]
    settings['TENANT_ID'] = sys.argv[1]
    settings['CLIENT_ID'] = sys.argv[2]
    settings['CLIENT_SECRET'] = sys.argv[3]

    return settings

def main():
    settings = get_settings()
    with open('settings', "w") as tmpfile:
        tmpfile.write(json.dumps(settings, indent=4, sort_keys=True))

    prepare_storage(settings)

    bosh_director_ip = render_bosh_manifest(settings)
    print bosh_director_ip

    render_cloud_foundry_manifest(settings)
    render_cloud_foundry_deployment_cmd(settings)

if __name__ == "__main__":
    main()
