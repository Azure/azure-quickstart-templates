#!/bin/sh

# $1 - VM Host User Name

sudo /bin/date +%H:%M:%S > /home/$1/install.progress.txt
echo "ooooo      TOMCAT INSTALL      ooooo" >> /home/$1/install.progress.txt

echo "Initial Tomcat setup" >> /home/$1/install.progress.txt

# Install Apache2, Tomcat7 and mod-jk packages on an updated OS image
sudo apt update
sudo apt upgrade -y
sudo apt-get install -y apache2
sudo apt-get install -y tomcat7
sudo apt-get install -y tomcat7-admin
sudo apt-get install -y libapache2-mod-jk

# Uncomment the Connector port="8009" line
sudo cp /etc/tomcat7/server.xml /etc/tomcat7/ORIG_server.xml
sudo sed -i '/Connector on port 8009 -->/{n;d}' /etc/tomcat7/server.xml
sudo sed -i '/protocol=\"AJP\/1.3\" redirectPort=\"8443\"/{n;d}' /etc/tomcat7/server.xml

# Create a new JkWorkers workers.propeties file
sudo echo "# Define 1 real worker using ajp13" > /etc/apache2/workers.properties
sudo echo "worker.list=worker1" >> /etc/apache2/workers.properties
sudo echo "worker.worker1.type=ajp13" >> /etc/apache2/workers.properties
sudo echo "worker.worker1.host=localhost" >> /etc/apache2/workers.properties
sudo echo "worker.worker1.port=8009" >> /etc/apache2/workers.properties

# Point to the newly created above JkWorkers file
sudo cp /etc/apache2/mods-available/jk.conf /etc/apache2/mods-available/ORIG_jk.conf
sudo sed -i 's,/etc/libapache2-mod-jk/workers.properties,/etc/apache2/workers.properties,g' /etc/apache2/mods-available/jk.conf

# Specify the mod-jk worker
sudo cp /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/ORIG_000-default.conf
sudo sed -i 's,</VirtualHost>,JkMount /* worker1\n</VirtualHost>,g' /etc/apache2/sites-enabled/000-default.conf

# Create a link to the Tomcat manager
cd /var/lib/tomcat7/webapps
sudo ln -s /usr/share/tomcat7-admin/manager manager

# Update the permissions on the Tomcat Webapps and install directory
sudo chown -R tomcat7.tomcat7 /var/lib/tomcat7/webapps
sudo chown tomcat7.tomcat7 /usr/share/tomcat7

# Change the default Tomcat umask to be 002 to enable owner and group access
sudo cp /etc/init.d/tomcat7 /etc/init.d/ORIG_tomcat7
sudo sed -i 's,umask 022,umask 002,g' /etc/init.d/tomcat7

# Restart the tomcat7 and apache2 services
sudo systemctl daemon-reload
sudo /etc/init.d/tomcat7 restart
sudo /etc/init.d/apache2 restart

echo "Done." >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Configuring Tomcat manager" >> /home/$1/install.progress.txt

# Setup permissions for the Tomcat manager
sudo mv /etc/tomcat7/tomcat-users.xml /etc/tomcat7/ORIG_tomcat-users.xml
sudo echo "<?xml version='1.0' encoding='utf-8'?>" >> /tmp/tomcat-users.xml
sudo echo "<tomcat-users>" >> /tmp/tomcat-users.xml
sudo echo "<role rolename=\"tomcat\"/>" >> /tmp/tomcat-users.xml
sudo echo "<role rolename=\"manager-script\"/>" >> /tmp/tomcat-users.xml
sudo echo "<role rolename=\"manager-gui\"/>" >> /tmp/tomcat-users.xml
sudo echo "<role rolename=\"manager\"/>" >> /tmp/tomcat-users.xml
sudo echo "<role rolename=\"admin-gui\"/>" >> /tmp/tomcat-users.xml
sudo echo "<user username=\"tomcat\" password=\"tomcat\" roles=\"tomcat\"/>" >> /tmp/tomcat-users.xml
sudo echo "<user username=\"$2\" password=\"$3\" roles=\"tomcat,manager-script,manager-gui,admin-gui\"/>" >> /tmp/tomcat-users.xml
sudo echo "</tomcat-users>" >> /tmp/tomcat-users.xml
sudo mv /tmp/tomcat-users.xml /etc/tomcat7
sudo chown root.tomcat7 /etc/tomcat7/tomcat-users.xml
sudo chmod 0640 /etc/tomcat7/tomcat-users.xml

# Restart the tomcat7 and apache2 services
sudo /etc/init.d/tomcat7 restart
sudo /etc/init.d/apache2 restart

echo "Done." >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Configuring SSH" >> /home/$1/install.progress.txt

