#!/bin/bash

#########################################################
# Script Name: couchbase_ansible.sh
# Author: Gonzalo Ruiz
# Version: 0.2
# Date Created:           01st Marh 2015
# Last Modified:          29th November 2015
# Last Modified By:       Gonzalo Ruiz
# Description:
#  This script automates the installation of a multi VM Couchbase cluster using Ansible. It will
#     Configur this VM as an Ansible Controller
#     Configure SSH keys
#     Configure STorage on all the VMs using an Ansible Playbook
#     Download Couchbase Ansible roles from Ansible Galaxy
#     Install Couchbase using the couchbase.couchbase-server Ansible role
#
# Parameters :
#  1 - i: IP Pattern
#  2 - n: Number of nodes
#  3 - r: Configure RAID
#  4 - f: filesystem : ext4 or xfs
#  5 - u: Couchbase user
#  6 - p: Couchbase password
# Note :
# This script has only been tested on CentOS 6.5 and Ubuntu 12.04 LTS
#########################################################

#---BEGIN VARIABLES---
IP_ADDRESS_SPACE=''
NUMBER_OF_NODES=''
NODE_LIST_IPS=()
CONFIGURE_RAID=''
FILE_SYSTEM=''
USER_NAME=''
USER_PASSWORD=''
TEMPLATE_ROLE='couchbase'
START_IP_INDEX=0
CB_USER=''
CB_PWD=''
CB_WEB_FQDN=''
CB_WEB_PORT=''
MOUNTPOINT='/datadrive'

SSH_AZ_ACCOUNT_NAME=''
SSH_AZ_ACCOUNT_KEY=''


 function usage()
 {
    echo "INFO:"
    echo "Usage: configure-ansible.sh [-i IP_ADDRESS_SPACE ] [-n NUMBER_OF_NODES ] [-r CONFIGURE_RAID ] [-f FILE_SYSTEM] [-u CB_USER] [-p CB_PWD] [-m] [-q] [-o] [-a] [-k]"
    echo "The -i (ipAddressSpace) parameters specifies the starting IP space for the vms.For instance if you specify 10.0.2.2, and 3 nodes, the script will find for the VMS 10.0.2.20, 10.0.2.21,10.0.2.22.Plase note that Azure reserves the first 4 IPs, so you will have to specify an IP space in which IP x.x.x0 is available"
    echo "The -n (numberOfNodes) parameter specifies the number of VMs"
    echo "The -r (configureRAID) parameter specifies whether you want to create a RAID with all the available data disks.Allowed values : true or false"
    echo "The -f (fileSystem) parameter specifies the file system you want to use.Allowed values : ext4 or xfs"
    echo "The -u (couchbaseUser) parameter specifies the Couchbase Admin user"
    echo "The -p (couchbasePassword) parameter specifies the Couchbase Password "
    echo "The -m (couchbaseAllocatedMemory) parameter specifies the percentage of memory allocated to Couchbase "
    echo "The -q (couchbaseFQDN) parameter specifies the fully qualified named assigned to the Azure public IP"
    echo "The -o (couchbaseAdminPort) parameter specifies the public Admin Port for the Couchbase Web Console"
    echo "The -a (azureStorageAccountName) parameter specifies the name of the storage account that contains the private keys"
    echo "The -k (azureStorageAccountKey) parameter specifies the key of the private storage account that contains the private keys"
}


function log()
{
    # If you want to enable this logging add a un-comment the line below and add your account id
    #curl -X POST -H "content-type:text/plain" --data-binary "${HOSTNAME} - $1" https://logs-01.loggly.com/inputs/<key>/tag/es-extension,${HOSTNAME}
    echo "$1"
}


