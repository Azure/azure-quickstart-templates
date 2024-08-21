#!/bin/bash

function log()
{
  message=$@
  # Log to the console and to the log file with timestamp
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message"
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message" >> /var/log/azure-quickstart-install-os.log
}

function installprequisites()
{
    log "start of installprequisites"
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
    log "end of installprequisites"
}

function addipaddress()
{
    log "start of addipaddress"
    # get the ip address of the host
    ip=$(hostname -I | awk '{print $1}')
    echo "$ip"
    # add the entry in /etc/hosts file
    echo "$ip" sid-hdb-s4h.dummy.nodomain sid-hdb-s4h >> /etc/hosts
    echo "$ip" vhcals4hci.dummy.nodomain vhcals4hci >> /etc/hosts
    #If vhcals4hci does not return a ip address, the log failure
    if [ ! "$(getent hosts vhcals4hci)" ]; then
        log "Failed to add ip address to /etc/hosts"
        exit 1
    else
        log "Added $ip address to /etc/hosts"
        log "end of addipaddress"
    fi
}

function addtofstab()
{
    log "start of addtofstab"

	local partPath=$1
    local mountPath=$2

    log "addtofstab $partPath $mountPath"

	mkfs -t xfs "$partPath"
	mkdir -p "$mountPath"

	local blkid=$(/sbin/blkid "$partPath")
	if [[ $blkid =~  UUID=\"(.{36})\" ]]
	then
		log "Adding fstab entry for $partPath"
		local uuid=${BASH_REMATCH[1]};
		local mountCmd=""
		mountCmd="/dev/disk/by-uuid/$uuid $mountPath xfs  defaults,nofail  0  2"
		echo "$mountCmd" >> /etc/fstab
		mount "$mountPath"
	else
		log "no UUID found for $partPath"
		exit 1;
	fi
    # Check if mount point exist, if not log failure
    if [ ! -d "$mountPath" ]; then
        log "Failed to create mount point $mountPath"
        exit 1
    else
        log "Successfully created mount point $mountPath"
        log "addtofstab done for $partPath"
    fi

    log "end of addtofstab"
}

function downloadscript()
{
    log "start of downloadscript"
    local scriptname="s4install.sh"
    local scripturl=$1+"/s4install.sh"
    log "Downloading $scriptname from $scripturl"
    curl -sSL -o /sapmedia/$scriptname $scripturl
    if [ ! -f /sapmedia/$scriptname ]; then
        log "Failed to download $scriptname"
        exit 1
    else
        log "Successfully downloaded $scriptname to /sapmedia"
    fi
    log "end of downloadscript"
}


# Main script starts here
log "start of install.sh"

s4scriptlocation=$1

# OS-level pre-requisites 
addipaddress
installprequisites

# SAP filesystem setup
addtofstab /dev/sdc /hana/data
addtofstab /dev/sdd /hana/log
addtofstab /dev/sde /sapmedia
addtofstab /dev/sdf /sapmnt
mount -a

# Download the SAP install script
downloadscript "$s4scriptlocation"

log "end of install.sh"