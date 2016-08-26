#!/usr/bin/python

import sys,os

print ("Getting %s file from Storage Account Name: %s to %s" % (str(sys.argv[3]), str(sys.argv[1]), os.path.join(os.getcwd(),str(sys.argv[3]))))

from  azure.storage.blob import BlockBlobService
blob_service = BlockBlobService(account_name=str(sys.argv[1]), account_key=str(sys.argv[2]))


blob = blob_service.get_blob_to_path(
    'ssh',
    str(sys.argv[3]),
    os.path.join(os.getcwd(),str(sys.argv[3])),
    max_connections=8
)
