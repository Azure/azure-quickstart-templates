#!/bin/bash
#
# ========================================================================================
# Microsoft patterns & practices (http://microsoft.com/practices)
# SEMANTIC LOGGING APPLICATION BLOCK
# ========================================================================================
#
# Copyright (c) Microsoft.  All rights reserved.
# Microsoft would like to thank its contributors, a list
# of whom are at http://aka.ms/entlib-contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#

help()
{
    echo ""
    echo ""
    echo "This script installs Logstash 2.2 on CentOS"
    echo "Parameters:"
    echo "e - The base64 encoded Logstash configuration string."
    echo "p - The name of Logstash plugin to be installed."
    echo ""
    echo ""
}

log()
{
    echo "$1"
}

#Loop through options passed
while getopts :e:h:p: optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
    h)  #show help
      help
      exit 2
      ;;
    e)  #set the encoded configuration string
      log "Setting the encoded configuration string"
      CONF_FILE_ENCODED_STRING="${OPTARG}"
      ;;
    p)
      LOGSTASH_PLUGIN_NAME=${OPTARG}
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

# Max retry count
MAX_RETRY=5

# Install Oracle Java
install_java()
{
    log "Installing Java"
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: downloading jdk-8u92-linux-x64.rpm..."
        wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to download jdk-8u92-linux-x64.rpm."
        exit 1
    fi
    yum -y localinstall jdk-8u92-linux-x64.rpm
#    rm ~/jdk-8u*-linux-x64.rpm
}

install_logstash()
{
	# Import the Elasticsearch public GPG key into RPM
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: importing GPG-KEY-elasticsearch..."
        rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to import GPG-KEY-elasticsearch."
        exit 1
    fi
    
    # Create a new yum repository file for logstash
    echo '[logstash-2.2]
name=logstash repository for 2.2 packages
baseurl=http://packages.elasticsearch.org/logstash/2.2/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1' | tee /etc/yum.repos.d/logstash.repo

    # Install logstash
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: installing logstash..."
        yum -y install logstash
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to install logstash."
        exit 1
    fi
    
}

install_plugin()
{
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: installing logstash plugin $LOGSTASH_PLUGIN_NAME..."
         /opt/logstash/bin/plugin install $LOGSTASH_PLUGIN_NAME
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to install logstash plugin $LOGSTASH_PLUGIN_NAME."
        exit 1
    fi
}

configure_and_start_logstash()
{
    log "Decoding configuration string"
    log "$CONF_FILE_ENCODED_STRING"
    echo $CONF_FILE_ENCODED_STRING > logstash.conf.encoded
    DECODED_STRING=$(base64 -d logstash.conf.encoded)
    log "$DECODED_STRING"
    echo $DECODED_STRING > ~/logstash.conf
    \cp -f ~/logstash.conf /etc/logstash/conf.d/
    
    log "start logstash service"
    service logstash start
    /sbin/chkconfig logstash on
}


# Install Java
install_java

# Install Logstash
install_logstash

# Install Logstash Plugin
if [ ! $LOGSTASH_PLUGIN_NAME = "na" ] 
then
    install_plugin
fi

# Install User Configuration from encoded string
if [ ! $CONF_FILE_ENCODED_STRING = "na" ] 
then
    configure_and_start_logstash
fi

