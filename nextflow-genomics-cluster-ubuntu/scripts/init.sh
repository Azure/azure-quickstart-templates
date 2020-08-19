#!/bin/bash

# ShellCheck is used for styling and static checking: https://github.com/koalaman/shellcheck
# The script is split into functions to aid readability and maintainance.
# Functions starting with an '_' child functions.
# See the end of the file for flow.

AZURE_STORAGE_NAME=$1
AZURE_STORAGE_KEY=$2
AZURE_FILESHARE_NAME=$3
AZURE_STORAGE_ENDPOINT=$4
MOUNTPOINT_PATH=$5
IS_RUNNING_ON_NODE=$6
USERNAME=$7
CLUSTER_MAXCPUS=$8
NEXTFLOW_INSTALL_URL=$9
ADDITIONAL_INSTALL_SCRIPT_URL=${10}
ADDITIONAL_INSTALL_SCRIPT_ARGUMENT=${11}


log () {
    echo "-------------------------" | tee -a "$2"
    date -Is | tee -a "$2"
    echo "$1" | tee -a "$2"
    echo "-------------------------" | tee -a "$2"
}

log "storageSuffix: $AZURE_STORAGE_ENDPOINT"

installUtils() {
    #Install CIFS and JQ (used by this script)
    log "Installing CIFS and JQ" /tmp/nfinstall.log
    apt-get -y update | tee /tmp/nfinstall.log
    apt-get install cifs-utils sudo apt-transport-https wget graphviz -y | tee -a /tmp/nfinstall.log

    #Create azure share if it doesn't already exist
    log "Installing AzureCLI and Mounting Azure Files Share" /tmp/nfinstall.log
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash #TODO: simplify CLI install - this one command will do



    az storage share create --name "$AZURE_FILESHARE_NAME" --quota 2048 --connection-string "DefaultEndpointsProtocol=https;EndpointSuffix=$AZURE_STORAGE_ENDPOINT;AccountName=$AZURE_STORAGE_NAME;AccountKey=$AZURE_STORAGE_KEY" | tee -a /tmp/nfinstall.log

    #Wait for the file share to be available.
    sleep 10
}

formatDataDisks() {
    DATA_DIR="/datadisks/disk1"

    if bash ./vm-disk-utils-0.1.sh && [ -d "$DATA_DIR" ];
    then
        log "Disk setup successful, using $DATA_DIR" /tmp/nfinstall.log
    else
        log "Disk setup failed, using default data storage location" /tmp/nfinstall.log
    fi

    #Format data disks
    mkdir -p $DATA_DIR
    chmod 777 $DATA_DIR
    chmod 777 /datadisks
}

mountCifs() {
    log "Mounting CIFS" /tmp/nfinstall.log

    #Mount the share with symlink and fifo support: see https://wiki.samba.org/index.php/SMB3-Linux
    mkdir -p "$MOUNTPOINT_PATH/cifs" | tee -a /tmp/nfinstall.log
    #TODO - hard coded endpoint
    echo "//$AZURE_STORAGE_NAME.file.$AZURE_STORAGE_ENDPOINT/$AZURE_FILESHARE_NAME $MOUNTPOINT_PATH/cifs cifs vers=3.0,username=$AZURE_STORAGE_NAME,password=$AZURE_STORAGE_KEY,dir_mode=0777,file_mode=0777,mfsymlinks,sfu" >> /etc/fstab
    mount -a  | tee -a /tmp/nfinstall.log
    CIFS_SHAREPATH="$MOUNTPOINT_PATH/cifs"
}

_setupNfsServer() {
    log "MASTER: Creating NFS share" /tmp/nfinstall.log

    #Variables
    ALLOWEDSUBNET=10.0.0.0/24

    #Install CIFS and JQ (used by this script)
    log "MASTER: Installing NFS Server" /tmp/nfinstall.log
    apt-get install nfs-kernel-server -y | tee -a /tmp/nfinstall.log

    #TODO: Review permissions and security
    mkdir "$NFS_SHAREPATH" | tee -a /tmp/nfinstall.log
    chown nobody:nogroup "$NFS_SHAREPATH" | tee -a /tmp/nfinstall.log
    chmod 777 "$NFS_SHAREPATH" | tee -a /tmp/nfinstall.log

    echo "$NFS_SHAREPATH    $ALLOWEDSUBNET(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=100)" > /etc/exports

    systemctl restart nfs-kernel-server | tee -a /tmp/nfinstall.log

    touch "$CIFS_SHAREPATH/.done_creating_nfs_share" | tee -a /tmp/nfinstall.log
}

