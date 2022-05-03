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
# Script: jenkMstrInstall.sh
#
# Author: Dennis Angeline (Full Scale 180 Inc)
#
# Description:
#    This script install Jenkins master on an Ubuntu VM image
#    and optionally configures tohe master with multiple dumb slave nodes.
#
# Parameters :
#    -n number of dumb slave nodes to configure
#    -h view this help content
#
# Note :
#    This script has only been tested on Ubuntu 14.04 LTS
#

help()
{

    echo "This script install Jenkins master on an Ubuntu VM image"
    echo "Parameters:"
    echo "-n number of slave nodes to configure on the master"
    echo "-h view this help content"
}

#Log method to control/redirect log output
log()
{
    echo "$1"
}


#Script Parameters
NODECNT=0

#Loop through options passed
while getopts :n:h optname; do
    log "Option $optname set with value ${OPTARG}"

  case $optname in
    n)  #set number of slave nodes
      NODECNT=${OPTARG}
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

log "Begin execution of Jenkins install script on ${HOSTNAME} with ${NODECNT} slave nodes"


# Install openjdk-7
install_java()
{
    log "Installing openjdk-7"
    apt-get -y update > /dev/null
    apt-get -y install openjdk-7-jdk > /dev/null
    apt-get -y update > /dev/null
}


# Install jenkins master
install_jenkins()
{
    log "Installing Jenkins master"
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get -y update > /dev/null
    apt-get -y install jenkins > /dev/null

    log "Waiting for Jenkins master to start..."
    sleep 60
}


# Configure jenkins slave nodes
configure_slave_nodes()
{
    log "Configuring Jenkins master with $NODECNT dumb slave node(s)"

    if [ $NODECNT -gt 0 ]; then
        # Run groovy script to configure master with $NODECNT dumb slave node(s)
        sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 groovy jenkAddNode.groovy $NODECNT
    fi
}

# Primary Install Tasks
install_java
install_jenkins
configure_slave_nodes
exit 0