#---PARSE AND VALIDATE PARAMETERS---
if [ $# -ne 22 ]; then
    log "ERROR:Wrong number of arguments specified. Parameters received $#. Terminating the script."
    usage
    exit 1
fi

while getopts :i:n:r:f:u:p:m:q:o:a:k: optname; do
    log "INFO:Option $optname set with value ${OPTARG}"
  case $optname in
    i) # IP address space
      IP_ADDRESS_SPACE=${OPTARG}
      ;;
    n) # Number of VMS
      NUMBER_OF_NODES=${OPTARG}
      IDX=${START_IP_INDEX}
      while [ "${IDX}" -lt "${NUMBER_OF_NODES}" ];
      do
        NODE_LIST_IPS[$IDX]="${IP_ADDRESS_SPACE}${IDX}"
        IDX=$((${IDX} + 1))
      done
      ;;
    r) # Configure RAID
      CONFIGURE_RAID=${OPTARG}
      if [[ "${CONFIGURE_RAID}" != "true" &&  "${CONFIGURE_RAID}" != "false" ]] ; then
          log "ERROR:Configure RAID (-r) value ${CONFIGURE_RAID} not allowed"
          usage
          exit 1
      fi
      ;;
    f) # File system  : ext4 or xfs
      FILE_SYSTEM=${OPTARG}
      if [[ "${FILE_SYSTEM}" != "ext4" &&  "${FILE_SYSTEM}" != "xfs" ]] ; then
          log "ERROR:File system (-f) ${FILE_SYSTEM} not allowed"
          usage
          exit 1
      fi
      ;;
    u) # COUCHBASE ADMIN USER
      CB_USER=${OPTARG}
      ;;
    p) # COUCHBASE ADMIN PASSWORD
      CB_PWD=${OPTARG}
      ;;
    m) # RAM Allocation Percentage
      MEMORY_ALLOCATION_PERCENTAGE=${OPTARG}
      ;;
    q) # FQDN -REMOVE LAST POINT
      CB_WEB_FQDN=${OPTARG}
      CB_WEB_FQDN=$(echo ${CB_WEB_FQDN} | sed s'/[.]$//' )
      ;;
    o) # Couchbase Web Console Port
      CB_WEB_PORT=${OPTARG}
      ;;
    a) # Azure Private Storage Account Name- SSH Keys
      SSH_AZ_ACCOUNT_NAME=${OPTARG}
      ;;
    k) # Azure Private Storage Account Key - SSH Keys
      SSH_AZ_ACCOUNT_KEY=${OPTARG}
      ;;

    \?) #Invalid option - show help
      log "ERROR:Option -${BOLD}$OPTARG${NORM} not allowed."
      usage
      exit 1
      ;;
  esac
done



