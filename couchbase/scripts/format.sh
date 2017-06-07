#!/usr/bin/env bash

# This script formats and mounts the drive on sdc as /datadisks/disk1
# sda - OS Disk
# sdb - Ephemeral
# sdc - Attached Disk

DISK="/dev/sdc"
DEVICE="/dev/sdc1"
MOUNTPOINT="/datadisks/disk1"

echo "Partitioning the disk."
echo "n
p
1


t
83
w"| fdisk ${DISK}

echo "Creating the filesystem."
mkfs -j -t ext4 ${DEVICE}

echo "Updating fstab"
LINE="${DEVICE}\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1\t2"
echo -e ${LINE} >> /etc/fstab

echo "Mounting the disk"
mkdir -p ${MOUNTPOINT}
mount ${MOUNTPOINT}
