#!/bin/bash

# Update apt-get package list
apt-get update

# Install Java
apt-get -y install openjdk-8-jdk

# https://devops.profitbricks.com/tutorials/how-to-install-and-configure-tomcat-8-on-ubuntu-1604/

# Create a tomcat group
groupadd tomcat
# Create a new tomcat user and make this user member of the tomcat group with home directory /opt/tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Install Tomcat
wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.tar.gz
tar -xzvf apache-tomcat-8.5.24.tar.gz
mv apache-tomcat-8.5.24 /opt/tomcat

# Give proper permission to the tomcat user to access to the Tomcat installation.
chgrp -R tomcat /opt/tomcat
chown -R tomcat /opt/tomcat
chmod -R 755 /opt/tomcat

if [ ! -z "$repository_url" ];
then
    # Clone code
    cd /tmp
    git clone $repository_url

    # Deploy code to ROOT
    rm -rf /opt/tomcat/webapps/ROOT/*
    cp -r /tmp/azure-quickstart-templates/jenkins-cicd-vmss/HelloWorld/WebContent/* /opt/tomcat/webapps/ROOT
else
    echo 'ERROR: Repository URL is not provided'
fi

#echo 'export CATALINA_HOME="/opt/tomcat9"' >> /etc/environment
#echo 'export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' >> /etc/environment
#echo 'export JRE_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"' >> /etc/environment

# Create a systemd Service File
echo "[Unit]
Description=Apache Tomcat Web Server
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=15
Restart=always

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/tomcat.service

# Reload the systemd daemon for the new service file above
systemctl daemon-reload
# Start the Tomcat service
systemctl start tomcat
# Configure the Tomcat service to start during boot
systemctl enable tomcat

# https://stackoverflow.com/questions/4756039/how-to-change-the-port-of-tomcat-from-8080-to-80
# https://dzone.com/articles/running-tomcat-port-80-user
# http://2ality.blogspot.com/2010/07/running-tomcat-on-port-80-in-user.html

# Change default port to 80 from 8080
sed -i 's/Connector port="8080"/Connector port="80"/g' /opt/tomcat/conf/server.xml
apt-get install authbind
touch /etc/authbind/byport/80
chmod 500 /etc/authbind/byport/80
chown tomcat /etc/authbind/byport/80
echo 'CATALINA_OPTS="-Djava.net.preferIPv4Stack=true"' >> /opt/tomcat/bin/setenv.sh
sed -i 's/exec "$PRGDIR"\/"$EXECUTABLE" start "$@"/exec authbind --deep "$PRGDIR"\/"$EXECUTABLE" start "$@"/g' /opt/tomcat/bin/startup.sh

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync

if [ ! -z "$oms_workspace_id" -a ! -z "$oms_workspace_key" ];
then
    wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w $oms_workspace_id -s $oms_workspace_key -d opinsights.azure.com
else
    echo 'ERROR: OMS workspace id or key is not provided'
fi
