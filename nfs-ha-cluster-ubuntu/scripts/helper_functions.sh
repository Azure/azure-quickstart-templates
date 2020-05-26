#!/bin/bash

# Common functions definitions

function get_setup_params_from_configs_json
{
    local configs_json_path=${1}    # E.g., /var/lib/cloud/instance/moodle_on_azure_configs.json

    (dpkg -l jq &> /dev/null) || (apt -y update; apt -y install jq)

    # Wait for the cloud-init write-files user data file to be generated (just in case)
    local wait_time_sec=0
    while [ ! -f "$configs_json_path" ]; do
        sleep 15
        let "wait_time_sec += 15"
        if [ "$wait_time_sec" -ge "1800" ]; then
            echo "Error: Cloud-init write-files didn't complete in 30 minutes!"
            return 1
        fi
    done

    local json=$(cat $configs_json_path)
    export moodleVersion=$(echo $json | jq -r .moodleProfile.version)
    export glusterNode=$(echo $json | jq -r .fileServerProfile.glusterVmName)
    export glusterVolume=$(echo $json | jq -r .fileServerProfile.glusterVolName)
    export siteFQDN=$(echo $json | jq -r .siteProfile.siteURL)
    export httpsTermination=$(echo $json | jq -r .siteProfile.httpsTermination)
    export dbIP=$(echo $json | jq -r .dbServerProfile.fqdn)
    export moodledbname=$(echo $json | jq -r .moodleProfile.dbName)
    export moodledbuser=$(echo $json | jq -r .moodleProfile.dbUser)
    export moodledbpass=$(echo $json | jq -r .moodleProfile.dbPassword)
    export adminpass=$(echo $json | jq -r .moodleProfile.adminPassword)
    export dbadminlogin=$(echo $json | jq -r .dbServerProfile.adminLogin)
    export dbadminloginazure=$(echo $json | jq -r .dbServerProfile.adminLoginAzure)
    export dbadminpass=$(echo $json | jq -r .dbServerProfile.adminPassword)
    export storageAccountName=$(echo $json | jq -r .moodleProfile.storageAccountName)
    export storageAccountKey=$(echo $json | jq -r .moodleProfile.storageAccountKey)
    export azuremoodledbuser=$(echo $json | jq -r .moodleProfile.dbUserAzure)
    export redisDns=$(echo $json | jq -r .moodleProfile.redisDns)
    export redisAuth=$(echo $json | jq -r .moodleProfile.redisKey)
    export elasticVm1IP=$(echo $json | jq -r .moodleProfile.elasticVm1IP)
    export installO365pluginsSwitch=$(echo $json | jq -r .moodleProfile.installO365pluginsSwitch)
    export dbServerType=$(echo $json | jq -r .dbServerProfile.type)
    export fileServerType=$(echo $json | jq -r .fileServerProfile.type)
    export mssqlDbServiceObjectiveName=$(echo $json | jq -r .dbServerProfile.mssqlDbServiceObjectiveName)
    export mssqlDbEdition=$(echo $json | jq -r .dbServerProfile.mssqlDbEdition)
    export mssqlDbSize=$(echo $json | jq -r .dbServerProfile.mssqlDbSize)
    export installObjectFsSwitch=$(echo $json | jq -r .moodleProfile.installObjectFsSwitch)
    export installGdprPluginsSwitch=$(echo $json | jq -r .moodleProfile.installGdprPluginsSwitch)
    export thumbprintSslCert=$(echo $json | jq -r .siteProfile.thumbprintSslCert)
    export thumbprintCaCert=$(echo $json | jq -r .siteProfile.thumbprintCaCert)
    export searchType=$(echo $json | jq -r .moodleProfile.searchType)
    export azureSearchKey=$(echo $json | jq -r .moodleProfile.azureSearchKey)
    export azureSearchNameHost=$(echo $json | jq -r .moodleProfile.azureSearchNameHost)
    export tikaVmIP=$(echo $json | jq -r .moodleProfile.tikaVmIP)
    export syslogServer=$(echo $json | jq -r .moodleProfile.syslogServer)
    export webServerType=$(echo $json | jq -r .moodleProfile.webServerType)
    export htmlLocalCopySwitch=$(echo $json | jq -r .moodleProfile.htmlLocalCopySwitch)
    export nfsVmName=$(echo $json | jq -r .fileServerProfile.nfsVmName)
    export nfsHaLbIP=$(echo $json | jq -r .fileServerProfile.nfsHaLbIP)
    export nfsHaExportPath=$(echo $json | jq -r .fileServerProfile.nfsHaExportPath)
}

function get_php_version {
# Returns current PHP version, in the form of x.x, eg 7.0 or 7.2
    if [ -z "$_PHPVER" ]; then
        _PHPVER=`/usr/bin/php -r "echo PHP_VERSION;" | /usr/bin/cut -c 1,2,3`
    fi
    echo $_PHPVER
}

