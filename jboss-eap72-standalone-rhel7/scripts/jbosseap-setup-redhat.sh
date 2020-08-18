#!/bin/sh

adddate() {
    while IFS= read -r line; do
        printf '%s %s\n' "$(date "+%Y-%m-%d %H:%M:%S")" "$line";
    done
}

/bin/date +%H:%M:%S >> jbosseap.install.log
echo "ooooo      RED HAT JBoss EAP 7.2 RPM INSTALL      ooooo" | adddate >> jbosseap.install.log

echo 'export EAP_HOME="/opt/rh/eap7/root/usr/share/wildfly"' >> ~/.bash_profile
source ~/.bash_profile
touch /etc/profile.d/eap_env.sh
echo 'export EAP_HOME="/opt/rh/eap7/root/usr/share/wildfly"' >> /etc/profile.d/eap_env.sh

export EAP_RPM_CONF_STANDALONE="/etc/opt/rh/eap7/wildfly/eap7-standalone.conf"
JBOSS_EAP_USER=$1
JBOSS_EAP_PASSWORD=$2
RHSM_USER=$3
RHSM_PASSWORD=$4
RHEL_OS_LICENSE_TYPE=$5
RHSM_POOL=$6
IP_ADDR=$(hostname -I)

echo "JBoss EAP admin user : " ${JBOSS_EAP_USER} | adddate >> jbosseap.install.log
echo "Initial JBoss EAP 7.2 setup" | adddate >> jbosseap.install.log
echo "subscription-manager register --username RHSM_USER --password RHSM_PASSWORD" | adddate >> jbosseap.install.log
subscription-manager register --username $RHSM_USER --password $RHSM_PASSWORD >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Red Hat Subscription Manager Registration Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
echo "subscription-manager attach --pool=EAP_POOL" | adddate  >> jbosseap.install.log
subscription-manager attach --pool=${RHSM_POOL} >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Pool Attach for JBoss EAP Failed" | adddate  >> jbosseap.install.log; exit $flag;  fi
if [ $RHEL_OS_LICENSE_TYPE == "BYOS" ] 
then 
    echo "Attaching Pool ID for RHEL OS" | adddate  >> jbosseap.install.log
    echo "subscription-manager attach --pool=RHEL_POOL" | adddate >> jbosseap.install.log
    subscription-manager attach --pool=$7 >> jbosseap.install.log 2>&1
    flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Pool Attach for RHEL OS Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
fi
echo "Subscribing the system to get access to JBoss EAP 7.2 repos" | adddate >> jbosseap.install.log

# Install JBoss EAP 7.2
echo "subscription-manager repos --enable=jb-eap-7-for-rhel-7-server-rpms" | adddate >> jbosseap.install.log
subscription-manager repos --enable=jb-eap-7-for-rhel-7-server-rpms >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Enabling repos for JBoss EAP Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
echo "yum-config-manager --disable rhel-7-server-htb-rpms" | adddate >> jbosseap.install.log
yum-config-manager --disable rhel-7-server-htb-rpms | adddate >> jbosseap.install.log

echo "Installing JBoss EAP 7.2 repos" | adddate >> jbosseap.install.log
echo "yum groupinstall -y jboss-eap7" | adddate >> jbosseap.install.log
yum groupinstall -y jboss-eap7 >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! JBoss EAP installation Failed" | adddate >> jbosseap.install.log; exit $flag;  fi

echo "echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config" | adddate >> jbosseap.install.log
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config | adddate >> jbosseap.install.log 2>&1
echo "systemctl restart sshd" | adddate >> jbosseap.install.log
systemctl restart sshd | adddate >> jbosseap.install.log 2>&1

