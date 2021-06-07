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
  log " not adding fstab entry"
  log " manual mount with 'mount $partPath $mount'"
  $(mount $partPath $mount)

  log " addtofstab done"
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

      local partedOut=$(parted $devicePath print -s | grep 'Partition Table' | awk '{print $3}')
      if [ "$partedOut" = "unknown" ];
      then
        log "   no partition table found - creating gpt"
        parted $devicePath mklabel gpt -s
      else
        log "  disk $devicePath already has a partition table - stopping to prevent data loss"
        exit -1
      fi

      local startPercent=0

      for ((j=0; j<mountPathCount; j++))
      do
        local mountPathLoc=${mountPathA[$j]}
        local sizeLoc=${sizeA[$j]}
        local partNumber=$(expr $j + 1)
        local endPercent=$( echo "((100 - $startPercent) * $sizeLoc / 100) + $startPercent" | bc)
        if [ "$sizeLoc" = "100" ];
        then
          local endPercent=100
        fi

        log "  Creating partition $partNumber for $mountPathLoc with size info $fdiskSize start $startPercent% end $endPercent%"
        parted $devicePath mkpart primary xfs $startPercent% $endPercent% -s

        log "  partition created - rereading partition table"
        partprobe $devicePath
        udevadm settle

        local partPath="$devicePath""$partNumber"
        log "  creating file system"
        mkfs.xfs $partPath -f
        mkdir -p $mountPathLoc

        addtofstab $partPath $mountPathLoc

        startPercent=$endPercent
      done
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

osVersion=$(cat /etc/os-release)
if [[ $osVersion =~ SUSE ]]
then
  systemctl restart nfsserver
  systemctl enable nfsserver
fi

exit
