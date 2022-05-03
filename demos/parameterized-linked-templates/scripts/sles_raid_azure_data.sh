#!/bin/bash
# Sleep 30 seconds to allow network to stabalize before attempting package install
sleep 30
zypper install -y mdadm
n=$(find /dev/disk/azure/scsi1/ -name "lun*"|wc -l)
n="${n//\ /}"
mdadm --create /dev/md0 --force --level=stripe --raid-devices=$n /dev/disk/azure/scsi1/lun*
mkfs.xfs /dev/md0
mkdir /mnt/raid0
echo "$(blkid /dev/md0 | cut -d ' ' -f 2) /mnt/raid0 xfs defaults 0 0" | tee -a /etc/fstab
mount /mnt/raid0
