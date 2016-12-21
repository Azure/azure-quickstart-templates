from azure.storage import BlobService
from azure.storage import TableService


def do_step(context):

    settings = context.meta['settings']

    # Prepare the containers
    storage_account_name = settings["STORAGE-ACCOUNT-NAME"]
    storage_access_key = settings["STORAGE-ACCESS-KEY"]
    blob_service = BlobService(storage_account_name, storage_access_key)
    blob_service.create_container('bosh')
    blob_service.create_container(container_name='stemcell', x_ms_blob_public_access='blob')

    # Prepare the table for storing meta datas of storage account and stemcells
    table_service = TableService(storage_account_name, storage_access_key)
    table_service.create_table('stemcells')

    context.meta['settings'] = settings
    return context
