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
# Trent Swanson (Full Scale 180 Inc)
#

help()
{
    echo "Usage: $(basename $0) [-v es_version] [-t target_host] [-m] [-s] [-h]"
    echo "Options:"
    echo "  -v    elasticsearch version to target (default: 2.3.1)"
    echo "  -t    target host (default: http://10.0.1.4:9200)"
    echo "  -m    install marvel (default: no)"
    echo "  -s    install sense (default: no)"
    echo "  -h    this help message"
}

error()
{
    echo "$1" >&2
    exit 3
}

MAX_RETRY=5

install_java() {
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        echo "Retry $RETRY: downloading jdk-8u92-linux-x64.rpm..."
        wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        echo "Failed to download jdk-8u92-linux-x64.rpm."
        exit 1
    fi
    yum -y localinstall jdk-8u92-linux-x64.rpm
#    rm ~/jdk-8u*-linux-x64.rpm
}

install_kibana() {
    # create repository files
    # default - ES 2.3.1
    KIBANA_VERSION='4.5'
    if [[ "${ES_VERSION}" == \2.\2* ]]; then
        KIBANA_VERSION='4.4'    
    fi 
    
    # TODO: Install Kibana 4.3 for ES 2.1.*
    if [[ "${ES_VERSION}" == \2.\1* ]]; then
        echo "Kibana installation for ES_VERSION 2.1.* is unimplemented."
        exit 1
    fi 
    
    if [[ "${ES_VERSION}" == \1.\7* ]]; then
        KIBANA_VERSION='4.1'    
    fi 
    
    echo "[kibana-${KIBANA_VERSION}]
name=Kibana repository for ${KIBANA_VERSION}.x packages
baseurl=http://packages.elastic.co/kibana/${KIBANA_VERSION}/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1" | tee /etc/yum.repos.d/kibana.repo
    
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        echo "Retry $RETRY: installing kibana..."
        yum install -y kibana
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        echo "Failed to install kibana."
        exit 1
    fi   
    
    mv /opt/kibana/config/kibana.yml /opt/kibana/config/kibana.yml.bak

    if [[ "${KIBANA_VERSION}" == "4.1" ]];
    then
        cat /opt/kibana/config/kibana.yml.bak | sed "s|http://localhost:9200|${ELASTICSEARCH_URL}|" >> /opt/kibana/config/kibana.yml 
    else
        echo "elasticsearch.url: \"$ELASTICSEARCH_URL\"" >> /opt/kibana/config/kibana.yml
    fi

    # install the marvel plugin for 2.x
    if [ ${INSTALL_MARVEL} -ne 0 ];
    then
		if [[ "${ES_VERSION}" == \2* ]];
        then 
            RETRY=0
            while [ $RETRY -lt $MAX_RETRY ]; do
                echo "Retry $RETRY: installing Marvel plugin..."
                /opt/kibana/bin/kibana plugin --install elasticsearch/marvel/${ES_VERSION}
                if [ $? -ne 0 ]; then
                    let RETRY=RETRY+1
                else
                    break
                fi
            done
            if [ $RETRY -eq $MAX_RETRY ]; then
                echo "Failed to install Marvel plugin."
                exit 1
            fi
        fi

        # for 1.x marvel is installed only within the cluster, not on the kibana node 
    fi
    
    # install the sense plugin for 2.x
    if [ ${INSTALL_SENSE} -ne 0 ];
    then
        if [[ "${ES_VERSION}" == \2* ]];
        then
            RETRY=0
            while [ $RETRY -lt $MAX_RETRY ]; do
                echo "Retry $RETRY: installing sense plugin..."
                /opt/kibana/bin/kibana plugin --install elastic/sense
                if [ $? -ne 0 ]; then
                    let RETRY=RETRY+1
                else
                    break
                fi
            done
            if [ $RETRY -eq $MAX_RETRY ]; then
                echo "Failed to install sense plugin."
                exit 1
            fi
        fi
                
        # for 1.x sense is not supported 
    fi

    chown -R kibana: /opt/kibana
        
    # Add start and enable kibana service
    systemctl start kibana
    systemctl enable kibana
       
    exit 0
}

###############

if [ "${UID}" -ne 0 ];
then
    error "You must be root to run this script."
fi

ES_VERSION="2.3.1"
INSTALL_MARVEL=0
INSTALL_SENSE=0
ELASTICSEARCH_URL="http://10.0.1.4:9200"

while getopts :v:t:msh optname; do
  case ${optname} in
    v) ES_VERSION=${OPTARG};;
    m) INSTALL_MARVEL=1;;
    s) INSTALL_SENSE=1;;
    t) ELASTICSEARCH_URL=${OPTARG};; 
    h) help; exit 1;;
   \?) help; error "Option -${OPTARG} not supported.";;
    :) help; error "Option -${OPTARG} requires an argument.";;
  esac
done

install_java
install_kibana
