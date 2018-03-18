#!/bin/bash

# Common functions definitions

function install_php_sql_driver 
{
# Download and build php/mssql driver
    /usr/bin/curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    /usr/bin/curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
    sudo apt-get update
    sudo ACCEPT_EULA=Y apt-get install msodbcsql mssql-tools unixodbc-dev -y
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
    source ~/.bashrc

    #Build mssql driver
    /usr/bin/pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system
    /usr/bin/pecl install sqlsrv
    /usr/bin/pecl install pdo_sqlsrv
    PHPVER=`/usr/bin/php -r "echo PHP_VERSION;" | /usr/bin/cut -c 1,2,3`
    echo "extension=sqlsrv.so" >> /etc/php/$PHPVER/fpm/php.ini
    echo "extension=pdo_sqlsrv.so" >> /etc/php/$PHPVER/fpm/php.ini
    echo "extension=sqlsrv.so" >> /etc/php/$PHPVER/apache2/php.ini
    echo "extension=pdo_sqlsrv.so" >> /etc/php/$PHPVER/apache2/php.ini
    echo "extension=sqlsrv.so" >> /etc/php/$PHPVER/cli/php.ini
    echo "extension=pdo_sqlsrv.so" >> /etc/php/$PHPVER/cli/php.ini

}

function check_fileServerType_param
{
    local fileServerType=$1
    if [ "$fileServerType" != "gluster" -a "$fileServerType" != "azurefiles" -a "$fileServerType" != "nfs" ]; then
        echo "Invalid fileServerType ($fileServerType) given. Only 'gluster', 'azurefiles' or 'nfs' are allowed. Exiting"
        exit 1
    fi
}

function create_azure_files_mahara_share
{
    local storageAccountName=$1
    local storageAccountKey=$2
    local logFilePath=$3

    az storage share create \
        --name mahara \
        --account-name $storageAccountName \
        --account-key $storageAccountKey \
        --fail-on-exist >> $logFilePath
}

function setup_and_mount_azure_files_mahara_share
{
    local storageAccountName=$1
    local storageAccountKey=$2

    cat <<EOF > /etc/mahara_azure_files.credential
username=$storageAccountName
password=$storageAccountKey
EOF
    chmod 600 /etc/mahara_azure_files.credential
    
    grep "^//$storageAccountName.file.core.windows.net/mahara\s\s*/mahara\s\s*cifs" /etc/fstab
    if [ $? != "0" ]; then
        echo -e "\n//$storageAccountName.file.core.windows.net/mahara   /mahara cifs    credentials=/etc/mahara_azure_files.credential,uid=www-data,gid=www-data,nofail,vers=3.0,dir_mode=0770,file_mode=0660,serverino,mfsymlinks" >> /etc/fstab
    fi
    mkdir -p /mahara
    mount /mahara
}

# Functions for making NFS share available
# TODO refactor these functions with the same ones in install_gluster.sh
function scan_for_new_disks
{
    local BLACKLIST=${1}    # E.g., /dev/sda|/dev/sdb
    declare -a RET
    local DEVS=$(ls -1 /dev/sd*|egrep -v "${BLACKLIST}"|egrep -v "[0-9]$")
    for DEV in ${DEVS};
    do
        # Check each device if there is a "1" partition.  If not,
        # "assume" it is not partitioned.
        if [ ! -b ${DEV}1 ];
        then
            RET+="${DEV} "
        fi
    done
    echo "${RET}"
}

function create_raid0_ubuntu {
    local RAIDDISK=${1}       # E.g., /dev/md1
    local RAIDCHUNKSIZE=${2}  # E.g., 128
    local DISKCOUNT=${3}      # E.g., 4
    shift
    shift
    shift
    local DISKS="$@"

    dpkg -s mdadm 
    if [ ${?} -eq 1 ];
    then 
        echo "installing mdadm"
        sudo apt-get -y -q install mdadm
    fi
    echo "Creating raid0"
    udevadm control --stop-exec-queue
    echo "yes" | mdadm --create $RAIDDISK --name=data --level=0 --chunk=$RAIDCHUNKSIZE --raid-devices=$DISKCOUNT $DISKS
    udevadm control --start-exec-queue
    mdadm --detail --verbose --scan > /etc/mdadm/mdadm.conf
}

