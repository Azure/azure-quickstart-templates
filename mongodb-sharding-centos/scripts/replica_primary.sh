#!/bin/bash

replSetName=$1
staticIP=$2
mongoAdminUser=$3
mongoAdminPasswd=$4
zabbixServer=$5

install_mongo3() {
#create repo
cat > /etc/yum.repos.d/mongodb-org-3.2.repo <<EOF
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1
EOF

	#install
	yum install -y mongodb-org

	#ignore update
	sed -i '$a exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools' /etc/yum.conf

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
}


disk_format() {
	cd /tmp
	yum install wget -y
	for ((j=1;j<=3;j++))
	do
		wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh 
		if [[ -f /tmp/vm-disk-utils-0.1.sh ]]; then
			bash /tmp/vm-disk-utils-0.1.sh -b /var/lib/mongo -s
			if [[ $? -eq 0 ]]; then
				sed -i 's/disk1//' /etc/fstab
				umount /var/lib/mongo/disk1
				mount /dev/md0 /var/lib/mongo
			fi
			break
		else
			echo "download vm-disk-utils-0.1.sh failed. try again."
			continue
		fi
	done
		
}


install_zabbix() {
	#install zabbix agent
	cd /tmp
	yum install -y gcc wget > /dev/null 
	wget http://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/2.2.5/zabbix-2.2.5.tar.gz > /dev/null
	tar zxvf zabbix-2.2.5.tar.gz
	cd zabbix-2.2.5
	groupadd zabbix
	useradd zabbix -g zabbix -s /sbin/nologin
	mkdir -p /usr/local/zabbix
	./configure --prefix=/usr/local/zabbix --enable-agent
	make install > /dev/null
	cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
	sed -i 's/BASEDIR=\/usr\/local/BASEDIR=\/usr\/local\/zabbix/g' /etc/init.d/zabbix_agentd
	sed -i '$azabbix-agent    10050/tcp\nzabbix-agent    10050/udp' /etc/services
	sed -i '/^LogFile/s/tmp/var\/log/' /usr/local/zabbix/etc/zabbix_agentd.conf
	hostName=`hostname`
	sed -i "s/^Hostname=Zabbix server/Hostname=$hostName/" /usr/local/zabbix/etc/zabbix_agentd.conf
	if [[ $zabbixServer =~ ([0-9]{1,3}.){3}[0-9]{1,3} ]];then
		sed -i "s/^Server=127.0.0.1/Server=$zabbixServer/" /usr/local/zabbix/etc/zabbix_agentd.conf
		sed -i "s/^ServerActive=127.0.0.1/ServerActive=$zabbixServer/" /usr/local/zabbix/etc/zabbix_agentd.conf
		sed -i "s/^Server=127.0.0.1/Server=$zabbixServer/" /usr/local/zabbix/etc/zabbix_agent.conf
	fi
	touch /var/log/zabbix_agentd.log
	chown zabbix:zabbix /var/log/zabbix_agentd.log

	#start zabbix agent
	chkconfig --add zabbix_agentd
	chkconfig zabbix_agentd on
	/etc/init.d/zabbix_agentd start
}


install_mongo3
disk_format
install_zabbix


#start mongod
mongod --dbpath /var/lib/mongo/ --logpath /var/log/mongodb/mongod.log --fork

sleep 30
n=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |wc -l`
if [[ $n -eq 1 ]];then
	echo "mongod started successfully"
else
	echo "mongod started failed!"
fi



#create users
mongo <<EOF
use admin
db.createUser({user:"$mongoAdminUser",pwd:"$mongoAdminPasswd",roles:[{role: "userAdminAnyDatabase", db: "admin" },{role: "readWriteAnyDatabase", db: "admin" },{role: "root", db: "admin" }]})
exit
EOF
if [[ $? -eq 0 ]];then
	echo "mongo user added succeefully."
else
	echo "mongo user added failed!"
fi

#stop mongod
sleep 15
MongoPid=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |awk '{print $2}'`
kill -2 $MongoPid



#set keyfile
echo "vfr4CDE1" > /etc/mongokeyfile
chown mongod:mongod /etc/mongokeyfile
chmod 600 /etc/mongokeyfile
sed -i 's/^#security/security/' /etc/mongod.conf
sed -i '/^security/akeyFile: /etc/mongokeyfile' /etc/mongod.conf
sed -i 's/^keyFile/  keyFile/' /etc/mongod.conf

sleep 15
MongoPid1=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |awk '{print $2}'`
if [[ -z $MongoPid1 ]];then
	echo "shutdown mongod successfully"
else
	echo "shutdown mongod failed!"
	kill $MongoPid1
	sleep 15
fi

#restart mongod with auth and replica set
mongod --dbpath /var/lib/mongo/ --replSet $replSetName --logpath /var/log/mongodb/mongod.log --fork --config /etc/mongod.conf





#initiate replica set
for((i=1;i<=3;i++))
do
	sleep 15
	n=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |wc -l`
	if [[ $n -eq 1 ]];then
		echo "mongo replica set started successfully"
		break
	else
		mongod --dbpath /var/lib/mongo/ --replSet $replSetName --logpath /var/log/mongodb/mongod.log --fork --config /etc/mongod.conf
		continue
	fi
done

n=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |wc -l`
if [[ $n -ne 1 ]];then
	echo "mongo replica set tried to start 3 times but failed!"
fi



mongo<<EOF
use admin
db.auth("$mongoAdminUser", "$mongoAdminPasswd")
config ={_id:"$replSetName",members:[{_id:0,host:"$staticIP:27017"}]}
rs.initiate(config)
exit
EOF
if [[ $? -eq 0 ]];then
	echo "replica set initiation succeeded."
else
	echo "replica set initiation failed!"
fi


#get replica secondary nodes ips
num=`echo $staticIP |awk -F"." '{print $NF}'`
if [[ $num -eq 100 ]];then
	let g=$num-97
elif [[ $num -eq 110 ]];then
	let g=$num-105
fi

#add secondary nodes
for((i=1;i<=2;i++))
do
	let a=$i+$g
	mongo -u "$mongoAdminUser" -p "$mongoAdminPasswd" "admin" --eval "printjson(rs.add('10.0.0.${a}:27017'))"
	if [[ $? -eq 0 ]];then
		echo "adding server 10.0.0.${a} successfully"
	else
		echo "adding server 10.0.0.${a} failed!"
	fi
done




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
mongod --dbpath /var/lib/mongo/ --replSet $replSetName --logpath /var/log/mongodb/mongod.log --fork --config /etc/mongod.conf
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


