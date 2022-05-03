#!/bin/sh

adddate() {
    while IFS= read -r line; do
        printf '%s %s\n' "$(date "+%Y-%m-%d %H:%M:%S")" "$line";
    done
}

/bin/date +%H:%M:%S >> jbosseap.install.log
echo "ooooo      RED HAT JBoss EAP RPM INSTALL      ooooo" | adddate >> jbosseap.install.log

echo 'export EAP_HOME="/opt/rh/eap7/root/usr/share/wildfly"' >> ~/.bash_profile
source ~/.bash_profile
touch /etc/profile.d/eap_env.sh
echo 'export EAP_HOME="/opt/rh/eap7/root/usr/share/wildfly"' >> /etc/profile.d/eap_env.sh

while getopts "a:t:p:f:" opt; do
    case $opt in
        a)
            artifactsLocation=$OPTARG #base uri of the file including the container
        ;;
        t)
            token=$OPTARG #saToken for the uri - use "?" if the artifact is not secured via sasToken
        ;;
        p)
            pathToFile=$OPTARG #path to the file relative to artifactsLocation
        ;;
        f)
            fileToDownload=$OPTARG #filename of the file to download from storage
        ;;
    esac
done

fileUrl="$artifactsLocation$pathToFile/$fileToDownload$token"

export EAP_RPM_CONF_STANDALONE="/etc/opt/rh/eap7/wildfly/eap7-standalone.conf"
JBOSS_EAP_USER=$9
JBOSS_EAP_PASSWORD=${10}
RHSM_USER=${11}
RHSM_PASSWORD=${12}
RHEL_OS_LICENSE_TYPE=${13}
RHSM_POOL=${14}
EAP_RHEL_VERSION=${15}
IP_ADDR=$(hostname -I)

echo "JBoss EAP admin user : " ${JBOSS_EAP_USER} | adddate >> jbosseap.install.log
echo "JBoss EAP on RHEL version you selected : " ${EAP_RHEL_VERSION} | adddate >> jbosseap.install.log
echo "Initial JBoss EAP setup" | adddate >> jbosseap.install.log
echo "subscription-manager register --username RHSM_USER --password RHSM_PASSWORD" | adddate >> jbosseap.install.log
subscription-manager register --username $RHSM_USER --password $RHSM_PASSWORD >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Red Hat Subscription Manager Registration Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
echo "subscription-manager attach --pool=EAP_POOL" | adddate >> jbosseap.install.log
subscription-manager attach --pool=${RHSM_POOL} >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Pool Attach for JBoss EAP Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
if [ $RHEL_OS_LICENSE_TYPE == "BYOS" ]
then
    echo "Attaching Pool ID for RHEL OS" | adddate >> jbosseap.install.log
    echo "subscription-manager attach --pool=RHEL_POOL" | adddate >> jbosseap.install.log
    subscription-manager attach --pool=${16} >> jbosseap.install.log 2>&1
fi

if [ ${EAP_RHEL_VERSION} == "JBoss-EAP7.3-on-RHEL8.4" ]
then
echo "Subscribing the system to get access to JBoss EAP 7.3 repos" | adddate >> jbosseap.install.log

# Install JBoss EAP 7.3
echo "subscription-manager repos --enable=jb-eap-7.3-for-rhel-8-x86_64-rpms" | adddate >> jbosseap.install.log
subscription-manager repos --enable=jb-eap-7.3-for-rhel-8-x86_64-rpms >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Enabling repos for JBoss EAP Failed" | adddate >> jbosseap.install.log; exit $flag;  fi

echo "Installing JBoss EAP 7.3 repos" | adddate >> jbosseap.install.log
echo "yum groupinstall -y jboss-eap7" | adddate >> jbosseap.install.log
yum groupinstall -y jboss-eap7 >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! JBoss EAP installation Failed" | adddate >> jbosseap.install.log; exit $flag;  fi

echo "sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config" | adddate >> jbosseap.install.log
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config | adddate >> jbosseap.install.log 2>&1
echo "echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config" | adddate >> jbosseap.install.log
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config | adddate >> jbosseap.install.log 2>&1
fi

if [ ${EAP_RHEL_VERSION} == "JBoss-EAP7.4-on-RHEL8.4" ]
then
echo "Subscribing the system to get access to JBoss EAP 7.4 repos" | adddate >> jbosseap.install.log

# Install JBoss EAP 7.4
echo "subscription-manager repos --enable=jb-eap-7.4-for-rhel-8-x86_64-rpms" | adddate >> jbosseap.install.log
subscription-manager repos --enable=jb-eap-7.4-for-rhel-8-x86_64-rpms >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Enabling repos for JBoss EAP Failed" | adddate >> jbosseap.install.log; exit $flag;  fi

echo "Installing JBoss EAP 7.4 repos" | adddate >> jbosseap.install.log
echo "yum groupinstall -y jboss-eap7" | adddate >> jbosseap.install.log
yum groupinstall -y jboss-eap7 >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! JBoss EAP installation Failed" | adddate >> jbosseap.install.log; exit $flag;  fi

echo "sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config" | adddate >> jbosseap.install.log
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config | adddate >> jbosseap.install.log 2>&1
echo "echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config" | adddate >> jbosseap.install.log
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config | adddate >> jbosseap.install.log 2>&1
fi

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

echo "Getting the sample JBoss-EAP on Azure app to install" | adddate >> jbosseap.install.log
echo "wget $fileUrl" | adddate >> jbosseap.install.log
wget $fileUrl >> jbosseap.install.log 2>&1
flag=$?; if [ $flag != 0 ] ; then echo  "ERROR! Sample Application Download Failed" | adddate >> jbosseap.install.log; exit $flag;  fi
echo "mv ./JBoss-EAP_on_Azure.war $EAP_HOME/standalone/deployments/JBoss-EAP_on_Azure.war" | adddate >> jbosseap.install.log
mv ./JBoss-EAP_on_Azure.war $EAP_HOME/standalone/deployments/JBoss-EAP_on_Azure.war | adddate >> jbosseap.install.log 2>&1
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