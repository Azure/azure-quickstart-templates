#!/bin/bash
set -e
set -x
set -v

createEnvironmentFile() {
cat << EOF > /tmp/sasinstall.env
export INSTALL_USER="${1}"
export azure_storage_account="${2}"
export azure_storage_files_share="${3}"
export azure_storage_files_password="${4}"

export CIFS_MOUNT_POINT="/sasshare"
export CIFS_SEMAPHORE_DIR="\${CIFS_MOUNT_POINT}/setup/readiness_flags"
export CIFS_ANSIBLE_KEYS="\${CIFS_MOUNT_POINT}/setup/ansible_key"
EOF
}

main() {
    echo "NON JUMP RUN"
    . /tmp/sasinstall.env
    # find type of server
    if [ -f /etc/redhat-release ]; then
        OS_TYPE="RHEL"
    else
        OS_TYPE="SUSE"
    fi
    if [[ "$OS_TYPE" == "RHEL" ]]; then
        mountSASRaidRHEL
        setupSASShareMountRHEL
        disableSelinuxRHEL
    else
        # Workaround for SUSE registration issue
        sed -i.bak -e 's/dataProvider/#dataProvider/g' /etc/regionserverclnt.cfg
        echo "dataProvider = /usr/bin/azuremetadata --api 2019-08-15 --subscriptionId --billingTag --xml" >>/etc/regionserverclnt.cfg
        registercloudguest --force-new
        # End workaround        
        mountSASRaidSUSE
        setupSASShareMountSUSE
    fi
    setupSUDOForAnsible
    setupSSHKeysForAnsible
}

mountSASRaidSUSE() {
    # Sleep 30 seconds to allow network to stabalize before attempting package install
    sleep 30
    zypper install -y mdadm
    n=$(find /dev/disk/azure/scsi1/ -name "lun*"|wc -l)
    n="${n//\ /}"
    mdadm --create /dev/md0 --force --level=stripe --raid-devices=$n /dev/disk/azure/scsi1/lun*
    mkfs.xfs /dev/md0
    mkdir /sas
    echo "$(blkid /dev/md0 | cut -d ' ' -f 2) /sas xfs defaults 0 0" | tee -a /etc/fstab
    mount /sas
}

mountSASRaidRHEL() {
    # Sleep 30 seconds to allow network to stabalize before attempting package install
    sleep 30
    yum install -y mdadm
    n=$(find /dev/disk/azure/scsi1/ -name "lun*"|wc -l)
    n="${n//\ /}"
    mdadm --create /dev/md0 --force --level=stripe --raid-devices=$n /dev/disk/azure/scsi1/lun*
    mkfs.xfs /dev/md0
    mkdir /sas
    echo "$(blkid /dev/md0 | cut -d ' ' -f 2) /sas xfs defaults 0 0" | tee -a /etc/fstab
    mount /sas
}

setupSASShareMountRHEL() {
    yum install -y yum-utils
    yum install -y cifs-utils time

    cifs_server_fqdn="${azure_storage_account}.file.core.windows.net"

    if [ ! -d "/etc/smbcredentials" ]; then
        sudo mkdir /etc/smbcredentials
    fi
    chmod 700 /etc/smbcredentials
    if [ ! -f "/etc/smbcredentials/${azure_storage_account}.cred" ]; then
        echo "username=${azure_storage_account}" >> /etc/smbcredentials/${azure_storage_account}.cred
        echo "password=${azure_storage_files_password}" >> /etc/smbcredentials/${azure_storage_account}.cred
    fi
    chmod 600 "/etc/smbcredentials/${azure_storage_account}.cred"

    mkdir -p "${CIFS_MOUNT_POINT}"
    echo "//${cifs_server_fqdn}/${azure_storage_files_share} ${CIFS_MOUNT_POINT}  cifs defaults,vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,sec=ntlmssp 0 0" >> /etc/fstab
    set +e
    mount "${CIFS_MOUNT_POINT}"
    RET=$?
    while [ "$RET" -gt "0" ]; do
        echo "Waiting 5 seconds for mount to be possible"
        sleep 5
        mount "${CIFS_MOUNT_POINT}"
        RET=$?
    done
    set -e
    echo "Mounting Successful"
    mkdir -p "${CIFS_MOUNT_POINT}/backup"
    ln -s "${CIFS_MOUNT_POINT}/backup" /backups
}
setupSASShareMountSUSE() {
    cifs_server_fqdn="${azure_storage_account}.file.core.windows.net"

    if [ ! -d "/etc/smbcredentials" ]; then
        sudo mkdir /etc/smbcredentials
    fi
    chmod 700 /etc/smbcredentials
    if [ ! -f "/etc/smbcredentials/${azure_storage_account}.cred" ]; then
        echo "username=${azure_storage_account}" >> /etc/smbcredentials/${azure_storage_account}.cred
        echo "password=${azure_storage_files_password}" >> /etc/smbcredentials/${azure_storage_account}.cred
    fi
    chmod 600 "/etc/smbcredentials/${azure_storage_account}.cred"

    mkdir -p "${CIFS_MOUNT_POINT}"
    echo "//${cifs_server_fqdn}/${azure_storage_files_share} ${CIFS_MOUNT_POINT}  cifs defaults,vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,sec=ntlmssp 0 0" >> /etc/fstab
    set +e
    mount "${CIFS_MOUNT_POINT}"
    RET=$?
    while [ "$RET" -gt "0" ]; do
        echo "Waiting 5 seconds for mount to be possible"
        sleep 5
        mount "${CIFS_MOUNT_POINT}"
        RET=$?
    done
    set -e
    echo "Mounting Successful"
    mkdir -p "${CIFS_MOUNT_POINT}/backup"
    ln -s "${CIFS_MOUNT_POINT}/backup" /backups
}

setupSUDOForAnsible() {
    # remove the requiretty from the sudoers file. Per bug https://bugzilla.redhat.com/show_bug.cgi?id=1020147 this is unnecessary and has been removed on future releases of redhat, 
    # so is just a slowdown that denies pipelining and makes the non-tty session from azure extentions break on sudo without faking one (my prefered method is ssh back into the same user, but seriously..)
    sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers
}

setupSSHKeysForAnsible() {
    wait_count=0
    stop_waiting_count=600
    ANSIBLE_AUTHORIZED_KEY_FILE="${CIFS_ANSIBLE_KEYS}/id_rsa.pub"
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

## First things first, we are going to map all the inputs to variables for postarity
createEnvironmentFile $@


main
