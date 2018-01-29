#!/usr/bin/env python

import sys
from azure.storage.blob import AppendBlobService
from azure.storage.table import TableService

def prepare_storage_account(storage_account_name, storage_access_key, endpoint_suffix, protocol="https"):
    blob_service = AppendBlobService(account_name=storage_account_name, account_key=storage_access_key, endpoint_suffix=endpoint_suffix, protocol=protocol)
    blob_service.create_container('bosh')
    blob_service.create_container(
        container_name='stemcell',
        public_access='blob'
    )

    # Prepare the table for storing metadata of storage account and stemcells
    table_service = TableService(account_name=storage_account_name, account_key=storage_access_key, endpoint_suffix=endpoint_suffix, protocol=protocol)
    table_service.create_table('stemcells')

if __name__ == "__main__":
    storage_account_name = sys.argv[1]
    storage_access_key = sys.argv[2]
    endpoint_suffix = sys.argv[3]
    environment = sys.argv[4]

    protocol = "https"
    if environment == "AzureStack":
        protocol = "http"

    prepare_storage_account(storage_account_name, storage_access_key, endpoint_suffix, protocol)
