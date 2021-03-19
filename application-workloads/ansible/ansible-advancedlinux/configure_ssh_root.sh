#!/bin/bash

#########################################################
# Script Name: configure_ssh_root.sh
# Author: Gonzalo Ruiz
# Version: 0.1
# Date Created:           01st Marh 2015
# Last Modified:          31st December 17:26 GMT
# Last Modified By:       Gonzalo Ruiz
# Description:
#  This script configures root login over ssh using keys.
#  The .pub key must file on the same folder
# Parameters :
#
# Note :
# This script has only been tested on CentOS 6.5 and Ubuntu 12.04 LTS
#########################################################

#---BEGIN VARIABLES---
SSH_AZ_ACCOUNT_NAME=''
SSH_AZ_ACCOUNT_KEY=''


 function usage()
 {
    echo "INFO:"
    echo "Usage: configure_ssh_root [-a] [-k]"
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
if [ $# -ne 4 ]; then
    log "ERROR:Wrong number of arguments specified. Parameters received $#. Terminating the script."
    usage
    exit 1
fi

while getopts :a:k: optname; do
    log "INFO:Option $optname set with value ${OPTARG}"
  case $optname in
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

#---PARSE AND VALIDATE PARAMETERS---

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

function configure_ssh()
{

    # copy root ssh key
    mkdir -p ~/.ssh
    cat id_rsa.pub >> ~/.ssh/authorized_keys
    rm id_rsa.pub

    # set permissions
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys

    if [[ "${DIST}" == "Ubuntu" ]];
    then
        #restart sshd service - Ubuntu
        service ssh restart
    elif [[ "${DIST}" == "CentOS" ]] ;
    then
        # configure SELinux
        restorecon -Rv ~/.ssh

        #restart sshd service - CentOS
        service sshd restart
    fi


}

function get_sshkeys()
 {
    # install python
    log "INFO:Installing Python and Azure Storage Python SDK"
    if [[ "${DIST}" == "Ubuntu" ]];
    then
        apt-get --yes --force-yes update
        apt-get --yes --force-yes install python-pip
    elif [[ "${DIST}" == "CentOS" ]] ;
    then
        wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
        rpm -ivh epel-release-6-8.noarch.rpm
        yum -y install python-pip
    fi

    # Install Python Azure Storage SDK
    pip install azure-storage

    # Download Public Key
    python GetSSHFromPrivateStorageAccount.py  ${SSH_AZ_ACCOUNT_NAME} ${SSH_AZ_ACCOUNT_KEY} id_rsa.pub

}


function ConfigureSSH()
{
    check_OS
    get_sshkeys

    if [[ "${DIST}" == "Ubuntu" ]];
    then
        log "INFO:Configuring root loging for Ubuntu"
        configure_ssh
    elif [[ "${DIST}" == "CentOS" ]] ;
    then
        log "INFO:Configuring root loging for CentOS"
        configure_ssh
    else
         log "ERROR:Unsupported OS ${DIST}"
    fi


}

ConfigureSSH
