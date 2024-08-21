#!/bin/bash
set -e

function log()
{
  message=$@
  # Log to the console and to the log file with timestamp
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message"
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message" >> /var/log/azure-quickstart-install-s4.log
}

function getsapmedia()
{ 
    log "start of getsapmedia"
    # Copy from a storage account to the local disk using azcli
    azcopy copy "$1?$2" '/sapmedia' --recursive >> /var/log/azure-quickstart-install-s4.log
    
    # If the /sapmedia directory is empty, then the copy failed
    if [ ! "$(ls -A /sapmedia)" ]; then
        log "azcopy failed to copy the SAP media"
        exit 1
    else
        log "azcopy successfully copied the SAP media"
    fi

    log "end of getsapmedia"
}

function unzipmedia()
{
    log "start of unzipmedia"
    # Unzip the media files
    for file in /sapmedia/*.ZIP
    do
        log "unzipping $file"
        unzip -o "$file" -d /sapmedia
    done
    log "end of unzipmedia"
}

# Main script starts here
log "start of s4hanafa-install.sh"
storagePath="$1"
storageAccountToken="$2"

getsapmedia "$storagePath" "$storageAccountToken"
unzipmedia  

log "end of s4hanafa-install.sh"