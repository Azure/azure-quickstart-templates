#!/usr/bin/env python

import json
import netaddr
import os
import random
import re
import requests
import sys
from azure.mgmt.common import SubscriptionCloudCredentials
from azure.mgmt.storage import StorageManagementClient
from azure.storage.blob import BlobService
from azure.storage.table import TableService

def get_token_from_client_credentials(endpoint, client_id, client_secret):
    payload = {
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'resource': 'https://management.core.windows.net/',
    }
    response = requests.post(endpoint, data=payload).json()
    return response['access_token']

def get_storage_client(settings):
    subscription_id = settings['SUBSCRIPTION_ID']
    auth_token = get_token_from_client_credentials(
        endpoint='https://login.windows.net/{0}/oauth2/token'.format(settings['TENANT_ID']),
        client_id=settings['CLIENT_ID'],
        client_secret=settings['CLIENT_SECRET']
    )
    creds = SubscriptionCloudCredentials(subscription_id, auth_token)
    storage_client = StorageManagementClient(creds)
    return storage_client

def create_containers(storage_client, resource_group_name, storage_account_name, blob_public_access=None):
    storage_access_key = storage_client.storage_accounts.list_keys(
        resource_group_name,
        storage_account_name
    ).storage_account_keys.key1
    blob_service = BlobService(storage_account_name, storage_access_key)
    blob_service.create_container('bosh')
    blob_service.create_container(
        container_name='stemcell',
        x_ms_blob_public_access=blob_public_access
    )

def create_tables(storage_client, resource_group_name, storage_account_name):
    # Prepare the table for storing meta datas of storage account and stemcells
    storage_access_key = storage_client.storage_accounts.list_keys(
        resource_group_name,
        storage_account_name
    ).storage_account_keys.key1
    table_service = TableService(storage_account_name, storage_access_key)
    table_service.create_table('stemcells')

def prepare_storage(settings):
    storage_client = get_storage_client(settings)
    resource_group_name = settings["RESOURCE_GROUP_NAME"]

    # Prepare the default storage account
    default_storage_account_name = settings["DEFAULT_STORAGE_ACCOUNT_NAME"]
    create_containers(
        storage_client,
        resource_group_name,
        default_storage_account_name,
        'blob'
    )
    create_tables(
        storage_client,
        resource_group_name,
        default_storage_account_name
    )

    # Prepare the additional storage accounts
    additional_storage_accounts_prefix = settings["ADDITIONAL_STORAGE_ACCOUNTS_PREFIX"]
    additional_storage_accounts_number = settings["ADDITIONAL_STORAGE_ACCOUNTS_NUMBER"]
    for index in range(0, int(additional_storage_accounts_number)):
        additional_storage_account_name = '{0}{1}'.format(
            additional_storage_accounts_prefix,
            index
        )
        create_containers(
            storage_client,
            resource_group_name,
            additional_storage_account_name
        )

def render_bosh_manifest(settings):
    with open('bosh.cert', 'r') as tmpfile:
        ssh_cert = tmpfile.read()
    indentation = " " * 8
    ssh_cert = ("\n"+indentation).join([line for line in ssh_cert.split('\n')])

    ip = netaddr.IPNetwork(settings['SUBNET_ADDRESS_RANGE_FOR_BOSH'])
    gateway_ip = str(ip[1])
    bosh_director_ip = str(ip[4])
    
    # Render the manifest for bosh-init
    bosh_template = 'bosh.yml'
    if os.path.exists(bosh_template):
        with open(bosh_template, 'r') as tmpfile:
            contents = tmpfile.read()
        for k in ["SUBNET_ADDRESS_RANGE_FOR_BOSH", "VNET_NAME", "SUBNET_NAME_FOR_BOSH", "SUBSCRIPTION_ID", "DEFAULT_STORAGE_ACCOUNT_NAME", "RESOURCE_GROUP_NAME", "TENANT_ID", "CLIENT_ID", "CLIENT_SECRET"]:
            v = settings[k]
            contents = re.compile(re.escape("REPLACE_WITH_{0}".format(k))).sub(v, contents)
        contents = re.compile(re.escape("REPLACE_WITH_SSH_CERTIFICATE")).sub(ssh_cert, contents)
        contents = re.compile(re.escape("REPLACE_WITH_GATEWAY_IP")).sub(gateway_ip, contents)
        contents = re.compile(re.escape("REPLACE_WITH_BOSH_DIRECTOR_IP")).sub(bosh_director_ip, contents)
        with open(bosh_template, 'w') as tmpfile:
            tmpfile.write(contents)

    return bosh_director_ip

