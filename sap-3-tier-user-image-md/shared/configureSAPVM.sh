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
	local blkid=$(/sbin/blkid $partPath)
	if [[ $blkid =~  UUID=\"(.{36})\" ]]
	then
		log "Adding fstab entry"
		local uuid=${BASH_REMATCH[1]};
		local mountCmd=""
		log "adding fstab entry"
		mountCmd="/dev/disk/by-uuid/$uuid $mountPath xfs  defaults,nofail  0  2"
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

function createlvm()
{
	log "createlvm"
	
	lunsA=(${1//,/ })	
	vgName=$2
	lvName=$3
	mountPath=$4

	arraynum=${#lunsA[@]}
	echo "count $arraynum"
	if [[ $arraynum -gt 1 ]]
	then
		log "createlvm - creating lvm"
		
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
				raidDevices="$raidDevices $devicePath "				
			else
				log "no device path for LUN $lun"
				exit -1;
			fi
		done
		log "num: $numRaidDevices paths: '$raidDevices'"
		$(pvcreate $raidDevices)
		$(vgcreate $vgName $raidDevices)
		$(lvcreate --extents 100%FREE --stripes $numRaidDevices --name $lvName $vgName)
		$(mkfs -t xfs /dev/$vgName/$lvName)

		$(mkdir $mountPath)
		addtofstab /dev/$vgName/$lvName		
	else
		log "createlvm - creating single disk"
		
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

	log "createlvm done"

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
	createlvm $dbluns "vg-$dbname" "lv-$dbname" "/$dbname";
fi

if [[ -n "$logluns" ]];
then
	createlvm $logluns "vg-$logname" "lv-$logname" "/$logname";
fi