_setupNfsClient() {
    log "NODE: Install NFS client tools" /tmp/nfinstall.log
    apt-get install nfs-kernel-server -y | tee -a /tmp/nfinstall.log

    log "NODE: Mounting NFS share" /tmp/nfinstall.log
    mkdir -p "$NFS_SHAREPATH" | tee -a /tmp/nfinstall.log
    echo "jumpboxvm:$NFS_SHAREPATH $NFS_SHAREPATH nfs rw,soft,intr" >> /etc/fstab
    mount -a | tee -a /tmp/nfinstall.log
    chmod 777 "$NFS_SHAREPATH" | tee -a /tmp/nfinstall.log
}

setupNfs() {
    #Variables
    #Location NFS share will be mounted at
    NFS_SHAREPATH="$MOUNTPOINT_PATH"/nfs

    mkdir -p "$NFS_SHAREPATH" | tee -a /tmp/nfinstall.log
    if [ "$IS_RUNNING_ON_NODE" != true ]; then
        _setupNfsServer
    fi

    while [ ! -f "$CIFS_SHAREPATH/.done_creating_nfs_share" ]
    do
        log "NODE: Waiting for NFS share to be created" /tmp/nfinstall.log
        sleep 5
    done

    if [ "$IS_RUNNING_ON_NODE" = true ]; then
        _setupNfsClient
    fi
}

copyLogsToCifsShareForDebugging() {
    log "Get machine metadata and copy logs to share"

    apt-get install curl -y | tee -a /tmp/nfinstall.log

    #Get node name and other instance metadata and write details into share log folder for debugging
    #see https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service
    METADATA=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-04-02")
    NODENAME=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2017-04-02&format=text")

    #Create a log folder for each node
    mkdir -p "$CIFS_SHAREPATH/logs/$NODENAME" | tee -a /tmp/nfinstall.log

    #Copy logs used so far
    cp /tmp/nfinstall.log "$CIFS_SHAREPATH/logs/$NODENAME/"
    LOGFOLDER="$CIFS_SHAREPATH/logs/$NODENAME/"
    LOGFILE="$CIFS_SHAREPATH/logs/$NODENAME/nfinstall.log"

    #Track the metadata for the node for debugging
    echo "$METADATA" > "$CIFS_SHAREPATH/logs/$NODENAME/node.metadata"
}

installNextflowDeps() {
    log "Add Singularity repo to apt" "$LOGFILE"
    wget -O- http://neuro.debian.net/lists/xenial.us-ca.full | tee /etc/apt/sources.list.d/neurodebian.sources.list
    wget -qO - http://neuro.debian.net/_static/neuro.debian.net.asc | apt-key add -

    log "Add Docker repo to apt" "$LOGFILE"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - | tee -a "$LOGFILE"
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee -a "$LOGFILE"

    apt-get update -y | tee -a "$LOGFILE"

    log "Installing JAVA" "$LOGFILE"
    apt-get install openjdk-8-jdk -y | tee -a "$LOGFILE"

    log "Install Singularity" "$LOGFILE"
    apt-get install -y singularity-container | tee -a "$LOGFILE"
    echo "bind path = $MOUNTPOINT_PATH" >> /etc/singularity/singularity.conf
    echo "bind path = /mnt" >> /etc/singularity/singularity.conf

    log "Install Docker" "$LOGFILE"
    apt-get install -y docker-ce | tee -a "$LOGFILE"
    #Add the nextflow user to the docker group.
    usermod -aG docker "$USERNAME" | tee -a "$LOGFILE"
    #Nextflow creates files with write permissions only allowed by user that created them
    #As we run nextflow under user/group nextflow/nextlow but the docker containers run under root
    #We need to add root to the nextflow user group to give it the correct permissions
    usermod -aG "$USERNAME" root | tee -a "$LOGFILE"
    usermod -aG nogroup root | tee -a "$LOGFILE"
}

setNextflowEnvironmentVars() {
    log "Setup Filesystem and Environment Variables" "$LOGFILE"

    mkdir -p "$NFS_SHAREPATH/work"
    chmod 777 "$NFS_SHAREPATH/work"
    mkdir -p "$NFS_SHAREPATH/assets"
    chmod 777 "$NFS_SHAREPATH/assets"

    #Configure nextflow environment vars
    {
        echo "export NXF_WORK=$NFS_SHAREPATH/work"
        echo "export NXF_ASSETS=$NFS_SHAREPATH/assets"

        #Added for debugging
        echo export "NXF_AZ_USER=$USERNAME"
        echo export "NXF_AZ_LOGFILE=$LOGFILE"
        echo export "NXF_AZ_CIFSPATH=$CIFS_SHAREPATH"
        echo export "NXF_AZ_NFSPATH=$NFS_SHAREPATH"
    } >> /etc/environment

    #Use azure epherical instance drive for tmp
    mkdir -p /mnt/nextflow_temp
    echo export NXF_TEMP=/mnt/nextflow_temp >> /etc/environment

    #Allow user access to temporary drive
    chmod -f 777 /mnt/nextflow_temp
}

