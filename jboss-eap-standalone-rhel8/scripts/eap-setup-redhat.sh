#!/bin/sh

# $1 - VM Host User Name

/bin/date +%H:%M:%S >> /home/$1/install.progress.txt
echo "ooooo      REDHAT EAP7.2 RPM INSTALL      ooooo" >> /home/$1/install.progress.txt

export EAP_HOME="/opt/rh/eap7/root/usr/share/wildfly"
export EAP_RPM_CONF_STANDALONE="/etc/opt/rh/eap7/wildfly/eap7-standalone.conf"
export EAP_RPM_CONF_DOMAIN="/etc/opt/rh/eap7/wildfly/eap7-domain.conf"

EAP_USER=$2
EAP_PASSWORD=$3
RHSM_USER=$4
RHSM_PASSWORD=$5
export RHSM_POOL=$6

PROFILE=standalone 
echo "EAP admin user"+${EAP_USER} >> /home/$1/install.progress.txt
echo "Initial EAP7.2 setup" >> /home/$1/install.progress.txt
subscription-manager register --username $RHSM_USER --password $RHSM_PASSWORD  >> /home/$1/install.progress.txt 2>&1
subscription-manager attach --pool=${RHSM_POOL} >> /home/$1/install.progress.txt 2>&1
echo "Subscribing the system to get access to EAP 7.2 repos" >> /home/$1/install.progress.txt

# Install EAP7.2 
subscription-manager repos --enable=jb-eap-7.2-for-rhel-8-x86_64-rpms >> /home/$1/install.out.txt 2>&1


echo "Installing EAP7.2 repos" >> /home/$1/install.progress.txt
yum groupinstall -y jboss-eap7 >> /home/$1/install.out.txt 2>&1

echo "Enabling EAP7.2 service" >> /home/$1/install.progress.txt
systemctl enable eap7-standalone.service

echo "Configure EAP7.2 RPM file" >> /home/$1/install.progress.txt

echo "WILDFLY_SERVER_CONFIG=standalone-full.xml" >> ${EAP_RPM_CONF_STANDALONE}
echo 'WILDFLY_OPTS="-Djboss.bind.address.management=0.0.0.0"' >> ${EAP_RPM_CONF_STANDALONE}

echo "Installing GIT" >> /home/$1/install.progress.txt
yum install -y git >> /home/$1/install.out.txt 2>&1

cd /home/$1
echo "Getting the sample dukes app to install" >> /home/$1/install.progress.txt
git clone https://github.com/MyriamFentanes/dukes.git >> /home/$1/install.out.txt 2>&1
mv /home/$1/dukes/target/dukes.war $EAP_HOME/standalone/deployments/dukes.war
cat > $EAP_HOME/standalone/deployments/dukes.war.dodeploy

echo "Configuring EAP managment user" >> /home/$1/install.progress.txt
$EAP_HOME/bin/add-user.sh -u $EAP_USER -p $EAP_PASSWORD -g 'guest,mgmtgroup'

echo "Start EAP 7.2" >> /home/$1/install.progress.txt
systemctl restart eap7-standalone.service 

# Open Red Hat software firewall for port 8080 and 9990:
firewall-cmd --zone=public --add-port=8080/tcp --permanent  >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=9990/tcp --permanent  >> /home/$1/install.out.txt 2>&1
firewall-cmd --reload  >> /home/$1/install.out.txt 2>&1
    
echo "Done." >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt

# Open Red Hat software firewall for port 22:
firewall-cmd --zone=public --add-port=22/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --reload >> /home/$1/install.out.txt 2>&1

# Seeing a race condition timing error so sleep to delay
sleep 20

echo "ALL DONE!" >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt
