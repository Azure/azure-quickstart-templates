#!/bin/sh

# $1 - VM Host User Name

/bin/date +%H:%M:%S > /home/$1/install.progress.txt
echo "ooooo      REDHAT EAP7 RPM INSTALL      ooooo" >> /home/$1/install.progress.txt

export EAP_HOME="/opt/rh/eap7/root/usr/share/wildfly"
export EAP_RPM_CONF_STANDALONE="/etc/opt/rh/eap7/wildfly/eap7-standalone.conf"
export EAP_RPM_CONF_DOMAIN="/etc/opt/rh/eap7/wildfly/eap7-domain.conf"

export EAP_USER=$2
export EAP_PASSWORD=$3
export RHSM_USER=$4
export RHSM_PASSWORD=$5
export RHSM_POOL=$6

PROFILE=standalone
echo "EAP admin user"+${EAP_USER} >> /home/$1/install.progress.txt
echo "Initial EAP7 setup" >> /home/$1/install.progress.txt
subscription-manager register --username $RHSM_USER --password $RHSM_PASSWORD  >> /home/$1/install.progress.txt 2>&1
subscription-manager attach --pool=${RHSM_POOL} >> /home/$1/install.progress.txt 2>&1
echo "Subscribing the system to get access to EAP 7 repos" >> /home/$1/install.progress.txt

# Install EAP7
subscription-manager repos --enable=jb-eap-7-for-rhel-7-server-rpms >> /home/$1/install.out.txt 2>&1
yum-config-manager --disable rhel-7-server-htb-rpms

echo "Installing EAP7 repos" >> /home/$1/install.progress.txt
yum groupinstall -y jboss-eap7 >> /home/$1/install.out.txt 2>&1

echo "Enabling EAP7 service" >> /home/$1/install.progress.txt
systemctl enable eap7-standalone.service

echo "Configure EAP7 RPM file" >> /home/$1/install.progress.txt

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

echo "Start EAP 7" >> /home/$1/install.progress.txt
systemctl restart eap7-standalone.service

# Open Red Hat software firewall for port 8080 and 9990:
firewall-cmd --zone=public --add-port=8080/tcp --permanent  >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=9990/tcp --permanent  >> /home/$1/install.out.txt 2>&1
firewall-cmd --reload  >> /home/$1/install.out.txt 2>&1

echo "Done." >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt

echo "Configuring SSH" >> /home/$1/install.progress.txt
echo "Done." >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt

# Update SSHd config to not use passwords and set default umask to be 002
cp /etc/ssh/sshd_config /etc/ssh/ORIG_sshd_config
sed -i 's,PasswordAuthentication yes,PasswordAuthentication no,g' /etc/ssh/sshd_config
echo "Match User "$1 >> /etc/ssh/sshd_config
echo "    ForceCommand internal-sftp -u 002" >> /etc/ssh/sshd_config

# Change group of user to same as JBoss
echo "Changing group of user "$1  >> /home/$1/install.out.txt 2>&1
#gpasswd -d $1 jboss >> /home/$1/install.out.txt 2>&1
#gpasswd -a $1 jboss >> /home/$1/install.out.txt 2>&1
#usermod -g jboss $1 >> /home/$1/install.out.txt 2>&1


# Configure the default umask for SSH to enable RW for user and group
cp /etc/pam.d/sshd /etc/pam.d/ORIG_sshd
echo "session optional pam_umask.so umask=002" >> /etc/pam.d/sshd

# Then start the SSH daemon:
systemctl daemon-reload >> /home/$1/install.out.txt 2>&1
systemctl start sshd.service >> /home/$1/install.out.txt 2>&1
systemctl enable sshd.service >> /home/$1/install.out.txt 2>&1

# Open Red Hat software firewall for port 22:
firewall-cmd --zone=public --add-port=22/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --reload >> /home/$1/install.out.txt 2>&1

# Create an RSA public and private key for SSH
cd /home/$1
mkdir /home/$1/.ssh
ssh-keygen -q -N $4 -f /home/$1/.ssh/id_rsa >> /home/$1/install.out.txt 2>&1
cd /home/$1/.ssh
cp id_rsa.pub authorized_keys
chown -R $1.jboss .
chown -R $1.jboss *
echo "SSH User name:  "$1 > /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 >> /home/$1/vsts_ssh_info
echo "SSH Private key:" >> /home/$1/vsts_ssh_info
cat id_rsa >> /home/$1/vsts_ssh_info
chown $1.tomcat /home/$1/vsts_ssh_info


# Configure SELinux to use Linux ACL's for file protection
setsebool -P allow_ftpd_full_access 1 >> /home/$1/install.out.txt 2>&1

# Seeing a race condition timing error so sleep to deplay
sleep 20

echo "ALL DONE!" >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt


chown $1.jboss /home/$1/install.progress.txt
chown $1.jboss /home/$1/install.out.txt

