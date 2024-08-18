#!/bin/bash

function log()
{
  message=$@
  echo "$message"
  echo "$message" >> /var/log/sapconfigcreate
}

function installprequisites()
{
    log "installprequisites"
    # install the required packages
    zypper install -y azcopy
    log "installprequisites done"
}

function addipaddress()
{
    log "addipaddress"
    # get the ip address of the host
    ip=$(hostname -I | awk '{print $1}')
    echo $ip
    # add the entry in /etc/hosts file
    echo $ip sid-hdb-s4h.dummy.nodomain sid-hdb-s4h >> /etc/hosts
    echo $ip vhcals4hci.dummy.nodomain vhcals4hci >> /etc/hosts
    echo $ip vhcalj2eci.dummy.nodomain vhcalj2eci >> /etc/hosts
    log "addipaddress done"
}


addipaddress
installprequisites

