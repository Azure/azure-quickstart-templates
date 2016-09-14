#!/bin/bash

adminUser=$1
#dataNodeCount=$2
#adminPassword=$3
zabbixServer=$2


prerequisiteInstall() {
apt-get update -y
apt-get install expect -y
apt-get install openjdk-7-jdk -y

}

disk_format() {
	cd /tmp
	mkdir /data
	for ((p=1;p<=3;p++))
	do
		wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh 
		if [[ -f /tmp/vm-disk-utils-0.1.sh ]]; then
		    sed -i 's/apt-get -y install mdadm/apt-get -y install mdadm --no-install-recommends/' /tmp/vm-disk-utils-0.1.sh
			bash /tmp/vm-disk-utils-0.1.sh -b /data/ -s
			if [[ $? -eq 0 ]]; then
				sed -i 's/disk1//' /etc/fstab
				umount /data/disk1
				mount /dev/md0 /data
				chown -R ${adminUser}:${adminUser} /data
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
	apt-get install gcc make -y > /dev/null
	for((q=1;q<=5;q++))
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
	cp /usr/local/zabbix/sbin/zabbix_agentd /etc/init.d/
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
	sed -i '$i /etc/init.d/zabbix_agentd' /etc/rc.local
	/etc/init.d/zabbix_agentd

}


prerequisiteInstall
disk_format
install_zabbix