function install_php_mssql_driver
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
    PHPVER=$(get_php_version)
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
    if [ "$fileServerType" != "gluster" -a "$fileServerType" != "azurefiles" -a "$fileServerType" != "nfs" -a "$fileServerType" != "nfs-ha" ]; then
        echo "Invalid fileServerType ($fileServerType) given. Only 'gluster', 'azurefiles', 'nfs' or 'nfs-ha' are allowed. Exiting"
        exit 1
    fi
}

function create_azure_files_moodle_share
{
    local storageAccountName=$1
    local storageAccountKey=$2
    local logFilePath=$3

    az storage share create \
        --name moodle \
        --account-name $storageAccountName \
        --account-key $storageAccountKey \
        --fail-on-exist >> $logFilePath
}

function setup_and_mount_gluster_moodle_share
{
    local glusterNode=$1
    local glusterVolume=$2

    grep -q "/moodle.*glusterfs" /etc/fstab || echo -e $glusterNode':/'$glusterVolume'   /moodle         glusterfs       defaults,_netdev,log-level=WARNING,log-file=/var/log/gluster.log 0 0' >> /etc/fstab
    mount /moodle
}

function setup_and_mount_azure_files_moodle_share
{
    local storageAccountName=$1
    local storageAccountKey=$2

    cat <<EOF > /etc/moodle_azure_files.credential
username=$storageAccountName
password=$storageAccountKey
EOF
    chmod 600 /etc/moodle_azure_files.credential

    grep "^//$storageAccountName.file.core.windows.net/moodle\s\s*/moodle\s\s*cifs" /etc/fstab
    if [ $? != "0" ]; then
        echo -e "\n//$storageAccountName.file.core.windows.net/moodle   /moodle cifs    credentials=/etc/moodle_azure_files.credential,uid=www-data,gid=www-data,nofail,vers=3.0,dir_mode=0770,file_mode=0660,serverino,mfsymlinks" >> /etc/fstab
    fi
    mkdir -p /moodle
    mount /moodle
}

function setup_moodle_mount_dependency_for_systemd_service
{
  local serviceName=$1 # E.g., nginx, apache2
  if [ -z "$serviceName" ]; then
    return 1
  fi

  local systemdSvcOverrideFileDir="/etc/systemd/system/${serviceName}.service.d"
  local systemdSvcOverrideFilePath="${systemdSvcOverrideFileDir}/moodle_on_azure_override.conf"

  grep -q "After=moodle.mount" $systemdSvcOverrideFilePath &> /dev/null
  if [ $? != "0" ]; then
    mkdir -p $systemdSvcOverrideFileDir
    cat <<EOF > $systemdSvcOverrideFilePath
[Unit]
After=moodle.mount
EOF
    systemctl daemon-reload
  fi
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
    local MOUNTPOINT=${2}   # E.g., /moodle

    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "Not adding ${UUID} to fstab again (it's already there!)"
    else
        LINE="\nUUID=${UUID} ${MOUNTPOINT} ext4 defaults,noatime 0 0"
        echo -e "${LINE}" >> /etc/fstab
    fi
}

function setup_raid_disk_and_filesystem {
    local MOUNTPOINT=${1}     # E.g., /moodle
    local RAIDDISK=${2}       # E.g., /dev/md1
    local RAIDPARTITION=${3}  # E.g., /dev/md1p1
    local CREATE_FILESYSTEM=${4}  # E.g., "" (true) or any non-empty string (false)

    local DISKS=$(scan_for_new_disks "/dev/sda|/dev/sdb")
    echo "Disks are ${DISKS}"
    declare -i DISKCOUNT
    local DISKCOUNT=$(echo "$DISKS" | wc -w)
    echo "Disk count is $DISKCOUNT"
    if [ $DISKCOUNT = "0" ]; then
        echo "No new (unpartitioned) disks available... Returning non-zero..."
        return 1
    fi

    if [ $DISKCOUNT -gt 1 ]; then
        create_raid0_ubuntu ${RAIDDISK} 128 $DISKCOUNT $DISKS
        AZMDL_DISK=$RAIDDISK
        if [ -z "$CREATE_FILESYSTEM" ]; then
          do_partition ${RAIDDISK}
          local PARTITION="${RAIDPARTITION}"
        fi
    else # Just one unpartitioned disk
        AZMDL_DISK=$DISKS
        if [ -z "$CREATE_FILESYSTEM" ]; then
          do_partition ${DISKS}
          local PARTITION=$(fdisk -l ${DISKS}|grep -A 1 Device|tail -n 1|awk '{print $1}')
        fi
    fi

    echo "Disk (RAID if multiple unpartitioned disks, or as is if only one unpartitioned disk) is set up, and env var AZMDL_DISK is set to '$AZMDL_DISK' for later reference"

    if [ -z "$CREATE_FILESYSTEM" ]; then
      echo "Creating filesystem on ${PARTITION}."
      mkfs -t ext4 ${PARTITION}
      mkdir -p "${MOUNTPOINT}"
      local UUID=$(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3}'|tr -d "\"")
      add_local_filesystem_to_fstab "${UUID}" "${MOUNTPOINT}"
      echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
      mount "${MOUNTPOINT}"
    fi
}

