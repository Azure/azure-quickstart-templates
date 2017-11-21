#!/bin/bash

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
n # new partition
p # primary partition
2 # partition number 1 # default - start at beginning of disk 
  # default start sector
+20G # 100 MB boot parttion
n # new partition
p # primary partition
3 # partition number 1 # default - start at beginning of disk
  # default start sector
+8G # GB for log partition
n # new partition
p # primary partition
4 # partion number 2 # default, start immediately after preceding partition # default, extend partition to end of disk
  # default start sector
  # default max size
p # print the in-memory partition table
w # write the partition table
q # and we're done
EOF

partprobe
mkfs.ext4 /dev/sda2 #backup
mkfs.ext4 /dev/sda3 #logs
mkfs.ext4 /dev/sda4 #data

#Migrate postgres data to sda4
service postgresql stop
mkdir /tmp/pg_main
mv /var/lib/postgresql/9.4/* /tmp/pg_main/.
blkid | grep /dev/sda4
UUID=$(blkid | grep /dev/sda4 | grep -Eo 'UUID=\"[^"]*\"')
echo "${UUID//\"} /var/lib/postgresql/9.4 ext4 errors=remount-ro 0 1" >> /etc/fstab
mount -a
mv /tmp/pg_main/* /var/lib/postgresql/9.4/.
chown postgres:postgres /var/lib/postgresql/9.4
#chmod 0700 /var/lib/postgresql/9.4
service postgresql start

#migrate backups to sda2
mkdir /tmp/patches                              
mv /home/safewalk/patches/* /tmp/patches/.          
blkid | grep /dev/sda2                                    
UUID=$(blkid | grep /dev/sda2 | grep -Eo 'UUID=\"[^"]*\"')                               
echo "${UUID//\"} /home/safewalk/patches ext4 errors=remount-ro 0 1" >> /etc/fstab
mount -a                                        
mv /tmp/patches/* /home/safewalk/patches/.    
chown safewalk:safewalk /home/safewalk/patches


#migrate backups to sda3
mkdir /tmp/log
mv /var/log/* /tmp/log/.
blkid | grep /dev/sda3
UUID=$(blkid | grep /dev/sda3 | grep -Eo 'UUID=\"[^"]*\"')
echo "${UUID//\"} /var/log ext4 errors=remount-ro 0 1" >> /etc/fstab
mount -a
mv /tmp/log/* /var/log/.
