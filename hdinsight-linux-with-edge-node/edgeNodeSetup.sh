clustername=$1
clusterSshUser=$2
clusterSshPw=$3
appInstallScriptUri=$4

#Make the file path for the configs to be copied to
targetFilePath=/etc
mkdir -p $targetFilePath
echo "Created $targetFilePath for configs to be placed"

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
for path in "${CONFIGPATHS[@]}"
do
	mkdir -p "$tmpFilePath/$path"
	sshpass -p $clusterSshPw scp -r $clusterSshUser@$clusterSshHostName:"$path/*" "$tmpFilePath$path"
done
cp -r $tmpFilePath/* /
rm -rf $tmpFilePath

#Decrypt and replace keys
echo "Decrypting storage keys"

#Get the decrypt script on the cluster
wasbDecryptScript=$(grep "shellkeyprovider" -A1 ${targetFilePath}/core-site.xml | perl -ne "s/<\/?value>//g and print" | sed 's/^[ \t]*//;s/[ \t]*$//')
echo $wasbDecryptScript

#Get a list of all the keys in the core-site file
#For each key it will create two entries in the array; the first will be the property name; the second will be the value
accountsAndKeys=($(sed -ne '/<name>fs.azure.account.key\..*.blob.core.windows.net/,/<\/value>/ p' "${targetFilePath}/core-site.xml"))
accountAndKeysLen=${#accountsAndKeys[@]}

index="0"
while [ $index -lt $accountAndKeysLen ]
do
    propertyName=$(echo ${accountsAndKeys[$index]} | perl -ne "s/<\/?name>//g and print")
    encryptedKey=$(echo ${accountsAndKeys[$index+1]} | perl -ne "s/<\/?value>//g and print")
    echo "Decrypting key"
    decryptedKey=$(sshpass -p $clusterSshPw ssh $clusterSshUser@$clusterSshHostName "${wasbDecryptScript} ${encryptedKey}")
    escapedKey=${decryptedKey//\//\\/}
    #Actually replace decrypted key
    perl -i -00pe "s/.*<name>$propertyName<\/name>\n.*<value>.*<\/value>\n/      <name>$propertyName<\/name>\n      <value>$escapedKey<\/value>\n/" ${targetFilePath}/core-site.xml
    index=$[$index+2]
done

#Remove the key provider from the config
perl -i -00pe 's/.*<property>\n.*fs.azure.account.keyprovider.*\n.*\n.*<\/property>\n.*\n//' ${targetFilePath}/core-site.xml

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
sudo -E bash $(basename "$appInstallScriptUri") >output 2>error

