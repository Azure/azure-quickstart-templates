#!/bin/bash
set -e
set -x
set -v

createEnvironmentFile() {
cat << EOF > /tmp/sasinstall.env
export instance_type="${1}"
export INSTALL_USER="${2}"
export azure_storage_account="${3}"
export azure_storage_files_share="${4}"
export azure_storage_files_password="${5}"
export endpoint_ip="${6}"
export sasFolder="${7}"

export NFS_MOUNT_POINT="/sasshare"
export BACKUP_NFS_MOUNT_POINT="/backups"
export NFS_SEMAPHORE_DIR="\${NFS_MOUNT_POINT}/setup/readiness_flags"
export NFS_ANSIBLE_KEYS="\${NFS_MOUNT_POINT}/setup/ansible_key"
EOF
}

main() {
    echo "NON JUMP RUN"
    . /tmp/sasinstall.env
    # find type of server and handle some OS-specific setups
    if [ -f /etc/redhat-release ]; then
            # Install necessary packages
        yum install -y yum-utils
        yum install -y rh-python36 gcc time
        yum install -y nfs-utils
        yum install -y mdadm

        disableSelinuxRHEL
    else
        zypper install -y mdadm
    fi

    setupSASShareMount

    # Sleep 30 seconds to allow network to stabilize
    sleep 30

    mountSASRaid
    setupSUDOForAnsible
    setupSSHKeysForAnsible
    startATdaemon
}

mountSASRaid() {
    n=$(find /dev/disk/azure/scsi1/ -name "lun*"|wc -l)
    n="${n//\ /}"
    mdadm --create /dev/md0 --force --level=stripe --raid-devices=$n /dev/disk/azure/scsi1/lun*
    mkfs.xfs /dev/md0
    mkdir "${sasFolder}"
    echo "$(blkid /dev/md0 | cut -d ' ' -f 2) ${sasFolder} xfs defaults 0 0" | tee -a /etc/fstab
    set +e
    mount "${sasFolder}"
    RET=$?
    while [ "$RET" -gt "0" ]; do
        echo "Waiting 5 seconds for mount to be possible"
        sleep 5
        mount "${sasFolder}"
        RET=$?
    done
    set -e
    echo "Mounting Successful for ${sasFolder}"
}

setupSASShareMount() {
    # Update /etc/hosts with private endpoint IP
    echo "$endpoint_ip $azure_storage_account.file.core.windows.net" | tee -a /etc/hosts
    # Create the share folder
    mkdir -p "${NFS_MOUNT_POINT}"
    # Adding the share folder to fstab
    echo "$azure_storage_account.file.core.windows.net:/$azure_storage_account${NFS_MOUNT_POINT} ${NFS_MOUNT_POINT} nfs vers=4,minorversion=1,sec=sys,actimeo=5" | tee -a /etc/fstab
    # Mount the share folder
    set +e
    mount "${NFS_MOUNT_POINT}"
    RET=$?
    while [ "$RET" -gt "0" ]; do
        echo "Waiting 5 seconds for mount to be possible"
        sleep 5
        mount "${NFS_MOUNT_POINT}"
        RET=$?
    done
    set -e
    echo "Mounting Successful for ${NFS_MOUNT_POINT}"

    # Create the backups folder for metadata nodes - this is a separate share only for metadata nodes
    if [[ "${instance_type}" == "metadata" ]]; then
       mkdir -p "${BACKUP_NFS_MOUNT_POINT}"
       echo "$azure_storage_account.file.core.windows.net:/$azure_storage_account${BACKUP_NFS_MOUNT_POINT} ${BACKUP_NFS_MOUNT_POINT} nfs vers=4,minorversion=1,sec=sys,noac" | tee -a /etc/fstab
       set +e
       mount "${BACKUP_NFS_MOUNT_POINT}"
       RET=$?
       while [ "$RET" -gt "0" ]; do
           echo "Waiting 5 seconds for mount to be possible"
           sleep 5
           mount "${BACKUP_NFS_MOUNT_POINT}"
           RET=$?
       done
       set -e
       echo "Mounting Successful for ${BACKUP_NFS_MOUNT_POINT}"
    fi
}

setupSUDOForAnsible() {
    # remove the requiretty from the sudoers file. Per bug https://bugzilla.redhat.com/show_bug.cgi?id=1020147 this is unnecessary and has been removed on future releases of redhat,
    # so is just a slowdown that denies pipelining and makes the non-tty session from azure extentions break on sudo without faking one (my prefered method is ssh back into the same user, but seriously..)
    sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers
}

setupSSHKeysForAnsible() {
    wait_count=0
    stop_waiting_count=900
    ANSIBLE_AUTHORIZED_KEY_FILE="${NFS_ANSIBLE_KEYS}/id_rsa.pub"
    while [ ! -e "$ANSIBLE_AUTHORIZED_KEY_FILE" ]; do
        echo "waiting 5 seconds for key to come around"
        sleep 1
        if [ "$((wait_count++))" -gt "$stop_waiting_count" ]; then
            exit 1
        fi
    done
    su - ${INSTALL_USER} <<END
    mkdir -p /home/${INSTALL_USER}/.ssh
    cat "$ANSIBLE_AUTHORIZED_KEY_FILE" >> "/home/${INSTALL_USER}/.ssh/authorized_keys"
    chmod 600 "/home/${INSTALL_USER}/.ssh/authorized_keys"
END
}

disableSelinuxRHEL() {
    # disable for this session
    setenforce 0
    # disable after restarts
    sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && cat /etc/sysconfig/selinux
}

startATdaemon() {
    sudo chkconfig atd on
    sudo service atd start
}

## First things first, we are going to map all the inputs to variables for postarity
createEnvironmentFile $@


main
