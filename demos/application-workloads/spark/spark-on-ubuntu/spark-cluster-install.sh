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
    echo "This script installs spark cluster on Ubuntu"
    echo "Parameters:"
    echo "-k spark version like 1.2.1"
    echo "-m master 1 slave 0"
    echo "-h view this help content"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key
    	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/[account-key]/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

echo "Begin execution of spark script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
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
SPK_VERSION="1.2.1"
MASTER1SLAVE0="-1"
MASTERIP="10.0.0.10"
NUMBEROFSLAVES="1"

#Loop through options passed
while getopts :k:m:d:s:h optname; do
    echo "Option $optname set with value ${OPTARG}"
  case $optname in
    k)  #spark version
      SPK_VERSION=${OPTARG}
      ;;
    m)  #Master 1 Slave 0
      MASTER1SLAVE0=${OPTARG}
      ;;
    d)  #Master IP
      MASTERIP=${OPTARG}
      ;;
    s)  #Number of Slaves
      NUMBEROFSLAVES=${OPTARG}
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

install_pre()
{
# First install pre-requisites
	sudo  apt-get -y update

	echo "Installing Java"
	add-apt-repository -y ppa:webupd8team/java
	apt-get -y update
	echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
	apt-get -y install oracle-java7-installer
	sudo ntpdate pool.ntp.org
	sudo apt-get -y install ntp
	sudo apt-get -y install python-software-properties
	sudo apt-get -y update
	sudo apt-get -y install git
}

# Install spark
install_spark()
{
	##Second download and install Apache Spark
	cd ~
	mkdir /usr/local/azurespark
	cd /usr/local/azurespark/

########## to build manually for versions where prebuilt binary is not available
#	wget http://mirror.tcpdiag.net/apache/spark/spark-1.2.1/spark-1.2.1.tgz
#	gunzip -c spark-1.2.1.tgz | tar -xvf -
#	mv spark-1.2.1 ../
#	cd ../spark-1.2.1/
# this will take quite a while
#	sudo sbt/sbt assembly 2>&1 1>buildlog.txt
##########

	version=${SPK_VERSION}
	wget https://archive.apache.org/dist/spark/spark-${version}/spark-${version}-bin-hadoop2.7.tgz
	echo "Unpacking Spark"
	tar xvzf spark-*.tgz > /tmp/spark-ec2_spark.log
	rm spark-*.tgz
	mv spark-${version}-bin-hadoop2.7 ../
	cd ..
	cd /usr/local/
	sudo ln -s spark-${version}-bin-hadoop2.7 spark

#	Third create a spark user with proper privileges and ssh keys.

	sudo addgroup spark
	sudo useradd -g spark spark
	sudo adduser spark sudo
	sudo mkdir /home/spark
	sudo chown spark:spark /home/spark

#	Add to sudoers file:

	echo "spark ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
	sudo chown -R spark:spark /usr/local/spark/

#	Setting passwordless ssh for root

        rm -f ~/.ssh/id_rsa
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#	Fourth setup some Apache Spark working directories with proper user permissions

	sudo mkdir -p /srv/spark/{logs,work,tmp,pids}
	sudo chown -R spark:spark /srv/spark
	sudo chmod 4755 /srv/spark/tmp

#	Fifth let�s do a quick test
#	cd /usr/local/spark
#	bin/run-example SparkPi 10

#	Now lets adjust some Spark configuration files

	cd /usr/local/spark/conf/
	cp -p spark-env.sh.template spark-env.sh
	touch spark-env.sh

#	========================================================
#	echo 'SPARK-ENV.SH (ADD BELOW)' >> spark-env.sh

# Can change the memory settings

	echo 'export SPARK_WORKER_MEMORY="1g"' >> spark-env.sh
	echo 'export SPARK_DRIVER_MEMORY="1g"' >> spark-env.sh
	echo 'export SPARK_REPL_MEM="2g"' >> spark-env.sh
	echo 'export SPARK_WORKER_PORT=9000' >> spark-env.sh
	echo 'export SPARK_CONF_DIR="/usr/local/spark/conf"' >> spark-env.sh
	echo 'export SPARK_TMP_DIR="/srv/spark/tmp"' >> spark-env.sh
	echo 'export SPARK_PID_DIR="/srv/spark/pids"' >> spark-env.sh
	echo 'export SPARK_LOG_DIR="/srv/spark/logs"' >> spark-env.sh
	echo 'export SPARK_WORKER_DIR="/srv/spark/work"' >> spark-env.sh
	echo 'export SPARK_LOCAL_DIRS="/srv/spark/tmp"' >> spark-env.sh
	echo 'export SPARK_COMMON_OPTS="$SPARK_COMMON_OPTS -Dspark.kryoserializer.buffer.mb=32 "' >> spark-env.sh
	echo 'LOG4J="-Dlog4j.configuration=file://$SPARK_CONF_DIR/log4j.properties"' >> spark-env.sh
	echo 'export SPARK_MASTER_OPTS=" $LOG4J -Dspark.log.file=/srv/spark/logs/master.log "' >> spark-env.sh
	echo 'export SPARK_WORKER_OPTS=" $LOG4J -Dspark.log.file=/srv/spark/logs/worker.log "' >> spark-env.sh
	echo 'export SPARK_EXECUTOR_OPTS=" $LOG4J -Djava.io.tmpdir=/srv/spark/tmp/executor "' >> spark-env.sh
	echo 'export SPARK_REPL_OPTS=" -Djava.io.tmpdir=/srv/spark/tmp/repl/\$USER "' >> spark-env.sh
	echo 'export SPARK_APP_OPTS=" -Djava.io.tmpdir=/srv/spark/tmp/app/\$USER "' >> spark-env.sh
	echo 'export PYSPARK_PYTHON="/usr/bin/python"' >> spark-env.sh
	echo "export SPARK_MASTER_IP=\"$MASTERIP\"" >> spark-env.sh
	echo 'export SPARK_MASTER_PORT=7077' >> spark-env.sh
	echo "export SPARK_PUBLIC_DNS=\"$MASTERIP\"" >> spark-env.sh
	echo "export SPARK_WORKER_INSTANCES=\"${NUMBEROFSLAVES}\"" >> spark-env.sh
	#=========================================================

	cp -p spark-defaults.conf.template spark-defaults.conf
	touch spark-defaults.conf

	#=========================================================
	#SPARK-DEFAULTS (ADD BELOW)

	echo "spark.master            spark://${MASTERIP}:7077" >> spark-defaults.conf
	echo 'spark.executor.memory   512m' >> spark-defaults.conf
	echo 'spark.eventLog.enabled  true' >> spark-defaults.conf
	echo 'spark.serializer        org.apache.spark.serializer.KryoSerializer' >> spark-defaults.conf

	#================================================================

	#Time to start Apache Spark up

	sudo su spark
	rm -f ~/.ssh/id_rsa
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

	ssh localhost

	cd /usr/local/spark/sbin
	if [ ${MASTER1SLAVE0} -eq "1" ];
	    then
		./start-master.sh
	    else
		./start-slaves.sh
	fi

#Note to stop processes do:

	#./stop-slaves.sh

	#./stop-master.sh
}

# Primary Install Tasks
#########################
#NOTE: These first three could be changed to run in parallel
#      Future enhancement - (export the functions and use background/wait to run in parallel)

#Install Pre requisites
#------------------------
install_pre

#Install spark
#-----------------------
install_spark

#========================= END ==================================