installNextflow() {
    #Install nextflow
    log "Installing nextflow" "$LOGFILE"
    curl -s "$NEXTFLOW_INSTALL_URL" | bash | tee -a "$LOGFILE"

    #Copy the binary to the path to be accessed by users
    cp ./nextflow /usr/local/bin
    chmod -f 777 /usr/local/bin/nextflow

    log "Invoke nextflow to install dependencies" "$LOGFILE"
    sudo -H -u "$USERNAME" bash -c 'nextflow' | tee -a "$LOGFILE"
}

_smokeTestFailed() {
    echo "Shutting down node...." | tee -a "$LOGFILE"
    if [ "$IS_RUNNING_ON_NODE" != true ]; then
        #If we're the master this fail the deployment
        exit 1
    fi

    #If we're just a faulty node then shutdown
    shutdown -h now | tee -a "$LOGFILE"
    exit 0
}

runSmokeTest() {
    log "Run smoke test. Validate machine is setup" "$LOGFILE"

    log "Check Installed programs" "$LOGFILE"
    if ! [ -x "$(command -v docker)" ] || ! [ -x "$(command -v singularity)" ] || ! [ -x "$(command -v nextflow)" ]; then
        log "FAIL: Missing commands" "$LOGFILE"
        echo "Docker" | tee -a "$LOGFILE"
        command -v docker | tee -a "$LOGFILE"

        echo "Singularity" | tee -a "$LOGFILE"
        command -v singularity | tee -a "$LOGFILE"

        echo "Nextflow" | tee -a "$LOGFILE"
        command -v nextflow | tee -a "$LOGFILE"

        _smokeTestFailed
    else
        echo "Success: Nextflow, docker and singularity installed" >> "$LOGFILE"
    fi

    log "Check mount points setup" "$LOGFILE"
    if mountpoint -q "$MOUNTPOINT_PATH"/cifs; then
        echo "CIFS Mounted" | tee -a "$LOGFILE"
    else
        echo "FAILED CIFS not mounted" | tee -a "$LOGFILE"
        _smokeTestFailed
    fi

    #NFS mount point only present on nodes as jumpbox is the NFS server.
    # so only perform the check on nodes not jumpbox.
    if [ "$IS_RUNNING_ON_NODE" = true ]; then
        if mountpoint -q "$MOUNTPOINT_PATH"/nfs
        then
            echo "NFS Mounted" | tee -a "$LOGFILE"
        else
            echo "FAILED NFS not mounted" | tee -a "$LOGFILE"
            _smokeTestFailed
        fi
    fi
}

runAdditionalInstallScriptIfProvided() {
    if [[ "$ADDITIONAL_INSTALL_SCRIPT_URL" ]]; then
        log "Run additional install script" "$LOGFILE"
        log "Additional script url: $ADDITIONAL_INSTALL_SCRIPT_URL / argument: $ADDITIONAL_INSTALL_SCRIPT_ARGUMENT" "$LOGFILE"
        curl -s "$ADDITIONAL_INSTALL_SCRIPT_URL" -o additional_script.sh
        bash additional_script.sh "$ADDITIONAL_INSTALL_SCRIPT_ARGUMENT" | tee -a "$LOGFILE"
    fi
}

startNextflowServiceIfNode() {
    #If we're a node run the daemon
    if [ "$IS_RUNNING_ON_NODE" = true ]; then

    #Create a systemd unit
    cat >/etc/systemd/system/nextflow.service <<EOL
[Unit]
Description=Nextflow Node service
After=network-online.target

[Service]
Type=forking
ExecStart=/usr/local/bin/nextflow node -bg -cluster.join path:$CIFS_SHAREPATH/cluster -cluster.interface eth0 -cluster.maxCpus "$CLUSTER_MAXCPUS"
Restart=always
WorkingDirectory=$LOGFOLDER

[Install]
WantedBy=multi-user.target
EOL

    log "NODE: Starting cluster nextflow cluster node" "$LOGFILE"
    systemctl enable nextflow.service | tee -a "$LOGFILE"
    systemctl start nextflow.service | tee -a "$LOGFILE"
    log "NODE: Cluster node started" "$LOGFILE"

    fi

}

# This is the install flow, invoking each of the functions.
installUtils
formatDataDisks
mountCifs
setupNfs
copyLogsToCifsShareForDebugging
installNextflowDeps
setNextflowEnvironmentVars
installNextflow
runSmokeTest
runAdditionalInstallScriptIfProvided
startNextflowServiceIfNode
