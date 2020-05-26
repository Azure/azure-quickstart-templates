#!/bin/bash

function log()
{
  message=$@
  echo "$message"
  echo "$message" >> /var/log/sapconfigcreate
}

function addtofstab()
{
  log "addtofstab"
  partPath=$1
  mount=$2

  local blkid=$(/sbin/blkid $partPath)

  if [[ $blkid =~  UUID=\"(.{36})\" ]]
  then

    log "Adding fstab entry"
    local uuid=${BASH_REMATCH[1]};
    local mountCmd=""
    log "adding fstab entry"
    mountCmd="/dev/disk/by-uuid/$uuid $mount xfs  defaults,nofail  0  2"
    echo "$mountCmd" >> /etc/fstab
    $(mount $partPath $mount)

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
  local readlinkOutput=$(readlink /dev/disk/azure/scsi1/lun$lun)
  local scsiOutput=$(lsscsi)
  if [[ $readlinkOutput =~ (sd[a-zA-Z]{1,2}) ]];
  then
    log "found device path using readlink"
    getdevicepathresult="/dev/${BASH_REMATCH[1]}";
  elif [[ $scsiOutput =~ \[5:0:0:$lun\][^\[]*(/dev/sd[a-zA-Z]{1,2}) ]];
  then
    log "found device path using lsscsi"
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

  local lunsA=(${1//,/ })
  local vgName=$2
  local lvName=$3
  local mountPathA=(${4//,/ })
  local sizeA=(${5//,/ })

  local lunsCount=${#lunsA[@]}
  local mountPathCount=${#mountPathA[@]}
  local sizeCount=${#sizeA[@]}
  log "count $lunsCount $mountPathCount $sizeCount"
  if [[ $lunsCount -gt 1 ]]
  then
    log "createlvm - creating lvm"

    local numRaidDevices=0
    local raidDevices=""
    log "num luns $lunsCount"

    for ((i=0; i<lunsCount; i++))
    do
      log "trying to find device path"
      local lun=${lunsA[$i]}
      getdevicepath $lun
      local devicePath=$getdevicepathresult;

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

    for ((j=0; j<mountPathCount; j++))
    do
      local mountPathLoc=${mountPathA[$j]}
      local sizeLoc=${sizeA[$j]}
      local lvNameLoc="$lvName-$j"
      $(lvcreate --extents $sizeLoc%FREE --stripes $numRaidDevices --name $lvNameLoc $vgName)
      $(mkfs -t xfs /dev/$vgName/$lvNameLoc)
      $(mkdir -p $mountPathLoc)

      addtofstab /dev/$vgName/$lvNameLoc $mountPathLoc
    done

  else
    log "createlvm - creating single disk"

    local lun=${lunsA[0]}
    local mountPathLoc=${mountPathA[0]}
    getdevicepath $lun;
    local devicePath=$getdevicepathresult;
    if [ -n "$devicePath" ];
    then
      log " Device Path is $devicePath"
      # http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
      $(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath) > /dev/null
      local partPath="$devicePath""1"
      $(mkfs -t xfs $partPath) > /dev/null
      $(mkdir -p $mountPathLoc)

      addtofstab $partPath $mountPathLoc
    else
      log "no device path for LUN $lun"
      exit -1;
    fi
  fi

  log "createlvm done"
}

log $@

luns=""
names=""
paths=""
sizes=""

while true;
do
  case "$1" in
    "-luns")  luns=$2;shift 2;log "found luns"
    ;;
    "-names")  names=$2;shift 2;log "found names"
    ;;
    "-paths")  paths=$2;shift 2;log "found paths"
    ;;
    "-sizes")  sizes=$2;shift 2;log "found sizes"
    ;;
    *) log "unknown parameter $1";shift 1;
    ;;
  esac

  if [[ -z "$1" ]];
  then
    break;
  fi
done

lunsSplit=(${luns//#/ })
namesSplit=(${names//#/ })
pathsSplit=(${paths//#/ })
sizesSplit=(${sizes//#/ })

lunsCount=${#lunsSplit[@]}
namesCount=${#namesSplit[@]}
pathsCount=${#pathsSplit[@]}
sizesCount=${#sizesSplit[@]}

log "count $lunsCount $namesCount $pathsCount $sizesCount"

if [[ $lunsCount -eq $namesCount && $namesCount -eq $pathsCount && $pathsCount -eq $sizesCount ]]
then
  for ((ipart=0; ipart<lunsCount; ipart++))
  do
    lun=${lunsSplit[$ipart]}
    name=${namesSplit[$ipart]}
    path=${pathsSplit[$ipart]}
    size=${sizesSplit[$ipart]}

    log "creating disk with $lun $name $path $size"
    createlvm $lun "vg-$name" "lv-$name" "$path" "$size";
  done
else
  log "count not equal"
fi

exit
