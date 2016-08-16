#!/bin/sh

# $1 - VM Host User Name

/bin/date +%H:%M:%S > /home/$1/install.progress.txt
echo "ooooo      REDHAT TOMCAT INSTALL      ooooo" >> /home/$1/install.progress.txt

echo "Initial Tomcat setup" >> /home/$1/install.progress.txt

# Install Apache2, Tomcat7 and then build mod-jk package
yum install -y httpd > /home/$1/install.out.txt 2>&1
yum install -y tomcat > /home/$1/install.out.txt 2>&1
yum install -y tomcat-webapps tomcat-admin-webapps > /home/$1/install.out.txt 2>&1
yum install -y gcc > /home/$1/install.out.txt 2>&1
yum install -y gcc-c++ > /home/$1/install.out.txt 2>&1
yum install -y httpd-devel > /home/$1/install.out.txt 2>&1
cd /home/$1
wget http://www-us.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz > /home/$1/install.out.txt 2>&1
tar xvfz tomcat-connectors-1.2.41-src.tar.gz > /home/$1/install.out.txt 2>&1
cd /home/$1/tomcat-connectors-1.2.41-src/native/
./configure --with-apxs=/usr/bin/apxs > /home/$1/install.out.txt 2>&1
make > /home/$1/install.out.txt 2>&1
make install > /home/$1/install.out.txt 2>&1
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

# Set the default umask for Tomcat
cp /usr/libexec/tomcat/server /usr/libexec/tomcat/ORIG_server
sed -i 's,run start,umask 002\n  run start,g' /usr/libexec/tomcat/server
systemctl daemon-reload > /home/$1/install.out.txt 2>&1

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


echo "Done." >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Configuring SSH" >> /home/$1/install.progress.txt
echo "Done." >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Installing and Configuring FTP" >> /home/$1/install.progress.txt

echo "ALL DONE!" >> /home/$1/install.progress.txt
/bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "These original files were saved in case you want to return to default settings:" >> /home/$1/install.progress.txt
find /etc -name ORIG_* -print >> /home/$1/install.progress.txt
find /usr/share/tomcat -name ORIG_* -print >> /home/$1/install.progress.txt
find /usr/libexec/tomcat -name ORIG_* -print >> /home/$1/install.progress.txt


# chown $1.tomcat7 /home/$1/install.progress.txt

