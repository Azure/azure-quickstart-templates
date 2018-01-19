#/bin/bash


mysqlPassword=$1
insertValue=$2
zabbixServer=$3
masterIP=10.0.0.20

	
install_ap() {


	#install apache 2.4 php5
	yum install httpd php php-mysql -y


	#start httpd
	service httpd start

	#auto-start 
	chkconfig httpd on
	chkconfig firewalld off
	chkconfig iptables off
	service firewalld stop
	service iptables stop

	#set selinux
	sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
	sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
	setenforce 0

}


disk_format() {
	cd /tmp
	yum install wget -y
	for ((j=1;j<=3;j++))
	do
		wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh 
		if [[ -f /tmp/vm-disk-utils-0.1.sh ]]; then
			bash /tmp/vm-disk-utils-0.1.sh -b /var/www/html -s
			if [[ $? -eq 0 ]]; then
				sed -i 's/disk1//' /etc/fstab
				umount /var/www/html/disk1
				mount /dev/md0 /var/www/html
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
	for((n=1;n<=5;n++))
	do
		wget http://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/2.2.5/zabbix-2.2.5.tar.gz
		if [[ $? -eq 0 ]];then
			break
		else
			continue
		fi
	done
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


create_test_page() {
#create test php page
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF

#create test php-mysql page
cat > /var/www/html/mysql.php <<EOF
<?php
\$conn = mysql_connect('$masterIP', 'root', '$mysqlPassword');
if (!\$conn) {
    die('Could not connect:' . mysql_error());
}
echo 'Connected to MySQL sucessfully!';

if(mysql_query("create database testdb")){
    echo "    Created database testdb successfully!";
}else{
    echo "    Database testdb already exists!";
}

\$db_selected = mysql_select_db('testdb',\$conn);

if(mysql_query("create table test01(name varchar(10))")){
    echo "    Created table test01 successfuly!";
}else{
    echo "    Table test01 already exists!";
}

if(mysql_query("insert into test01 values ('$insertValue')")){
    echo "    Inserted value $insertValue into test01 successfully!";
}else{
    echo "    Inserted value $insertValue into test01 failed!";
}

\$result = mysql_query("select * from testdb.test01");
while(\$row = mysql_fetch_array(\$result))
{
echo "    Welcome ";
echo \$row["name"];
echo "!!!";
}

mysql_close(\$conn)
?>
EOF

}




install_ap
disk_format
create_test_page
install_zabbix