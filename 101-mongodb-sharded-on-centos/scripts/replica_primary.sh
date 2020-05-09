#!/bin/bash

replSetName=$1
staticIP=$2
mongoAdminUser=$3
mongoAdminPasswd=$4
dnsNamePrefix=$5
mongoSslCertPswd=$6

GetMongoPackage() {
	packageUri=$1
	
	while true; do
	#install mongo package
    wget $packageUri && break || {
      if [[ $n -lt 3 ]]; then
        ((n++))
        echo "Command failed. Attempt $n of 3:"
        sleep 15;
      else
        echo "Failed to get the package $packageUri after $n attempts."
		exit 1
      fi
    }
  	done
}

install_mongo3() {

	#install
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


disk_format() {
	cd /tmp
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

yum install wget -y
echo "Generating ssl certificate"
openssl req -newkey rsa:2048 -nodes -keyout /etc/key.pem -x509 -days 365 -out /etc/certificate.pem -subj "/CN=$dnsNamePrefix"
openssl pkcs12 -inkey /etc/key.pem -in /etc/certificate.pem -export -out /etc/MongoAuthCert.p12 -passout pass:$mongoSslCertPswd
openssl pkcs12 -in /etc/MongoAuthCert.p12 -out /etc/MongoAuthCert.pem -passin pass:$mongoSslCertPswd -passout pass:$mongoSslCertPswd

GetMongoPackage "https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-server-3.6.17-1.el7.x86_64.rpm"
GetMongoPackage "https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-shell-3.6.17-1.el7.x86_64.rpm"
install_mongo3
disk_format

#start mongod
mongod --dbpath /var/lib/mongo/ --logpath /var/log/mongodb/mongod.log --bind_ip 0.0.0.0 --fork --sslMode requireSSL --sslPEMKeyFile /etc/MongoAuthCert.pem --sslPEMKeyPassword $mongoSslCertPswd

sleep 30
n=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |wc -l`
if [[ $n -eq 1 ]];then
	echo "mongod started successfully"
else
	echo "mongod started failed!"
	exit 1
fi


#create users
mongo --ssl --sslCAFile /etc/MongoAuthCert.pem --sslAllowInvalidHostnames<<EOF
use admin
db.createUser({user:"$mongoAdminUser",pwd:"$mongoAdminPasswd",roles:[{role: "userAdminAnyDatabase", db: "admin" },{role: "readWriteAnyDatabase", db: "admin" },{role: "root", db: "admin" }]})
exit
EOF
if [[ $? -eq 0 ]];then
	echo "mongo user added succeefully."
else
	echo "mongo user added failed!"
	exit 1
fi

#stop mongod
sleep 15
MongoPid=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |awk '{print $2}'`
kill -2 $MongoPid



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
mongod --dbpath /var/lib/mongo/ --shardsvr --replSet $replSetName --logpath /var/log/mongodb/mongod.log --bind_ip 0.0.0.0 --fork --config /etc/mongod.conf --sslMode requireSSL --sslPEMKeyFile /etc/MongoAuthCert.pem --sslPEMKeyPassword $mongoSslCertPswd


#initiate replica set
for((i=1;i<=3;i++))
do
	sleep 15
	n=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |wc -l`
	if [[ $n -eq 1 ]];then
		echo "mongo replica set started successfully"
		break
	else
		mongod --dbpath /var/lib/mongo/ --shardsvr --replSet $replSetName --logpath /var/log/mongodb/mongod.log --bind_ip 0.0.0.0 --fork --config /etc/mongod.conf --sslMode requireSSL --sslPEMKeyFile /etc/MongoAuthCert.pem --sslPEMKeyPassword $mongoSslCertPswd
		continue
	fi
done

n=`ps -ef |grep "mongod --dbpath /var/lib/mongo/" |grep -v grep |wc -l`
if [[ $n -ne 1 ]];then
	echo "mongo replica set tried to start 3 times but failed!"
	exit 1
fi



mongo --ssl --sslCAFile /etc/MongoAuthCert.pem --sslAllowInvalidHostnames<<EOF
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
	exit 1
fi


#get replica secondary nodes ips
num=`echo $staticIP |awk -F"." '{print $NF}'`
if [[ $num -eq 100 ]];then
	let g=$num-97
elif [[ $num -eq 110 ]];then
	let g=$num-105
fi

#add secondary nodes
for((i=1;i<=3;i++))
do
	let a=$i+$g
	mongo -u "$mongoAdminUser" -p "$mongoAdminPasswd" "admin" --ssl --sslCAFile /etc/MongoAuthCert.pem --sslAllowInvalidHostnames --eval "printjson(rs.add('10.0.0.${a}:27017'))"
	if [[ $? -eq 0 ]];then
		echo "adding server 10.0.0.${a} successfully"
	else
		echo "adding server 10.0.0.${a} failed!"
		exit 1
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
mongod --dbpath /var/lib/mongo/ --shardsvr --replSet $replSetName --logpath /var/log/mongodb/mongod.log --bind_ip 0.0.0.0 --fork --config /etc/mongod.conf --sslMode requireSSL --sslPEMKeyFile /etc/MongoAuthCert.pem --sslPEMKeyPassword $mongoSslCertPswd
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


