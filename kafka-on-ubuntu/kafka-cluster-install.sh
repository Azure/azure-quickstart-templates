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
# Author: Cognosys Technologies
 
### 
### Warning! This script partitions and formats disk information be careful where you run it
###          This script is currently under development and has only been tested on Ubuntu images in Azure
###          This script is not currently idempotent and only works for provisioning at the moment

### Remaining work items
### -Alternate discovery options (Azure Storage)
### -Implement Idempotency and Configuration Change Support
### -Recovery Settings (These can be changed via API)

help()
{
    #TODO: Add help text here
    echo "This script installs kafka cluster on Ubuntu"
    echo "Parameters:"
    echo "-k kafka version like 0.8.2.1"
    echo "-b broker id"
    echo "-h view this help content"
    echo "-z zookeeper not kafka"
    echo "-i zookeeper Private IP address prefix"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
  curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/ad167a6e-a762-41a6-aed0-4582d5e9b8a4/tag/kafka-test,${HOSTNAME}
	echo "$1"
}

log "Begin execution of kafka script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# TEMP FIX - Re-evaluate and remove when possible
# This is an interim fix for hostname resolution in current VM
grep -q "${HOSTNAME}" /etc/hosts
if [ $? -eq $SUCCESS ];
then
  echo "${HOSTNAME}found in /etc/hosts"
else
  echo "${HOSTNAME} not found in /etc/hosts"
  # Append it to the hsots file if not there
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
  log "hostname ${HOSTNAME} added to /etc/hosts"
fi

#Script Parameters
SCALA_VERSION="2.12"
KAFKA_VERSION="2.3.0"
KAFKA_SOURCE="http://mirror.dkm.cz/apache/kafka/"
BROKER_ID=0
INSTALL_ZOOKEEPER=false
ZOOKEEPER_VERSION="3.5.5"
ZOOKEEPER_SOURCE="http://mirrors.ukfast.co.uk/sites/ftp.apache.org/zookeeper/stable/"

ZOOKEEPER_IP_PREFIX="10.0.0.4"
INSTANCE_COUNT=1
ZOOKEEPER_PORT="2181"

#Loop through options passed
while getopts :k:K:b:z:Z:i:c:p:h optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
    k)  #kafka version
      KAFKA_VERSION=${OPTARG}
      ;;
    K)  #kafka source url
      KAFKA_SOURCE=${OPTARG}
      ;;
    b)  #broker id
      BROKER_ID=${OPTARG}
      ;;
    z)  #zookeeper not kafka
      INSTALL_ZOOKEEPER=true
      ZOOKEEPER_VERSION=${OPTARG}
      ;;
    Z)  #zookeeper source url
      ZOOKEEPER_SOURCE=${OPTARG}
      ;;
    i)  #zookeeper Private IP address prefix
      ZOOKEEPER_IP_PREFIX=${OPTARG}
      ;;
    c) # Number of instances
	INSTANCE_COUNT=${OPTARG}
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

# Install Oracle Java
install_java()
{
    log "Installing Java"
    add-apt-repository -y ppa:webupd8team/java
    apt-get -y update 
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
    apt-get -y install oracle-java7-installer
}

# Expand a list of successive IP range defined by a starting address prefix (e.g. 10.0.0.1) and the number of machines in the range
# 10.0.0.1-3 would be converted to "10.0.0.10 10.0.0.11 10.0.0.12"

expand_ip_range_for_server_properties() {
    IFS='-' read -a HOST_IPS <<< "$1"
    for (( n=0 ; n<("${HOST_IPS[1]}"+0) ; n++))
    do
        echo "server.$(expr ${n} + 1)=${HOST_IPS[0]}${n}:2888:3888" >> zookeeper-3.4.6/conf/zoo.cfg       
    done
}

function join { local IFS="$1"; shift; echo "$*"; }

expand_ip_range() {
    IFS='-' read -a HOST_IPS <<< "$1"

    declare -a EXPAND_STATICIP_RANGE_RESULTS=()

    for (( n=0 ; n<("${HOST_IPS[1]}"+0) ; n++))
    do
        HOST="${HOST_IPS[0]}${n}:${ZOOKEEPER_PORT}"
                EXPAND_STATICIP_RANGE_RESULTS+=($HOST)
    done

    echo "${EXPAND_STATICIP_RANGE_RESULTS[@]}"
}

# Install Zookeeper - can expose zookeeper version
install_zookeeper()
{
	mkdir -p /var/lib/zookeeper
	cd /var/lib/zookeeper
	zookeeper="zookeeper-${ZOOKEEPER_VERSION}"
	zookeeper_package="${zookeeper}.tar.gz"
	zookeeper_config="${zookeeper}/conf/zoo.cfg"
	wget "${ZOOKEEPER_SOURCE}/$zookeeper_package"
	tar -xvf $zookeeper_package

	touch $zookeeper_config

	echo "tickTime=2000" >> $zookeeper_config
	echo "dataDir=/var/lib/zookeeper" >> $zookeeper_config
	echo "clientPort=2181" >> $zookeeper_config
	echo "initLimit=5" >> $zookeeper_config
	echo "syncLimit=2" >> $zookeeper_config
	# OLD Test echo "server.1=${ZOOKEEPER_IP_PREFIX}:2888:3888" >> ${zookeeper}/conf/zoo.cfg
	$(expand_ip_range_for_server_properties "${ZOOKEEPER_IP_PREFIX}-${INSTANCE_COUNT}")

	echo $(($1+1)) >> /var/lib/zookeeper/myid

	${zookeeper}/bin/zkServer.sh start
}

# Install kafka
install_kafka()
{
	cd /usr/local
	name=kafka
	version=${KAFKA_VERSION}
	description="Apache Kafka is a distributed publish-subscribe messaging system."
	url="https://kafka.apache.org/"
	arch="all"
	section="misc"
	license="Apache Software License 2.0"
	package_version="-1"
	kafka="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"
	kafka_package="${kafka}.tgz"

	rm -rf kafka
	mkdir -p kafka
	cd kafka
	kafka_path="${pwd}/$kafka"
	#_ MAIN _#
	if [[ ! -f "${kafka_package}" ]]; then
	  wget "${KAFKA_SOURCE}/${KAFKA_VERSION}/${kafka_package}"
	fi
	tar zxf $kafka_package
	cd $kafka_path
	
	sed -r -i "s/(broker.id)=(.*)/\1=${BROKER_ID}/g" config/server.properties 
	sed -r -i "s/(zookeeper.connect)=(.*)/\1=$(join , $(expand_ip_range "${ZOOKEEPER_IP_PREFIX}-${INSTANCE_COUNT}"))/g" config/server.properties 
#	cp config/server.properties config/server-1.properties 
#	sed -r -i "s/(broker.id)=(.*)/\1=1/g" config/server-1.properties 
#	sed -r -i "s/^(port)=(.*)/\1=9093/g" config/server-1.properties````
	chmod u+x $kafka_path/bin/kafka-server-start.sh
	$kafka_path/bin/kafka-server-start.sh $kafka_path/config/server.properties &
}

# Primary Install Tasks
#########################
#NOTE: These first three could be changed to run in parallel
#      Future enhancement - (export the functions and use background/wait to run in parallel)

#Install Oracle Java
#------------------------
install_java

if [ "$INSTALL_ZOOKEEPER" == true ];
then
	#
	#Install zookeeper
	#-----------------------
	install_zookeeper
else
	#
	#Install kafka
	#-----------------------
	install_kafka
fi

