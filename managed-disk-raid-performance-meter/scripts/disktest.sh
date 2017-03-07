#!/bin/bash

dl=cdefghijklmnopqrstuvwxyz
part=

#init and mount data disk
if [ ! -d "/datadisk" ]; then

	apt-get -y update > /dev/null
	apt-get --no-install-recommends -y install mdadm > /dev/null

	for i in `seq 1 $6`; do
		
			(echo n; echo p; echo 1; echo; echo; echo w) | fdisk /dev/sd${dl:$i-1:1} > /dev/null 
			part="$part /dev/sd${dl:$i-1:1}1"
		
	done

	mdadm --create /dev/md1 --level 0 --raid-devices $6 $part > /dev/null
	
	mkfs -t ext4 /dev/md1 > /dev/null 
	
	mkdir /datadisk 
	mount /dev/md1 /datadisk

	echo "UUID=$(blkid | grep -oP '/dev/md1: UUID="*"\K[^"]*')   /datadisk   ext4   defaults   1   2" >> /etc/fstab
	chmod go+w /datadisk
fi
 

confdir=/opt/vmdiskperf/
if [ ! -d "$confdir" ]; then
	firstrun=true
	mkdir "$confdir"

	#install fio
	apt-get update > /dev/null 
	apt-get -y install fio > /dev/null
fi

#create test config
cd "$confdir"
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
if [ $firstrun = true ]; then
	fio --runtime $3 t | grep -E 'READ:|WRITE:' | tr '\n' ';' | tr -s [:space:] | sed 's/ :/:/g' | sed 's/= /=/g'
else
	fio --runtime $3 t 
fi