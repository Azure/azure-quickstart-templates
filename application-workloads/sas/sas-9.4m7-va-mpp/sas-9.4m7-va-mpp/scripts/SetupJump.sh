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
export azure_subscription="${15}"
export azure_resource_group="${16}"
export planfile_uri="${17}"
export HADOOP_VERSION="${18}"
export HADOOP_HOME="${19}"
export HDAT_HOME="${20}"
export endpoint_ip="${21}"
export sasFolder="${22}"

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
    echo "JUMP RUN"
    . /tmp/sasinstall.env
    # find type of server and handle some OS-specific setups
    if [ -f /etc/redhat-release ]; then
        # Kludge provided by Azure to resolve expired certificate issue
        sudo yum update -y --disablerepo='*' --enablerepo='*microsoft*'
        # Install necessary packages
        yum install -y yum-utils
        yum install -y python3 gcc time
        yum install -y nfs-utils
        yum install -y mdadm

        installAnsibleRHEL
    else
        zypper install -y mdadm

        installAnsibleSUSE
    fi

    setupSASShareMount

    # Sleep 30 seconds to allow network to stabilize
    sleep 30

    mountSASRaid
    setupSUDOForAnsible
    setupSSHKeysForAnsible
    downloadAllFiles
    makeAnsibleInventory
    createCertificates
    downloadHadoop
    installAzureCLI
}

mountSASRaid() {
    n=$(find /dev/disk/azure/scsi1/ -name "lun*"|wc -l)
    n="${n//\ /}"
    mdadm --create /dev/md0 --force --level=stripe --raid-devices=$n /dev/disk/azure/scsi1/lun*
    mkfs.xfs /dev/md0
    mkdir /sas
    echo "$(blkid /dev/md0 | cut -d ' ' -f 2) /sas xfs defaults 0 0" | tee -a /etc/fstab
    mount /sas
}

setupSASShareMount() {
    # Update /etc/hosts with private endpoint IP
    echo "$endpoint_ip $azure_storage_account.file.core.windows.net" | tee -a /etc/hosts

    # Create the share folder
    mkdir -p "${DIRECTORY_NFS_SHARE}"

    # Mount the share
    sudo mount -t nfs $azure_storage_account.file.core.windows.net:/$azure_storage_account/sasshare ${DIRECTORY_NFS_SHARE} -o "vers=4,minorversion=1,actimeo=5,sec=sys"

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
    su - ${INSTALL_USER}<<END
    mkdir -p "${DIRECTORY_NFS_SHARE}/setup/ansible_key/"
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
    chmod_attr="$(echo "$line" | sed 's/\r$//' | cut -f2 -d'|')"
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

downloadHadoop() {
    echo "Downloading Hadoop"
    curl "https://downloads.apache.org/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" --output "/tmp/hadoop-${HADOOP_VERSION}.tar.gz"
    su - ${INSTALL_USER}<<END
    cp "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" /sasshare
END
}

installAnsibleSUSE() {
    echo "Installing pip"
    curl https://bootstrap.pypa.io/pip/get-pip.py -o get-pip.py
    python get-pip.py
    /usr/local/bin/pip install ansible==2.9.2
}

installAnsibleRHEL() {
  curl --retry 10 --max-time 60 --fail --silent --show-error "https://bootstrap.pypa.io/pip/get-pip.py" -o "get-pip.py"
  sudo python3 get-pip.py
  sudo /usr/local/bin/pip install 'ansible==2.7.10'
}

installAzureCLI() {
    /usr/local/bin/pip install azure-cli
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
    echo "[midtier_head]" >> $INVENTORY_FILE
    echo "midtier-0" >> $INVENTORY_FILE
    echo "[midtier_nodes]" >> $INVENTORY_FILE
    for (( i=1; i<$count_of_midtier; i++)); do
      echo "midtier-${i}" >> $INVENTORY_FILE
    done
    echo "[midtier_servers]" >> $INVENTORY_FILE
    for (( i=0; i<$count_of_midtier; i++)); do
        echo "midtier-${i}" >> $INVENTORY_FILE
    done
    echo "[metadata_head]" >> $INVENTORY_FILE
    echo "metadata-0" >> $INVENTORY_FILE
    echo "[metadata_nodes]" >> $INVENTORY_FILE
    for (( i=1; i<$count_of_metadata; i++)); do
      echo "metadata-${i}" >> $INVENTORY_FILE
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

startSASInstall() {
    export uriParts=(${depot_uri//\?/ })
    if [ "${depot_uri}" != "${DEPOT_DUMMY_FOR_QUICK_EXIT_VALUE}" ]; then
        export depot_uri_mod="${uriParts[0]}/*?${uriParts[1]}"
    else
        export depot_uri_mod=""
    fi
    su - ${INSTALL_USER}<<END
    pushd ${ANSIBLE_DIR}
	if [ "${depot_uri_mod}" != "${DEPOT_DUMMY_FOR_QUICK_EXIT_VALUE}" ]; then
    	export ANSIBLE_LOG_PATH=/tmp/download_mirror_and_licenses.log
    	ansible-playbook -i ${INVENTORY_FILE} \
    		-e "DEPOT_DOWNLOAD_LOCATION=$depot_uri_mod" \
    		-e "LICENSE_DOWNLOAD_LOCATION=$license_file_uri" \
    		-e "PLANFILE_DOWNLOAD_LOCATION=$planfile_uri" \
    		-e "PRIMARY_USER=$INSTALL_USER" \
    		-vvv download_mirror_and_licenses.yaml
    fi
    export ANSIBLE_LOG_PATH=/tmp/wait_for_servers.log
    ansible-playbook -i ${INVENTORY_FILE} -vvv wait_for_servers.yaml
    export ANSIBLE_LOG_PATH=/tmp/install_os_updates.log
    ansible-playbook -i ${INVENTORY_FILE} -vvv install_os_updates.yaml
    popd
    pushd ${INSTALL_DIR}/scripts/install_runner
    ./wrapper__base.sh
    popd
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
  startSASInstall
fi
