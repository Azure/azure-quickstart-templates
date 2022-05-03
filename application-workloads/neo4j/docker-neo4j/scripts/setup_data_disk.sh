#!/bin/bash

# This script is necessary to set up the data disk that will
# be passed into the Neo4j docker instance and used as the
# mount point for the Neo4J data.

# The ARM script only mounts a single data disk.  It is safe
# to assume that on a new VM, this data disk is located at /dev/sdc.

# If you have a more complicated setup, then do examine what this
# script is doing and modify accordingly.

# create a partition table for the disk
parted -s /dev/sdc mklabel msdos

# create a single large partition
parted -s /dev/sdc mkpart primary ext4 0\% 100\%

# install the file system
mkfs.ext4 /dev/sdc1

# create the mount point
mkdir /datadisk

# mount the disk
sudo mount /dev/sdc1 /datadisk/

# add mount to /etc/fstab to persist across reboots
echo "/dev/sdc1    /datadisk/    ext4    defaults 0 0" >> /etc/fstab
