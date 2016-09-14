
#!/bin/bash

adminUser=$1
dataNodeCount=$2
adminPassword=$3
zabbixServer=$4


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



cat >> /home/${adminUser}/hadoop.sh <<EOO

adminUser=\$1
dataNodeCount=\$2
adminPassword=\$3
zabbixServer=\$4

hadoopConfigure() {
if [[ ! -d /data ]];then
    echo "Error: No directory /data found. Exit."
	exit
fi
cd /data
wget http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
tar -zxf hadoop-2.7.3.tar.gz
if [[ ! -d /data/hadoop-2.7.3 ]];then
    echo "Error:no hadoop directory found. Exit."
    exit
fi
cd hadoop-2.7.3
mkdir tmp
mkdir hdfs
mkdir hdfs/data
mkdir hdfs/name

cd etc/hadoop

#configure core-stie.xml
sed -i '\$d' core-site.xml
cat >> core-site.xml << EOF
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://10.0.0.240:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>file:/data/hadoop-2.7.3/tmp</value>
    </property>
    <property>
        <name>io.file.buffer.size</name>
        <value>131702</value>
    </property>
</configuration>
EOF

#configure hdfs-site.xml
sed -i '\$d' hdfs-site.xml
cat >> hdfs-site.xml <<EOF
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/data/hadoop-2.7.3/hdfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/data/hadoop-2.7.3/hdfs/data</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>\${dataNodeCount}</value>
    </property>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>10.0.0.240:9001</value>
    </property>
    <property>
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
    </property>
</configuration>
EOF


#configure yarn-site.xml
sed -i '\$d' yarn-site.xml
cat >> yarn-site.xml <<EOF
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>10.0.0.240:10020</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>10.0.0.240:19888</value>
    </property>
</configuration>
EOF


#configure mapred-site.xml
cp mapred-site.xml.template mapred-site.xml
sed -i '\$d' mapred-site.xml
cat >> mapred-site.xml <<EOF
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>10.0.0.240:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>10.0.0.240:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>10.0.0.240:8031</value>
    </property>
    <property>
        <name>yarn.resourcemanager.admin.address</name>
        <value>10.0.0.240:8033</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>10.0.0.240:8088</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>1024</value>
    </property>
</configuration>
EOF

#configure hadoop-env.sh
sed -i 's#export JAVA_HOME=\${JAVA_HOME}#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre#' hadoop-env.sh

#configure yarn-env.sh
sed -i 's%# export JAVA_HOME=/home/y/libexec/jdk1.6.0/%export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre%' yarn-env.sh


#configure slaves
for((i=1;i<=\${dataNodeCount};i++))
do
    let j=3+i
	sed -i '\$i 10.0.0.'\${j}'' slaves
done
sed -i '\$d' slaves
}



noSSHAuth() {
if [[ ! -f /home/\${adminUser}/.ssh/id_rsa ]];then
    ssh-keygen -q -t rsa -N "" -f /home/\${adminUser}/.ssh/id_rsa
fi
auto_ssh_copy_id () {

    expect -c "set timeout -1;
                spawn ssh-copy-id \$2;
                expect {
                    *(yes/no)* {send -- yes\r;exp_continue;}
                    *assword:* {send -- \$1\r;exp_continue;}
                    eof        {exit 0;}
                }";
}  
for((k=1;k<=\${dataNodeCount};k++))
do
    let m=3+k
    auto_ssh_copy_id \${adminPassword} 10.0.0.\${m}
done
auto_ssh_copy_id \${adminPassword} 10.0.0.240
auto_ssh_copy_id \${adminPassword} 127.0.0.1

}


fileTransfer() {
cd /data
for((n=1;n<=\${dataNodeCount};n++))
do
    let o=3+n
	scp -r hadoop-2.7.3 10.0.0.\${o}:/data/
done

}

hadoopStart() {
cd /data/hadoop-2.7.3
bin/hdfs namenode -format
sbin/start-all.sh

}



hadoopConfigure
noSSHAuth
fileTransfer
hadoopStart
EOO

chown ${adminUser}:${adminUser} /home/${adminUser}/hadoop.sh


prerequisiteInstall
disk_format
install_zabbix


su - ${adminUser} <<EOF
bash /home/${adminUser}/hadoop.sh ${adminUser} ${dataNodeCount} ${adminPassword} ${zabbixServer}
EOF

