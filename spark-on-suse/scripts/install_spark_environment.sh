#!/bin/bash

echo "Starting Spark Setup"

ISMASTER="-1"
MASTERIP="10.0.0.4"

while getopts :k:m:d:s:h optname; do
    echo "Option $optname set with value ${OPTARG}"
  case $optname in
    m)  #Master 1 Slave 0
      ISMASTER=${OPTARG}
      ;;
	i)
	  MASTERIP=${OPTARG}
	  ;;
  esac
done

echo "Using $MASTERIP as master ip"

install_prerequisites()
{
	echo "Working as user $USER"
	echo "Updating Suse"
	JAVAC=$(which javac)
	if [[ -z $JAVAC ]]; then
		echo "Installing OpenJDK"
		sudo zypper install -y java-1_8_0-openjdk
	fi
}

setup_spark_env_and_defaults()
{
	echo "Setting up spark-env.sh and spark-defaults.sh"
	cd /usr/local/spark/conf/
	
	cp -p spark-env.sh.template spark-env.sh
	touch spark-env.sh
	
	# Main Parameters
	echo "export SPARK_MASTER_IP=\"$MASTERIP\"" >> spark-env.sh
	echo 'export SPARK_MASTER_PORT=7077' >> spark-env.sh
	echo "export SPARK_PUBLIC_DNS=\"$MASTERIP\"" >> spark-env.sh
	echo "export SPARK_EXECUTOR_INSTANCES=\"1\"" >> spark-env.sh
	
	# Other Paramters
	echo 'export SPARK_CONF_DIR="/usr/local/spark/conf"' >> spark-env.sh
	echo 'export SPARK_TMP_DIR="/srv/spark/tmp"' >> spark-env.sh
	echo 'export SPARK_PID_DIR="/srv/spark/pids"' >> spark-env.sh
	echo 'export SPARK_LOG_DIR="/srv/spark/logs"' >> spark-env.sh
	echo 'export SPARK_WORKER_DIR="/srv/spark/work"' >> spark-env.sh
	echo 'export SPARK_LOCAL_DIRS="/srv/spark/tmp"' >> spark-env.sh
	
	cp -p spark-defaults.conf.template spark-defaults.conf
	touch spark-defaults.conf
	
	echo "spark.master            spark://10.0.0.4:7077" >> spark-defaults.conf
	echo 'spark.executor.memory   512m' >> spark-defaults.conf
	echo 'spark.eventLog.enabled  false' >> spark-defaults.conf
	echo 'spark.serializer        org.apache.spark.serializer.KryoSerializer' >> spark-defaults.conf
	
	cd ~
}

install_spark()
{
	cd ~
	mkdir /usr/local/sparkforsuse
	cd /usr/local/sparkforsuse
	
	wget http://mirror.nohup.it/apache/spark/spark-2.0.0/spark-2.0.0-bin-hadoop2.7.tgz
	
	tar xvzf spark-2.0.0-bin-hadoop2.7.tgz > /tmp/spark_unzip.log
	rm spark-2.0.0-bin-hadoop2.7.tgz
	mv spark-2.0.0-bin-hadoop2.7 ../
	cd ..
	cd /usr/local/
	
	sudo ln -s spark-2.0.0-bin-hadoop2.7 spark
	
	sudo groupadd spark
	sudo useradd -g spark spark
	#sudo adduser spark sudo
	sudo mkdir /home/spark
	sudo chown spark:spark /home/spark
	
	echo "spark ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users	 
	sudo chown -R spark:spark /usr/local/spark/
	
	rm -f ~/.ssh/id_rsa
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	
	sudo mkdir -p /srv/spark/{logs,work,tmp,pids}
	sudo chown -R spark:spark /srv/spark
	sudo chmod 4755 /srv/spark/tmp
	
	setup_spark_env_and_defaults
	
	sudo su spark
	rm -f ~/.ssh/id_rsa 
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

	# need to say yes to every question
	ssh localhost
	
	cd /usr/local/spark
	
	if [ ${ISMASTER} -eq "1" ];
	    then
		./sbin/start-master.sh
	    else
		./sbin/start-slave.sh spark://$MASTERIP:7077
	fi
}

install_prerequisites > /tmp/install_prerequisites.log

install_spark > /tmp/install_spark.log

