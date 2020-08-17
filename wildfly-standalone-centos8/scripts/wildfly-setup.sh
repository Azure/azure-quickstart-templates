#!/bin/sh

adddate() {
    while IFS= read -r line; do
        printf '%s %s\n' "$(date "+%Y-%m-%d %H:%M:%S")" "$line";
    done
}

echo "WILDFLY 18.0.1.Final Standalone Intallation Start..." | adddate >> wildfly.install.log
/bin/date +%H:%M:%S  >> wildfly.install.log

WILDFLY_USER=$1
WILDFLY_PASSWORD=$2
IP_ADDR=$(hostname -I)

echo "WILDFLY_USER: " ${WILDFLY_USER} | adddate >> wildfly.install.log

echo "WILDFLY Downloading..." | adddate >> wildfly.install.log
echo "yum install -y git unzip java" | adddate >> wildfly.install.log
yum install -y git unzip java | adddate >> wildfly.install.log 2>&1
echo "yum -y install wget" | adddate >> wildfly.install.log
yum -y install wget | adddate >> wildfly.install.log 2>&1
WILDFLY_RELEASE="18.0.1"
echo "wget https://download.jboss.org/wildfly/$WILDFLY_RELEASE.Final/wildfly-$WILDFLY_RELEASE.Final.tar.gz" | adddate >> wildfly.install.log
wget https://download.jboss.org/wildfly/$WILDFLY_RELEASE.Final/wildfly-$WILDFLY_RELEASE.Final.tar.gz >> wildfly.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Downloading WildFly Failed" | adddate >> wildfly.install.log; exit $flag;  fi
echo "tar xvf wildfly-$WILDFLY_RELEASE.Final.tar.gz" | adddate >> wildfly.install.log
tar xvf wildfly-$WILDFLY_RELEASE.Final.tar.gz | adddate >> wildfly.install.log 2>&1

echo "echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config" | adddate >> wildfly.install.log
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config | adddate >> wildfly.install.log 2>&1
echo "systemctl restart sshd" | adddate >> wildfly.install.log
systemctl restart sshd | adddate >> wildfly.install.log 2>&1

echo "Sample app deploy..." | adddate >> wildfly.install.log
echo "git clone https://github.com/Azure/azure-quickstart-templates.git" | adddate >> wildfly.install.log
git clone https://github.com/Azure/azure-quickstart-templates.git >> wildfly.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Git clone Failed" | adddate >> wildfly.install.log; exit $flag;  fi
echo "/bin/cp -rf ./azure-quickstart-templates/wildfly-standalone-centos8/scripts/JBoss-EAP_on_Azure.war ./wildfly-$WILDFLY_RELEASE.Final/standalone/deployments/" | adddate >> wildfly.install.log
/bin/cp -rf ./azure-quickstart-templates/wildfly-standalone-centos8/scripts/JBoss-EAP_on_Azure.war ./wildfly-$WILDFLY_RELEASE.Final/standalone/deployments/ | adddate >> wildfly.install.log 2>&1

echo "Configuring WILDFLY managment user..." | adddate >> wildfly.install.log
echo "./wildfly-$WILDFLY_RELEASE.Final/bin/add-user.sh -u WILDFLY_USER -p WILDFLY_PASSWORD -g 'guest,mgmtgroup'" | adddate >> wildfly.install.log
./wildfly-$WILDFLY_RELEASE.Final/bin/add-user.sh -u $WILDFLY_USER -p $WILDFLY_PASSWORD -g 'guest,mgmtgroup' >> wildfly.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! WildFly management user configuration Failed" | adddate >> wildfly.install.log; exit $flag;  fi

echo "Start WILDFLY 18.0.1.Final instance..." | adddate >> wildfly.install.log
echo "./wildfly-$WILDFLY_RELEASE.Final/bin/standalone.sh -b $IP_ADDR -bmanagement $IP_ADDR &" | adddate >> wildfly.install.log
./wildfly-$WILDFLY_RELEASE.Final/bin/standalone.sh -b $IP_ADDR -bmanagement $IP_ADDR | adddate >> wildfly.install.log 2>&1 &
sleep 20

echo "Configure firewall for ports 8080, 9990..." | adddate >> wildfly.install.log
echo "firewall-cmd --zone=public --add-port=8080/tcp --permanent" | adddate >> wildfly.install.log
firewall-cmd --zone=public --add-port=8080/tcp --permanent | adddate >> wildfly.install.log 2>&1
echo "firewall-cmd --zone=public --add-port=9990/tcp --permanent" | adddate >> wildfly.install.log
firewall-cmd --zone=public --add-port=9990/tcp --permanent | adddate >> wildfly.install.log 2>&1
echo "firewall-cmd --reload" | adddate >> wildfly.install.log
firewall-cmd --reload | adddate >> wildfly.install.log 2>&1

echo "Open WILDFLY software firewall for port 22..." | adddate >> wildfly.install.log
echo "firewall-cmd --zone=public --add-port=22/tcp --permanent" | adddate >> wildfly.install.log
firewall-cmd --zone=public --add-port=22/tcp --permanent | adddate >> wildfly.install.log 2>&1
echo "firewall-cmd --reload" | adddate >> wildfly.install.log
firewall-cmd --reload | adddate >> wildfly.install.log 2>&1

echo "WILDFLY 18.0.1.Final Standalone Intallation End..." | adddate >> wildfly.install.log
/bin/date +%H:%M:%S >> wildfly.install.log
