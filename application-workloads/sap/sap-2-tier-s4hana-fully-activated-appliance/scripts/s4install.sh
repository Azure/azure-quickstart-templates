#!/bin/bash
function log()
{
  local message="$@"
  # Log to the console and to the log file with timestamp
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message"
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message" >> /var/log/azure-quickstart-install-s4.log
}

function getsapmedia()
{ 
    log "Start of getsapmedia"
    if $2 '==' "null"; then
        log "Use managed identity to access the storage account"
        export AZCOPY_AUTO_LOGIN_TYPE=MSI
        azcopy sync "$1" '/sapmedia' --exclude-pattern 51057501_5.ZIP
    else
        log "Using Storage account SAS token"
        azcopy sync "$1?$2" '/sapmedia' --exclude-pattern 51057501_5.ZIP 
    fi
    #count the number of zip files in the /sapmedia directory
    local zipcount=$(find /sapmedia -name "*.ZIP" 2>/dev/null | wc -l)
    if [ "$zipcount" -lt 4 ]; then
        log "azcopy failed to copy the SAP media"
        exit 1
    else
        log "azcopy successfully copied the SAP media"
    fi
    log "End of getsapmedia"
}

function unzipmedia()
{
    log "Start of unzipmedia"
    for file in /sapmedia/*.ZIP
    do
        log "unzipping $file"
        unzip -q -o "$file" -d /sapmedia 
    done

    if [ ! -f /sapmedia/"$1"_1/dbdata.tgz-ah ]; then
        log "Failed to unzip the media"
        exit 1
    else
        log "Media unzipped successfully"
    fi    

    log "End of unzipmedia"
}

function copybinaries()
{
    log "Start of copybinaries"
    cd /sapmedia/"$1"_1 || exit
    mv /sapmedia/"$1"_2/*.tgz-* .
    mv /sapmedia/"$1"_3/*.tgz-* .
    mv /sapmedia/"$1"_4/*.tgz-* . 
    log "End of copybinaries"
}

function extractbinaries()
{
    log "Start of extractbinaries"
    local tar_files=("dbdata.tgz-*" "dblog.tgz-*" "dbexe.tgz-*" "sapmnt_s4h.tgz-*" "usrsap_s4h.tgz-*")
                      
    for tar_file in "${tar_files[@]}"; 
    do
        cd /sapmedia/"$1"_1 || exit
        cat $tar_file | tar -zpxvf - -C / 
        log "$tar_file extracted"
    done

    if [ ! -f /sapmnt/S4H/exe/uc/linuxx86_64/SAPCAR ]; then
        log "Failed to extract the binaries"
        exit 1
    else
        log "Binaries extracted successfully"
    fi
    log "End of extractbinaries"
}

function renamedb()
{   
    log "Start of renamedb"
    local xmlFile=/sapmedia/"$1"_4/SAP_Software_Appliance.xml
    local pwvalue=$(xmllint --xpath "string(//Password)" $xmlFile)
    /hana/shared/HDB/hdblcm/hdblcm --batch --action=register_rename_system --sapadm_password="$pwvalue" --target_password="$pwvalue"
    log "End of renamedb"
}

function renamesap()
{
    log "Start of renamesap"

    #Bug fix for the issue where the SAP system is not starting after the rename
    export LD_LIBRARY_PATH=/usr/sap/S4H/SYS/exe/run:/usr/sap/S4H/SYS/exe/uc/linuxx86_64:/usr/sap/S4H/SYS/exe/uc/linuxx86_64/hdbclient
    /usr/sap/S4H/ASCS01/exe/sapstartsrv -reg pf=/sapmnt/S4H/profile/S4H_ASCS01_vhcals4hcs
    systemctl start SAPS4H_01

    local swpmfile=$(ls /sapmedia | grep SWPM20)
    cd /sapmedia || exit
    /sapmnt/S4H/exe/uc/linuxx86_64/SAPCAR -xvf /sapmedia/$swpmfile
    mkdir /sapmedia/sapinstdir
    cd /sapmedia/sapinstdir || exit
    mv /sapmedia/inifile.params /sapmedia/sapinstdir/inifile.params
    local xmlFile=/sapmedia/"$1"_4/SAP_Software_Appliance.xml
    local pwvalue=$(xmllint --xpath "string(//Password)" $xmlFile)
    sed -i "s/<REPLACE>/$pwvalue/g" /sapmedia/sapinstdir/inifile.params
    /sapmedia/sapinst SAPINST_INPUT_PARAMETERS_URL=/sapmedia/sapinstdir/inifile.params SAPINST_EXECUTE_PRODUCT_ID=NW_StorageBasedCopy SAPINST_SKIP_DIALOGS=true SAPINST_START_GUISERVER=false
    
    if [ ! -f /tmp/sapinst_instdir/NW73/SBC/STANDARD/installationSuccesfullyFinished.dat ]; then
        log "Failed to rename the SAP system"
        exit 1
    else
        log "SAP system installed successfully"
    fi
    
    log "End of renamesap"
}

# Main script starts here
log "start of s4hanafa-install.sh"
storagePath="$1"
storageAccountToken="$2"
sapdir="SAPS4HANA2023FPS00SAPHANADB20"

if [[ -z "$storagePath" ]]; then
  log "Storage path not provided. Exiting."
  exit 1
fi

getsapmedia "$storagePath" "$storageAccountToken"
unzipmedia  "$sapdir"
copybinaries "$sapdir"
extractbinaries "$sapdir"
renamedb "$sapdir"
renamesap "$sapdir"

log "end of s4hanafa-install.sh"