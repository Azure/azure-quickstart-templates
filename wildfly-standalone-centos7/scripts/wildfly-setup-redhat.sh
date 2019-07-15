#!/bin/sh

echo "Red Hat WILDFLY 16.0.0.Final Standalone Intallation Start..." >> /home/$1/install.log
/bin/date +%H:%M:%S  >> /home/$1/install.log

export WILDFLY_USER=$2
export WILDFLY_PASSWORD=$3

echo "WILDFLY_USER: " ${WILDFLY_USER} >> /home/$1/install.log
echo "WILDFLY_PASSWORD: " ${WILDFLY_PASSWORD} >> /home/$1/install.log

echo "WILDFLY Downloading..." >> /home/$1/install.log
cd /home/$1
yum install -y git unzip java
curl https://download.jboss.org/wildfly/16.0.0.Final/wildfly-16.0.0.Final.zip -o wildfly-16.0.0.Final.zip
unzip wildfly-16.0.0.Final.zip

echo "Sample app deploy..." >> /home/$1/install.log 
git clone https://github.com/RedHat-Middleware-Workshops/msft-eap-quickstarts-app.git
/bin/cp -rf /home/$1/dukes/target/dukes.war /home/$1/wildfly-16.0.0.Final/standalone/deployments/

echo "Configuring WILDFLY managment user..." >> /home/$1/install.log 
/home/$1/wildfly-16.0.0.Final/bin/add-user.sh -u $WILDFLY_USER -p $WILDFLY_PASSWORD -g 'guest,mgmtgroup' 

echo "Start WILDFLY 16.0.0.Final instance..." >> /home/$1/install.log 
/home/$1/wildfly-16.0.0.Final/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 > /dev/null 2>&1 &

echo "Configure firewall for ports 8080, 9990..." >> /home/$1/install.log 
firewall-cmd --zone=public --add-port=8080/tcp --permanent 
firewall-cmd --zone=public --add-port=9990/tcp --permanent 
firewall-cmd --reload 

echo "Update SSHd config to not use passwords and set default umask to be 002..." >> /home/$1/install.log
/bin/cp /etc/ssh/sshd_config /etc/ssh/ORIG_sshd_config
sed -i 's,PasswordAuthentication yes,PasswordAuthentication no,g' /etc/ssh/sshd_config
echo "Match User "$1 >> /etc/ssh/sshd_config
echo "    ForceCommand internal-sftp -u 002" >> /etc/ssh/sshd_config

echo "Configure the default umask for SSH to enable RW for user and group..." >> /home/$1/install.log
/bin/cp /etc/pam.d/sshd /etc/pam.d/ORIG_sshd
echo "session optional pam_umask.so umask=002" >> /etc/pam.d/sshd

echo "Start the SSH daemon..." >> /home/$1/install.log
systemctl daemon-reload
systemctl start sshd.service
systemctl enable sshd.service

echo "Open Red Hat software firewall for port 22..." >> /home/$1/install.log
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --reload

echo "Create an RSA public and private key for SSH..." >> /home/$1/install.log
cd /home/$1
mkdir /home/$1/.ssh
ssh-keygen -q -N $4 -f /home/$1/.ssh/id_rsa
cd /home/$1/.ssh
cp id_rsa.pub authorized_keys
echo "SSH User name:  "$1 > /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 >> /home/$1/vsts_ssh_info
echo "SSH Private key:" >> /home/$1/vsts_ssh_info
cat id_rsa >> /home/$1/vsts_ssh_info

echo "Configure SELinux to use Linux ACL's for file protection..." >> /home/$1/install.log
setsebool -P allow_ftpd_full_access 1

echo "Red Hat WILDFLY 16.0.0.Final Standalone Intallation End..." >> /home/$1/install.log
/bin/date +%H:%M:%S >> /home/$1/install.log