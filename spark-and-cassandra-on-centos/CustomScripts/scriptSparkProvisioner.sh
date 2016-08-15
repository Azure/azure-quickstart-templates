#!/bin/bash

install_dependencies()
{
	echo "Installing ntp"
	yum -y -q install ntp

	echo "Installing wget"
	yum -y -q install wget

	echo "Installing Java 1.8 (openjdk)"
	yum -y -q install java-1.8.0-openjdk
}

configure_dependencies()
{
	echo "Updating ntp"
	ntpdate pool.ntp.org
}

ensure_system_updated()
{
	yum makecache fast

	echo "Updating Operating System"
	yum -y -q update
}

install_spark()
{
	DOWNLOAD_URL="http://d3kbcqa49mib13.cloudfront.net/spark-1.6.0-bin-hadoop2.6.tgz"
	FILE_NAME="spark-1.6.0-bin-hadoop2.6.tgz"
	TMP_DIR="/tmp/spark"
	INSTALL_DIR="/opt/spark"
	SPARK_HOME="$INSTALL_DIR/spark-1.6.0-bin-hadoop2.6"

	if [ -d $SPARK_HOME ];
	then
		echo "Found an installation at $SPARK_HOME.  Exiting."
		exit 0
	fi

	echo "Downloading Spark"
	mkdir -p $TMP_DIR
	wget --directory-prefix $TMP_DIR $DOWNLOAD_URL

	echo "Creating Spark user and group"
	groupadd spark
	useradd -g spark spark

	echo "Setting up password-less access"
    rm -f ~/.ssh/id_rsa 
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

	echo "Setting up work directory"
	mkdir -p /var/spark/{logs,work,tmp,pids}
	chown -R spark:spark /var/spark
	chmod 4755 /var/spark/tmp

	echo "Extracting Spark"
	mkdir -p /opt/spark
	tar -xzvf $TMP_DIR/$FILE_NAME --directory $INSTALL_DIR

	echo "Configuring Spark"
	cd $SPARK_HOME/conf
	cp -p spark-env.sh.template spark-env.sh
	touch spark-env.sh

	echo 'export SPARK_WORKER_MEMORY="1g"' >> spark-env.sh
	echo 'export SPARK_DRIVER_MEMORY="1g"' >> spark-env.sh
	echo 'export SPARK_REPL_MEM="2g"' >> spark-env.sh
	echo 'export SPARK_WORKER_PORT=9000' >> spark-env.sh
	echo 'export SPARK_CONF_DIR="$SPARK_HOME/conf"' >> spark-env.sh
	echo 'export SPARK_TMP_DIR="/var/spark/tmp"' >> spark-env.sh
	echo 'export SPARK_PID_DIR="/var/spark/pids"' >> spark-env.sh
	echo 'export SPARK_LOG_DIR="/var/spark/logs"' >> spark-env.sh
	echo 'export SPARK_WORKER_DIR="/var/spark/work"' >> spark-env.sh
	echo 'export SPARK_LOCAL_DIRS="/var/spark/tmp"' >> spark-env.sh
	echo 'export SPARK_COMMON_OPTS="$SPARK_COMMON_OPTS -Dspark.kryoserializer.buffer.mb=32 "' >> spark-env.sh
	echo 'export SPARK_MASTER_OPTS=" $LOG4J -Dspark.log.file=/var/spark/logs/master.log "' >> spark-env.sh
	echo 'export SPARK_WORKER_OPTS=" $LOG4J -Dspark.log.file=/var/spark/logs/worker.log "' >> spark-env.sh
	echo 'export SPARK_EXECUTOR_OPTS=" $LOG4J -Djava.io.tmpdir=/var/spark/tmp/executor "' >> spark-env.sh
	echo 'export SPARK_REPL_OPTS=" -Djava.io.tmpdir=/var/spark/tmp/repl/\$USER "' >> spark-env.sh
	echo 'export SPARK_APP_OPTS=" -Djava.io.tmpdir=/var/spark/tmp/app/\$USER "' >> spark-env.sh
	echo 'export PYSPARK_PYTHON="/usr/bin/python"' >> spark-env.sh
	echo "export SPARK_MASTER_IP=\"$MASTERIP\"" >> spark-env.sh
	echo 'export SPARK_MASTER_PORT=7077' >> spark-env.sh
	echo "export SPARK_PUBLIC_DNS=\"$MASTERIP\"" >> spark-env.sh

	cp -p spark-defaults.conf.template spark-defaults.conf
	touch spark-defaults.conf

	echo "spark.master            spark://${MASTERIP}:7077" >> spark-defaults.conf
	echo 'spark.executor.memory   512m' >> spark-defaults.conf
	echo 'spark.eventLog.enabled  true' >> spark-defaults.conf
	echo 'spark.serializer        org.apache.spark.serializer.KryoSerializer' >> spark-defaults.conf

	echo "Setting permissions"
	chown -R spark:spark $INSTALL_DIR

	SPARKSERVICE_NAME=""

	if [ "$RUNAS" = "slave" ];
	then
		echo "Creating Spark Service (slave)"
		SPARKSERVICE_NAME="spark-slave.service"
	else
		echo "Creating Spark Service (master)"
		SPARKSERVICE_NAME="spark-master.service"
	fi

	cd /etc/systemd/system
	touch $SPARKSERVICE_NAME

	echo '[Unit]' >> $SPARKSERVICE_NAME
	echo 'Description=Spark Service' >> $SPARKSERVICE_NAME
	echo 'After=network.target' >> $SPARKSERVICE_NAME

	echo '[Service]' >> $SPARKSERVICE_NAME
	echo 'User=spark' >> $SPARKSERVICE_NAME
	echo 'Type=forking' >> $SPARKSERVICE_NAME

	if [ "$RUNAS" = "slave" ];
	then
		echo "ExecStart=$SPARK_HOME/sbin/start-slave.sh spark://$MASTERIP:7077" >> $SPARKSERVICE_NAME
		echo "ExecStop=$SPARK_HOME/sbin/stop-slave.sh" >> $SPARKSERVICE_NAME
	else
		echo "ExecStart=$SPARK_HOME/sbin/start-master.sh" >> $SPARKSERVICE_NAME
		echo "ExecStop=$SPARK_HOME/sbin/stop-master.sh" >> $SPARKSERVICE_NAME
	fi

	echo '[Install]' >> $SPARKSERVICE_NAME
	echo 'WantedBy=multi-user.target' >> $SPARKSERVICE_NAME

	systemctl enable $SPARKSERVICE_NAME

	echo "Starting $SPARKSERVICE_NAME"
	systemctl start $SPARKSERVICE_NAME
}

# need to run with sudo
if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

MASTERIP="localhost"
RUNAS="master"

for i in "$@"
do
case $i in
    -master=*)
    MASTERIP="${i#*=}"

    ;;

    -runas=*)
    RUNAS="${i#*=}"

    ;;

    *)
		# unknown option
    ;;
esac
done

export MASTERIP

ensure_system_updated
install_dependencies
configure_dependencies
install_spark