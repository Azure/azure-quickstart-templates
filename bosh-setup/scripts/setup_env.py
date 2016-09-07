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

def render_manifest(manifest_file, config):
    if os.path.exists(manifest_file):
        with open(manifest_file, 'r') as tmpfile:
            contents = tmpfile.read()
        for key in config:
            value = config[key]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(value, contents)
        with open(manifest_file, 'w') as tmpfile:
            tmpfile.write(contents)
    else:
      print "{0} does not exist.".format(manifest_file)

def get_bosh_configuration(settings):
    config = {}
    keys = [
        "SUBNET_ADDRESS_RANGE_FOR_BOSH",
        "SECONDARY_DNS",
        "VNET_NAME",
        "SUBNET_NAME_FOR_BOSH",
        "DNS_RECURSOR",
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
        "ENVIRONMENT",
        "BOSH_VM_SIZE"
    ]
    for key in keys:
        config[key] = settings[key]

    with open('bosh.pub', 'r') as tmpfile:
        ssh_public_key = tmpfile.read().strip()
    config["SSH_PUBLIC_KEY"] = ssh_public_key

    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_BOSH'])
    config["GATEWAY_IP"] = str(ip[1])
    config["BOSH_DIRECTOR_IP"] = str(ip[4])

    environment = settings["ENVIRONMENT"]
    ntp_servers_maps = {
        "AzureCloud": "0.north-america.pool.ntp.org",
        "AzureChinaCloud": "1.cn.pool.ntp.org, 1.asia.pool.ntp.org, 0.asia.pool.ntp.org"
    }
    ntp_servers = ntp_servers_maps[environment]
    config["NTP_SERVERS"] = ntp_servers

    postgres_address_maps = {
        "AzureCloud": "127.0.0.1",
        "AzureChinaCloud": config["BOSH_DIRECTOR_IP"]
    }
    postgres_address = postgres_address_maps[environment]
    config["POSTGRES_ADDRESS"] = postgres_address

    return config

def render_bosh_manifest(settings):
    # Render the manifest for bosh-init
    bosh_template = 'bosh.yml'
    config = get_bosh_configuration(settings)
    render_manifest(bosh_template, config)

    return config["BOSH_DIRECTOR_IP"]

def get_cloud_foundry_configuration(scenario, settings, bosh_director_ip):
    config = {}
    keys = [
        "SUBNET_ADDRESS_RANGE_FOR_CLOUD_FOUNDRY",
        "VNET_NAME",
        "SUBNET_NAME_FOR_CLOUD_FOUNDRY",
        "CLOUD_FOUNDRY_PUBLIC_IP",
        "NSG_NAME_FOR_CLOUD_FOUNDRY"
    ]
    for key in keys:
        config[key] = settings[key]

    dns_maps = {
        "AzureCloud": "168.63.129.16, {0}".format(settings["SECONDARY_DNS"]),
        "AzureChinaCloud": bosh_director_ip
    }
    environment = settings["ENVIRONMENT"]
    config["DNS"] = dns_maps[environment]

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
        config["STATIC_IP_FROM"] = str(ip[4])
        config["STATIC_IP_TO"] = str(ip[100])
        config["POSTGRES_IP"] = str(ip[11])
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

def render_cloud_foundry_manifest(settings, bosh_director_ip):
    for scenario in ["single-vm-cf", "multiple-vm-cf"]:
        cloudfoundry_template = "{0}.yml".format(scenario)
        config = get_cloud_foundry_configuration(scenario, settings, bosh_director_ip)
        render_manifest(cloudfoundry_template, config)

def render_bosh_deployment_cmd(bosh_director_ip):
    bosh_deployment_cmd = "deploy_bosh.sh"
    if os.path.exists(bosh_deployment_cmd):
        with open(bosh_deployment_cmd, 'r') as tmpfile:
            contents = tmpfile.read()
        contents = re.compile(re.escape("REPLACE_WITH_BOSH_DIRECOT_IP")).sub(bosh_director_ip, contents)
        with open(bosh_deployment_cmd, 'w') as tmpfile:
            tmpfile.write(contents)

def render_cloud_foundry_deployment_cmd(settings):
    cloudfoundry_deployment_cmd = "deploy_cloudfoundry.sh"
    if os.path.exists(cloudfoundry_deployment_cmd):
        with open(cloudfoundry_deployment_cmd, 'r') as tmpfile:
            contents = tmpfile.read()
        keys = [
            "STEMCELL_URL",
            "STEMCELL_SHA1",
            "CF_RELEASE_URL",
            "CF_RELEASE_SHA1",
            "DIEGO_RELEASE_URL",
            "DIEGO_RELEASE_SHA1",
            "GARDEN_RELEASE_URL",
            "GARDEN_RELEASE_SHA1",
            "CFLINUXFS2_RELEASE_URL",
            "CFLINUXFS2_RELEASE_SHA1"
        ]
        for key in keys:
            value = settings[key]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(value, contents)
        with open(cloudfoundry_deployment_cmd, 'w') as tmpfile:
            tmpfile.write(contents)

def get_settings():
    settings = dict()
    config_file = sys.argv[4]
    with open(config_file) as f:
        settings = json.load(f)
    settings['TENANT_ID'] = sys.argv[1]
    settings['CLIENT_ID'] = sys.argv[2]
    settings['CLIENT_SECRET'] = base64.b64decode(sys.argv[3])

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

    render_cloud_foundry_manifest(settings, bosh_director_ip)
    render_cloud_foundry_deployment_cmd(settings)

    environment = settings["ENVIRONMENT"]
    if environment == "AzureChinaCloud":
        with open("/etc/resolvconf/resolv.conf.d/head", "a") as myfile:
            myfile.write("\nnameserver {0}\n".format(bosh_director_ip))

if __name__ == "__main__":
    main()
