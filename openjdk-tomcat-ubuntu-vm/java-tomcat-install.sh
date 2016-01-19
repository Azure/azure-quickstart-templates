sudo apt-get install unzip

cd /usr/lib
sudo mkdir jvm
sudo mkdir tomcat

cd jvm
sudo curl -o ./zulu1.8.0_latest-x86lx64.zip https://azuredownloads.blob.core.windows.net/openjdk/zulu1.8.0_latest-x86lx64.zip
sudo unzip zulu1.8.0_latest-x86lx64.zip
sudo rm zulu1.8.0_latest-x86lx64.zip

export JAVA_HOME=/usr/lib/jvm/zulu1.8.0_latest-x86lx64
export PATH=$PATH:$JAVA_HOME/bin

sudo chmod a+x $JAVA_HOME/bin/java

cd ../tomcat
if [ -z "$1" ]; then
       tomcatZipLoc="https://azuredownloads.blob.core.windows.net/tomcat/apache-tomcat-8.latest.zip"
elif [ $1 == tomcat7 ]; then
       tomcatZipLoc="https://azuredownloads.blob.core.windows.net/tomcat/apache-tomcat-7.latest.zip"
elif [ $1 == tomcat6 ]; then
       tomcatZipLoc="https://azuredownloads.blob.core.windows.net/tomcat/apache-tomcat-6.latest.zip"
else 
       tomcatZipLoc="https://azuredownloads.blob.core.windows.net/tomcat/apache-tomcat-8.latest.zip"
fi
      
sudo curl -o ./latest.zip $tomcatZipLoc
sudo unzip latest.zip
sudo rm latest.zip
export CurrentTomcatFolder=$(ls | head -1)
sudo mv $CurrentTomcatFolder latest

export CATALINA_HOME=/usr/lib/tomcat/latest
export SERVER_APPS_LOCATION=$CATALINA_HOME/webapps
export PATH=$PATH:$CATALINA_HOME/bin
cd $CATALINA_HOME
sudo chown -R $USER .
cd $CATALINA_HOME/bin
sudo chmod +x *.sh

sudo touch setenv.sh
echo 'export JAVA_HOME=/usr/lib/jvm/zulu1.8.0_latest-x86lx64' | sudo tee --append setenv.sh

sudo touch /etc/init.d/tomcat
sudo echo '# Tomcat auto-start' | sudo tee --append /etc/init.d/tomcat
sudo echo '#' | sudo tee --append /etc/init.d/tomcat
sudo echo '# description: Auto-starts tomcat' | sudo tee --append /etc/init.d/tomcat
sudo echo '# processname: tomcat' | sudo tee --append /etc/init.d/tomcat
sudo echo '# pidfile: /var/run/tomcat.pid' | sudo tee --append /etc/init.d/tomcat
sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-6-sun' | sudo tee --append /etc/init.d/tomcat
sudo echo 'export CATALINA_HOME=/usr/lib/tomcat/latest' | sudo tee --append /etc/init.d/tomcat
sudo echo 'export SERVER_APPS_LOCATION=$CATALINA_HOME/webapps' | sudo tee --append /etc/init.d/tomcat
sudo echo 'export PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin' | sudo tee --append /etc/init.d/tomcat
sudo echo 'case $1 in' | sudo tee --append /etc/init.d/tomcat
sudo echo 'start)' | sudo tee --append /etc/init.d/tomcat
sudo echo '        sh /usr/lib/tomcat/latest/bin/startup.sh' | sudo tee --append /etc/init.d/tomcat
sudo echo '        ;; ' | sudo tee --append /etc/init.d/tomcat
sudo echo 'stop)   ' | sudo tee --append /etc/init.d/tomcat
sudo echo '        sh /usr/lib/tomcat/latest/bin/shutdown.sh' | sudo tee --append /etc/init.d/tomcat
sudo echo '        ;; ' | sudo tee --append /etc/init.d/tomcat
sudo echo 'restart)' | sudo tee --append /etc/init.d/tomcat
sudo echo '        sh /usr/lib/tomcat/latest/bin/shutdown.sh' | sudo tee --append /etc/init.d/tomcat
sudo echo '        sh /usr/lib/tomcat/latest/bin/startup.sh' | sudo tee --append /etc/init.d/tomcat
sudo echo '        ;; ' | sudo tee --append /etc/init.d/tomcat
sudo echo 'esac    ' | sudo tee --append /etc/init.d/tomcat
sudo echo 'exit 0' | sudo tee --append /etc/init.d/tomcat

sudo chmod 755 /etc/init.d/tomcat

sudo ln -s /etc/init.d/tomcat /etc/rc1.d/K99tomcat
sudo ln -s /etc/init.d/tomcat /etc/rc2.d/S99tomcat

sh /usr/lib/tomcat/latest/bin/startup.sh