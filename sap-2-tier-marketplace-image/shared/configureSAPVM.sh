#!/bin/bash
# create-mdadm <lun array> <mdadm path e.g. /dev/md127> <mount path e.g. /dbdata>
# TODO: SWAP file
# TODO: run /usr/sbin/SAPconf

function log()
{
	message=$1
	echo "$message"
	echo "$message" >> /var/log/sapconfigcreate
}

function addtofstab()
{
	log "addtofstab"
	partPath=$1
	local blkid=$(sudo /sbin/blkid $partPath)
	if [[ $blkid =~  UUID=\"(.{36})\" ]]
	then
		log "Adding fstab entry"
		local uuid=${BASH_REMATCH[1]};
		local vLinux=$(cat /etc/os-release)
		local mountCmd=""
		if [[ $vLinux =~ VERSION=\"11\..\" && $vLinux =~ NAME=\"SLES\" ]];
		then
			#SLES 11
			log "adding fstab entry for SLES 11"
			mountCmd="UUID=$uuid $mountPath xfs  defaults  0  2"
		fi
		if [[ $vLinux =~ VERSION=\"12\" && $vLinux =~ NAME=\"SLES\" ]];
		then
			#SLES 12
			log "adding fstab entry for SLES 12"
			mountCmd="/dev/disk/by-uuid/$uuid $mountPath xfs  defaults  0  2"
		fi
		echo "$mountCmd" >> /etc/fstab
		$(mount $mountPath)
	else
		log "no UUID found"
		exit -1;
	fi
	log "addtofstab done"
}

function getdevicepath()
{
	log "getdevicepath"
	getdevicepathresult=""
	local lun=$1
	local scsiOutput=$(lsscsi)
	if [[ $scsiOutput =~ \[5:0:0:$lun\][^\[]*(/dev/sd[a-zA-Z]{1,2}) ]];
	then 
		getdevicepathresult=${BASH_REMATCH[1]};
	else
		log "lsscsi output not as expected for $lun"
		exit -1;
	fi
	log "getdevicepath done"
}

function createmdadm()
{	
	log "createmdadm"
	
	lunsA=(${1//,/ })	
	mdadmPath=$2
	mountPath=$3
	
	arraynum=${#lunsA[@]}
	echo "count $arraynum"
	if [[ $arraynum -gt 1 ]]
	then
		log "createmdadm - creating mdadm"
		
		numRaidDevices=0
		raidDevices=""
		num=${#lunsA[@]}
		log "num luns $num"
		for ((i=0; i<num; i++))
		do
			log "trying to find device path"
			lun=${lunsA[$i]}
			getdevicepath $lun
			devicePath=$getdevicepathresult;
			if [ -n "$devicePath" ];
			then
				log " Device Path is $devicePath"
				numRaidDevices=$((numRaidDevices + 1))
				raidDevices="$raidDevices $devicePath""1 "
				# http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
				$(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath)
				log "changing partition type"
				$(echo -e "t\nfd\nw" | fdisk $devicePath)
			else
				log "no device path for LUN $lun"
				exit -1;
			fi
		done
		log "num: $numRaidDevices paths: '$raidDevices'"
		$(mdadm --create $mdadmPath --level 0 --raid-devices $numRaidDevices $raidDevices --force)
		$(mkfs -t xfs $mdadmPath)

		local vLinux=$(cat /etc/os-release)		
		if [[ $vLinux =~ VERSION=\"11\..\" && $vLinux =~ NAME=\"SLES\" ]];
		then
			#SLES 11
			log "createmdadm - SLES 11"
			$(chkconfig --add boot.md)
			$(echo 'DEVICE /dev/sd*[0-9]' >> /etc/mdadm.conf)
		fi

		$(mkdir $mountPath)
		addtofstab $mdadmPath		
	else
		log "createmdadm - creating single disk"
		
		lun=${lunsA[0]}
		getdevicepath $lun;
		devicePath=$getdevicepathresult;
		if [ -n "$devicePath" ];
		then
			log " Device Path is $devicePath"
			# http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
			$(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath)
			partPath="$devicePath""1"
			$(mkfs -t xfs $partPath)
			$(mkdir $mountPath)	

			addtofstab $partPath
		else
			log "no device path for LUN $lun"
			exit -1;
		fi
	fi

	log "createmdadm done"
}

dbluns=""
dbname="dbdata"
logluns=""
logname="dblog"

while true; do
	case "$1" in
    "-DBLogLUNS")  logluns=$2;shift 2;
        ;;
    "-DBDataLUNS")  dbluns=$2;shift 2;
	        ;;
	"-DBDataName")  dbname=$2;shift 2;
        ;;
	"-DBLogName")  logname=$2;shift 2;
        ;;
    esac
	if [[ -z "$1" ]]; then break; fi
done

if [[ -n "$dbluns" ]];
then
	createmdadm $dbluns "/dev/md127" "/$dbname";
fi

if [[ -n "$logluns" ]];
then
	createmdadm $logluns "/dev/md128" "/$logname";
fi

vLinux=$(cat /etc/os-release)		
if [[ $vLinux =~ VERSION=\"11\..\" && $vLinux =~ NAME=\"SLES\" ]];
then
	#SLES 11
	log "SLES 11 - restarting"
	$(shutdown -r now)
fi
