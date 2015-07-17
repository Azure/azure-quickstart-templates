#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# 
# See the License for the specific language governing permissions and
# limitations under the License.

DRIVE=$1
INDEX=$2

echo "Creating filesystem on $DRIVE..."
mke2fs -F -t ext4 -b 4096 -O sparse_super,dir_index,extent,has_journal -m1 $DRIVE

echo "Mounting disk $DRIVE at /disks/$INDEX"
mkdir -p /disks/$INDEX
chmod 777 /disks/$INDEX
mount -o noatime -t ext4 $DRIVE /disks/$INDEX
