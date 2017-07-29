#!/usr/bin/env python

import json
import netaddr
import os
import random
import re
import requests
import sys
import ruamel.yaml
import base64
from azure.storage.blob import AppendBlobService
from azure.storage.table import TableService
import azure.mgmt.network
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.network import NetworkManagementClient, NetworkManagementClientConfiguration

def my_represent_none(self, data):
    return self.represent_scalar(u'tag:yaml.org,2002:null', u'null')

def prepare_storage(settings):
    default_storage_account_name = settings["DEFAULT_STORAGE_ACCOUNT_NAME"]
    storage_access_key = settings["DEFAULT_STORAGE_ACCESS_KEY"]
    endpoint_suffix = settings["SERVICE_HOST_BASE"]
    protocol = "https"
    if settings["ENVIRONMENT"] == "AzureStack":
        protocol = "http"

    blob_service = AppendBlobService(account_name=default_storage_account_name, account_key=storage_access_key, endpoint_suffix=endpoint_suffix, protocol=protocol)
    blob_service.create_container('bosh')
    blob_service.create_container(
        container_name='stemcell',
        public_access='blob'
    )

    # Prepare the table for storing meta datas of storage account and stemcells
    table_service = TableService(account_name=default_storage_account_name, account_key=storage_access_key, endpoint_suffix=endpoint_suffix, protocol=protocol)
    table_service.create_table('stemcells')

# file_path: String. The path to the file in which some configs starting with 'REPLACE_WITH_' need to be replaced with the actual values.
# keys: Array. The keys indicate which configs should be replaced in the file.
# values: Dict. Key-value pairs indicate which configs should be replaced by what values.
def render_file(file_path, keys, values):
    try:
        with open(file_path, 'r') as tmpfile:
            contents = tmpfile.read()
        for key in keys:
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(values[key], contents)
        with open(file_path, 'w') as tmpfile:
            tmpfile.write(contents)
        return True
    except Exception as e:
        print("render_file - {0}: {1}".format(file_path, str(e)))
        return False

def render_bosh_manifest(settings):
    with open('bosh.pub', 'r') as tmpfile:
        ssh_public_key = tmpfile.read().strip()

    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_BOSH'])
    gateway_ip = str(ip[1])
    bosh_director_ip = str(ip[4])

    ntp_servers_maps = {
        "AzureCloud": "0.north-america.pool.ntp.org",
        "AzureChinaCloud": "1.cn.pool.ntp.org, 1.asia.pool.ntp.org, 0.asia.pool.ntp.org",
        "AzureUSGovernment": "0.north-america.pool.ntp.org",
        "AzureGermanCloud": "0.europe.pool.ntp.org",
        "AzureStack": "0.north-america.pool.ntp.org"
    }
    environment = settings["ENVIRONMENT"]
    ntp_servers = ntp_servers_maps[environment]

    postgres_address_maps = {
        "AzureCloud": "127.0.0.1",
        "AzureChinaCloud": bosh_director_ip,
        "AzureUSGovernment": "127.0.0.1",
        "AzureGermanCloud": "127.0.0.1",
        "AzureStack": "127.0.0.1"
    }
    postgres_address = postgres_address_maps[environment]

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
        "DYNAMIC_STEMCELL_URL",
        "DYNAMIC_STEMCELL_SHA1",
        "ENVIRONMENT",
        "BOSH_VM_SIZE",
        "SSH_PUBLIC_KEY",
        "GATEWAY_IP",
        "BOSH_DIRECTOR_IP",
        "NTP_SERVERS",
        "POSTGRES_ADDRESS"
    ]
    values = settings.copy()
    values["SSH_PUBLIC_KEY"] = ssh_public_key
    values["GATEWAY_IP"] = gateway_ip
    values["BOSH_DIRECTOR_IP"] = bosh_director_ip
    values["NTP_SERVERS"] = ntp_servers
    values["POSTGRES_ADDRESS"] = postgres_address

    manifest_file = "bosh.yml"
    render_file(manifest_file, keys, values)

    if environment == "AzureStack":
        azure_stack_properties = {
            "domain": str(values["AZURE_STACK_DOMAIN"]),
            "authentication": "AzureAD",
            "resource": str(values["AZURE_STACK_RESOURCE"]),
            "endpoint_prefix": "management",
            "skip_ssl_validation": True,
            "use_http_to_access_storage_account": True
        }
        with open(manifest_file, "r") as conf:
            manifest = ruamel.yaml.round_trip_load(conf, preserve_quotes=True)
        manifest['cloud_provider']['properties']['azure']['azure_stack'] = azure_stack_properties
        with open(manifest_file, "w") as conf:
            ruamel.yaml.round_trip_dump(manifest, conf)

    return bosh_director_ip

def get_cloud_foundry_configuration(settings, bosh_director_ip):
    dns_maps = {
        "AzureCloud": "168.63.129.16\n    - {0}".format(settings["SECONDARY_DNS"]),
        "AzureChinaCloud": bosh_director_ip,
        "AzureUSGovernment": "168.63.129.16\n    - {0}".format(settings["SECONDARY_DNS"]),
        "AzureGermanCloud": "168.63.129.16\n    - {0}".format(settings["SECONDARY_DNS"]),
        "AzureStack": "168.63.129.16\n    - {0}".format(settings["SECONDARY_DNS"])
    }

    config = {}
    config["DNS"] = dns_maps[settings["ENVIRONMENT"]]
    config["SYSTEM_DOMAIN"] = "{0}.xip.io".format(settings["CLOUD_FOUNDRY_PUBLIC_IP"])

    keys = [
        "VNET_NAME",
        "SUBNET_NAME_FOR_CLOUD_FOUNDRY",
        "CLOUD_FOUNDRY_PUBLIC_IP",
        "NSG_NAME_FOR_CLOUD_FOUNDRY",
        "ENVIRONMENT",
        "DEFAULT_STORAGE_ACCOUNT_NAME",
        "DEFAULT_STORAGE_ACCESS_KEY"
    ]
    for key in keys:
        config[key] = settings[key]

    return config

