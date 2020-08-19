#!/bin/bash

# Common functions definitions

function check_fileServerType_param
{
    local fileServerType=$1
    if [ "$fileServerType" != "gluster" -a "$fileServerType" != "azurefiles" -a "$fileServerType" != "nfs" ]; then
        echo "Invalid fileServerType ($fileServerType) given. Only 'gluster', 'azurefiles' or 'nfs' are allowed. Exiting"
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

function create_filesystem_with_raid {
    local MOUNTPOINT=${1}     # E.g., /moodle
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
    local NFS_SERVER=${1}     # E.g., jumpbox-vm-ab12cd
    local NFS_DIR=${2}        # E.g., /moodle
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
