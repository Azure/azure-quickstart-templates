#!/bin/sh

# Install Apache2, Tomcat7 and then build mod-jk package
sudo yum install -y httpd
sudo yum install -y tomcat 
sudo yum install -y tomcat-webapps tomcat-admin-webapps 
sudo yum install -y gcc 
sudo yum install -y gcc-c++ 
sudo yum install -y httpd-devel 
sudo yum install -y make 
sudo wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz 
sudo tar xvfz tomcat-connectors-1.2.41-src.tar.gz 
sudo $PWD/tomcat-connectors-1.2.41-src/native/configure --with-apxs=/usr/bin/apxs 
sudo make -C $PWD/tomcat-connectors-1.2.41-src/native 
sudo make install -C $PWD/tomcat-connectors-1.2.41-src/native 
sudo groupadd --system tomcat
sudo useradd -d /usr/share/tomcat -r -s /bin/false -g tomcat tomcat

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
JkShmFile /var/run/mod_jk/jk-runtime-status" | sudo tee /etc/httpd/conf/mod_jk.conf

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
worker.worker1.prepost_timeout=5000" | sudo tee /etc/httpd/conf/workers.properties

# Update httpd conf file with server name and mod_jk config file name
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/ORIG_httpd.conf
sudo sed -i 's,#ServerName,ServerName,g' /etc/httpd/conf/httpd.conf
sudo sed -i "s,www.example.com:80,`hostname`:80,g" /etc/httpd/conf/httpd.conf
echo "\
# Include mod_jk's specific configuration file
Include conf/mod_jk.conf" | sudo tee -a /etc/httpd/conf/httpd.conf

# Update the server.xml file to specify the mod_jk worker
sudo cp /usr/share/tomcat/conf/server.xml /usr/share/tomcat/conf/ORIG_server.xml
sudo sed -i 's,"localhost">,"localhost" jvmRoute="worker1">,g' /usr/share/tomcat/conf/server.xml

# Update the permissions on the Tomcat webapps and install directory
sudo chown -R tomcat:tomcat /var/lib/tomcat/webapps
sudo chown tomcat:tomcat /usr/share/tomcat
sudo chown tomcat:tomcat /var/lib/tomcat

# Set the default umask for Tomcat
sudo cp /usr/libexec/tomcat/server /usr/libexec/tomcat/ORIG_server
sudo sed -i 's,run start,umask 002\n  run start,g' /usr/libexec/tomcat/server
sudo systemctl daemon-reload 

# Configure SELinux to allow mod_jk to work
sudo yum install -y policycoreutils-python 
sudo mkdir /var/run/mod_jk
sudo /usr/sbin/semanage fcontext -a -t httpd_var_run_t "/var/run/mod_jk(/.*)?" 

# Remove unnecessary http modules that create warnings
sudo cp /etc/httpd/conf.modules.d/00-proxy.conf /etc/httpd/conf.modules.d/ORIG_00-proxy.conf
sudo sed -i 's,LoadModule lbmethod_heartbeat,# LoadModule lbmethod_heartbeat,g' /etc/httpd/conf.modules.d/00-proxy.conf

#Configure the system to run httpd and tomcat every time the server is booted:
sudo systemctl enable httpd  
sudo systemctl enable tomcat  

# Restart the Tomcat7 and Apache2 servers:
sudo service httpd start  
sudo service tomcat start  

# Open Red Hat software firewall for port 80:
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent  
sudo firewall-cmd --reload  

# Setup permissions for the Tomcat manager
sudo mv /etc/tomcat/tomcat-users.xml /etc/tomcat/ORIG_tomcat-users.xml

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
</tomcat-users>" | sudo tee -a /tmp/tomcat-users.xml

sudo mv /tmp/tomcat-users.xml /etc/tomcat
sudo chown root:tomcat /etc/tomcat/tomcat-users.xml
sudo chmod 0640 /etc/tomcat/tomcat-users.xml

# Restart httpd and tomcat servers
sudo service tomcat restart 
sudo service httpd restart 

# Update SSHd config to not use passwords and set default umask to be 002
sudo cp /etc/ssh/sshd_config /etc/ssh/ORIG_sshd_config
sudo sed -i 's,PasswordAuthentication yes,PasswordAuthentication no,g' /etc/ssh/sshd_config
echo "Match User "$1 | sudo tee -a /etc/ssh/sshd_config
echo "    ForceCommand internal-sftp -u 002" | sudo tee -a /etc/ssh/sshd_config

# Change group of user to same as Tomcat 
sudo gpasswd -d $1 $1 
sudo gpasswd -a $1 tomcat 
sudo usermod -g tomcat $1 


# Configure the default umask for SSH to enable RW for user and group
sudo cp /etc/pam.d/sshd /etc/pam.d/ORIG_sshd
echo "session optional pam_umask.so umask=002" | sudo tee -a /etc/pam.d/sshd

# Then start the SSH daemon:
sudo systemctl daemon-reload 
sudo systemctl start sshd.service 
sudo systemctl enable sshd.service 

# Open Red Hat software firewall for port 22:
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent 
sudo firewall-cmd --reload 

# Create an RSA public and private key for SSH
sudo mkdir /home/$1/.ssh
sudo ssh-keygen -q -N $4 -f /home/$1/.ssh/id_rsa 
sudo cp /home/$1/.ssh/id_rsa.pub authorized_keys
sudo chown -R $1:tomcat /home/$1/.ssh
echo "SSH User name:  "$1 | sudo tee /home/$1/vsts_ssh_info
echo "SSH passphrase: "$4 | sudo tee /home/$1/vsts_ssh_info
echo "SSH Private key:" | sudo tee /home/$1/vsts_ssh_info
cat id_rsa | sudo tee /home/$1/vsts_ssh_info
sudo chown $1:tomcat /home/$1/vsts_ssh_info


echo "Installing and Configuring FTP" 

# Install the vsftp package (i.e. FTP) and create some needed directories:
sudo yum install -y vsftpd 
sudo mkdir /var/run/vsftpd
sudo mkdir /var/run/vsftpd/empty


# Generate an SSL self-signed certificate:
sudo mkdir /etc/ssl/private
# Generate SSL self-signed certificate
echo "\
US
NC
Raleigh
Microsoft
Team Services
$1
$1@" | sudo tee /tmp/info.txt

cat /tmp/info.txt | sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
sudo rm -f /tmp/info.txt

# Backup original and create a new vsftp conf file
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/ORIG_vsftpd.conf
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
pasv_max_port=13454" | sudo tee /tmp/vsftpd.conf

sudo mv /tmp/vsftpd.conf /etc/vsftpd
sudo chmod 0600 /etc/vsftpd/vsftpd.conf

# Configure SELinux to use Linux ACL's for file protection
sudo setsebool -P allow_ftpd_full_access 1 

# Open the ftp ports on the Red Hat software firewall:
sudo firewall-cmd --zone=public --add-port=21/tcp --permanent 
sudo firewall-cmd --zone=public --add-port=13450/tcp --permanent 
sudo firewall-cmd --zone=public --add-port=13451/tcp --permanent 
sudo firewall-cmd --zone=public --add-port=13452/tcp --permanent 
sudo firewall-cmd --zone=public --add-port=13453/tcp --permanent 
sudo firewall-cmd --zone=public --add-port=13454/tcp --permanent 
sudo firewall-cmd --reload 

# Seeing a race condition timing error so sleep to deplay
sleep 20

# Restart the ftp service:
sudo service vsftpd restart 
sudo systemctl enable vsftpd 

sudo chown $1:tomcat /home/$1/install.progress.txt
chown $1:tomcat /home/$1/install.out.txt

