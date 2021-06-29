#!/bin/sh

# Install Apache2, Tomcat7 and then build mod-jk package
yum update -y --disablerepo='*' --enablerepo='*microsoft*'
yum install -y httpd
yum install -y tomcat 
yum install -y tomcat-webapps tomcat-admin-webapps 
yum install -y gcc 
yum install -y gcc-c++ 
yum install -y httpd-devel 
yum install -y make 
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz 
tar xvfz tomcat-connectors-1.2.41-src.tar.gz 
$PWD/tomcat-connectors-1.2.41-src/native/configure --with-apxs=/usr/bin/apxs 
make -C $PWD/tomcat-connectors-1.2.41-src/native 
make install -C $PWD/tomcat-connectors-1.2.41-src/native 
groupadd --system tomcat
useradd -d /usr/share/tomcat -r -s /bin/false -g tomcat tomcat

# Create a mod_jk config file

echo "\
# Load mod_jk module
# Specify the filename of the mod_jk lib
LoadModule jk_module modules/mod_jk.so
# Where to find workers.properties
JkWorkersFile conf/workers.properties
# Where to put jk logs
JkLogFile /var/log/httpd/mod_jk.log
# Set the jk log level [debug/error/info]
JkLogLevel info
# Select the log format
JkLogStampFormat \"[%a %b %d %H:%M:%S %Y]\"
# JkOptions indicates to send SSK KEY SIZE
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories
# JkRequestLogFormat
JkRequestLogFormat \"%w %V %T\"
# Mount your applications
JkMount /* worker1
JkShmFile /var/run/mod_jk/jk-runtime-status" | tee /etc/httpd/conf/mod_jk.conf

# Create mod_jk workers file
echo "\
# Define 1 real worker using ajp13
worker.list=worker1
worker.worker1.type=ajp13
worker.worker1.host=localhost
worker.worker1.port=8009
worker.worker1.socket_keepalive=true
worker.worker1.lbfactor=1
worker.worker1.connection_pool_size=50
worker.worker1.connect_timeout=5000
worker.worker1.prepost_timeout=5000" | tee /etc/httpd/conf/workers.properties

# Update httpd conf file with server name and mod_jk config file name
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/ORIG_httpd.conf
sed -i 's,#ServerName,ServerName,g' /etc/httpd/conf/httpd.conf
sed -i "s,www.example.com:80,`hostname`:80,g" /etc/httpd/conf/httpd.conf
echo "\
# Include mod_jk's specific configuration file
Include conf/mod_jk.conf" | tee -a /etc/httpd/conf/httpd.conf

# Update the server.xml file to specify the mod_jk worker
cp /usr/share/tomcat/conf/server.xml /usr/share/tomcat/conf/ORIG_server.xml
sed -i 's,"localhost">,"localhost" jvmRoute="worker1">,g' /usr/share/tomcat/conf/server.xml

# Update the permissions on the Tomcat webapps and install directory
chown -R tomcat:tomcat /var/lib/tomcat/webapps
chown tomcat:tomcat /usr/share/tomcat
chown tomcat:tomcat /var/lib/tomcat

# Set the default umask for Tomcat
cp /usr/libexec/tomcat/server /usr/libexec/tomcat/ORIG_server
sed -i 's,run start,umask 002\n  run start,g' /usr/libexec/tomcat/server
systemctl daemon-reload 

# Configure SELinux to allow mod_jk to work
yum install -y policycoreutils-python 
mkdir /var/run/mod_jk
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/var/run/mod_jk(/.*)?" 

# Remove unnecessary http modules that create warnings
cp /etc/httpd/conf.modules.d/00-proxy.conf /etc/httpd/conf.modules.d/ORIG_00-proxy.conf
sed -i 's,LoadModule lbmethod_heartbeat,# LoadModule lbmethod_heartbeat,g' /etc/httpd/conf.modules.d/00-proxy.conf

#Configure the system to run httpd and tomcat every time the server is booted:
systemctl enable httpd  
systemctl enable tomcat  

# Restart the Tomcat7 and Apache2 servers:
service httpd start  
service tomcat start  

# Open Red Hat software firewall for port 80:
firewall-cmd --zone=public --add-port=80/tcp --permanent  
firewall-cmd --reload  

# Setup permissions for the Tomcat manager
mv /etc/tomcat/tomcat-users.xml /etc/tomcat/ORIG_tomcat-users.xml

echo "\
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
<role rolename=\"tomcat\"/>
<role rolename=\"manager-script\"/>
<role rolename=\"manager-gui\"/>
<role rolename=\"manager\"/>
<role rolename=\"admin-gui\"/>
<user username=\"tomcat\" password=\"tomcat\" roles=\"tomcat\"/>
<user username=\"$2\" password=\"$3\" roles=\"tomcat,manager-script,manager-gui,admin-gui\"/>
</tomcat-users>" | tee -a /tmp/tomcat-users.xml

mv /tmp/tomcat-users.xml /etc/tomcat
chown root:tomcat /etc/tomcat/tomcat-users.xml
chmod 0640 /etc/tomcat/tomcat-users.xml

# Restart httpd and tomcat servers
service tomcat restart 
service httpd restart 

# Update SSHd config to not use passwords and set default umask to be 002
cp /etc/ssh/sshd_config /etc/ssh/ORIG_sshd_config
sed -i 's,PasswordAuthentication yes,PasswordAuthentication no,g' /etc/ssh/sshd_config
echo "Match User "$1 | tee -a /etc/ssh/sshd_config
echo "    ForceCommand internal-sftp -u 002" | tee -a /etc/ssh/sshd_config

# Change group of user to same as Tomcat 
gpasswd -d $1 $1 
gpasswd -a $1 tomcat 
usermod -g tomcat $1 


# Configure the default umask for SSH to enable RW for user and group
cp /etc/pam.d/sshd /etc/pam.d/ORIG_sshd
echo "session optional pam_umask.so umask=002" | tee -a /etc/pam.d/sshd

# Then start the SSH daemon:
systemctl daemon-reload 
systemctl start sshd.service 
systemctl enable sshd.service 

# Open Red Hat software firewall for port 22:
firewall-cmd --zone=public --add-port=22/tcp --permanent 
firewall-cmd --reload 

# Create an RSA public and private key for SSH
mkdir /home/$1/.ssh
ssh-keygen -q -N $4 -f /home/$1/.ssh/id_rsa 
cp /home/$1/.ssh/id_rsa.pub authorized_keys
chown -R $1:tomcat /home/$1/.ssh
echo "SSH User name:  "$1 | tee /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 | tee /home/$1/vsts_ssh_info
echo "SSH Private key:" | tee /home/$1/vsts_ssh_info
cat id_rsa | tee /home/$1/vsts_ssh_info
chown $1:tomcat /home/$1/vsts_ssh_info


echo "Installing and Configuring FTP" 

# Install the vsftp package (i.e. FTP) and create some needed directories:
yum install -y vsftpd 
mkdir /var/run/vsftpd
mkdir /var/run/vsftpd/empty


# Generate an SSL self-signed certificate:
mkdir /etc/ssl/private
# Generate SSL self-signed certificate
echo "\
US
NC
Raleigh
Microsoft
Team Services
$1
$1@" | tee /tmp/info.txt

cat /tmp/info.txt | openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
rm -f /tmp/info.txt

# Backup original and create a new vsftp conf file
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/ORIG_vsftpd.conf
echo "\
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=002 # this is different than the default 022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_file=/var/log/vsftpd.log
ls_recurse_enable=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
# ftps/ssl specific cofig stuff below this line
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
debug_ssl=YES
pasv_enable=YES
pasv_address=`wget http://ipinfo.io/ip -qO -`
pasv_min_port=13450
pasv_max_port=13454" | tee /tmp/vsftpd.conf

mv /tmp/vsftpd.conf /etc/vsftpd
chmod 0600 /etc/vsftpd/vsftpd.conf

# Configure SELinux to use Linux ACL's for file protection
setsebool -P allow_ftpd_full_access 1 

# Open the ftp ports on the Red Hat software firewall:
firewall-cmd --zone=public --add-port=21/tcp --permanent 
firewall-cmd --zone=public --add-port=13450/tcp --permanent 
firewall-cmd --zone=public --add-port=13451/tcp --permanent 
firewall-cmd --zone=public --add-port=13452/tcp --permanent 
firewall-cmd --zone=public --add-port=13453/tcp --permanent 
firewall-cmd --zone=public --add-port=13454/tcp --permanent 
firewall-cmd --reload 

# Seeing a race condition timing error so sleep to deplay
sleep 20

# Restart the ftp service:
service vsftpd restart 
systemctl enable vsftpd 
