#!/bin/bash
set -e
set -v
set -x

if [[ -z "$SCRIPT_PHASE" ]]; then
  SCRIPT_PHASE="$1"
fi

if [[ "$SCRIPT_PHASE" -eq "1" ]]; then
cat << EOF > /tmp/sasinstall.env
export INSTALL_USER="${2}"
export azure_storage_account="${3}"
export azure_storage_files_share="${4}"
export azure_storage_files_password="${5}"
export https_location="${6}"
export https_sas_key="${7}"
export depot_uri="${8}"
export count_of_midtier="${9}"
export count_of_metadata="${10}"
export count_of_va_worker="${11}"
export sasPassword="${12}"
export azurePassword="${13}"
export PUBLIC_DNS_NAME="${14}"

export DIRECTORY_NFS_SHARE="/sasshare"
export INSTALL_DIR="/sas/install"
export ANSIBLE_DIR="\${INSTALL_DIR}/ansible"
export INVENTORY_FILE="\${ANSIBLE_DIR}/inventory.ini"
export DEPOT_DUMMY_FOR_QUICK_EXIT_VALUE=""

export DIRECTORY_SSL_JSON_FILE="\${INSTALL_DIR}/setup/ssl"
export FILE_SSL_JSON_FILE="\${DIRECTORY_SSL_JSON_FILE}/loadbalancer.pfx.json"
EOF
else
  . /tmp/sasinstall.env
fi

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
        setupSasShareMountRHEL
        mountSASRaidRHEL
    else
        setupSasShareMountSUSE
        mountSASRaidSUSE
    fi
    setupSUDOForAnsible
    setupSSHKeysForAnsible
    downloadAllFiles
    if [[ "$OS_TYPE" == "SUSE" ]]; then
        installAnsibleSUSE
    else
        installAnsibleRHEL
    fi
    makeAnsibleInventory
    createCertificates
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

setupSasShareMountRHEL() {
    # first step is to install the azure-cli
    yum install -y yum-utils
    echo "Creating the share on the storage account."
    yum install -y rh-python36 gcc time
    /opt/rh/rh-python36/root/usr/bin/pip3 install azure-cli
    /opt/rh/rh-python36/root/usr/bin/az storage share create --name ${azure_storage_files_share} --connection-string "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=${azure_storage_account};AccountKey=${azure_storage_files_password}"

    # second we install the cifs filesystem
    echo "setup cifs"
    cifs_server_fqdn="${azure_storage_account}.file.core.windows.net"
    yum install -y cifs-utils

    # now we create a credentials file to do the mounting of the azure files store.
    if [ ! -d "/etc/smbcredentials" ]; then
        sudo mkdir /etc/smbcredentials
    fi
    chmod 700 /etc/smbcredentials
    if [ ! -f "/etc/smbcredentials/${azure_storage_account}.cred" ]; then
        echo "username=${azure_storage_account}" >> /etc/smbcredentials/${azure_storage_account}.cred
        echo "password=${azure_storage_files_password}" >> /etc/smbcredentials/${azure_storage_account}.cred
    fi
    chmod 600 "/etc/smbcredentials/${azure_storage_account}.cred"

    mkdir -p "${DIRECTORY_NFS_SHARE}"
    echo "//${cifs_server_fqdn}/${azure_storage_files_share} ${DIRECTORY_NFS_SHARE}  cifs defaults,vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,sec=ntlmssp 0 0" >> /etc/fstab

    mount "${DIRECTORY_NFS_SHARE}"
    RET=$?
    if [ "$RET" -ne "0" ]; then
        exit $RET
    fi
    echo "Mounting Successful"

}

setupSasShareMountSUSE() {
    # first step is to install the azure-cli
    sudo zypper install -y curl
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo zypper addrepo --name 'Azure CLI' --check https://packages.microsoft.com/yumrepos/azure-cli azure-cli
    sudo zypper install -y --from azure-cli azure-cli=2.10.1-1.el7
    echo "Creating the share on the storage account."
    az storage share create --name ${azure_storage_files_share} --connection-string "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=${azure_storage_account};AccountKey=${azure_storage_files_password}"

    # second we install the cifs filesystem
    echo "setup cifs"
    cifs_server_fqdn="${azure_storage_account}.file.core.windows.net"

    # now we create a credentials file to do the mounting of the azure files store.
    if [ ! -d "/etc/smbcredentials" ]; then
        sudo mkdir /etc/smbcredentials
    fi
    chmod 700 /etc/smbcredentials
    if [ ! -f "/etc/smbcredentials/${azure_storage_account}.cred" ]; then
        echo "username=${azure_storage_account}" >> /etc/smbcredentials/${azure_storage_account}.cred
        echo "password=${azure_storage_files_password}" >> /etc/smbcredentials/${azure_storage_account}.cred
    fi
    chmod 600 "/etc/smbcredentials/${azure_storage_account}.cred"

    mkdir -p "${DIRECTORY_NFS_SHARE}"
    echo "//${cifs_server_fqdn}/${azure_storage_files_share} ${DIRECTORY_NFS_SHARE}  cifs defaults,vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,sec=ntlmssp 0 0" >> /etc/fstab

    mount "${DIRECTORY_NFS_SHARE}"
    RET=$?
    if [ "$RET" -ne "0" ]; then
        exit $RET
    fi
    echo "Mounting Successful"

}

setupSUDOForAnsible() {
    # remove the requiretty from the sudoers file. Per bug https://bugzilla.redhat.com/show_bug.cgi?id=1020147 this is unnecessary and has been removed on future releases of redhat,
    # so is just a slowdown that denies pipelining and makes the non-tty session from azure extentions break on sudo without faking one (my prefered method is ssh back into the same user, but seriously..)
    sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers
}

