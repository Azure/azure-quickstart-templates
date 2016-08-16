#!/bin/sh

# $1 - VM Host User Name

sudo /bin/date +%H:%M:%S > /home/$1/install.progress.txt
echo "ooooo      REDHAT TOMCAT INSTALL      ooooo" >> /home/$1/install.progress.txt

echo "Initial Tomcat setup" >> /home/$1/install.progress.txt

# Install Apache2, Tomcat7 and then build mod-jk package
sudo yum install -y httpd
sudo yum install -y tomcat
sudo yum install -y tomcat-webapps tomcat-admin-webapps
sudo yum install -y gcc
sudo yum install -y gcc-c++
sudo yum install -y httpd-devel
cd
wget http://www-us.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz
tar xvfz tomcat-connectors-1.2.41-src.tar.gz
cd tomcat-connectors-1.2.41-src/native/
./configure --with-apxs=/usr/bin/apxs
make
sudo make install

# Create a mod_jk config file
sudo echo "# Load mod_jk module" > /etc/httpd/conf/mod_jk.conf
sudo echo "# Specify the filename of the mod_jk lib" >> /etc/httpd/conf/mod_jk.conf
sudo echo "LoadModule jk_module modules/mod_jk.so" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# Where to find workers.properties" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkWorkersFile conf/workers.properties" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# Where to put jk logs" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkLogFile /var/log/httpd/mod_jk.log" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# Set the jk log level [debug/error/info]" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkLogLevel info" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# Select the log format" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkLogStampFormat \"[%a %b %d %H:%M:%S %Y]\"" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# JkOptions indicates to send SSK KEY SIZE" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# JkRequestLogFormat" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkRequestLogFormat \"%w %V %T\"" >> /etc/httpd/conf/mod_jk.conf
sudo echo "# Mount your applications" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkMount /* worker1" >> /etc/httpd/conf/mod_jk.conf
sudo echo "JkShmFile /var/run/mod_jk/jk-runtime-status" >> /etc/httpd/conf/mod_jk.conf

# Create mod_jk workers file
sudo echo "# Define 1 real worker using ajp13" > /etc/httpd/conf/workers.properties
sudo echo "worker.list=worker1" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.type=ajp13" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.host=localhost" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.port=8009" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.socket_keepalive=true" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.lbfactor=1" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.connection_pool_size=50" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.connect_timeout=5000" >> /etc/httpd/conf/workers.properties
sudo echo "worker.worker1.prepost_timeout=5000" >> /etc/httpd/conf/workers.properties

# Update httpd conf file with server name and mod_jk config file name
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/ORIG_httpd.conf
sudo sed -i 's,#ServerName,ServerName,g' /etc/httpd/conf/httpd.conf
sudo sed -i "s,www.example.com:80,`hostname`:80,g" /etc/httpd/conf/httpd.conf
sudo echo "# Include mod_jk's specific configuration file" >> /etc/httpd/conf/httpd.conf
sudo echo "Include conf/mod_jk.conf" >> /etc/httpd/conf/httpd.conf

# Update the server.xml file to specify the mod_jk worker
sudo cp /usr/share/tomcat/conf/server.xml /usr/share/tomcat/conf/ORIG_server.xml
sudo sed -i 's,"localhost">,"localhost" jvmRoute="worker1">,g' /usr/share/tomcat/conf/server.xml

# Update the permissions on the Tomcat webapps and install directory
sudo chown -R tomcat.tomcat /var/lib/tomcat/webapps
sudo chown tomcat.tomcat /usr/share/tomcat

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

echo "Done." >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Configuring Tomcat manager" >> /home/$1/install.progress.txt


echo "Done." >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Configuring SSH" >> /home/$1/install.progress.txt
echo "Done." >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "Installing and Configuring FTP" >> /home/$1/install.progress.txt

echo "ALL DONE!" >> /home/$1/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt


echo "These original files were saved in case you want to return to default settings:" >> /home/$1/install.progress.txt
sudo find /etc -name ORIG_* -print >> /home/$1/install.progress.txt


# chown $1.tomcat7 /home/$1/install.progress.txt

