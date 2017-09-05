#!/usr/bin/env python

import json
import netaddr
import os
import random
import re
import requests
import sys
import base64
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
        ssh_public_key = tmpfile.read().strip()

    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_BOSH'])
    gateway_ip = str(ip[1])
    bosh_director_ip = str(ip[4])

    ntp_servers_maps = {
        "AzureCloud": "0.pool.ntp.org, 1.pool.ntp.org",
        "AzureChinaCloud": "1.cn.pool.ntp.org, 1.asia.pool.ntp.org, 0.asia.pool.ntp.org",
        "AzureUSGovernment": "0.north-america.pool.ntp.org"
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

def render_cloud_config_manifest(settings):
    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_CONCOURSE'])
    gateway_ip = str(ip[1])
    reserved_ip_start = str(ip[2])
    reserved_ip_end = str(ip[3])

    ephemeral_disk_size = int(settings['CONCOURSE_WORKER_DISK_SIZE'])
    ephemeral_disk_size_in_mb = ephemeral_disk_size * 1024
    # Set 40% of the ephemeral disk size as graph cleanup threshold, which equals 80% of the garden data disk size, for Concourse use half of the ephemeral disk as garden graph store
    settings["CONCOURSE_GRAPH_CLEANUP_THRESHOLD"] = str(ephemeral_disk_size_in_mb * 2 / 5)

    cloud_config_template = 'cloud.yml'
    if os.path.exists(cloud_config_template):
        with open(cloud_config_template, 'r') as tmpfile:
            contents = tmpfile.read()
        keys = [
            "VNET_NAME",
            "SUBNET_NAME_FOR_CONCOURSE",
            "SUBNET_ADDRESS_RANGE_FOR_CONCOURSE",
            "NSG_NAME_FOR_CONCOURSE"
        ]
        for k in keys:
            v = settings[k]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(k))).sub(str(v), contents)
        contents = re.compile(re.escape("REPLACE_WITH_CONCOURSE_GATEWAY_IP")).sub(gateway_ip, contents)
        contents = re.compile(re.escape("REPLACE_WITH_RESERVED_IP_START")).sub(reserved_ip_start, contents)
        contents = re.compile(re.escape("REPLACE_WITH_RESERVED_IP_END")).sub(reserved_ip_end, contents)
        contents = re.compile(re.escape("REPLACE_WITH_CONCOURSE_WORKER_DISK_SIZE")).sub(str(ephemeral_disk_size_in_mb), contents)
        with open(cloud_config_template, 'w') as tmpfile:
            tmpfile.write(contents)

def render_bosh_deployment_cmd(bosh_director_ip):
    bosh_deployment_cmd = "deploy_bosh.sh"
    if os.path.exists(bosh_deployment_cmd):
        with open(bosh_deployment_cmd, 'r') as tmpfile:
            contents = tmpfile.read()
        contents = re.compile(re.escape("REPLACE_WITH_BOSH_DIRECTOR_IP")).sub(bosh_director_ip, contents)
        with open(bosh_deployment_cmd, 'w') as tmpfile:
            tmpfile.write(contents)

def render_concourse_manifest(settings):
    # Render the manifest for concourse
    concourse_template = 'concourse.yml'
    if os.path.exists(concourse_template):
        with open(concourse_template, 'r') as tmpfile:
            contents = tmpfile.read()
        keys = [
            "CONCOURSE_PUBLIC_IP",
            "CONCOURSE_USERNAME",
            "CONCOURSE_PASSWORD",
            "CONCOURSE_DB_ROLE_NAME",
            "CONCOURSE_DB_ROLE_PASSWORD",
            "CONCOURSE_GRAPH_CLEANUP_THRESHOLD"
        ]
        for k in keys:
            v = settings[k]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(k))).sub(str(v), contents)
        with open(concourse_template, 'w') as tmpfile:
            tmpfile.write(contents)

def render_concourse_deployment_cmd(settings):
    concourse_deployment_cmd = "deploy_concourse.sh"
    if os.path.exists(concourse_deployment_cmd):
        with open(concourse_deployment_cmd, 'r') as tmpfile:
            contents = tmpfile.read()
        keys = ["GARDEN_RELEASE_URL", "CONCOURSE_RELEASE_URL", "STEMCELL_URL"]
        for key in keys:
            value = settings[key]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(value, contents)
        with open(concourse_deployment_cmd, 'w') as tmpfile:
            tmpfile.write(contents)

def get_settings():
    settings = dict()
    config_file = sys.argv[4]
    with open(config_file) as f:
        settings = json.load(f)
    settings['TENANT_ID'] = sys.argv[1]
    settings['CLIENT_ID'] = sys.argv[2]
    settings['CLIENT_SECRET'] = sys.argv[3]

    print "tenant_id: {0}xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx".format(settings['TENANT_ID'][0:4])
    print "client_id: {0}xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx".format(settings['CLIENT_ID'][0:4])
    print "The length of client_secret is {0}".format(len(settings['CLIENT_SECRET']))

    return settings

def main():
    settings = get_settings()
    with open('settings', "w") as tmpfile:
        tmpfile.write(json.dumps(settings, indent=4, sort_keys=True))

    prepare_storage(settings)

    bosh_director_ip = render_bosh_manifest(settings)
    render_bosh_deployment_cmd(bosh_director_ip)
    print bosh_director_ip

    render_cloud_config_manifest(settings)
    render_concourse_manifest(settings)
    render_concourse_deployment_cmd(settings)

if __name__ == "__main__":
    main()
