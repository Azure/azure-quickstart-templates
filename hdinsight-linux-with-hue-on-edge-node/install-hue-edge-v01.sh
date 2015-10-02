#! /bin/bash

CORESITEPATH=/etc/hadoop/conf/core-site.xml
AMBARICONFIGS_SH=/var/lib/ambari-server/resources/scripts/configs.sh
PORT=8080

WEBWASB_TARFILE=webwasb-tomcat.tar.gz
WEBWASB_TARFILEURI=https://hdiconfigactions.blob.core.windows.net/linuxhueconfigactionedgenodev01/$WEBWASB_TARFILE
WEBWASB_TMPFOLDER=/tmp/webwasb
WEBWASB_INSTALLFOLDER=/usr/share/webwasb-tomcat

HUE_TARFILE=hue-binaries.tgz
HUE_TARFILEURI=https://hdiconfigactions.blob.core.windows.net/linuxhueconfigactionedgenodev01/$HUE_TARFILE
HUE_TMPFOLDER=/tmp/hue
HUE_INSTALLFOLDER=/usr/share/hue
HUE_INIPATH=$HUE_INSTALLFOLDER/desktop/conf/hue.ini

usage() {
    echo ""
    echo "Usage: sudo -E bash install-hue-edge-v01.sh <CLUSTERNAME> <USERID> <PASSWORD>";
    echo "       [CLUSTERNAME]: Mandatory parameter cluster name";
    echo "       [USERID]: Mandatory parameter user name/id";
    echo "       [PASSWORD]: Mandatory cluster password for cluster user surrounded by single quotes. E.g. 'Your password goes here'";
    exit 1;
}

selectActiveAmbariHost() {
	echo "Selecting active ambari host"
	
    ACTIVEAMBARIHOST=headnode0
    coreSiteContent=$(bash $AMBARICONFIGS_SH -u $USERID -p $PASSWD get $ACTIVEAMBARIHOST $CLUSTERNAME core-site)
    if [[ $coreSiteContent == *"[ERROR]"* ]]; then
        if [[ $coreSiteContent == *"Bad credentials"* ]]; then
            echo "[ERROR] Username and password are invalid. Exiting!"
            exit 1
        else
            ACTIVEAMBARIHOST=headnode1
        fi
    fi
    
    coreSiteContent=$(bash $AMBARICONFIGS_SH -u $USERID -p $PASSWD get $ACTIVEAMBARIHOST $CLUSTERNAME core-site)
    if [[ $coreSiteContent == *"[ERROR]"* ]]; then
        if [[ $coreSiteContent == *"Bad credentials"* ]]; then
            echo "[ERROR] Username and password are invalid. Exiting!"
            exit 1
        else
            echo "[ERROR] There is no active Ambari host. Exiting!"
            exit 1
        fi
    fi
	
	echo "Active ambari host is $ACTIVEAMBARIHOST"
}

updateAmbariConfigs() {
	echo "Updating ambari configs, adding hue user to oozie configs"
	
    updateResult=$(bash $AMBARICONFIGS_SH -u $USERID -p $PASSWD set $ACTIVEAMBARIHOST $CLUSTERNAME core-site "hadoop.proxyuser.oozie.groups" "*")
    
    if [[ $updateResult != *"Tag:version"* ]] && [[ $updateResult == *"[ERROR]"* ]]; then
        echo "[ERROR] Failed to update core-site. Exiting!"
        echo $updateResult
        exit 1
    fi
    
    echo "Updated hadoop.proxyuser.oozie.groups = *"
    
    updateResult=$(bash $AMBARICONFIGS_SH -u $USERID -p $PASSWD set $ACTIVEAMBARIHOST $CLUSTERNAME oozie-site "oozie.service.ProxyUserService.proxyuser.hue.hosts" "*")
    
    if [[ $updateResult != *"Tag:version"* ]] && [[ $updateResult == *"[ERROR]"* ]]; then
        echo "[ERROR] Failed to update oozie-site. Exiting!"
        echo $updateResult
        exit 1
    fi
    
    echo "Updated oozie.service.ProxyUserService.proxyuser.hue.hosts = *"
    
    updateResult=$(bash $AMBARICONFIGS_SH -u $USERID -p $PASSWD set $ACTIVEAMBARIHOST $CLUSTERNAME oozie-site "oozie.service.ProxyUserService.proxyuser.hue.groups" "*")
    
    if [[ $updateResult != *"Tag:version"* ]] && [[ $updateResult == *"[ERROR]"* ]]; then
        echo "[ERROR] Failed to update oozie-site. Exiting!"
        echo $updateResult
        exit 1
    fi
    
    echo "Updated oozie.service.ProxyUserService.proxyuser.hue.groups = *"
}

stopServiceViaRest() {
    if [ -z "$1" ]; then
        echo "Need service name to stop service"
        exit 1
    fi
    SERVICENAME=$1
    echo "Stopping $SERVICENAME"
    curl -u $USERID:$PASSWD -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Stop Service for Hue installation"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://$ACTIVEAMBARIHOST:$PORT/api/v1/clusters/$CLUSTERNAME/services/$SERVICENAME
}

