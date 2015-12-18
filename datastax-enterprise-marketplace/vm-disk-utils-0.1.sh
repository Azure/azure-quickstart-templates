#!/bin/bash
# This script automates the partitioning and formatting of data disks
# Data disks can be partitioned and formatted as seperate disks or in a RAID0 configuration
# The script will scan for unpartitioined and unformatted data disks and partition, format, and add fstab entries

if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

resourceString=$(ls -l /dev/disk/azure/resource)
rootString=$(ls -l /dev/disk/azure/root)
BLACKLIST="\""/dev/${resourceString:(-3)}"|/dev/${rootString:(-3)}\""
echo $BLACKLIST

# Base path for data disk mount points
DATA_BASE="/datadisks"

while getopts b:s: opt; do
  echo "Option $opt set with value ${OPTARG}"
  case ${opt} in
    b)  
      #set clsuter name
      DATA_BASE=${OPTARG}
      ;;
    s) 
      #Partition and format data disks as RAID set
      RAID_CONFIGURATION=1
      ;;
    \?) 
      echo "Invalid option: -$OPTARG"
      ;;
  esac
done

get_next_md_device() {
  shopt -s extglob
  LAST_DEVICE=$(ls -1 /dev/md+([0-9]) 2>/dev/null|sort -n|tail -n1)
  if [ -z "${LAST_DEVICE}" ]; then
    NEXT=/dev/md0
  else
    NUMBER=$((${LAST_DEVICE/\/dev\/md/}))
    NEXT=/dev/md${NUMBER}
  fi
  echo ${NEXT}
}

is_partitioned() {
  OUTPUT=$(partx -s ${1} 2>&1)
  egrep "partition table does not contains usable partitions|failed to read partition table" <<< "${OUTPUT}" >/dev/null 2>&1
  if [ ${?} -eq 0 ]; then
    return 1
  else
    return 0
  fi    
}

has_filesystem() {
  DEVICE=${1}
  OUTPUT=$(file -L -s ${DEVICE})
  grep filesystem <<< "${OUTPUT}" > /dev/null 2>&1
  return ${?}
}

scan_for_new_disks() {
  # Looks for unpartitioned disks
  declare -a RET
  DEVS=($(ls -1 /dev/sd*|egrep -v "${BLACKLIST}"|egrep -v "[0-9]$"))
  for DEV in "${DEVS[@]}";
  do
    # The disk will be considered a candidate for partitioning
    # and formatting if it does not have a sd?1 entry or
    # if it does have an sd?1 entry and does not contain a filesystem
    is_partitioned "${DEV}"
    if [ ${?} -eq 0 ]; then
      has_filesystem "${DEV}1"
      if [ ${?} -ne 0 ]; then
        RET+=" ${DEV}"
      fi
    else
      RET+=" ${DEV}"
    fi
  done
  echo "${RET}"
}

get_next_mountpoint() {
  DIRS=$(ls -1d ${DATA_BASE}/disk* 2>/dev/null| sort --version-sort)
  MAX=$(echo "${DIRS}"|tail -n 1 | tr -d "[a-zA-Z/]")
  if [ -z "${MAX}" ]; then
    echo "${DATA_BASE}/disk1"
    return
  fi
  IDX=1
  while [ "${IDX}" -lt "${MAX}" ];
  do
    NEXT_DIR="${DATA_BASE}/disk${IDX}"
    if [ ! -d "${NEXT_DIR}" ]; then
      echo "${NEXT_DIR}"
      return
    fi
    IDX=$(( ${IDX} + 1 ))
  done
  IDX=$(( ${MAX} + 1))
  echo "${DATA_BASE}/disk${IDX}"
}

add_to_fstab() {
  UUID=${1}
  MOUNTPOINT=${2}
  grep "${UUID}" /etc/fstab >/dev/null 2>&1
  if [ ${?} -eq 0 ]; then
    echo "Not adding ${UUID} to fstab again (it's already there!)"
  else
    LINE="UUID=\"${UUID}\"\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1 2"
    echo -e "${LINE}" >> /etc/fstab
  fi
}

