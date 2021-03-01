#!/usr/bin/env python3

#      The MIT License (MIT)
#
#      Copyright (c) 2016 Microsoft. All rights reserved.
#
#      Permission is hereby granted, free of charge, to any person obtaining a copy
#      of this software and associated documentation files (the "Software"), to deal
#      in the Software without restriction, including without limitation the rights
#      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#      copies of the Software, and to permit persons to whom the Software is
#      furnished to do so, subject to the following conditions:
#
#      The above copyright notice and this permission notice shall be included in
#      all copies or substantial portions of the Software.
#
#      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#      THE SOFTWARE.

"""Back up a tar-ball to Azure blob storage.

Usage:

    python dobackup.py <path/file.tar>
"""

from azure.storage import CloudStorageAccount
import config, time, argparse

def _get_parameters():
    parser              = argparse.ArgumentParser()
    parser.add_argument("input_file", help="path+name of tar-ball to send to blob storage")
    args                = parser.parse_args()
    input_file          = args.input_file
    return input_file

def _get_service():
    account_name        = config.STORAGE_ACCOUNT_NAME
    account_key         = config.STORAGE_ACCOUNT_KEY
    account             = CloudStorageAccount(account_name = account_name, account_key = account_key)
    service             = account.create_block_blob_service()
    return service

#    The last time a backup was dropped into the folder, it was named 'splunketccfg.tar'.
#    This time, I rename that file to have a datetime stamp on the end of it.
#    And then I copy the new backup to 'splunketccfg.tar'.
#    This way, the newest backup is always 'splunketccfg.tar'.  Easier to find when it's time to restore.
#    The edge case is the first time backup is run.  So I check for existence before trying to copy.

def _store_tarball(service, input_file):
    trg_container_name  = 'backups'
    stacked_blob_name   = 'splunketccfg_' + time.strftime('%m%d%YT%H%M%S') + '.tar'
    newest_blob_name    = 'splunketccfg.tar'

    exists              = service.exists(trg_container_name, newest_blob_name)
    if exists:
        source          = service.make_blob_url(trg_container_name, newest_blob_name)
        service.copy_blob(trg_container_name, stacked_blob_name, source)
    
    service.create_blob_from_path(trg_container_name, newest_blob_name, input_file)

def main():
    input_file          = _get_parameters()
    service             = _get_service()
    _store_tarball(service, input_file)

if __name__ == '__main__':
    main()
