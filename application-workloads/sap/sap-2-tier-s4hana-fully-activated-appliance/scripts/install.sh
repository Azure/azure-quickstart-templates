#!/bin/bash

function log()
{
  local message="$@"
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message"
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message" >> /var/log/azure-quickstart-install-os.log
}

function installprequisites()
{
    log "Start of installprequisites"
    log "Installing azcopy"

    curl -sSL -O https://packages.microsoft.com/config/sles/15/packages-microsoft-prod.rpm
    if [[ $? -ne 0 ]]; then
        log "Failed to download azcopy package"
        exit 1
    fi
    
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
    log "End of installprequisites"
}

function addipaddress()
{
    log "Start of addipaddress"
    local ip=$(hostname -I | awk '{print $1}')
    log "Server ip address is $ip"
    
    local entries=("sid-hdb-s4h.dummy.nodomain sid-hdb-s4h" 
                   "vhcals4hci.dummy.nodomain vhcals4hci" 
                   "vhcals4hcs.dummy.nodomain vhcals4hcs" 
                   "vhcalhdbdb.dummy.nodomain vhcalhdbdb")
    for entry in "${entries[@]}"; do
        echo "$ip $entry" >> /etc/hosts
    done

    if [ ! "$(getent hosts vhcals4hci)" ]; then
        log "Failed to add ip address to /etc/hosts"
        exit 1
    else
        log "Added $ip address to /etc/hosts"
        log "End of addipaddress"
    fi
}

function addtofstab()
{
    log "Start of addtofstab"
	local partPath=$1
    local mountPath=$2

    log "End of addtofstab $partPath $mountPath"

	mkfs -t xfs "$partPath"
	mkdir -p "$mountPath"

	local blkid="$(/sbin/blkid "$partPath")"
	if [[ $blkid =~  UUID=\"(.{36})\" ]]
	then
		log "Adding fstab entry for $partPath"
		local uuid=${BASH_REMATCH[1]};
        echo "/dev/disk/by-uuid/$uuid $mountPath xfs defaults,nofail 0 2" >> /etc/fstab
        mount "$mountPath"
	else
		log "No UUID found for $partPath"
		exit 1;
	fi
    # Check if mount point exist, if not log failure
    if [ ! -d "$mountPath" ]; then
        log "Failed to create mount point $mountPath"
        exit 1
    else
        log "Created mount point $mountPath"
    fi
    log "End of addtofstab"
}

function downloadscript()
{
    log "Start of downloadscript"
    local scriptname=$2
    local scripturl=$1

    log "Downloading $scriptname from $scripturl"
    curl -sSL -o /sapmedia/"$scriptname" "$scripturl"
    chmod +x /sapmedia/"$scriptname"
    
    if [[ ! -f "/sapmedia/$scriptname" ]]; then
        log "Failed to download $scriptname"
        exit 1
    else
        log "Downloaded $scriptname to /sapmedia"
    fi
    log "End of downloadscript"
}

# Main script starts here
log "Start of install.sh"

s4scriptlocation=$1
if [[ -z "$s4scriptlocation" ]]; then
    log "Script location not provided. Exiting."
    exit 1
fi

s4inifilelocation=$2
if [[ -z "$s4inifilelocation" ]]; then
    log "Ini file location not provided. Exiting."
    exit 1
fi

addipaddress
installprequisites

addtofstab /dev/sdc /hana/data
addtofstab /dev/sdd /hana/log
addtofstab /dev/sde /sapmedia
addtofstab /dev/sdf /sapmnt
mount -a

downloadscript "$s4scriptlocation" "s4install.sh"
downloadscript "$s4inifilelocation" "inifile.params"

log "End of install.sh"