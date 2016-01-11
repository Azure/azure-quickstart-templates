appInstallScriptUri=$1
clustername=$2
clusterSshUser=$3
clusterSshPw=$4
clusterLogin=$5
clusterPassword=$6

clusterSshHostName="$clustername-ssh.azurehdinsight.net"
echo "Adding cluster host to known hosts if not exist"
knownHostKey=$(ssh-keygen -H -F $clusterSshHostName 2>/dev/null)
if [ -z "$knownHostKey" ]
then
ssh-keyscan -H $clusterSshHostName >> ~/.ssh/known_hosts
fi

#Get sshpass
echo "Installing sshpass"
apt-get -y -qq install sshpass

#Copying configs
echo "Copying configs and cluster resources local"
tmpFilePath=~/tmpConfigs
mkdir -p $tmpFilePath
RESOURCEPATHS=(/etc/hadoop/conf /etc/hive/conf /var/lib/ambari-server/resources/scripts)
for path in "${RESOURCEPATHS[@]}"
do
	mkdir -p "$tmpFilePath/$path"
	sshpass -p $clusterSshPw scp -r $clusterSshUser@$clusterSshHostName:"$path/*" "$tmpFilePath$path"
done

#Get the decrypt utilities from the cluster
wasbDecryptScript=$(grep "shellkeyprovider" -A1 ${tmpFilePath}/etc/hadoop/conf/core-site.xml | perl -ne "s/<\/?value>//g and print" | sed 's/^[ \t]*//;s/[ \t]*$//')
decryptUtils=$(dirname $wasbDecryptScript)
echo "WASB Decrypt Utils being copied locally from $decryptUtils on the headnode"

echo "Copying decrypt utilities for WASB storage"
mkdir -p "$tmpFilePath/$decryptUtils"
sshpass -p $clusterSshPw scp -r $clusterSshUser@$clusterSshHostName:"$decryptUtils/*" "$tmpFilePath$decryptUtils"

#Get hadoop symbolic links from the cluster
mkdir -p "$tmpFilePath/usr/bin"
sshpass -p $clusterSshPw ssh $clusterSshUser@$clusterSshHostName "find /usr/bin -readable -lname '/usr/hdp/*' -exec test -e {} \; -print" | while read fileName ; do sshpass -p $clusterSshPw scp $clusterSshUser@$clusterSshHostName:$fileName "$tmpFilePath$fileName" ; done

#Get the hadoop binaries from the cluster
binariesLocation=$(grep HADOOP_HOME "$tmpFilePath/usr/bin/hadoop" -m 1 | sed 's/.*:-//;s/\(.*\)hadoop}/\1/;s/\(.*\)\/.*/\1/')
#Zip the files
echo "Zipping binaries on headnode"
bitsFileName=hdpBits.tar.gz
loggingBitsFileName=loggingBits.tar.gz
tmpRemoteFolderName=tmpBits
sshpass -p $clusterSshPw ssh $clusterSshUser@$clusterSshHostName "mkdir ~/$tmpRemoteFolderName"
sshpass -p $clusterSshPw ssh $clusterSshUser@$clusterSshHostName "tar -cvzf ~/$tmpRemoteFolderName/$bitsFileName $binariesLocation &>/dev/null"
sshpass -p $clusterSshPw ssh $clusterSshUser@$clusterSshHostName "tar -cvzf ~/$tmpRemoteFolderName/$loggingBitsFileName /usr/lib/hdinsight-logging &>/dev/null"
#Copy the binaries
echo "Copying binaries from headnode"
sshpass -p $clusterSshPw scp $clusterSshUser@$clusterSshHostName:"~/$tmpRemoteFolderName/$bitsFileName" .
sshpass -p $clusterSshPw scp $clusterSshUser@$clusterSshHostName:"~/$tmpRemoteFolderName/$loggingBitsFileName" .
#Unzip the binaries
echo "Unzipping binaries"
tar -xhzvf $bitsFileName -C /
tar -xhzvf $loggingBitsFileName -C /
#Remove the temporary folders
rm -f $bitsFileName
sshpass -p $clusterSshPw ssh $clusterSshUser@$clusterSshHostName "rm -rf ~/$tmpRemoteFolderName"

#Copy all from the temp directory into the final directory
cp -rf $tmpFilePath/* /
rm -rf $tmpFilePath

#Install Java
echo "Installing Java"
#Retrying due to reliability issues when installing
installedJavaPkg=""
javaRetryAttempt="0"
javaRetryMaxAttempt="3"
while [ -z "$installedJavaPkg" ] && [ $javaRetryAttempt -lt $javaRetryMaxAttempt ]
do
    apt-get -y -qq install openjdk-7-jdk
    javaRetryAttempt=$[$javaRetryAttempt+1]
    installedJavaPkg=$(dpkg --get-selections | grep -o openjdk-7-jdk)
    if [ -z $installedJavaPkg ]
    then
        echo "Java package did not install properly. Running apt-get update and retrying" >&2
        apt-get update
    fi
done

if [ -z "$installedJavaPkg" ]
then
    echo "Java package did not install properly after retries" >&2
	exit 1
fi
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

#Install WebWasb
WEBWASB_TARFILE=webwasb-tomcat.tar.gz
WEBWASB_TARFILEURI=https://hdiconfigactions.blob.core.windows.net/linuxhueconfigactionv01/$WEBWASB_TARFILE
WEBWASB_TMPFOLDER=/tmp/webwasb
WEBWASB_INSTALLFOLDER=/usr/share/webwasb-tomcat

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

echo "Adding webwasb user"
useradd -r webwasb

echo "Making webwasb a service and start it"
sed -i "s|JAVAHOMEPLACEHOLDER|$JAVA_HOME|g" $WEBWASB_INSTALLFOLDER/upstart/webwasb.conf
chown -R webwasb:webwasb $WEBWASB_INSTALLFOLDER

cp -f $WEBWASB_INSTALLFOLDER/upstart/webwasb.conf /etc/init/
initctl reload-configuration
stop webwasb
start webwasb

#WebWasb takes a little bit of time to start up.
sleep 20

#Get and execute app install script Uri
APP_TEMP_INSTALLDIR=/var/log/hdiapp
rm -rf $APP_TEMP_INSTALLDIR
mkdir $APP_TEMP_INSTALLDIR

wget $appInstallScriptUri -P $APP_TEMP_INSTALLDIR
cd $APP_TEMP_INSTALLDIR 
#Output the stdout and stderror to the app directory
sudo -E bash $(basename "$appInstallScriptUri") $clustername $clusterLogin $clusterPassword >output 2>error