function check_OS()
{
    OS=`uname`
    KERNEL=`uname -r`
    MACH=`uname -m`


    if [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`cat /etc/redhat-release |sed s/\ release.*//`
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            if [ -f /etc/lsb-release ] ; then
                 DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
                 PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                 REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            fi
    fi

            OS=$OS
            DistroBasedOn=$DistroBasedOn
            readonly OS
            readonly DIST
            readonly DistroBasedOn
            readonly PSUEDONAME
            readonly REV
            readonly KERNEL
            readonly MACH

            log "INFO: Detected OS : ${OS}  Distribution: ${DIST}-${DistroBasedOn}-${PSUEDONAME} Revision: ${REV} Kernel: ${KERNEL}-${MACH}"

}


function install_packages_ubuntu()
{


    apt-get --yes --force-yes install software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt-get --yes --force-yes update
    apt-get --yes --force-yes install ansible

    # install Git
    apt-get --yes --force-yes install git

    # install nginx - Reverse proxy for the Couchbase admin console
    apt-get --yes --force-yes install nginx


 }

 function install_packages_centos()
 {

    # install EPEL Packages - sshdpass
    #wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    #rpm -ivh epel-release-6-8.noarch.rpm
    yum -y install epel-release
    # install ansible
    yum -y install ansible
    yum -y install  libselinux-python

    # install Git
    yum -y install git

    # install nginx - Reverse proxy for the Couchbase admin console
    yum -y install nginx
 }


function get_sshkeys()
 {
    apt-get -y update

    apt-get -y install python-pip
    pip install azure-storage

    apt-get -y update

    # Download both Private and Public Key
    python GetSSHFromPrivateStorageAccount.py ${SSH_AZ_ACCOUNT_NAME} ${SSH_AZ_ACCOUNT_KEY} id_rsa
    python GetSSHFromPrivateStorageAccount.py ${SSH_AZ_ACCOUNT_NAME} ${SSH_AZ_ACCOUNT_KEY} id_rsa.pub

}

function configure_ssh()
{

    # copy ssh private key
    mkdir -p ~/.ssh
    mv id_rsa ~/.ssh

    # set permissions
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_rsa

    # copy root ssh key
    cat id_rsa.pub >> ~/.ssh/authorized_keys
    rm id_rsa.pub

    # set permissions
    chmod 600 ~/.ssh/authorized_keys

    if [[ "${DIST}" == "Ubuntu" ]]; then
        #restart sshd service - Ubuntu
        service ssh restart

    elif [[ "${DIST}" == "CentOS" ]] ; then
        # configure SELinux
        restorecon -Rv ~/.ssh

        #restart sshd service - CentOS
        service sshd restart
    fi

}


 function configure_ansible()
 {
    # Copy ansible hosts file
    ANSIBLE_HOST_FILE=/etc/ansible/hosts
    ANSIBLE_CONFIG_FILE=/etc/ansible/ansible.cfg

    mv ${ANSIBLE_HOST_FILE} ${ANSIBLE_HOST_FILE}.backup
    mv ${ANSIBLE_CONFIG_FILE} ${ANSIBLE_CONFIG_FILE}.backup

    # Accept ssh keys by default
    printf  "[defaults]\nhost_key_checking = False\n\n" >> "${ANSIBLE_CONFIG_FILE}"
    # Shorten the ControlPath to avoid errors with long host names , long user names or deeply nested home directories
    echo  $'[ssh_connection]\ncontrol_path = ~/.ssh/ansible-%%h-%%r' >> "${ANSIBLE_CONFIG_FILE}"
    echo "\nscp_if_ssh=True" >> "${ANSIBLE_CONFIG_FILE}"
    # Generate a new ansible host file
    printf  "[${TEMPLATE_ROLE}]\n" >> "${ANSIBLE_HOST_FILE}"
    printf  "${IP_ADDRESS_SPACE}0 node_role=primary\n" >> "${ANSIBLE_HOST_FILE}"
    printf  "${IP_ADDRESS_SPACE}[1:$(($NUMBER_OF_NODES - 1))] node_role=additional\n" >> "${ANSIBLE_HOST_FILE}"


    # Validate ansible configuration
    ansible ${TEMPLATE_ROLE} -m ping -v


 }


 function configure_storage()
 {
    log "INFO: Configuring Storage "
    log "WARNING: This process is not incremental, don't use it if you don't want to lose your existing storage configuration"

    # Run ansible template to configure Storage : Create RAID and Configure Filesystem
    ansible-playbook InitStorage_RAID.yml  --extra-vars "target=${TEMPLATE_ROLE} file_system=${FILE_SYSTEM}" -v

 }


function install_couchbase()
{
   # Calculate Memory assigned to Couchbase
   # COUCHBASE_MEMORY=$(($(free|awk '/^Mem:/{print $2}')/1024*80/100))

   # Role copied in /etc/ansible/roles/couchbase.couchbase-server/
   ansible-galaxy install couchbaselabs.couchbase-server -p .
   log "INFO: ******** Installing Couchbase "


   # Run ansible template to Install and Initialise Couchbase
   ansible-playbook couchbase_setup.yml  --extra-vars "target=${TEMPLATE_ROLE} file_system=${FILE_SYSTEM} couchbase_server_admin=${CB_USER} couchbase_server_password=${CB_PWD} mount_point=${MOUNTPOINT} memory_allocation_percentage=${MEMORY_ALLOCATION_PERCENTAGE}" -v

}

function configure_nginx()
{
  # Create nginx folders
  mkdir -p /etc/nginx/ssl
  mkdir -p /etc/nginx/sites-enabled/

  # Generate Self-signed certificate for the web console
  openssl req -x509 -nodes -days 1095 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=US/ST=WA/L=Redmond/O=IT/CN=${CB_WEB_FQDN}"

  # CentOS - Configure SELinux & Update /etc/nginx/nginx.conf
  if [[ "${DIST}" == "CentOS" ]];  then
    yum -y install policycoreutils-python
    semanage port -a -t http_port_t -p tcp 16195
    setsebool -P allow_ypbind 1


    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.back
    sed -i '/http {/a   \    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
  fi

  # Generate the nginx Config file
  cat nginx | sed "s/{PORT}/${CB_WEB_PORT}/" | sed "s/{FQDN}/${CB_WEB_FQDN}/" | sed "s/{CB_SRV1}/${NODE_LIST_IPS[0]}/" >> /etc/nginx/sites-enabled/couchbaseconsole


  # Start nginx service
  service nginx start
  service nginx restart




}


InitializeVMs()
{
    check_OS

    get_sshkeys
    configure_ssh

    if [[ "${DIST}" == "Ubuntu" ]];
    then
        log "INFO:Installing Ansible for Ubuntu"
        install_packages_ubuntu
    elif [[ "${DIST}" == "CentOS" ]] ; then
        log "INFO:Installing Ansible for CentOS"
        install_packages_centos
    else
       log "ERROR:Unsupported OS ${ DIST}"
       exit 2
    fi


    configure_ansible
    configure_storage
    install_couchbase
    # nginx will be a reverse proxy for the Couchbase admin console
    # It will use a self-signed certificate to expose the Web Admin console over https
    configure_nginx


}

InitializeVMs