startServiceViaRest() {
    if [ -z "$1" ]; then
        echo "Need service name to start service"
        exit 1
    fi
    sleep 2
    SERVICENAME=$1
    echo "Starting $SERVICENAME"
    startResult=$(curl -u $USERID:$PASSWD -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start Service for Hue installation"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://$ACTIVEAMBARIHOST:$PORT/api/v1/clusters/$CLUSTERNAME/services/$SERVICENAME)
    if [[ $startResult == *"500 Server Error"* || $startResult == *"internal system exception occurred"* ]]; then
        sleep 60
        echo "Retry starting $SERVICENAME"
        startResult=$(curl -u $USERID:$PASSWD -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start Service for Hue installation"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://$ACTIVEAMBARIHOST:$PORT/api/v1/clusters/$CLUSTERNAME/services/$SERVICENAME)
    fi
    echo $startResult
}

downloadAndUnzipWebWasb() {
    echo "Removing WebWasb installation and tmp folder"
    rm -rf $WEBWASB_INSTALLFOLDER/
    rm -rf $WEBWASB_TMPFOLDER/
    mkdir $WEBWASB_TMPFOLDER/
    
    echo "Downloading webwasb tar file"
    wget $WEBWASB_TARFILEURI -P $WEBWASB_TMPFOLDER
    
    echo "Unzipping webwasb-tomcat"
    cd $WEBWASB_TMPFOLDER
    tar -zxvf $WEBWASB_TARFILE -C /usr/share/
    
    rm -rf $WEBWASB_TMPFOLDER/
}

setupWebWasbService() {
    echo "Adding webwasb user"
    useradd -r webwasb

    echo "Making webwasb a service and start it"
    sed -i "s|JAVAHOMEPLACEHOLDER|$JAVA_HOME|g" $WEBWASB_INSTALLFOLDER/upstart/webwasb.conf
    chown -R webwasb:webwasb $WEBWASB_INSTALLFOLDER

    cp -f $WEBWASB_INSTALLFOLDER/upstart/webwasb.conf /etc/init/
    initctl reload-configuration
    stop webwasb
    start webwasb
}

downloadAndUnzipHue() {
    echo "Removing Hue tmp folder"
    rm -rf $HUE_TMPFOLDER
    mkdir $HUE_TMPFOLDER
    
    echo "Downloading Hue tar file"
    wget $HUE_TARFILEURI -P $HUE_TMPFOLDER
    
    echo "Unzipping Hue"
    cd $HUE_TMPFOLDER
    tar -zxvf $HUE_TARFILE -C /usr/share/
    
    rm -rf $HUE_TMPFOLDER
}

setupHueService() {
    echo "Installing Hue dependencies"
    export DEBIAN_FRONTEND=noninteractive
    apt-get -q -y install libxslt-dev
    
    echo "Configuring Hue default FS"
    defaultfsnode=$(sed -n '/<name>fs.default/,/<\/value>/p' $CORESITEPATH)
    if [ -z "$defaultfsnode" ]
      then
        echo "[ERROR] Cannot find fs.defaultFS configuration in core-site.xml. Exiting"
        exit 1
    fi

    defaultfs=$(sed -n -e 's/.*<value>\(.*\)<\/value>.*/\1/p' <<< $defaultfsnode)

    if [[ $defaultfs != wasb* ]]
      then
        echo "[ERROR] fs.defaultFS is not WASB. Exiting."
        exit 1
    fi

    sed -i "s|DEFAULTFSPLACEHOLDER|$defaultfs|g" $HUE_INIPATH
    
    echo "Adding hue user"
    useradd -r hue
    chown -R hue:hue /usr/share/hue

    echo "Making Hue a service and start it"
    cp $HUE_INSTALLFOLDER/upstart/hue.conf /etc/init/
    initctl reload-configuration
    stop hue
    start hue
}

##############################

if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] The script has to be run as root."
    usage
fi

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

if [ -e $HUE_INSTALLFOLDER ]; then
    echo "Hue is already installed. Exiting ..."
    exit 0
fi

echo JAVA_HOME=$JAVA_HOME

CLUSTERNAME=$1;
if [ -z "$CLUSTERNAME" ]; then
    echo "[ERROR] No cluster name specified. Exiting!"
    usage
fi
echo "CLUSTERNAME=$CLUSTERNAME";

USERID=$2;
if [ -z "$USERID" ]; then
    echo "[ERROR] No user id specified. Exiting!"
    usage
fi
echo "USERID=$USERID";

PASSWD=$3;
if [ -z "$PASSWD" ]; then
    echo "[ERROR] No password specified. Exiting!"
    usage
fi
echo "PASSWD=$PASSWD";

selectActiveAmbariHost
updateAmbariConfigs
stopServiceViaRest HDFS
stopServiceViaRest YARN
stopServiceViaRest MAPREDUCE2
stopServiceViaRest OOZIE

echo "Download and unzip WebWasb and Hue while services are STOPPING"
downloadAndUnzipWebWasb
downloadAndUnzipHue

startServiceViaRest YARN
startServiceViaRest MAPREDUCE2
startServiceViaRest OOZIE
startServiceViaRest HDFS

setupWebWasbService
setupHueService

