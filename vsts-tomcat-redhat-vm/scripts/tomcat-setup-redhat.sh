#!/bin/sh

# $1 - VM Host User Name

/bin/date +%H:%M:%S > /home/$1/install.progress.txt
echo "ooooo      REDHAT TOMCAT INSTALL      ooooo" >> /home/$1/install.progress.txt

echo "Initial Tomcat setup" >> /home/$1/install.progress.txt

# Install Apache2, Tomcat7 and then build mod-jk package
yum install -y httpd > /home/$1/install.out.txt 2>&1
yum install -y tomcat >> /home/$1/install.out.txt 2>&1
yum install -y tomcat-webapps tomcat-admin-webapps >> /home/$1/install.out.txt 2>&1
yum install -y gcc >> /home/$1/install.out.txt 2>&1
yum install -y gcc-c++ >> /home/$1/install.out.txt 2>&1
yum install -y httpd-devel >> /home/$1/install.out.txt 2>&1
cd /home/$1
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz >> /home/$1/install.out.txt 2>&1
tar xvfz tomcat-connectors-1.2.41-src.tar.gz >> /home/$1/install.out.txt 2>&1
cd /home/$1/tomcat-connectors-1.2.41-src/native/
./configure --with-apxs=/usr/bin/apxs >> /home/$1/install.out.txt 2>&1
make >> /home/$1/install.out.txt 2>&1
make install >> /home/$1/install.out.txt 2>&1
cd /home/$1

# Create a mod_jk config file
echo "# Load mod_jk module" > /etc/httpd/conf/mod_jk.conf
echo "# Specify the filename of the mod_jk lib" >> /etc/httpd/conf/mod_jk.conf
echo "LoadModule jk_module modules/mod_jk.so" >> /etc/httpd/conf/mod_jk.conf
echo "# Where to find workers.properties" >> /etc/httpd/conf/mod_jk.conf
echo "JkWorkersFile conf/workers.properties" >> /etc/httpd/conf/mod_jk.conf
echo "# Where to put jk logs" >> /etc/httpd/conf/mod_jk.conf
echo "JkLogFile /var/log/httpd/mod_jk.log" >> /etc/httpd/conf/mod_jk.conf
echo "# Set the jk log level [debug/error/info]" >> /etc/httpd/conf/mod_jk.conf
echo "JkLogLevel info" >> /etc/httpd/conf/mod_jk.conf
echo "# Select the log format" >> /etc/httpd/conf/mod_jk.conf
echo "JkLogStampFormat \"[%a %b %d %H:%M:%S %Y]\"" >> /etc/httpd/conf/mod_jk.conf
echo "# JkOptions indicates to send SSK KEY SIZE" >> /etc/httpd/conf/mod_jk.conf
echo "JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories" >> /etc/httpd/conf/mod_jk.conf
echo "# JkRequestLogFormat" >> /etc/httpd/conf/mod_jk.conf
echo "JkRequestLogFormat \"%w %V %T\"" >> /etc/httpd/conf/mod_jk.conf
echo "# Mount your applications" >> /etc/httpd/conf/mod_jk.conf
echo "JkMount /* worker1" >> /etc/httpd/conf/mod_jk.conf
echo "JkShmFile /var/run/mod_jk/jk-runtime-status" >> /etc/httpd/conf/mod_jk.conf

# Create mod_jk workers file
echo "# Define 1 real worker using ajp13" > /etc/httpd/conf/workers.properties
echo "worker.list=worker1" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.type=ajp13" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.host=localhost" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.port=8009" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.socket_keepalive=true" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.lbfactor=1" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.connection_pool_size=50" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.connect_timeout=5000" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.prepost_timeout=5000" >> /etc/httpd/conf/workers.properties

# Update httpd conf file with server name and mod_jk config file name
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/ORIG_httpd.conf
sed -i 's,#ServerName,ServerName,g' /etc/httpd/conf/httpd.conf
sed -i "s,www.example.com:80,`hostname`:80,g" /etc/httpd/conf/httpd.conf
echo "# Include mod_jk's specific configuration file" >> /etc/httpd/conf/httpd.conf
echo "Include conf/mod_jk.conf" >> /etc/httpd/conf/httpd.conf

# Update the server.xml file to specify the mod_jk worker
cp /usr/share/tomcat/conf/server.xml /usr/share/tomcat/conf/ORIG_server.xml
sed -i 's,"localhost">,"localhost" jvmRoute="worker1">,g' /usr/share/tomcat/conf/server.xml

# Update the permissions on the Tomcat webapps and install directory
chown -R tomcat.tomcat /var/lib/tomcat/webapps
chown tomcat.tomcat /usr/share/tomcat
chown tomcat.tomcat /var/lib/tomcat

# Set the default umask for Tomcat
cp /usr/libexec/tomcat/server /usr/libexec/tomcat/ORIG_server
sed -i 's,run start,umask 002\n  run start,g' /usr/libexec/tomcat/server
systemctl daemon-reload >> /home/$1/install.out.txt 2>&1

# Configure SELinux to allow mod_jk to work
yum install -y policycoreutils-python >> /home/$1/install.out.txt 2>&1
mkdir /var/run/mod_jk
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/var/run/mod_jk(/.*)?" >> /home/$1/install.out.txt 2>&1

# Remove unnecessary http modules that create warnings
cp /etc/httpd/conf.modules.d/00-proxy.conf /etc/httpd/conf.modules.d/ORIG_00-proxy.conf
sed -i 's,LoadModule lbmethod_heartbeat,# LoadModule lbmethod_heartbeat,g' /etc/httpd/conf.modules.d/00-proxy.conf

#Configure the system to run httpd and tomcat every time the server is booted:
systemctl enable httpd  >> /home/$1/install.out.txt 2>&1
systemctl enable tomcat  >> /home/$1/install.out.txt 2>&1

# Restart the Tomcat7 and Apache2 servers:
service httpd start  >> /home/$1/install.out.txt 2>&1
service tomcat start  >> /home/$1/install.out.txt 2>&1

# Open Red Hat software firewall for port 80:
firewall-cmd --zone=public --add-port=80/tcp --permanent  >> /home/$1/install.out.txt 2>&1
firewall-cmd --reload  >> /home/$1/install.out.txt 2>&1

echo "Done." >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Configuring Tomcat manager" >> /home/$1/install.progress.txt

# Setup permissions for the Tomcat manager
mv /etc/tomcat/tomcat-users.xml /etc/tomcat/ORIG_tomcat-users.xml
echo "<?xml version='1.0' encoding='utf-8'?>" > /tmp/tomcat-users.xml
echo "<tomcat-users>" >> /tmp/tomcat-users.xml
echo "<role rolename=\"tomcat\"/>" >> /tmp/tomcat-users.xml
echo "<role rolename=\"manager-script\"/>" >> /tmp/tomcat-users.xml
echo "<role rolename=\"manager-gui\"/>" >> /tmp/tomcat-users.xml
echo "<role rolename=\"manager\"/>" >> /tmp/tomcat-users.xml
echo "<role rolename=\"admin-gui\"/>" >> /tmp/tomcat-users.xml
echo "<user username=\"tomcat\" password=\"tomcat\" roles=\"tomcat\"/>" >> /tmp/tomcat-users.xml
echo "<user username=\"$2\" password=\"$3\" roles=\"tomcat,manager-script,manager-gui,admin-gui\"/>" >> /tmp/tomcat-users.xml
echo "</tomcat-users>" >> /tmp/tomcat-users.xml
mv /tmp/tomcat-users.xml /etc/tomcat
chown root.tomcat /etc/tomcat/tomcat-users.xml 
chmod 0640 /etc/tomcat/tomcat-users.xml

# Restart httpd and tomcat servers
service tomcat restart >> /home/$1/install.out.txt 2>&1
service httpd restart >> /home/$1/install.out.txt 2>&1

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

# Change group of user to same as Tomcat
echo "Changing group of user "$1  >> /home/$1/install.out.txt 2>&1
gpasswd -d $1 $1 >> /home/$1/install.out.txt 2>&1
gpasswd -a $1 tomcat >> /home/$1/install.out.txt 2>&1
usermod -g tomcat $1 >> /home/$1/install.out.txt 2>&1


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
chown -R $1.tomcat .
chown -R $1.tomcat *
echo "SSH User name:  "$1 > /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 >> /home/$1/vsts_ssh_info
echo "SSH Private key:" >> /home/$1/vsts_ssh_info
cat id_rsa >> /home/$1/vsts_ssh_info
chown $1.tomcat /home/$1/vsts_ssh_info


echo "Installing and Configuring FTP" >> /home/$1/install.progress.txt

# Install the vsftp package (i.e. FTP) and create some needed directories:
yum install -y vsftpd >> /home/$1/install.out.txt 2>&1
mkdir /var/run/vsftpd
mkdir /var/run/vsftpd/empty


# Generate an SSL self-signed certificate:
mkdir /etc/ssl/private
# Generate SSL self-signed certificate
echo US > /tmp/info.txt
echo NC >> /tmp/info.txt
echo Raleigh >> /tmp/info.txt
echo Microsoft >> /tmp/info.txt
echo Team Services >> /tmp/info.txt
echo $1  >> /tmp/info.txt
echo $1@  >> /tmp/info.txt
cat /tmp/info.txt | openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
rm -f /tmp/info.txt

# Backup original and create a new vsftp conf file
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/ORIG_vsftpd.conf
echo "listen=NO" > /tmp/vsftpd.conf
echo "listen_ipv6=YES" >> /tmp/vsftpd.conf
echo "anonymous_enable=NO" >> /tmp/vsftpd.conf
echo "local_enable=YES" >> /tmp/vsftpd.conf
echo "write_enable=YES" >> /tmp/vsftpd.conf
echo "local_umask=002 # this is different than the default 022" >> /tmp/vsftpd.conf
echo "dirmessage_enable=YES" >> /tmp/vsftpd.conf
echo "use_localtime=YES" >> /tmp/vsftpd.conf
echo "xferlog_enable=YES" >> /tmp/vsftpd.conf
echo "connect_from_port_20=YES" >> /tmp/vsftpd.conf
echo "xferlog_file=/var/log/vsftpd.log" >> /tmp/vsftpd.conf
echo "ls_recurse_enable=YES" >> /tmp/vsftpd.conf
echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /tmp/vsftpd.conf
echo "pam_service_name=vsftpd" >> /tmp/vsftpd.conf
echo "# ftps/ssl specific cofig stuff below this line" >> /tmp/vsftpd.conf
echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" >> /tmp/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.pem" >> /tmp/vsftpd.conf
echo "ssl_enable=YES" >> /tmp/vsftpd.conf
echo "allow_anon_ssl=NO" >> /tmp/vsftpd.conf
echo "force_local_data_ssl=YES" >> /tmp/vsftpd.conf
echo "force_local_logins_ssl=YES" >> /tmp/vsftpd.conf
echo "ssl_tlsv1=YES" >> /tmp/vsftpd.conf
echo "ssl_sslv2=NO" >> /tmp/vsftpd.conf
echo "ssl_sslv3=NO" >> /tmp/vsftpd.conf
echo "require_ssl_reuse=NO" >> /tmp/vsftpd.conf
echo "ssl_ciphers=HIGH" >> /tmp/vsftpd.conf
echo "debug_ssl=YES" >> /tmp/vsftpd.conf
echo "pasv_enable=YES" >> /tmp/vsftpd.conf
echo "pasv_address=`wget http://ipinfo.io/ip -qO -`" >> /tmp/vsftpd.conf
echo "pasv_min_port=13450" >> /tmp/vsftpd.conf
echo "pasv_max_port=13454" >> /tmp/vsftpd.conf
mv /tmp/vsftpd.conf /etc/vsftpd
chmod 0600 /etc/vsftpd/vsftpd.conf

# Configure SELinux to use Linux ACL's for file protection
setsebool -P allow_ftpd_full_access 1 >> /home/$1/install.out.txt 2>&1

# Open the ftp ports on the Red Hat software firewall:
firewall-cmd --zone=public --add-port=21/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=13450/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=13451/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=13452/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=13453/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --zone=public --add-port=13454/tcp --permanent >> /home/$1/install.out.txt 2>&1
firewall-cmd --reload >> /home/$1/install.out.txt 2>&1

# Seeing a race condition timing error so sleep to deplay
sleep 20

# Restart the ftp service:
echo "Restart vsftp" >> /home/$1/install.out.txt 2>&1
service vsftpd restart >> /home/$1/install.out.txt 2>&1
systemctl enable vsftpd >> /home/$1/install.out.txt 2>&1

echo "ALL DONE!" >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt

echo "These original files were saved in case you want to return to default settings:" >> /home/$1/install.progress.txt
find /etc -name ORIG_* -print >> /home/$1/install.progress.txt
find /usr/share/tomcat/conf -name ORIG_* -print >> /home/$1/install.progress.txt
find /usr/libexec/tomcat -name ORIG_* -print >> /home/$1/install.progress.txt


chown $1.tomcat /home/$1/install.progress.txt
chown $1.tomcat /home/$1/install.out.txt

