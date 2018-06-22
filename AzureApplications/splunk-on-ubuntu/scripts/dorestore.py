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

from azure.storage import CloudStorageAccount

import config, time

account_name = config.STORAGE_ACCOUNT_NAME
account_key  = config.STORAGE_ACCOUNT_KEY

account = CloudStorageAccount(account_name = account_name, 
                              account_key = account_key)

service = account.create_block_blob_service()

#   The last time a backup was dropped into the folder, it was named 'splunketccfg.tar'.
#   This is (almost) always the one to restore.

container_name      = 'backups'
restore_file_name   = 'splunketccfg.tar'
OUTPUT_FILE         = 'splunketccfg.tar'

exists              = service.exists(container_name, restore_file_name)
if exists:
    service.get_blob_to_path(container_name, restore_file_name, OUTPUT_FILE)
else:
    print('Backup file does not exist')
    