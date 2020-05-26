#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Script: jenkSlaveInstall.sh
#
# Author: Dennis Angeline (Full Scale 180 Inc)
#
# Description:
#    This script install Jenkins slave on an Ubuntu VM image
#
# Parameters :
#    -m The ip address of the master node
#    -s The name of THIS slave node as configured on the master
#    -h view this help content
#
# Note :
#    This script has only been tested on Ubuntu 14.04 LTS
#

help()
{

    echo "This script install Jenkins slave on an Ubuntu VM"
    echo "Parameters:"
    echo "-m The ip address of the master node"
    echo "-s The name of THIS slave node as configured on the master"
    echo "-h view this help content"
}

#Log method to control/redirect log output
log()
{
    echo "$1"
}

log "Begin execution of Jenkins slave install script on ${HOSTNAME}"

#Script Parameters
MASTERNODE="missing"
SLAVENAME="missing"

#Loop through options passed
while getopts :m:s:h optname; do
    log "Option $optname set with value ${OPTARG}"

  case $optname in
    m)  #set the ip address of the master
      MASTERNODE=${OPTARG}
      ;;
    s)  #set the name of this slave node
      SLAVENAME=${OPTARG}
      ;;
    h)  #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

# Install openjdk-7
install_java()
{
    log "Installing openjdk-7"
    apt-get -y update > /dev/null
    apt-get -y install openjdk-7-jdk > /dev/null
    apt-get -y update > /dev/null
}

download_slave_jar()
{
    log "Downloading slave.jar from $MASTERNODE"
    wget http://$MASTERNODE:8080/jnlpJars/slave.jar -O ~/slave.jar > /dev/null
    chmod 777 ~/slave.jar
}

create_upstart_task()
{
    upstart_conf="/etc/init/jenkins_slave.conf"

    log "Creating Upstart conf file $upstart_conf"
    echo "# Jenkin Slave"                                                                                     > $upstart_conf
    echo "description \"slave node for Jenkins Continuous Integration Service\""                             >> $upstart_conf
    echo ""                                                                                                  >> $upstart_conf
    echo "start on starting"                                                                                 >> $upstart_conf
    echo "script"                                                                                            >> $upstart_conf
    echo "  java -jar /root/slave.jar -jnlpUrl http://$MASTERNODE:8080/computer/$SLAVENAME/slave-agent.jnlp" >> $upstart_conf
    echo "end script"                                                                                        >> $upstart_conf

    chmod +x $upstart_conf
}

start_slave()
{
    log "Executing slave.jar with http://$MASTERNODE:8080/computer/$SLAVENAME/slave-agent.jnlp"
    service jenkins_slave start
    # nohup java -jar ~/slave.jar -jnlpUrl http://$MASTERNODE:8080/computer/$SLAVENAME/slave-agent.jnlp &
}

# Primary Install Tasks

if [ $MASTERNODE == "missing" ]; then
    log "Master node not specified"
    exit 1
fi

if [ $SLAVENAME == "missing" ]; then
    log "Slave name not specified"
    exit 2
fi


install_java
download_slave_jar
create_upstart_task
start_slave
exit 0


