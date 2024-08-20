#!/bin/bash

function log()
{
  message=$@
  echo "$message"
  echo "$message" >> /var/log/sapinstall.log
}

function installprequisites()
{
    log "installprequisites"
    #azcopy
    log "installing azcopy"
    curl -sSL -O https://packages.microsoft.com/config/sles/15/packages-microsoft-prod.rpm
    rpm -i packages-microsoft-prod.rpm
    rm -f packages-microsoft-prod.rpm
    zypper --non-interactive --gpg-auto-import-keys refresh
    zypper install -y azcopy
    if [ ! "$(azcopy --version)" ]; then
        log "Failed to install azcopy"
        exit 1
    else
        log "Successfully installed $(azcopy --version)"
    fi
    log "installprequisites done"
}

function addipaddress()
{
    log "addipaddress"
    # get the ip address of the host
    ip=$(hostname -I | awk '{print $1}')
    echo "$ip"
    # add the entry in /etc/hosts file
    echo $ip sid-hdb-s4h.dummy.nodomain sid-hdb-s4h >> /etc/hosts
    echo $ip vhcals4hci.dummy.nodomain vhcals4hci >> /etc/hosts
    #If vhcals4hci does not return a ip address, the log failure
    if [ ! "$(getent hosts vhcals4hci)" ]; then
        log "Failed to add ip address to /etc/hosts"
        exit 1
    else
        log "Successfully added $ip address to /etc/hosts"
        log "addipaddress done"
    fi
    
}

function addtofstab()
{
	partPath=$1
    mountPath=$2

    log "addtofstab $partPath $mountPath"

	mkfs -t xfs $partPath
	mkdir -p $mountPath

	local blkid=$(/sbin/blkid $partPath)
	if [[ $blkid =~  UUID=\"(.{36})\" ]]
	then
		log "Adding fstab entry for $partPath"
		local uuid=${BASH_REMATCH[1]};
		local mountCmd=""
		mountCmd="/dev/disk/by-uuid/$uuid $mountPath xfs  defaults,nofail  0  2"
		echo "$mountCmd" >> /etc/fstab
		mount $mountPath
	else
		log "no UUID found for $partPath"
		exit 1;
	fi
	log "addtofstab done for $partPath"
}

function getsapmedia()
{
    # Copy from a storage account to the local disk using azcli
    log "getsapmedia from $1"
    # If the string does not end with / then add /* to the end
    if [[ $1 != */ ]]; then
        storagePath="$1/*"
    else
        storagePath="$1"
    fi

    azcopy login --login-type=MSI
    azcopy copy "$storagePath" '/sapmedia' --recursive
    
    # If the /sapmedia directory is empty, then the copy failed
    if [ ! "$(ls -A /sapmedia)" ]; then
        log "azcopy failed to copy the SAP media"
        exit 1
    else
        log "azcopy successfully copied the SAP media"
    fi
}

storagePath=$1

addipaddress
installprequisites
addtofstab /dev/sdc /hana/data
addtofstab /dev/sdd /hana/log
addtofstab /dev/sde /sapmedia
addtofstab /dev/sdf /sapmnt
getsapmedia $storagePath