function configure_nfs_server_and_export {
    local MOUNTPOINT=${1}     # E.g., /moodle

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
    local NFS_SERVER=${1}     # E.g., controller-vm-ab12cd or IP (NFS-HA LB)
    local NFS_DIR=${2}        # E.g., /moodle or /drbd/data
    local MOUNTPOINT=${3}     # E.g., /moodle

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

SERVER_TIMESTAMP_FULLPATH="/moodle/html/moodle/.last_modified_time.moodle_on_azure"
LOCAL_TIMESTAMP_FULLPATH="/var/www/html/moodle/.last_modified_time.moodle_on_azure"

# Create a script to sync /moodle/html/moodle (gluster/NFS) and /var/www/html/moodle (local) and set up a minutely cron job
# Should be called by root and only on a VMSS web frontend VM
function setup_html_local_copy_cron_job {
  if [ "$(whoami)" != "root" ]; then
    echo "${0}: Must be run as root!"
    return 1
  fi

  local SYNC_SCRIPT_FULLPATH="/usr/local/bin/sync_moodle_html_local_copy_if_modified.sh"
  mkdir -p $(dirname ${SYNC_SCRIPT_FULLPATH})

  local SYNC_LOG_FULLPATH="/var/log/moodle-html-sync.log"

  cat <<EOF > ${SYNC_SCRIPT_FULLPATH}
#!/bin/bash

sleep \$((\$RANDOM%30))

if [ -f "$SERVER_TIMESTAMP_FULLPATH" ]; then
  SERVER_TIMESTAMP=\$(cat $SERVER_TIMESTAMP_FULLPATH)
  if [ -f "$LOCAL_TIMESTAMP_FULLPATH" ]; then
    LOCAL_TIMESTAMP=\$(cat $LOCAL_TIMESTAMP_FULLPATH)
  else
    logger -p local2.notice -t moodle "Local timestamp file ($LOCAL_TIMESTAMP_FULLPATH) does not exist. Probably first time syncing? Continuing to sync."
    mkdir -p /var/www/html
  fi
  if [ "\$SERVER_TIMESTAMP" != "\$LOCAL_TIMESTAMP" ]; then
    logger -p local2.notice -t moodle "Server time stamp (\$SERVER_TIMESTAMP) is different from local time stamp (\$LOCAL_TIMESTAMP). Start syncing..."
    if [[ \$(find $SYNC_LOG_FULLPATH -type f -size +20M 2> /dev/null) ]]; then
      truncate -s 0 $SYNC_LOG_FULLPATH
    fi
    echo \$(date +%Y%m%d%H%M%S) >> $SYNC_LOG_FULLPATH
    rsync -av --delete /moodle/html/moodle /var/www/html >> $SYNC_LOG_FULLPATH
  fi
else
  logger -p local2.notice -t moodle "Remote timestamp file ($SERVER_TIMESTAMP_FULLPATH) does not exist. Is /moodle mounted? Exiting with error."
  exit 1
fi
EOF
  chmod 500 ${SYNC_SCRIPT_FULLPATH}

  local CRON_DESC_FULLPATH="/etc/cron.d/sync-moodle-html-local-copy"
  cat <<EOF > ${CRON_DESC_FULLPATH}
* * * * * root ${SYNC_SCRIPT_FULLPATH}
EOF
  chmod 644 ${CRON_DESC_FULLPATH}

  # Addition of a hook for custom script run on VMSS from shared mount to allow customised configuration of the VMSS as required
  local CRON_DESC_FULLPATH2="/etc/cron.d/update-vmss-config"
  cat <<EOF > ${CRON_DESC_FULLPATH2}
* * * * * root [ -f /moodle/bin/update-vmss-config ] && /bin/bash /moodle/bin/update-vmss-config
EOF
  chmod 644 ${CRON_DESC_FULLPATH2}
}

LAST_MODIFIED_TIME_UPDATE_SCRIPT_FULLPATH="/usr/local/bin/update_last_modified_time.moodle_on_azure.sh"

# Create a script to modify the last modified timestamp file (/moodle/html/moodle/last_modified_time.moodle_on_azure)
# Should be called by root and only on the controller VM.
# The moodle admin should run the generated script everytime the /moodle/html/moodle directory content is updated (e.g., moodle upgrade, config change or plugin install/upgrade)
function create_last_modified_time_update_script {
  if [ "$(whoami)" != "root" ]; then
    echo "${0}: Must be run as root!"
    return 1
  fi

  mkdir -p $(dirname $LAST_MODIFIED_TIME_UPDATE_SCRIPT_FULLPATH)
  cat <<EOF > $LAST_MODIFIED_TIME_UPDATE_SCRIPT_FULLPATH
#!/bin/bash
echo \$(date +%Y%m%d%H%M%S) > $SERVER_TIMESTAMP_FULLPATH
EOF

  chmod +x $LAST_MODIFIED_TIME_UPDATE_SCRIPT_FULLPATH
}

function run_once_last_modified_time_update_script {
  $LAST_MODIFIED_TIME_UPDATE_SCRIPT_FULLPATH
}

# O365 plugins are released only for 'MOODLE_xy_STABLE',
# whereas we want to support the Moodle tagged versions (e.g., 'v3.4.2').
# This function helps getting the stable version # (for O365 plugin ver.)
# from a Moodle version tag. This utility function recognizes tag names
# of the form 'vx.y.z' only.
function get_o365plugin_version_from_moodle_version {
  local moodleVersion=${1}
  if [[ "$moodleVersion" =~ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    echo "MOODLE_${BASH_REMATCH[1]}${BASH_REMATCH[2]}_STABLE"
  else
    echo $moodleVersion
  fi
}

# For Moodle tags (e.g., "v3.4.2"), the unzipped Moodle dir is no longer
# "moodle-$moodleVersion", because for tags, it's without "v". That is,
# it's "moodle-3.4.2". Therefore, we need a separate helper function for that...
function get_moodle_unzip_dir_from_moodle_version {
  local moodleVersion=${1}
  if [[ "$moodleVersion" =~ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    echo "moodle-${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  else
    echo "moodle-$moodleVersion"
  fi
}

# Long Redis cache Moodle config file generation code moved here
function create_redis_configuration_in_moodledata_muc_config_php
{
    # create redis configuration in /moodle/moodledata/muc/config.php
    cat <<EOF > /moodle/moodledata/muc/config.php
<?php defined('MOODLE_INTERNAL') || die();
 \$configuration = array (
  'siteidentifier' => '7a142be09ea65699e4a6f6ef91c0773c',
  'stores' =>
  array (
    'default_application' =>
    array (
      'name' => 'default_application',
      'plugin' => 'file',
      'configuration' =>
      array (
      ),
      'features' => 30,
      'modes' => 3,
      'default' => true,
      'class' => 'cachestore_file',
      'lock' => 'cachelock_file_default',
    ),
    'default_session' =>
    array (
      'name' => 'default_session',
      'plugin' => 'session',
      'configuration' =>
      array (
      ),
      'features' => 14,
      'modes' => 2,
      'default' => true,
      'class' => 'cachestore_session',
      'lock' => 'cachelock_file_default',
    ),
    'default_request' =>
    array (
      'name' => 'default_request',
      'plugin' => 'static',
      'configuration' =>
      array (
      ),
      'features' => 31,
      'modes' => 4,
      'default' => true,
      'class' => 'cachestore_static',
      'lock' => 'cachelock_file_default',
    ),
    'redis' =>
    array (
      'name' => 'redis',
      'plugin' => 'redis',
      'configuration' =>
      array (
        'server' => '$redisDns',
        'prefix' => 'moodle_prod',
        'password' => '$redisAuth',
        'serializer' => '1',
      ),
      'features' => 26,
      'modes' => 3,
      'mappingsonly' => false,
      'class' => 'cachestore_redis',
      'default' => false,
      'lock' => 'cachelock_file_default',
    ),
    'local_file' =>
    array (
      'name' => 'local_file',
      'plugin' => 'file',
      'configuration' =>
      array (
        'path' => '/tmp/muc/moodle_prod',
        'autocreate' => 1,
      ),
      'features' => 30,
      'modes' => 3,
      'mappingsonly' => false,
      'class' => 'cachestore_file',
      'default' => false,
      'lock' => 'cachelock_file_default',
    ),
  ),
  'modemappings' =>
  array (
    0 =>
    array (
      'store' => 'redis',
      'mode' => 1,
      'sort' => 0,
    ),
    1 =>
    array (
      'store' => 'default_session',
      'mode' => 2,
      'sort' => 0,
    ),
    2 =>
    array (
      'store' => 'default_request',
      'mode' => 4,
      'sort' => 0,
    ),
  ),
  'definitions' =>
  array (
    'core/string' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'string',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/langmenu' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'langmenu',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/databasemeta' =>
    array (
      'mode' => 1,
      'requireidentifiers' =>
      array (
        0 => 'dbfamily',
      ),
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 15,
      'component' => 'core',
      'area' => 'databasemeta',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/eventinvalidation' =>
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'requiredataguarantee' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'eventinvalidation',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/questiondata' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'requiredataguarantee' => false,
      'datasource' => 'question_finder',
      'datasourcefile' => 'question/engine/bank.php',
      'component' => 'core',
      'area' => 'questiondata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/htmlpurifier' =>
    array (
      'mode' => 1,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'htmlpurifier',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/config' =>
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'config',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/groupdata' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'component' => 'core',
      'area' => 'groupdata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/calendar_subscriptions' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'component' => 'core',
      'area' => 'calendar_subscriptions',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/capabilities' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'ttl' => 3600,
      'component' => 'core',
      'area' => 'capabilities',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/yuimodules' =>
    array (
      'mode' => 1,
      'component' => 'core',
      'area' => 'yuimodules',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/observers' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'component' => 'core',
      'area' => 'observers',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/plugin_manager' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'plugin_manager',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursecattree' =>
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'invalidationevents' =>
      array (
        0 => 'changesincoursecat',
      ),
      'component' => 'core',
      'area' => 'coursecattree',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursecat' =>
    array (
      'mode' => 2,
      'invalidationevents' =>
      array (
        0 => 'changesincoursecat',
        1 => 'changesincourse',
      ),
      'ttl' => 600,
      'component' => 'core',
      'area' => 'coursecat',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/coursecatrecords' =>
    array (
      'mode' => 4,
      'simplekeys' => true,
      'invalidationevents' =>
      array (
        0 => 'changesincoursecat',
      ),
      'component' => 'core',
      'area' => 'coursecatrecords',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/coursecontacts' =>
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'simplekeys' => true,
      'ttl' => 3600,
      'component' => 'core',
      'area' => 'coursecontacts',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/repositories' =>
    array (
      'mode' => 4,
      'component' => 'core',
      'area' => 'repositories',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/externalbadges' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'ttl' => 3600,
      'component' => 'core',
      'area' => 'externalbadges',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursemodinfo' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'coursemodinfo',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/userselections' =>
    array (
      'mode' => 2,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'userselections',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/completion' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'ttl' => 3600,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'component' => 'core',
      'area' => 'completion',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursecompletion' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'ttl' => 3600,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'component' => 'core',
      'area' => 'coursecompletion',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/navigation_expandcourse' =>
    array (
      'mode' => 2,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'navigation_expandcourse',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/suspended_userids' =>
    array (
      'mode' => 4,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'suspended_userids',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/roledefs' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'component' => 'core',
      'area' => 'roledefs',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/plugin_functions' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 5,
      'component' => 'core',
      'area' => 'plugin_functions',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/tags' =>
    array (
      'mode' => 4,
      'simplekeys' => true,
      'staticacceleration' => true,
      'component' => 'core',
      'area' => 'tags',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/grade_categories' =>
    array (
      'mode' => 2,
      'simplekeys' => true,
      'invalidationevents' =>
      array (
        0 => 'changesingradecategories',
      ),
      'component' => 'core',
      'area' => 'grade_categories',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/temp_tables' =>
    array (
      'mode' => 4,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'temp_tables',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/tagindexbuilder' =>
    array (
      'mode' => 2,
      'simplekeys' => true,
      'simplevalues' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'ttl' => 900,
      'invalidationevents' =>
      array (
        0 => 'resettagindexbuilder',
      ),
      'component' => 'core',
      'area' => 'tagindexbuilder',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/contextwithinsights' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'core',
      'area' => 'contextwithinsights',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/message_processors_enabled' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 3,
      'component' => 'core',
      'area' => 'message_processors_enabled',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/message_time_last_message_between_users' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simplevalues' => true,
      'datasource' => '\\core_message\\time_last_message_between_users',
      'component' => 'core',
      'area' => 'message_time_last_message_between_users',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/fontawesomeiconmapping' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'core',
      'area' => 'fontawesomeiconmapping',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/postprocessedcss' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => false,
      'component' => 'core',
      'area' => 'postprocessedcss',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/user_group_groupings' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'component' => 'core',
      'area' => 'user_group_groupings',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'availability_grade/scores' =>
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'ttl' => 3600,
      'component' => 'availability_grade',
      'area' => 'scores',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'availability_grade/items' =>
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'ttl' => 3600,
      'component' => 'availability_grade',
      'area' => 'items',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'mod_glossary/concepts' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => false,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'component' => 'mod_glossary',
      'area' => 'concepts',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'repository_googledocs/folder' =>
    array (
      'mode' => 1,
      'simplekeys' => false,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'canuselocalstore' => true,
      'component' => 'repository_googledocs',
      'area' => 'folder',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'repository_onedrive/folder' =>
    array (
      'mode' => 1,
      'simplekeys' => false,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'canuselocalstore' => true,
      'component' => 'repository_onedrive',
      'area' => 'folder',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'repository_skydrive/foldername' =>
    array (
      'mode' => 2,
      'component' => 'repository_skydrive',
      'area' => 'foldername',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'tool_mobile/plugininfo' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'tool_mobile',
      'area' => 'plugininfo',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'tool_monitor/eventsubscriptions' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'component' => 'tool_monitor',
      'area' => 'eventsubscriptions',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'tool_uploadcourse/helper' =>
    array (
      'mode' => 4,
      'component' => 'tool_uploadcourse',
      'area' => 'helper',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'tool_usertours/tourdata' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'tool_usertours',
      'area' => 'tourdata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'tool_usertours/stepdata' =>
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'tool_usertours',
      'area' => 'stepdata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
  ),
  'definitionmappings' =>
  array (
    0 =>
    array (
      'store' => 'local_file',
      'definition' => 'core/coursemodinfo',
      'sort' => 1,
    ),
    1 =>
    array (
      'store' => 'redis',
      'definition' => 'core/groupdata',
      'sort' => 1,
    ),
    2 =>
    array (
      'store' => 'redis',
      'definition' => 'core/roledefs',
      'sort' => 1,
    ),
    3 =>
    array (
      'store' => 'redis',
      'definition' => 'tool_usertours/tourdata',
      'sort' => 1,
    ),
    4 =>
    array (
      'store' => 'redis',
      'definition' => 'repository_onedrive/folder',
      'sort' => 1,
    ),
    5 =>
    array (
      'store' => 'redis',
      'definition' => 'core/message_processors_enabled',
      'sort' => 1,
    ),
    6 =>
    array (
      'store' => 'redis',
      'definition' => 'core/coursecontacts',
      'sort' => 1,
    ),
    7 =>
    array (
      'store' => 'redis',
      'definition' => 'repository_googledocs/folder',
      'sort' => 1,
    ),
    8 =>
    array (
      'store' => 'redis',
      'definition' => 'core/questiondata',
      'sort' => 1,
    ),
    9 =>
    array (
      'store' => 'redis',
      'definition' => 'core/coursecat',
      'sort' => 1,
    ),
    10 =>
    array (
      'store' => 'redis',
      'definition' => 'core/databasemeta',
      'sort' => 1,
    ),
    11 =>
    array (
      'store' => 'redis',
      'definition' => 'core/eventinvalidation',
      'sort' => 1,
    ),
    12 =>
    array (
      'store' => 'redis',
      'definition' => 'core/coursecattree',
      'sort' => 1,
    ),
    13 =>
    array (
      'store' => 'redis',
      'definition' => 'core/coursecompletion',
      'sort' => 1,
    ),
    14 =>
    array (
      'store' => 'redis',
      'definition' => 'core/user_group_groupings',
      'sort' => 1,
    ),
    15 =>
    array (
      'store' => 'redis',
      'definition' => 'core/capabilities',
      'sort' => 1,
    ),
    16 =>
    array (
      'store' => 'redis',
      'definition' => 'core/yuimodules',
      'sort' => 1,
    ),
    17 =>
    array (
      'store' => 'redis',
      'definition' => 'core/observers',
      'sort' => 1,
    ),
    18 =>
    array (
      'store' => 'redis',
      'definition' => 'mod_glossary/concepts',
      'sort' => 1,
    ),
    19 =>
    array (
      'store' => 'redis',
      'definition' => 'core/fontawesomeiconmapping',
      'sort' => 1,
    ),
    20 =>
    array (
      'store' => 'redis',
      'definition' => 'core/config',
      'sort' => 1,
    ),
    21 =>
    array (
      'store' => 'redis',
      'definition' => 'tool_mobile/plugininfo',
      'sort' => 1,
    ),
    22 =>
    array (
      'store' => 'redis',
      'definition' => 'core/plugin_functions',
      'sort' => 1,
    ),
    23 =>
    array (
      'store' => 'redis',
      'definition' => 'core/postprocessedcss',
      'sort' => 1,
    ),
    24 =>
    array (
      'store' => 'redis',
      'definition' => 'core/plugin_manager',
      'sort' => 1,
    ),
    25 =>
    array (
      'store' => 'redis',
      'definition' => 'tool_usertours/stepdata',
      'sort' => 1,
    ),
    26 =>
    array (
      'store' => 'redis',
      'definition' => 'availability_grade/items',
      'sort' => 1,
    ),
    27 =>
    array (
      'store' => 'local_file',
      'definition' => 'core/string',
      'sort' => 1,
    ),
    28 =>
    array (
      'store' => 'redis',
      'definition' => 'core/externalbadges',
      'sort' => 1,
    ),
    29 =>
    array (
      'store' => 'local_file',
      'definition' => 'core/langmenu',
      'sort' => 1,
    ),
    30 =>
    array (
      'store' => 'local_file',
      'definition' => 'core/htmlpurifier',
      'sort' => 1,
    ),
    31 =>
    array (
      'store' => 'redis',
      'definition' => 'core/completion',
      'sort' => 1,
    ),
    32 =>
    array (
      'store' => 'redis',
      'definition' => 'core/calendar_subscriptions',
      'sort' => 1,
    ),
    33 =>
    array (
      'store' => 'redis',
      'definition' => 'core/contextwithinsights',
      'sort' => 1,
    ),
    34 =>
    array (
      'store' => 'redis',
      'definition' => 'tool_monitor/eventsubscriptions',
      'sort' => 1,
    ),
    35 =>
    array (
      'store' => 'redis',
      'definition' => 'core/message_time_last_message_between_users',
      'sort' => 1,
    ),
    36 =>
    array (
      'store' => 'redis',
      'definition' => 'availability_grade/scores',
      'sort' => 1,
    ),
  ),
  'locks' =>
  array (
    'cachelock_file_default' =>
    array (
      'name' => 'cachelock_file_default',
      'type' => 'cachelock_file',
      'dir' => 'filelocks',
      'default' => true,
    ),
  ),
);
EOF
}

# Long fail2ban config command moved here
function config_fail2ban
{
    cat <<EOF > /etc/fail2ban/jail.conf
# Fail2Ban configuration file.
#
# This file was composed for Debian systems from the original one
# provided now under /usr/share/doc/fail2ban/examples/jail.conf
# for additional examples.
#
# Comments: use '#' for comment lines and ';' for inline comments
#
# To avoid merges during upgrades DO NOT MODIFY THIS FILE
# and rather provide your changes in /etc/fail2ban/jail.local
#

# The DEFAULT allows a global definition of the options. They can be overridden
# in each jail afterwards.

[DEFAULT]

# "ignoreip" can be an IP address, a CIDR mask or a DNS host. Fail2ban will not
# ban a host which matches an address in this list. Several addresses can be
# defined using space separator.
ignoreip = 127.0.0.1/8

# "bantime" is the number of seconds that a host is banned.
bantime  = 600

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime = 600
maxretry = 3

# "backend" specifies the backend used to get files modification.
# Available options are "pyinotify", "gamin", "polling" and "auto".
# This option can be overridden in each jail as well.
#
# pyinotify: requires pyinotify (a file alteration monitor) to be installed.
#            If pyinotify is not installed, Fail2ban will use auto.
# gamin:     requires Gamin (a file alteration monitor) to be installed.
#            If Gamin is not installed, Fail2ban will use auto.
# polling:   uses a polling algorithm which does not require external libraries.
# auto:      will try to use the following backends, in order:
#            pyinotify, gamin, polling.
backend = auto

# "usedns" specifies if jails should trust hostnames in logs,
#   warn when reverse DNS lookups are performed, or ignore all hostnames in logs
#
# yes:   if a hostname is encountered, a reverse DNS lookup will be performed.
# warn:  if a hostname is encountered, a reverse DNS lookup will be performed,
#        but it will be logged as a warning.
# no:    if a hostname is encountered, will not be used for banning,
#        but it will be logged as info.
usedns = warn

#
# Destination email address used solely for the interpolations in
# jail.{conf,local} configuration files.
destemail = root@localhost

#
# Name of the sender for mta actions
sendername = Fail2Ban

#
# ACTIONS
#

# Default banning action (e.g. iptables, iptables-new,
# iptables-multiport, shorewall, etc) It is used to define
# action_* variables. Can be overridden globally or per
# section within jail.local file
banaction = iptables-multiport

# email action. Since 0.8.1 upstream fail2ban uses sendmail
# MTA for the mailing. Change mta configuration parameter to mail
# if you want to revert to conventional 'mail'.
mta = sendmail

# Default protocol
protocol = tcp

# Specify chain where jumps would need to be added in iptables-* actions
chain = INPUT

#
# Action shortcuts. To be used to define action parameter

# The simplest action to take: ban only
action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]

# ban & send an e-mail with whois report to the destemail.
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
              %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]

# ban & send an e-mail with whois report and relevant log lines
# to the destemail.
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
               %(mta)s-whois-lines[name=%(__name__)s, dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s", sendername="%(sendername)s"]

# Choose default action.  To change, just override value of 'action' with the
# interpolation to the chosen action shortcut (e.g.  action_mw, action_mwl, etc) in jail.local
# globally (section [DEFAULT]) or per specific section
action = %(action_)s

#
# JAILS
#

# Next jails corresponds to the standard configuration in Fail2ban 0.6 which
# was shipped in Debian. Enable any defined here jail by including
#
# [SECTION_NAME]
# enabled = true

#
# in /etc/fail2ban/jail.local.
#
# Optionally you may override any other parameter (e.g. banaction,
# action, port, logpath, etc) in that section within jail.local

[ssh]

enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 6

[dropbear]

enabled  = false
port     = ssh
filter   = dropbear
logpath  = /var/log/auth.log
maxretry = 6

# Generic filter for pam. Has to be used with action which bans all ports
# such as iptables-allports, shorewall
[pam-generic]

enabled  = false
# pam-generic filter can be customized to monitor specific subset of 'tty's
filter   = pam-generic
# port actually must be irrelevant but lets leave it all for some possible uses
port     = all
banaction = iptables-allports
port     = anyport
logpath  = /var/log/auth.log
maxretry = 6

[xinetd-fail]

enabled   = false
filter    = xinetd-fail
port      = all
banaction = iptables-multiport-log
logpath   = /var/log/daemon.log
maxretry  = 2


[ssh-ddos]

enabled  = false
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 6


# Here we use blackhole routes for not requiring any additional kernel support
# to store large volumes of banned IPs

[ssh-route]

enabled = false
filter = sshd
action = route
logpath = /var/log/sshd.log
maxretry = 6

# Here we use a combination of Netfilter/Iptables and IPsets
# for storing large volumes of banned IPs
#
# IPset comes in two versions. See ipset -V for which one to use
# requires the ipset package and kernel support.
[ssh-iptables-ipset4]

enabled  = false
port     = ssh
filter   = sshd
banaction = iptables-ipset-proto4
logpath  = /var/log/sshd.log
maxretry = 6

[ssh-iptables-ipset6]

enabled  = false
port     = ssh
filter   = sshd
banaction = iptables-ipset-proto6
logpath  = /var/log/sshd.log
maxretry = 6


#
# HTTP servers
#

[apache]

enabled  = false
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 6

# default action is now multiport, so apache-multiport jail was left
# for compatibility with previous (<0.7.6-2) releases
[apache-multiport]

enabled   = false
port      = http,https
filter    = apache-auth
logpath   = /var/log/apache*/*error.log
maxretry  = 6

[apache-noscript]

enabled  = false
port     = http,https
filter   = apache-noscript
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-overflows]

enabled  = false
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 2

# Ban attackers that try to use PHP's URL-fopen() functionality
# through GET/POST variables. - Experimental, with more than a year
# of usage in production environments.

[php-url-fopen]

enabled = false
port    = http,https
filter  = php-url-fopen
logpath = /var/www/*/logs/access_log

# A simple PHP-fastcgi jail which works with lighttpd.
# If you run a lighttpd server, then you probably will
# find these kinds of messages in your error_log:
#   ALERT – tried to register forbidden variable ‘GLOBALS’
#   through GET variables (attacker '1.2.3.4', file '/var/www/default/htdocs/index.php')

[lighttpd-fastcgi]

enabled = false
port    = http,https
filter  = lighttpd-fastcgi
logpath = /var/log/lighttpd/error.log

# Same as above for mod_auth
# It catches wrong authentifications

[lighttpd-auth]

enabled = false
port    = http,https
filter  = suhosin
logpath = /var/log/lighttpd/error.log

[nginx-http-auth]

enabled = false
filter  = nginx-http-auth
port    = http,https
logpath = /var/log/nginx/error.log

# Monitor roundcube server

[roundcube-auth]

enabled  = false
filter   = roundcube-auth
port     = http,https
logpath  = /var/log/roundcube/userlogins


[sogo-auth]

enabled  = false
filter   = sogo-auth
port     = http, https
# without proxy this would be:
# port    = 20000
logpath  = /var/log/sogo/sogo.log


#
# FTP servers
#

[vsftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = vsftpd
logpath  = /var/log/vsftpd.log
# or overwrite it in jails.local to be
# logpath = /var/log/auth.log
# if you want to rely on PAM failed login attempts
# vsftpd's failregex should match both of those formats
maxretry = 6


[proftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = proftpd
logpath  = /var/log/proftpd/proftpd.log
maxretry = 6


[pure-ftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = pure-ftpd
logpath  = /var/log/syslog
maxretry = 6


[wuftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = wuftpd
logpath  = /var/log/syslog
maxretry = 6


#
# Mail servers
#

[postfix]

enabled  = false
port     = smtp,ssmtp,submission
filter   = postfix
logpath  = /var/log/mail.log


[couriersmtp]

enabled  = false
port     = smtp,ssmtp,submission
filter   = couriersmtp
logpath  = /var/log/mail.log


#
# Mail servers authenticators: might be used for smtp,ftp,imap servers, so
# all relevant ports get banned
#

[courierauth]

enabled  = false
port     = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
filter   = courierlogin
logpath  = /var/log/mail.log


[sasl]

enabled  = false
port     = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
filter   = postfix-sasl
# You might consider monitoring /var/log/mail.warn instead if you are
# running postfix since it would provide the same log lines at the
# "warn" level but overall at the smaller filesize.
logpath  = /var/log/mail.log

[dovecot]

enabled = false
port    = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
filter  = dovecot
logpath = /var/log/mail.log

# To log wrong MySQL access attempts add to /etc/my.cnf:
# log-error=/var/log/mysqld.log
# log-warning = 2
[mysqld-auth]

enabled  = false
filter   = mysqld-auth
port     = 3306
logpath  = /var/log/mysqld.log


# DNS Servers


# These jails block attacks against named (bind9). By default, logging is off
# with bind9 installation. You will need something like this:
#
# logging {
#     channel security_file {
#         file "/var/log/named/security.log" versions 3 size 30m;
#         severity dynamic;
#         print-time yes;
#     };
#     category security {
#         security_file;
#     };
# };
#
# in your named.conf to provide proper logging

# !!! WARNING !!!
#   Since UDP is connection-less protocol, spoofing of IP and imitation
#   of illegal actions is way too simple.  Thus enabling of this filter
#   might provide an easy way for implementing a DoS against a chosen
#   victim. See
#    http://nion.modprobe.de/blog/archives/690-fail2ban-+-dns-fail.html
#   Please DO NOT USE this jail unless you know what you are doing.
#[named-refused-udp]
#
#enabled  = false
#port     = domain,953
#protocol = udp
#filter   = named-refused
#logpath  = /var/log/named/security.log

[named-refused-tcp]

enabled  = false
port     = domain,953
protocol = tcp
filter   = named-refused
logpath  = /var/log/named/security.log

# Multiple jails, 1 per protocol, are necessary ATM:
# see https://github.com/fail2ban/fail2ban/issues/37
[asterisk-tcp]

enabled  = false
filter   = asterisk
port     = 5060,5061
protocol = tcp
logpath  = /var/log/asterisk/messages

[asterisk-udp]

enabled  = false
filter	 = asterisk
port     = 5060,5061
protocol = udp
logpath  = /var/log/asterisk/messages


# Jail for more extended banning of persistent abusers
# !!! WARNING !!!
#   Make sure that your loglevel specified in fail2ban.conf/.local
#   is not at DEBUG level -- which might then cause fail2ban to fall into
#   an infinite loop constantly feeding itself with non-informative lines
[recidive]

enabled  = false
filter   = recidive
logpath  = /var/log/fail2ban.log
action   = iptables-allports[name=recidive]
           sendmail-whois-lines[name=recidive, logpath=/var/log/fail2ban.log]
bantime  = 604800  ; 1 week
findtime = 86400   ; 1 day
maxretry = 5
EOF
}
