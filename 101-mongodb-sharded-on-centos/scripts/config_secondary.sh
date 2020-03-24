#!/bin/bash

certUri=$1

install_mongo3() {
	#install
	wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-server-3.6.17-1.el7.x86_64.rpm
	wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-shell-3.6.17-1.el7.x86_64.rpm
	rpm -i mongodb-org-server-3.6.17-1.el7.x86_64.rpm
	rpm -i mongodb-org-shell-3.6.17-1.el7.x86_64.rpm
	PATH=$PATH:/usr/bin; export PATH

	#disable selinux
	sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
	sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
	setenforce 0

	#kernel settings
	if [[ -f /sys/kernel/mm/transparent_hugepage/enabled ]];then
		echo never > /sys/kernel/mm/transparent_hugepage/enabled
	fi
	if [[ -f /sys/kernel/mm/transparent_hugepage/defrag ]];then
		echo never > /sys/kernel/mm/transparent_hugepage/defrag
	fi

	#configure
	sed -i 's/\(bindIp\)/#\1/' /etc/mongod.conf

	#set keyfile
	echo "vfr4CDE1" > /etc/mongokeyfile
	chown mongod:mongod /etc/mongokeyfile
	chmod 600 /etc/mongokeyfile
	sed -i 's/^#security/security/' /etc/mongod.conf
	sed -i '/^security/akeyFile: /etc/mongokeyfile' /etc/mongod.conf
	sed -i 's/^keyFile/  keyFile/' /etc/mongod.conf
}

yum install wget -y
echo "Downloading the ssl cert"
wget $certUri -O /etc/MongoAuthCert.pem
install_mongo3

#start config replica set
mongod --configsvr --replSet crepset --bind_ip 0.0.0.0 --port 27019 --dbpath /var/lib/mongo/ --logpath /var/log/mongodb/config.log --fork --config /etc/mongod.conf --keyFile /etc/mongokeyfile --sslMode requireSSL --sslPEMKeyFile /etc/MongoAuthCert.pem --sslPEMKeyPassword Mongo123


#check if mongod started or not
sleep 15
n=`ps -ef |grep "mongod --configsvr" |grep -v grep |wc -l`
if [[ $n -eq 1 ]];then
    echo "mongod config replica set started successfully"
else
    echo "mongod config replica set started failed!"
	exit 1
fi


#set mongod auto start
cat > /etc/init.d/mongod1 <<EOF
#!/bin/bash
#chkconfig: 35 84 15
#description: mongod auto start
. /etc/init.d/functions

Name=mongod1
start() {
if [[ ! -d /var/run/mongodb ]];then
mkdir /var/run/mongodb
chown -R mongod:mongod /var/run/mongodb
fi
mongod --configsvr --replSet crepset --bind_ip 0.0.0.0 --port 27019 --dbpath /var/lib/mongo/ --logpath /var/log/mongodb/config.log --fork --config /etc/mongod.conf --keyFile /etc/mongokeyfile --sslMode requireSSL --sslPEMKeyFile /etc/MongoAuthCert.pem --sslPEMKeyPassword Mongo123
}
stop() {
pkill mongod
}
restart() {
stop
sleep 15
start
}

case "\$1" in
    start)
	start;;
	stop)
	stop;;
	restart)
	restart;;
	status)
	status \$Name;;
	*)
	echo "Usage: service mongod1 start|stop|restart|status"
esac
EOF
chmod +x /etc/init.d/mongod1
chkconfig mongod1 on