function do_partition {
    # This function creates one (1) primary partition on the
    # disk device, using all available space
    local DISK=${1}   # E.g., /dev/sdc

    echo "Partitioning disk $DISK"
    echo -ne "n\np\n1\n\n\nw\n" | fdisk "${DISK}" 
    #> /dev/null 2>&1

    #
    # Use the bash-specific $PIPESTATUS to ensure we get the correct exit code
    # from fdisk and not from echo
    if [ ${PIPESTATUS[1]} -ne 0 ];
    then
        echo "An error occurred partitioning ${DISK}" >&2
        echo "I cannot continue" >&2
        exit 2
    fi
}

function add_local_filesystem_to_fstab {
    local UUID=${1}
    local MOUNTPOINT=${2}   # E.g., /mahara

    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "Not adding ${UUID} to fstab again (it's already there!)"
    else
        LINE="\nUUID=${UUID} ${MOUNTPOINT} ext4 defaults,noatime 0 0"
        echo -e "${LINE}" >> /etc/fstab
    fi
}

function create_filesystem_with_raid {
    local MOUNTPOINT=${1}     # E.g., /mahara
    local RAIDDISK=${2}       # E.g., /dev/md1
    local RAIDPARTITION=${3}  # E.g., /dev/md1p1

    mkdir -p $MOUNTPOINT

    local DISKS=$(scan_for_new_disks "/dev/sda|/dev/sdb")
    echo "Disks are ${DISKS}"
    declare -i DISKCOUNT
    local DISKCOUNT=$(echo "$DISKS" | wc -w) 
    echo "Disk count is $DISKCOUNT"
    if [ $DISKCOUNT = "0" ];
    then
        echo "No new (unpartitioned) disks available... Returning..."
        return
    elif [ $DISKCOUNT -gt 1 ];
    then
        create_raid0_ubuntu /dev/md1 128 $DISKCOUNT $DISKS
        do_partition ${RAIDDISK}
        local PARTITION="${RAIDPARTITION}"
    else
        do_partition ${DISKS}
        local PARTITION=$(fdisk -l ${DISKS}|grep -A 1 Device|tail -n 1|awk '{print $1}')
    fi

    echo "Creating filesystem on ${PARTITION}."
    mkfs -t ext4 ${PARTITION}
    mkdir -p "${MOUNTPOINT}"
    local UUID=$(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3}'|tr -d "\"")
    add_local_filesystem_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    mount "${MOUNTPOINT}"
}

function configure_nfs_server_and_export {
    local MOUNTPOINT=${1}     # E.g., /mahara

    echo "Installing nfs server..."
    apt install -y nfs-kernel-server

    echo "Exporting ${MOUNTPOINT}..."
    grep "^${MOUNTPOINT}" /etc/exports > /dev/null 2>&1
    if [ $? = "0" ]; then
        echo "${MOUNTPOINT} is already exported. Returning..."
    else
        echo -e "\n${MOUNTPOINT}   *(rw,sync,no_root_squash)" >> /etc/exports
        systemctl restart nfs-kernel-server.service
    fi
}

function configure_nfs_client_and_mount {
    local NFS_SERVER=${1}     # E.g., jumpbox-vm-ab12cd
    local NFS_DIR=${2}        # E.g., /mahara
    local MOUNTPOINT=${3}     # E.g., /mahara

    apt install -y nfs-common
    mkdir -p ${MOUNTPOINT}

    grep "^${NFS_SERVER}:${NFS_DIR}" /etc/fstab > /dev/null 2>&1
    if [ $? = "0" ]; then
        echo "${NFS_SERVER}:${NFS_DIR} already in /etc/fstab... skipping to add"
    else
        echo -e "\n${NFS_SERVER}:${NFS_DIR}    ${MOUNTPOINT}    nfs    auto    0    0" >> /etc/fstab
    fi
    mount ${MOUNTPOINT}
}