echo "Start JBoss-EAP service" | adddate >> jbosseap.install.log
echo "systemctl enable eap7-standalone.service" | adddate >> jbosseap.install.log
systemctl enable eap7-standalone.service | adddate >> jbosseap.install.log 2>&1
echo "echo "WILDFLY_SERVER_CONFIG=standalone-full.xml" >> ${EAP_RPM_CONF_STANDALONE}" | adddate >> jbosseap.install.log
echo "WILDFLY_SERVER_CONFIG=standalone-full.xml" >> ${EAP_RPM_CONF_STANDALONE} | adddate >> jbosseap.install.log
echo "echo 'WILDFLY_BIND='$IP_ADDR >> ${EAP_RPM_CONF_STANDALONE}" | adddate >> jbosseap.install.log
echo 'WILDFLY_BIND='$IP_ADDR >> ${EAP_RPM_CONF_STANDALONE} | adddate >> jbosseap.install.log 2>&1
echo "echo "WILDFLY_OPTS=-Djboss.bind.address.management=$IP_ADDR" >> ${EAP_RPM_CONF_STANDALONE}" | adddate >> jbosseap.install.log
echo "WILDFLY_OPTS=-Djboss.bind.address.management=$IP_ADDR" >> ${EAP_RPM_CONF_STANDALONE} | adddate >> jbosseap.install.log 2>&1

echo "systemctl restart eap7-standalone.service" | adddate >> jbosseap.install.log
systemctl restart eap7-standalone.service | adddate >> jbosseap.install.log 2>&1
echo "systemctl status eap7-standalone.service" | adddate >> jbosseap.install.log
systemctl status eap7-standalone.service | adddate >> jbosseap.install.log 2>&1

echo "Installing GIT" | adddate >> jbosseap.install.log
echo "yum install -y git" | adddate >> jbosseap.install.log
yum install -y git | adddate >> jbosseap.install.log 2>&1

echo "Getting the sample JBoss-EAP on Azure app to install" | adddate >> jbosseap.install.log
echo "git clone https://github.com/Azure/azure-quickstart-templates.git" | adddate >> jbosseap.install.log
git clone https://github.com/Azure/azure-quickstart-templates.git >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Git clone Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
echo "mv ./azure-quickstart-templates/jboss-eap72-standalone-rhel7/scripts/JBoss-EAP_on_Azure.war $EAP_HOME/standalone/deployments/JBoss-EAP_on_Azure.war" | adddate >> jbosseap.install.log
mv ./azure-quickstart-templates/jboss-eap72-standalone-rhel7/scripts/JBoss-EAP_on_Azure.war $EAP_HOME/standalone/deployments/JBoss-EAP_on_Azure.war | adddate >> jbosseap.install.log 2>&1
echo "cat > $EAP_HOME/standalone/deployments/JBoss-EAP_on_Azure.war.dodeploy" | adddate >> jbosseap.install.log
cat > $EAP_HOME/standalone/deployments/JBoss-EAP_on_Azure.war.dodeploy | adddate >> jbosseap.install.log 2>&1

echo "Configuring JBoss EAP management user" | adddate >> jbosseap.install.log
echo "$EAP_HOME/bin/add-user.sh -u JBOSS_EAP_USER -p JBOSS_EAP_PASSWORD -g 'guest,mgmtgroup'" | adddate >> jbosseap.install.log
$EAP_HOME/bin/add-user.sh -u $JBOSS_EAP_USER -p $JBOSS_EAP_PASSWORD -g 'guest,mgmtgroup' >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! JBoss EAP management user configuration Failed" | adddate >> jbosseap.install.log; exit $flag;  fi

# Open Red Hat software firewall for port 8080 and 9990:
echo "firewall-cmd --zone=public --add-port=8080/tcp --permanent" | adddate >> jbosseap.install.log
firewall-cmd --zone=public --add-port=8080/tcp --permanent | adddate >> jbosseap.install.log 2>&1
echo "firewall-cmd --zone=public --add-port=9990/tcp --permanent" | adddate >> jbosseap.install.log
firewall-cmd --zone=public --add-port=9990/tcp --permanent | adddate  >> jbosseap.install.log 2>&1
echo "firewall-cmd --reload" | adddate >> jbosseap.install.log
firewall-cmd --reload | adddate >> jbosseap.install.log 2>&1

# Open Red Hat software firewall for port 22:
echo "firewall-cmd --zone=public --add-port=22/tcp --permanent" | adddate >> jbosseap.install.log
firewall-cmd --zone=public --add-port=22/tcp --permanent | adddate >> jbosseap.install.log 2>&1
echo "firewall-cmd --reload" | adddate >> jbosseap.install.log
firewall-cmd --reload | adddate >> jbosseap.install.log 2>&1

# Seeing a race condition timing error so sleep to delay
sleep 20

echo "ALL DONE!" | adddate >> jbosseap.install.log
/bin/date +%H:%M:%S >> jbosseap.install.log