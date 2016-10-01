#!/bin/bash

#init and mount data disk
(echo n; echo p; echo 1; echo; echo; echo w) | fdisk /dev/sdc > /dev/null 
mkfs -t ext4 /dev/sdc1 > /dev/null 
mkdir /datadisk 
mount /dev/sdc1 /datadisk

#install fio
apt-get update > /dev/null 
apt-get -y install fio > /dev/null

#create test config
cat << EOF > t
[global]
size=$1
direct=1
iodepth=256
ioengine=libaio
bs=$5
EOF

for i in `seq 1 $4`; do
		echo "[w$i]" >> t
		echo rw=$2 >> t
		echo directory=/datadisk >> t
done

#run test
fio --runtime $3 t | grep -E 'READ:|WRITE:' | tr '\n' ';' | tr -s [:space:] | sed 's/ :/:/g' | sed 's/= /=/g'
