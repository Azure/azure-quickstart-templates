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

help()
{
    echo "This script installs Elasticsearch on Ubuntu"
    echo "Parameters:"
    echo "  -n elasticsearch cluster name"
    echo "  -m configure as master node (default: off)"
    echo "  -h view this help content"
}

# Log method to control/redirect log output
log()
{
    echo "$1"
}

log "Begin execution of Elasticsearch script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# TEMP FIX - Re-evaluate and remove when possible
# This is an interim fix for hostname resolution in current VM
grep -q "${HOSTNAME}" /etc/hosts
if [ $? == 0 ]
then
  echo "${HOSTNAME} found in /etc/hosts"
else
  echo "${HOSTNAME} not found in /etc/hosts"
  # Append it to the hosts file if not there
  echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
  log "hostname ${HOSTNAME} added to /etc/hosts"
fi

#Script Parameters
CLUSTER_NAME="es-azure"
ES_VERSION="5.1.2"
IS_DATA_NODE=1

#Loop through options passed
while getopts :n:mh optname; do
  log "Option $optname set with value ${OPTARG}"
  case $optname in
    n) #set cluster name
      CLUSTER_NAME=${OPTARG}
      ;;
    m) #set master mode
      IS_DATA_NODE=0
      ;;
    h) #show help
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

# Install Oracle Java
install_java()
{
    if [ -f "jdk-8u73-linux-x64.tar.gz" ];
    then
        log "Java already downloaded"
        return
    fi
    
    log "Installing Java"
    RETRY=0
    MAX_RETRY=5
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: downloading jdk-8u73-linux-x64.tar.gz"
        wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u73-b02/jdk-8u73-linux-x64.tar.gz
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to download jdk-8u73-linux-x64.tar.gz"
        exit 1
    fi
    
    tar xzf jdk-8u73-linux-x64.tar.gz -C /var/lib
    export JAVA_HOME=/var/lib/jdk1.8.0_73
    export PATH=$PATH:$JAVA_HOME/bin
    log "JAVA_HOME: $JAVA_HOME"
    log "PATH: $PATH"
    
    java -version
    if [ $? -ne 0 ]; then
        log "Java installation failed"
        exit 1
    fi
}

install_es()
{
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list    
    apt-get update -y 
    apt-get install -y elasticsearch
    pushd /usr/share/elasticsearch/
    bin/elasticsearch-plugin install x-pack --batch
    popd
    
    if [ ${IS_DATA_NODE} -eq 0 ]; 
    then
        apt-get install -y kibana
        pushd /usr/share/kibana/
        bin/kibana-plugin install x-pack
        popd
    fi
}

configure_es()
{
	log "Update configuration"
	mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.bak
	echo "cluster.name: $CLUSTER_NAME" >> /etc/elasticsearch/elasticsearch.yml
	echo "node.name: ${HOSTNAME}" >> /etc/elasticsearch/elasticsearch.yml
	echo "discovery.zen.minimum_master_nodes: 2" >> /etc/elasticsearch/elasticsearch.yml
	echo 'discovery.zen.ping.unicast.hosts: ["10.0.0.10", "10.0.0.11", "10.0.0.12"]' >> /etc/elasticsearch/elasticsearch.yml
	echo "network.host: _site_" >> /etc/elasticsearch/elasticsearch.yml
	echo "bootstrap.memory_lock: true" >> /etc/elasticsearch/elasticsearch.yml
    echo "xpack.security.enabled: false" >> /etc/elasticsearch/elasticsearch.yml

	if [ ${IS_DATA_NODE} -eq 1 ]; then
	    echo "node.master: false" >> /etc/elasticsearch/elasticsearch.yml
	    echo "node.data: true" >> /etc/elasticsearch/elasticsearch.yml
	else
        echo "node.master: true" >> /etc/elasticsearch/elasticsearch.yml
        echo "node.data: false" >> /etc/elasticsearch/elasticsearch.yml
	fi
}

configure_system()
{
	echo "options timeout:1 attempts:5" >> /etc/resolvconf/resolv.conf.d/head
	resolvconf -u
	ES_HEAP=`free -m |grep Mem | awk '{if ($2/2 >31744)  print 31744;else printf "%.0f", $2/2;}'`
	echo "ES_JAVA_OPTS=\"-Xms${ES_HEAP}m -Xmx${ES_HEAP}m\"" >> /etc/default/elasticsearch
    echo "JAVA_HOME=$JAVA_HOME" >> /etc/default/elasticsearch
    echo 'MAX_OPEN_FILES=65536' >> /etc/default/elasticsearch
    echo 'MAX_LOCKED_MEMORY=unlimited' >> /etc/default/elasticsearch
    sed -i 's|#LimitMEMLOCK=infinity|LimitMEMLOCK=infinity|' /usr/lib/systemd/system/elasticsearch.service
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
    
    if [ ${IS_DATA_NODE} -eq 0 ]; 
    then
        # Kibana    
        IPADDRESS=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
        echo "server.host: \"$IPADDRESS\"" >> /etc/kibana/kibana.yml
        echo "elasticsearch.url: \"http://$IPADDRESS:9200\"" >> /etc/kibana/kibana.yml
        echo "xpack.security.enabled: false" >> /etc/kibana/kibana.yml
        chown -R kibana:kibana /usr/share/kibana
    else
        # data disk
        DATA_DIR="/datadisks/disk1"
        if ! [ -f "vm-disk-utils-0.1.sh" ]; 
        then
            DOWNLOAD_SCRIPT="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh"
            log "Disk setup script not found in `pwd`, download from $DOWNLOAD_SCRIPT"
            wget -q $DOWNLOAD_SCRIPT
        fi
        
        bash ./vm-disk-utils-0.1.sh
        if [ $? -eq 0 ] && [ -d "$DATA_DIR" ];
        then
            log "Disk setup successful, using $DATA_DIR"
            chown -R elasticsearch:elasticsearch $DATA_DIR
            echo "DATA_DIR=$DATA_DIR" >> /etc/default/elasticsearch
        else
            log "Disk setup failed, using default data storage location"
        fi
    fi
}

start_service()
{
	log "Starting Elasticsearch on ${HOSTNAME}"
    systemctl daemon-reload
    systemctl enable elasticsearch.service
    systemctl start elasticsearch.service
    sleep 60
    
    if [ `systemctl is-failed elasticsearch.service` == 'failed' ];
    then
        log "Elasticsearch unit failed to start"
        exit 1
    fi
    
    if [ ${IS_DATA_NODE} -eq 0 ]; 
    then
        log "Starting Kibana on ${HOSTNAME}"
        systemctl enable kibana.service
        systemctl start kibana.service
        sleep 10
    
        if [ `systemctl is-failed kibana.service` == 'failed' ];
        then
            log "Kibana unit failed to start"
            exit 1
        fi    
    fi
}

log "starting elasticsearch setup"

install_java
install_es
configure_es
configure_system
start_service

log "completed elasticsearch setup"

exit 0
