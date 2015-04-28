#!/bin/bash

DRIVE=$1
INDEX=$2

echo "Creating filesystem on $DRIVE..."
mke2fs -F -t ext4 -b 4096 -O sparse_super,dir_index,extent,has_journal -m1 $DRIVE

echo "Mounting disk $DRIVE at /disks/$INDEX"
mkdir -p /disks/$INDEX
chmod 777 /disks/$INDEX
mount -o noatime -t ext4 $DRIVE /disks/$INDEX
