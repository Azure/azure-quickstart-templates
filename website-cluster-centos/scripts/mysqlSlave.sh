#/bin/bash


mysqlPassword=$1
zabbixServer=$2
masterIP=10.0.0.20


	
install_mysql() {

	#get repo
	yum install wget -y
	for((i=1;i<=5;i++))
	do
		wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
		if [[ $? -ne 0 ]];then
			if [[ $i == 5 ]];then
				echo "tried 5 times to download repo but failed. exit. try again later."
				exit 1
			fi
			continue
		else
			echo "download repo successfully"
			break
		fi
	done
	yum localinstall -y mysql-community-release-el6-5.noarch.rpm

	#install mysql 5.6
	for((i=1;i<=5;i++))
	do
		yum install -y mysql-community-server
		if [[ $? -ne 0 ]];then
			if [[ $i == 5 ]];then
				echo "tried 5 times to install mysql server but failed. exit. try again later."
				exit 10
			fi
			yum clean all
			continue
		else
			echo "installed mysql server successfully."
			break
		fi
	done

	#configure my.cnf
	sed -i '/\[mysqld\]/a server-id = 2\nlog_bin = /var/lib/mysql/mysql-bin.log\nreplicate-ignore-db = mysql' /etc/my.cnf
	
	#auto-start
	chkconfig mysqld on
	

}


disk_format() {
	cd /tmp
	yum install wget -y
	for ((j=1;j<=3;j++))
	do
		wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh 
		if [[ -f /tmp/vm-disk-utils-0.1.sh ]]; then
			bash /tmp/vm-disk-utils-0.1.sh -b /var/lib/mysql -s
			if [[ $? -eq 0 ]]; then
				sed -i 's/disk1//' /etc/fstab
				umount /var/lib/mysql/disk1
				mount /dev/md0 /var/lib/mysql
				chown -R mysql:mysql /var/lib/mysql
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

start_mysql() {
	#start mysql
	service mysqld start

	#set mysql root password
	mysqladmin -uroot password "$mysqlPassword" 2> /dev/null

	#grant privileges
	mysql -uroot -p$mysqlPassword -e "grant all privileges on *.* to 'root'@'%' identified by '$mysqlPassword';flush privileges;"

	#configure slave
	mysql -uroot -p$mysqlPassword -e "change master to master_host='$masterIP',master_user='repluser',master_password='replpass';start slave;"
	slaveStatus=`mysql -uroot -p$mysqlPassword -e "show slave status\G" |grep -i "Running: Yes"|wc -l`
	if [[ $slaveStatus -ne 2 ]];then
		echo "master-slave replication issue!"
	else
		echo "master-slave configuration succeeds! "
	fi

}

install_mysql
disk_format
install_zabbix
start_mysql