# Change group of user to same as Tomcat 7
sudo usermod -g tomcat7 $1

# Change the default SSH umask to be 002 to enable owner and group access
sudo cp /etc/pam.d/sshd /etc/pam.d/ORIG_sshd
sudo sed -i 's,common-session,common-session\nsession optional pam_umask.so umask=002,g' /etc/pam.d/sshd

# Reload and restart the SSHD service
sudo systemctl daemon-reload
sudo service sshd restart

# Create an RSA public and private key for SSH
ssh-keygen -q -N $4 -f /home/$1/.ssh/id_rsa
cd /home/$1/.ssh
sudo cp id_rsa.pub authorized_keys
chown -R $1.tomcat7 .
chown -R $1.tomcat7 *
echo "SSH User name:  "$1 > /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 >> /home/$1/vsts_ssh_info
echo "SSH Private key:" >> /home/$1/vsts_ssh_info
cat id_rsa >> /home/$1/vsts_ssh_info
chown $1.tomcat7 /home/$1/vsts_ssh_info

echo "Done." >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Installing and Configuring FTP" >> /home/$1/install.progress.txt

# Install vsftpd
sudo apt-get install -y vsftpd

# Generate SSL self-signed certificate
echo US > /tmp/info.txt
echo NC >> /tmp/info.txt
echo Raleigh >> /tmp/info.txt
echo Microsoft >> /tmp/info.txt
echo Team Services >> /tmp/info.txt
echo $1  >> /tmp/info.txt
echo $1@  >> /tmp/info.txt
cat /tmp/info.txt | sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
sudo rm -f /tmp/info.txt

# Backup original and create a new vsftp conf file
sudo cp /etc/vsftpd.conf /etc/ORIG_vsftpd.conf
sudo echo "listen=NO" > /tmp/vsftpd.conf
sudo echo "listen_ipv6=YES" >> /tmp/vsftpd.conf
sudo echo "anonymous_enable=NO" >> /tmp/vsftpd.conf
sudo echo "local_enable=YES" >> /tmp/vsftpd.conf
sudo echo "write_enable=YES" >> /tmp/vsftpd.conf
sudo echo "local_umask=002 # this is different than the default 022" >> /tmp/vsftpd.conf
sudo echo "dirmessage_enable=YES" >> /tmp/vsftpd.conf
sudo echo "use_localtime=YES" >> /tmp/vsftpd.conf
sudo echo "xferlog_enable=YES" >> /tmp/vsftpd.conf
sudo echo "connect_from_port_20=YES" >> /tmp/vsftpd.conf
sudo echo "xferlog_file=/var/log/vsftpd.log" >> /tmp/vsftpd.conf
sudo echo "ls_recurse_enable=YES" >> /tmp/vsftpd.conf
sudo echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /tmp/vsftpd.conf
sudo echo "pam_service_name=vsftpd" >> /tmp/vsftpd.conf
sudo echo "# ftps/ssl specific cofig stuff below this line" >> /tmp/vsftpd.conf
sudo echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" >> /tmp/vsftpd.conf
sudo echo "rsa_private_key_file=/etc/ssl/private/vsftpd.pem" >> /tmp/vsftpd.conf
sudo echo "ssl_enable=YES" >> /tmp/vsftpd.conf
sudo echo "allow_anon_ssl=NO" >> /tmp/vsftpd.conf
sudo echo "force_local_data_ssl=YES" >> /tmp/vsftpd.conf
sudo echo "force_local_logins_ssl=YES" >> /tmp/vsftpd.conf
sudo echo "ssl_tlsv1=YES" >> /tmp/vsftpd.conf
sudo echo "ssl_sslv2=NO" >> /tmp/vsftpd.conf
sudo echo "ssl_sslv3=NO" >> /tmp/vsftpd.conf
sudo echo "require_ssl_reuse=NO" >> /tmp/vsftpd.conf
sudo echo "ssl_ciphers=HIGH" >> /tmp/vsftpd.conf
sudo echo "debug_ssl=YES" >> /tmp/vsftpd.conf
sudo echo "pasv_enable=YES" >> /tmp/vsftpd.conf
sudo echo "pasv_address=`wget http://ipinfo.io/ip -qO -`" >> /tmp/vsftpd.conf
sudo echo "pasv_min_port=13450" >> /tmp/vsftpd.conf
sudo echo "pasv_max_port=13454" >> /tmp/vsftpd.conf
sudo mv /tmp/vsftpd.conf /etc

# Restart vsftp server
sudo service vsftpd restart

echo "ALL DONE!" >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "These original files were saved in case you want to return to default settings:" >> /home/$1/install.progress.txt
sudo find /etc -name ORIG_* -print >> /home/$1/install.progress.txt


chown $1.tomcat7 /home/$1/install.progress.txt