def get_cloud_foundry_configuration(scenario, settings):
    config = {}
    for key in ["SUBNET_ADDRESS_RANGE_FOR_CLOUD_FOUNDRY", "VNET_NAME", "SUBNET_NAME_FOR_CLOUD_FOUNDRY", "CLOUD_FOUNDRY_PUBLIC_IP"]:
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
    if settings["AZURE_DNS"] == "enabled":
        config["SYSTEM_DOMAIN"] = settings["SYSTEM_DOMAIN_NAME"]
    else:
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
    elif scenario == "cf-for-enterprise":
        config["STATIC_IP_FROM"] = str(ip[4])
        config["STATIC_IP_TO"] = str(ip[100])
        config["HAPROXY_IP"] = str(ip[4])
        config["POSTGRES_IP"] = str(ip[11])
        config["ROUTER1_IP"] = str(ip[12])
        config["ROUTER2_IP"] = str(ip[22])
        config["NATS_IP"] = str(ip[13])
        config["ETCD_IP"] = str(ip[14])
        config["NFS_IP"] = str(ip[15])

    return config

def render_cloud_foundry_manifest(settings):
    for scenario in ["single-vm-cf", "multiple-vm-cf", "cf-for-enterprise"]:
        cloudfoundry_template = "{0}.yml".format(scenario)
        if os.path.exists(cloudfoundry_template):
            with open(cloudfoundry_template, 'r') as tmpfile:
                contents = tmpfile.read()
            config = get_cloud_foundry_configuration(scenario, settings)
            for key in config:
                value = config[key]
                contents = re.compile(re.escape("REPLACE_WITH_{0}".format(key))).sub(value, contents)
            additional_storage_accounts_number = settings["ADDITIONAL_STORAGE_ACCOUNTS_NUMBER"]
            if scenario == "cf-for-enterprise" and int(additional_storage_accounts_number) > 0:
                additional_storage_accounts_prefix = settings["ADDITIONAL_STORAGE_ACCOUNTS_PREFIX"]
                additional_storage_accounts = ["{0}{1}".format(additional_storage_accounts_prefix, index) for index in range(0, int(additional_storage_accounts_number))]
                for role_name in ["NATS", "ETCD_SERVER", "NFS_SERVER", "POSTGRES", "CC", "HAPROXY", "HEALTH_MANAGER", "DOPPLER", "LOGGREGATOR", "UAA", "ROUTER", "RUNNER1", "RUNNER2"]:
                    contents = re.compile(re.escape("REPLACE_WITH_{0}_STORAGE_ACCOUNT".format(role_name))).sub(random.choice(additional_storage_accounts), contents)
            with open(cloudfoundry_template, 'w') as tmpfile:
                tmpfile.write(contents)

def get_settings():
    settings = dict()
    for item in sys.argv[1].split(';'):
        key, value = item.split(':')
        settings[key] = value
    settings['TENANT_ID'] = sys.argv[2]
    settings['CLIENT_ID'] = sys.argv[3]
    settings['CLIENT_SECRET'] = sys.argv[4]
    return settings

def main():
    settings = get_settings()
    with open('settings', "w") as tmpfile:
        tmpfile.write(json.dumps(settings, indent=4, sort_keys=True))

    prepare_storage(settings)

    bosh_director_ip = render_bosh_manifest(settings)
    print bosh_director_ip

    render_cloud_foundry_manifest(settings)

if __name__ == "__main__":
    main()