setupSSHKeysForAnsible() {
    echo "next we generate the ssh key for ansible"
    # now we create the ssh key and send it over the directory.
    mkdir -p "${DIRECTORY_NFS_SHARE}/setup/ansible_key/"
    su - ${INSTALL_USER}<<END
    ssh-keygen -f /home/${INSTALL_USER}/.ssh/id_rsa -t rsa -N ''
    cp /home/${INSTALL_USER}/.ssh/id_rsa.pub "${DIRECTORY_NFS_SHARE}/setup/ansible_key/id_rsa.pub"
    cat "/home/${INSTALL_USER}/.ssh/id_rsa.pub" >> "/home/${INSTALL_USER}/.ssh/authorized_keys"
    chmod 600 "/home/${INSTALL_USER}/.ssh/authorized_keys"
END
}

downloadAllFiles() {
    # load the code from remote
    echo "$(date)"
    echo "download all files from file tree"
    file_list_url="${https_location}file_tree.txt"
    if [ ! -z "$https_sas_key" ]; then
        file_list_url="${file_list_url}${https_sas_key}"
    fi
    echo "pullin from url: $file_list_url"
    curl --retry 10 --max-time 60 --fail --silent --show-error "$file_list_url" > file_list.txt
    while read line; do
    file_name="$(echo "$line" | cut -f1 -d'|')"
    chmod_attr="$(echo "$line" | cut -f2 -d'|')"
    directory="$(dirname "$line")"
    target_directory="${INSTALL_DIR}/$directory"
    target_file_name="${INSTALL_DIR}/${file_name}"
    target_url="${https_location%"/"}${file_name}"
    if [ ! -z "$https_sas_key" ]; then
        target_url="${target_url}${https_sas_key}"
    fi
    mkdir -p "$target_directory"
    echo "Downloading '$target_file_name' from '$target_url'"
    curl --retry 10 --max-time 60 --fail --silent --show-error "$target_url" > "$target_file_name"
    chmod $chmod_attr "$target_file_name"
    done <file_list.txt
}

installAnsibleSUSE() {
    echo "Installing pip"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    /usr/local/bin/pip install ansible==2.9.2
}

installAnsibleRHEL() {
  curl --retry 10 --max-time 60 --fail --silent --show-error "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
  sudo python get-pip.py
  sudo pip install 'ansible==2.7.10'
}

makeAnsibleInventory() {
    echo "localhost ansible_connection=local" >> $INVENTORY_FILE
    for (( i=0; i<$count_of_midtier; i++)); do
        echo "midtier-${i} ansible_connection=ssh" >> $INVENTORY_FILE
    done
    for (( i=0; i<$count_of_metadata; i++)); do
        echo "metadata-${i} ansible_connection=ssh" >> $INVENTORY_FILE
    done
    for (( i=0; i<$count_of_va_worker; i++)); do
        echo "vaworker-${i} ansible_connection=ssh" >> $INVENTORY_FILE
    done
    echo "vacontroller ansible_connection=ssh" >> $INVENTORY_FILE
    cat  <<END >>$INVENTORY_FILE
[sas_servers:children]
midtier_servers
metadata_servers
va_workers
va_controllers
END
    echo "[midtier_servers]" >> $INVENTORY_FILE
    for (( i=0; i<$count_of_midtier; i++)); do
        echo "midtier-${i}" >> $INVENTORY_FILE
    done
    echo "[metadata_servers]" >> $INVENTORY_FILE
    for (( i=0; i<$count_of_metadata; i++)); do
        echo "metadata-${i}" >> $INVENTORY_FILE
    done
    echo "[va_workers]" >> $INVENTORY_FILE
    for (( i=0; i<$count_of_va_worker; i++)); do
        echo "vaworker-${i}" >> $INVENTORY_FILE
    done
    echo "[va_controllers]" >> $INVENTORY_FILE
    echo "vacontroller" >> $INVENTORY_FILE
}

createCertificates() {
  echo "Create loadbalancer certificate files"
  pushd ${ANSIBLE_DIR}
  export ANSIBLE_LOG_PATH=/tmp/create_load_balancer_cert.log
  time ansible-playbook -v create_load_balancer_cert.yaml -i ${INVENTORY_FILE} -e "SSL_HOSTNAME=${PUBLIC_DNS_NAME}" -e "SSL_WORKING_FOLDER=${DIRECTORY_SSL_JSON_FILE}" -e "ARM_CERTIFICATE_FILE=${FILE_SSL_JSON_FILE}"
  popd
}

waitForSasServers() {
    su - ${INSTALL_USER}<<END
    cd ${ANSIBLE_DIR}
    export ANSIBLE_LOG_PATH=/tmp/step01_wait_for_servers.log
    ansible-playbook -i ${INVENTORY_FILE} -v step01_wait_for_servers.yaml
END
}

handoverToInstallRunner() {
    echo "handover"
    su - ${INSTALL_USER}<<END
    cd ${INSTALL_DIR}/scripts/install_runner
    ./wrapper__base.sh
END
}

## First things first, we are going to map all the inputs to variables
#createEnvironmentFile $@
if [[ "$SCRIPT_PHASE" -eq "1" ]]; then
  main
elif [[ "$SCRIPT_PHASE" -eq "2" ]]; then
  cat "${FILE_SSL_JSON_FILE}.1" | tr -d '\n'
elif [[ "$SCRIPT_PHASE" -eq "3" ]]; then
  cat "${FILE_SSL_JSON_FILE}.2" | tr -d '\n'
elif [[ "$SCRIPT_PHASE" -eq "4" ]]; then
  waitForSasServers
  handoverToInstallRunner
fi
