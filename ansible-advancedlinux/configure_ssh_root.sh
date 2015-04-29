#!/bin/bash

#########################################################
# Script Name: configure_ssh_root.sh
# Author: Gonzalo Ruiz 
# Version: 0.1
# Date Created:           01st Marh 2015
# Last Modified:          04st April 17:26 GMT
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


 function usage()
 {
    echo "INFO:"
    echo "Usage: configure_ssh_root"
}

function log()
{
    # If you want to enable this logging add a un-comment the line below and add your account id
    #curl -X POST -H "content-type:text/plain" --data-binary "${HOSTNAME} - $1" https://logs-01.loggly.com/inputs/<key>/tag/es-extension,${HOSTNAME}
    echo "$1"
}


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



function ConfigureSSH()
{
    check_OS
    
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
