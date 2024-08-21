#!/bin/bash
set -e

function log()
{
  message=$@
  # Log to the console and to the log file with timestamp
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message"
  echo "$(date +'%Y-%m-%d %H:%M:%S') $message" >> /var/log/azure-quickstart-install-s4.log
}

function checksapmedia()
{
    # Check if the SAP media is empty in the /sapmedia directory
    if [ ! "$(ls -A /sapmedia)" ]; then
        log "/sapmedia is empty, proceed with the installation"
    else 
        log "The /sapmedia directory is not empty"
        exit 1
    fi
}

function getsapmedia()
{ 
    log "start of getsapmedia"
    # Copy from a storage account to the local disk using azcli
    azcopy copy "$1?$2" '/sapmedia' --recursive 
    
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

function copybinaries()
{
    # Copy the binaries to the /usr/sap/install directory
    log "start of copybinaries"
    cd /sapmedia/SAPS4HANA2023FPS00SAPHANADB20_1
    mv /sapmedia/SAPS4HANA2023FPS00SAPHANADB20_2/*.tgz-* .
    mv /sapmedia/SAPS4HANA2023FPS00SAPHANADB20_3/*.tgz-* .
    mv /sapmedia/SAPS4HANA2023FPS00SAPHANADB20_4/*.tgz-* .    
    log "end of copybinaries"
}

function extractbinaries()
{
    log "start of extractbinaries"
    # Extract the binaries
    cat dbdata.tgz-* | tar -zpxvf - -C /
    log "dbdata extracted"

    cat dblog.tgz-* | tar -zpxvf - -C /
    log "dblog extracted"

    cat dbexe.tgz-* | tar -zpxvf - -C /  
    log "dbexe extracted"

    cat sapmnt_s4h.tgz-* | tar -zpxvf - -C / 
    log "sapmnt extracted"

    cat usrsap_s4h.tgz-* | tar -zpxvf - -C /
    log "usrsap extracted"

    log "end of extractbinaries"
}

function renamedb()
{   
    log "start of renamedb"
    #Get SAP default password from the xml file provided in the media
    local xmlFile=/sapmedia/SAPS4HANA2023FPS00SAPHANADB20_4/SAP_Software_Appliance.xml
    local pwvalue=$(xmllint --xpath "string(//Password)" $xmlFile)
    /hana/shared/HDB/hdblcm/hdblcm --batch --action=register_rename_system --sapadm_password="$pwvalue" --target_password="$pwvalue"
    log "end of renamedb"
}

function renamesap()
{
    log "start of renamesap"
    #Get SAP default password from the xml file provided in the media
    #Get the name of the file that begins with SWPM20
    local swpmfile=$(ls /sapmedia | grep SWPM20)
    cd /sapmedia
    /sapmnt/S4H/exe/uc/linuxx86_64/SAPCAR -xvf /sapmedia/$swpmfile
    mkdir /sapmedia/sapinstdir
    cd /sapmedia/sapinstdir
    mv /sapmedia/inifile.params /sapmedia/sapinstdir/inifile.params
    
    #Get SAP default password from the xml file provided in the media
    local xmlFile=/sapmedia/SAPS4HANA2023FPS00SAPHANADB20_4/SAP_Software_Appliance.xml
    local pwvalue=$(xmllint --xpath "string(//Password)" $xmlFile)
    sed -i "s/<REPLACE>/$pwvalue/g" /sapmedia/sapinstdir/inifile.params
    /sapmedia/sapinst SAPINST_INPUT_PARAMETERS_URL=/sapmedia/sapinstdir/inifile.params SAPINST_EXECUTE_PRODUCT_ID=NW_StorageBasedCopy SAPINST_SKIP_DIALOGS=true SAPINST_START_GUISERVER=false

    log "end of renamesap"
}

# Main script starts here
log "start of s4hanafa-install.sh"
storagePath="$1"
storageAccountToken="$2"

checksapmedia
getsapmedia "$storagePath" "$storageAccountToken"

unzipmedia  
copybinaries
extractbinaries
renamedb
renamesap

log "end of s4hanafa-install.sh"