def render_cloud_foundry_manifest(settings, bosh_director_ip):
    config = get_cloud_foundry_configuration(settings, bosh_director_ip)
    if settings["ENVIRONMENT"] == "AzureStack":
        manifest_file = "multiple-vm-cf.yml"
        update_cloud_foundry_manifest_for_azurestack(manifest_file)
        render_file(manifest_file, config.keys(), config)
    else:
        for manifest_file in ["single-vm-cf.yml", "multiple-vm-cf.yml"]:
            render_file(manifest_file, config.keys(), config)

def update_cloud_foundry_manifest_for_azurestack(manifest_file):
    with open(manifest_file, "r") as conf:
        manifest = ruamel.yaml.round_trip_load(conf, preserve_quotes=True)
    # Use smaller VM size
    manifest["compilation"]["cloud_properties"]["instance_type"] = "Standard_A1"
    for resource_pool in manifest["resource_pools"]:
        if resource_pool["name"].startswith("cell"):
            resource_pool["cloud_properties"]["instance_type"] = "Standard_A4"
        else:
            resource_pool["cloud_properties"]["instance_type"] = "Standard_A1"
        # In AzureStack, availability sets can only be configured with a fault domain of one and an update domain of one
        resource_pool["cloud_properties"]["platform_update_domain_count"] = 1
        resource_pool["cloud_properties"]["platform_fault_domain_count"] = 1
    # Use webdav as the blobstore since fog is not supported in AzureStack
    webdav_config = {
        "blobstore_timeout": 5,
        "ca_cert": "REPLACE_WITH_BLOBSTORE_CA_CERT",
        "password": "REPLACE_WITH_BLOBSTORE_PASSWORD",
        "private_endpoint": "https://blobstore.service.cf.internal:4443",
        "public_endpoint": "http://blobstore.REPLACE_WITH_SYSTEM_DOMAIN",
        "username": "blobstore"
    }
    for item in ["buildpacks", "droplets", "packages", "resource_pool"]:
        manifest["properties"]["cc"][item]["blobstore_type"] = "webdav"
        manifest["properties"]["cc"][item]["fog_connection"] = None
        manifest["properties"]["cc"][item]["webdav_config"] = webdav_config
    for job in manifest["jobs"]:
        if job["name"].startswith("blobstore"):
            job["instances"] = 1
    blobstore = {
        "admin_users": [
            {
                "password": "REPLACE_WITH_BLOBSTORE_PASSWORD",
                "username": "blobstore"
            }
        ],
        "port": 8080,
        "secure_link": {
            "secret": "REPLACE_WITH_BLOBSTORE_SECRET"
        },
        "tls": {
            "ca_cert": "REPLACE_WITH_BLOBSTORE_CA_CERT",
            "cert": "REPLACE_WITH_BLOBSTORE_TLS_CERT",
            "port": 4443,
            "private_key": "REPLACE_WITH_BLOBSTORE_PRIVATE_KEY"
        }
    }
    manifest["properties"]["blobstore"] = blobstore
    with open(manifest_file, "w") as conf:
        ruamel.yaml.round_trip_dump(manifest, conf)

def render_bosh_deployment_cmd(bosh_director_ip):
    keys = ["BOSH_DIRECOT_IP"]
    values = {}
    values["BOSH_DIRECOT_IP"] = bosh_director_ip
    render_file("deploy_bosh.sh", keys, values)

def render_cloud_foundry_deployment_cmd(settings):
    keys = [
        "STATIC_STEMCELL_URL",
        "STATIC_STEMCELL_SHA1",
        "STATIC_CF_RELEASE_URL",
        "STATIC_CF_RELEASE_SHA1",
        "STATIC_DIEGO_RELEASE_URL",
        "STATIC_DIEGO_RELEASE_SHA1",
        "STATIC_GARDEN_RELEASE_URL",
        "STATIC_GARDEN_RELEASE_SHA1",
        "STATIC_CFLINUXFS2_RELEASE_URL",
        "STATIC_CFLINUXFS2_RELEASE_SHA1",
        "DYNAMIC_STEMCELL_URL",
        "DYNAMIC_STEMCELL_SHA1",
        "DYNAMIC_CF_RELEASE_URL",
        "DYNAMIC_CF_RELEASE_SHA1",
        "DYNAMIC_DIEGO_RELEASE_URL",
        "DYNAMIC_DIEGO_RELEASE_SHA1",
        "DYNAMIC_GARDEN_RELEASE_URL",
        "DYNAMIC_GARDEN_RELEASE_SHA1",
        "DYNAMIC_CFLINUXFS2_RELEASE_URL",
        "DYNAMIC_CFLINUXFS2_RELEASE_SHA1"
    ]
    render_file("deploy_cloudfoundry.sh", keys, settings)

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

if __name__ == "__main__":
    ruamel.yaml.RoundTripRepresenter.add_representer(type(None), my_represent_none)
    main()
