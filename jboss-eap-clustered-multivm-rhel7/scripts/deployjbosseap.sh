#!/bin/sh

# $1 - VM Host User Name

echo "Red Hat JBoss EAP 7.2 Cluster Intallation Start " >> /home/$1/install.log
/bin/date +%H:%M:%S  >> /home/$1/install.log

export EAP_HOME="/opt/rh/eap7/root/usr/share"
export EAP_RPM_CONF_STANDALONE="/etc/opt/rh/eap7/wildfly/eap7-standalone.conf"
export EAP_USER=$2
export EAP_PASSWORD=$3
export RHSM_USER=$4
export RHSM_PASSWORD=$5
export RHSM_POOL=$6
export IP_ADDR=$7
export STORAGE_ACCOUNT_NAME=${8}
export CONTAINER_NAME=$9
export STORAGE_ACCESS_KEY=$(echo "${10}" | openssl enc -d -base64)

echo "EAP admin user"+${EAP_USER} >> /home/$1/install.log
echo "Private IP Address of VM"+${IP_ADDR} >> /home/$1/install.log
echo "Storage Account Name"+${STORAGE_ACCOUNT_NAME} >> /home/$1/install.log
echo "Storage Container Name"+${CONTAINER_NAME} >> /home/$1/install.log
echo "Storage Account Access Key"+${STORAGE_ACCESS_KEY} >> /home/$1/install.log
echo "RHSM_USER: " ${RHSM_USER} >> /home/$1/install.log
echo "RHSM_POOL: " ${RHSM_POOL} >> /home/$1/install.log

echo "Configure firewall for ports 8080, 8180, 9990, 10090..." >> /home/$1/install.log 

sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9990/tcp --permanent
sudo firewall-cmd --zone=public --add-port=45700/tcp --permanent
sudo firewall-cmd --zone=public --add-port=7600/tcp --permanent
sudo firewall-cmd --zone=public --add-port=55200/tcp --permanent
sudo firewall-cmd --zone=public --add-port=45688/tcp --permanent
sudo firewall-cmd --reload
sudo iptables-save

echo "Install openjdk, wget, git, unzip, vim"  >> /home/$1/install.log
sudo yum install java-1.8.0-openjdk wget unzip vim git -y

echo "Initial EAP7.2 setup" >> /home/$1/install.log
subscription-manager register --username $RHSM_USER --password $RHSM_PASSWORD
subscription-manager attach --pool=${RHSM_POOL}
echo "Subscribing the system to get access to EAP 7.2 repos" >> /home/$1/install.log

# Install EAP7.2 
subscription-manager repos --enable=jb-eap-7-for-rhel-7-server-rpms >> /home/$1/install.log
yum-config-manager --disable rhel-7-server-htb-rpms

echo "Installing EAP7.2 repos" >> /home/$1/install.log
yum groupinstall -y jboss-eap7 >> /home/$1/install.log

echo "Enabling EAP7.2 service" >> /home/$1/install.log
systemctl enable eap7-standalone.service

echo "Configure EAP7.2 RPM file" >> /home/$1/install.log

echo "WILDFLY_SERVER_CONFIG=standalone-full.xml" >> ${EAP_RPM_CONF_STANDALONE}
echo 'WILDFLY_OPTS="-Djboss.bind.address.management=0.0.0.0"' >> ${EAP_RPM_CONF_STANDALONE}

echo "Copy the standalone-azure-ha.xml from EAP_HOME/doc/wildfly/examples/configs folder to EAP_HOME/wildfly/standalone/configuration folder" >> /home/$1/install.log
cp $EAP_HOME/doc/wildfly/examples/configs/standalone-azure-ha.xml $EAP_HOME/wildfly/standalone/configuration/

echo "change the jgroups stack from UDP to TCP " >> /home/$1/install.log

sed -i 's/stack="udp"/stack="tcp"/g'  $EAP_HOME/wildfly/standalone/configuration/standalone-azure-ha.xml

echo "Update interfaces section update jboss.bind.address.management, jboss.bind.address and jboss.bind.address.private from 127.0.0.1 to 0.0.0.0" >> /home/$1/install.log
sed -i 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/g'  $EAP_HOME/wildfly/standalone/configuration/standalone-azure-ha.xml
sed -i 's/jboss.bind.address:127.0.0.1/jboss.bind.address:0.0.0.0/g'  $EAP_HOME/wildfly/standalone/configuration/standalone-azure-ha.xml
sed -i 's/jboss.bind.address.private:127.0.0.1/jboss.bind.address.private:0.0.0.0/g'  $EAP_HOME/wildfly/standalone/configuration/standalone-azure-ha.xml

echo "start jboss server" >> /home/$1/install.log

$EAP_HOME/wildfly/bin/standalone.sh -bprivate $IP_ADDR --server-config=standalone-azure-ha.xml -Djboss.jgroups.azure_ping.storage_account_name=$STORAGE_ACCOUNT_NAME -Djboss.jgroups.azure_ping.storage_access_key=$STORAGE_ACCESS_KEY -Djboss.jgroups.azure_ping.container=$CONTAINER_NAME -Djava.net.preferIPv4Stack=true &

echo "export EAP_HOME="/opt/rh/eap7/root/usr/share"" >>/bin/jbossservice.sh
echo "$EAP_HOME/wildfly/bin/standalone.sh -bprivate $IP_ADDR --server-config=standalone-azure-ha.xml -Djboss.jgroups.azure_ping.storage_account_name=$STORAGE_ACCOUNT_NAME -Djboss.jgroups.azure_ping.storage_access_key=$STORAGE_ACCESS_KEY -Djboss.jgroups.azure_ping.container=$CONTAINER_NAME -Djava.net.preferIPv4Stack=true &" > /bin/jbossservice.sh
chmod +x /bin/jbossservice.sh

yum install cronie cronie-anacron
service crond start
chkconfig crond on
echo "@reboot sleep 90 && /bin/jbossservice.sh" >>  /etc/crontab	

echo "deploy an application " >> /home/$1/install.log
git clone https://github.com/danieloh30/eap-session-replication.git
cp eap-session-replication/target/eap-session-replication.war $EAP_HOME/wildfly/standalone/deployments/
touch $EAP_HOME/wildfly/standalone/deployments/eap-session-replication.war.dodeploy

echo "Configuring EAP managment user..." >> /home/$1/install.log 
$EAP_HOME/wildfly/bin/add-user.sh  -u $EAP_USER -p $EAP_PASSWORD -g 'guest,mgmtgroup'

# Seeing a race condition timing error so sleep to deplay
sleep 20

echo "Red Hat JBoss EAP 7.2 Cluster Intallation End " >> /home/$1/install.log
/bin/date +%H:%M:%S  >> /home/$1/install.log