do_partition() {
  # This function creates one (1) primary partition on the disk, using all available space
  _disk=${1}
  _type=${2}
  if [ -z "${_type}" ]; then
    # default to Linux partition type (ie, ext3/ext4/xfs)
    _type=83
  fi
  echo "n
p
1


t
${_type}
w"| fdisk "${_disk}"

  # Use the bash-specific $PIPESTATUS to ensure we get the correct exit code from fdisk and not from echo
  if [ ${PIPESTATUS[1]} -ne 0 ]; then
    echo "An error occurred partitioning ${_disk}" >&2
    echo "I cannot continue" >&2
    exit 2
  fi
}
#end do_partition

scan_partition_format()
{
  echo "Begin scanning and formatting data disks"
  DISKS=($(scan_for_new_disks))
  if [ "${#DISKS}" -eq 0 ]; then
    echo "No unpartitioned disks without filesystems detected"
    return
  fi
  echo "Disks are ${DISKS[@]}"
  for DISK in "${DISKS[@]}"; do
    echo "Working on ${DISK}"
    is_partitioned ${DISK}
    if [ ${?} -ne 0 ]; then
      echo "${DISK} is not partitioned, partitioning"
      do_partition ${DISK}
    fi
    PARTITION=$(fdisk -l ${DISK}|grep -A 1 Device|tail -n 1|awk '{print $1}')
    has_filesystem ${PARTITION}
    if [ ${?} -ne 0 ]; then
      echo "Creating filesystem on ${PARTITION}."
      mkfs -j -t ext4 ${PARTITION}
    fi
    MOUNTPOINT=$(get_next_mountpoint)
    echo "Next mount point appears to be ${MOUNTPOINT}"
    [ -d "${MOUNTPOINT}" ] || mkdir -p "${MOUNTPOINT}"
    read UUID FS_TYPE < <(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
    add_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    mount "${MOUNTPOINT}"
  done
}

create_striped_volume()
{
  DISKS=(${@})
  if [ "${#DISKS[@]}" -eq 0 ]; then
    echo "No unpartitioned disks without filesystems detected"
    return
  fi

  echo "Disks are ${DISKS[@]}"
  declare -a PARTITIONS

  for DISK in "${DISKS[@]}"; do
    echo "Working on ${DISK}"
    is_partitioned ${DISK}
    if [ ${?} -ne 0 ]; then
      echo "${DISK} is not partitioned, partitioning"
      do_partition ${DISK} fd
    fi

    PARTITION=$(fdisk -l ${DISK}|grep -A 2 Device|tail -n 1|awk '{print $1}')
    PARTITIONS+=("${PARTITION}")
  done

  MDDEVICE=$(get_next_md_device)    
  mdadm --create ${MDDEVICE} --level 0 --raid-devices ${#PARTITIONS[@]} ${PARTITIONS[*]}
  MOUNTPOINT=$(get_next_mountpoint)
  echo "Next mount point appears to be ${MOUNTPOINT}"
  [ -d "${MOUNTPOINT}" ] || mkdir -p "${MOUNTPOINT}"

  #Make a file system on the new device
  mkfs -t ext4 "${MDDEVICE}"

  read UUID FS_TYPE < <(blkid -u filesystem ${MDDEVICE}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
  add_to_fstab "${UUID}" "${MOUNTPOINT}"
  mount "${MOUNTPOINT}"
}

check_mdadm() {
  dpkg -s mdadm >/dev/null 2>&1
  if [ ${?} -ne 0 ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y install mdadm
  fi
}

# Create Partitions
DISKS=$(scan_for_new_disks)

if [ "$RAID_CONFIGURATION" -eq 1 ]; then
  check_mdadm
  create_striped_volume "${DISKS[@]}"
else
  scan_partition_format
fi

