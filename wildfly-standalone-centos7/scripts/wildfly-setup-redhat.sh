#!/bin/sh

echo "Red Hat WILDFLY 16.0.0.Final Standalone Intallation Start: " | /bin/date +%H:%M:%S  >> /home/$1/install.log

export WILDFLY_HOME="/home/"$1"/wildfly-16.0.0.Final"
export SVR_CONFIG="standalone-full.xml"
export WILDFLY_USER=$2
export WILDFLY_PASSWORD=$3

echo "SVR_CONFIG: " ${SVR_CONFIG} >> /home/$1/install.log
echo "WILDFLY_USER: " ${WILDFLY_USER} >> /home/$1/install.log
echo "WILDFLY_PASSWORD: " ${WILDFLY_PASSWORD} >> /home/$1/install.log

echo "WILDFLY Downloading..." >> /home/$1/install.log
cd /home/$1
yum install -y git unzip
curl https://download.jboss.org/wildfly/16.0.0.Final/wildfly-16.0.0.Final.zip -o wildfly-16.0.0.Final.zip
unzip wildfly-16.0.0.Final.zip

echo "Sample app deploy..." >> /home/$1/install.log 
git clone https://github.com/MyriamFentanes/dukes.git
/bin/cp -rf /home/$1/dukes/target/dukes.war $WILDFLY_HOME/deployments/

echo "Configuring WILDFLY managment user..." >> /home/$1/install.log 
$WILDFLY_HOME/bin/add-user.sh -u $WILDFLY_USER -p $WILDFLY_PASSWORD -g 'guest,mgmtgroup' 

echo "Start WILDFLY 16.0.0.Final instance..." >> /home/$1/install.log 
$WILDFLY_HOME/bin/standalone.sh -c $SVR_CONFIG -b $IP_ADDR -bmanagement $IP_ADDR -bprivate $IP_ADDR > /dev/null 2>&1 &
$
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
chown -R $1.jboss .
chown -R $1.jboss *
echo "SSH User name:  "$1 > /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 >> /home/$1/vsts_ssh_info
echo "SSH Private key:" >> /home/$1/vsts_ssh_info
cat id_rsa >> /home/$1/vsts_ssh_info

echo "Configure SELinux to use Linux ACL's for file protection..." >> /home/$1/install.log
setsebool -P allow_ftpd_full_access 1

# Seeing a race condition timing error so sleep to deplay
sleep 20
chown $1.jboss /home/$1/install.log

echo "Red Hat WILDFLY 16.0.0.Final Standalone Intallation End: " | /bin/date +%H:%M:%S  >> /home/$1/install.log