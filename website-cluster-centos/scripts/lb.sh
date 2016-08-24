#/bin/bash

webNodeCount=$1
zabbixServer=$2


	
install_haproxy() {
	cd /tmp
	yum install wget -y
		for((i=1;i<=5;i++))
		do
			wget http://www.haproxy.org/download/1.6/src/haproxy-1.6.3.tar.gz
			if [[ $? -eq 0 ]];then
				break
			else
				continue
			fi
		done
	tar zxvf haproxy-1.6.3.tar.gz
	cd haproxy-1.6.3
	yum install gcc -y
	make TARGET=linux2628 PREFIX=/usr/local/haproxy
	make install PREFIX=/usr/local/haproxy


}


disk_format() {
	cd /tmp
	mkdir /data
	yum install wget -y
	for ((j=1;j<=3;j++))
	do
		wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh 
		if [[ -f /tmp/vm-disk-utils-0.1.sh ]]; then
			bash /tmp/vm-disk-utils-0.1.sh -b /data/ -s
			if [[ $? -eq 0 ]]; then
				sed -i 's/disk1//' /etc/fstab
				umount /data/disk1
				mount /dev/md0 /data
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


config_haproxy() {
haproxyConfigFile="/usr/local/haproxy/haproxy.cfg"
cat > ${haproxyConfigFile} <<EOF
global         
       maxconn 4096           
       chroot /usr/local/haproxy
        uid 99                 
        gid 99               
       daemon                  
       pidfile /usr/local/haproxy/haproxy.pid  

defaults             
       log    global
        log     127.0.0.1       local3        
       mode    http         
       option  httplog       
        option  dontlognull  
        option  httpclose    
       retries 3           
       option  redispatch   
       maxconn 2000                     
       timeout connect     5000           
       timeout client     50000          
       timeout server     50000          

frontend http-in                       
       bind *:80
        mode    http 
        option  httplog
        log     global
        default_backend httppool 
       
backend httppool                    
       balance source
EOF


	for ((k=1;k<=$webNodeCount;k++))
	do
		let ip=3+$k
		sed -i "\$a server  web${k} 10.0.0.${ip}:80  weight 5 check inter 2000 rise 2 fall 3" ${haproxyConfigFile}
		sed -i '$s/^/       /' ${haproxyConfigFile}
	done	

	#start haproxy
	/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg
}




install_haproxy
disk_format
config_haproxy
install_zabbix