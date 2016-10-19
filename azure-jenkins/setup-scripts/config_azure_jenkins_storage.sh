#!/bin/sh

#echo "Usage:
#  1 sh config_azure_jenkins_storage.sh
#  2 sh config_azure_jenkins_storage.sh <Subscription ID>
#  3 sh config_azure_jenkins_storage.sh <Subscription ID> <Storage Account name>
#  4 sh config_azure_jenkins_storage.sh <Subscription ID> <Storage Account name> <Resource Group name>
#  5 sh config_azure_jenkins_storage.sh <Subscription ID> <Storage Account name> <Resource Group name> <Source Container name> <Dest Container name>
#"

#create log file
log_dir_path='/tmp/azurejenkinslog/'
if [ ! -d $log_dir_path ]
then
  sudo mkdir $log_dir_path
fi

log_file_name="config_azure.log"
log_file_path="$log_dir_path$log_file_name"

if [ ! -f $log_file_path ]
then
  sudo touch $log_file_path
fi

# ip_addr=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
instruction_goto_dashboard="Please go to Jenkins dashboard by inputting <Your VM IP address>:8080 in your preferred browser. You can find the IP address in Azure portal."

dest_account_file_path='/var/lib/jenkins/com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher.xml'

SUBSCRIPTION_ID=$1
STORAGE_ACCOUNT_NAME=$2
RESOURCE_GROUP_NAME=$3
SOURCE_CONTAINER_NAME=$4
DEST_CONTAINER_NAME=$5

echo ""
#check if the user has subscriptions. If not she's probably not logged in
subscriptions_list=$(azure account list --json)
subscriptions_list_count=$(echo $subscriptions_list | jq '. | length' 2>/dev/null)
if [ $? -ne 0 ] || [ "$subscriptions_list_count" -eq "0" ]
then
  azure login
fi

if [ -z "$SUBSCRIPTION_ID" ]
then
  #prompt for subscription
  subscriptions_list=$(azure account list --json)
  subscriptions_list_count=$(echo $subscriptions_list | jq '. | length')
  if [ $subscriptions_list_count -eq 0 ]
  then
    echo "  You need to sign up an Azure Subscription here: https://azure.microsoft.com"
    exit 1
  elif [ $subscriptions_list_count -gt 1 ]
  then
    echo $subscriptions_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

    subscription_idx=0
    until [ $subscription_idx -ge 1 -a $subscription_idx -le $subscriptions_list_count ]
    do
      read -p "  Select a subscription by typing an index number from above list and press [Enter]: " subscription_idx
      if [ $subscription_idx -ne 0 -o $subscription_idx -eq 0 2>/dev/null ]
      then
        :
      else
        subscription_idx=0
      fi
    done
    subscription_index=$((subscription_idx-1))

    SUBSCRIPTION_ID=`echo $subscriptions_list | jq -r '.['$subscription_index'] | .id'`
    echo ""
  fi
fi

azure account set $SUBSCRIPTION_ID >/dev/null
if [ $? -ne 0 ]
then
  exit 1
else
  echo "  Using subscription ID $SUBSCRIPTION_ID"
  echo ""
fi

if [ -z "$STORAGE_ACCOUNT_NAME" ]
then
    sudo sh -c "echo '$(date): List storage accounts' >> $log_file_path"
    storage_account_list=`azure storage account list --json`
    storage_account_list_length=`echo $storage_account_list | jq '. | length'`
    if [ $storage_account_list_length -eq 0 ]
    then
        sudo sh -c "echo '$(date): No storage accounts found' >> $log_file_path"
        echo "  Please go to Azure portal and create a storage account."
        exit 1
    else
        storage_account_index=0
        if [ $storage_account_list_length -gt 1 ]
        then
            sudo sh -c "echo '$(date): List storage accounts for selection' >> $log_file_path"
            echo $storage_account_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

            storage_account_idx=0
            until [ $storage_account_idx -ge 1 -a $storage_account_idx -le $storage_account_list_length ]
            do
              read -p "  Select a storage account by typing an index number from above list and press [Enter]: " storage_account_idx
              if [ $storage_account_idx -ne 0 -o $storage_account_idx -eq 0 2>/dev/null ]
              then
                :
              else
                storage_account_idx=0
              fi
            done
            storage_account_index=$((storage_account_idx-1))
        fi

        sudo sh -c "echo '$(date): Set storage account' >> $log_file_path"
        STORAGE_ACCOUNT_NAME=`echo $storage_account_list | jq -r '.['$storage_account_index'] | .name'`
        RESOURCE_GROUP_NAME=`echo $storage_account_list | jq -r '.['$storage_account_index'] | .resourceGroup'`
    fi
fi

echo "  Using storage account $STORAGE_ACCOUNT_NAME"
echo "  Using resource group $RESOURCE_GROUP_NAME"
echo ""

sudo sh -c "echo '$(date): Get storage account key' >> $log_file_path"
keys_result=`azure storage account keys list $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME --json`
STORAGE_ACCOUNT_KEY=`echo $keys_result | jq -r '.[0].value'`

# Create config file for adding storage account
tmp_account_file_path='/tmp/com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher.xml'

sudo sh -c "echo '$(date): Create temp storage account config file' >> $log_file_path"

cat <<EOF > $tmp_account_file_path
<?xml version='1.0' encoding='UTF-8'?>
<com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher_-WAStorageDescriptor plugin="windows-azure-storage@0.3.1">
  <storageAccounts>
    <com.microsoftopentechnologies.windowsazurestorage.beans.StorageAccountInfo>
      <storageAccName>${STORAGE_ACCOUNT_NAME}</storageAccName>
      <storageAccountKey>${STORAGE_ACCOUNT_KEY}</storageAccountKey>
      <blobEndPointURL>http://blob.core.windows.net/</blobEndPointURL>
    </com.microsoftopentechnologies.windowsazurestorage.beans.StorageAccountInfo>
  </storageAccounts>
</com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher_-WAStorageDescriptor>
EOF

sudo sh -c "echo '$(date): Copy temp config file to Jenkins directory' >> $log_file_path"
sudo cp $tmp_account_file_path $dest_account_file_path
if [ $? -ne 0 ]
then
  exit 1
else
  echo "  Storage account was successfully added to Jenkins Azure Storage plugin."
  echo ""
fi

dest_download_container_file_path='/var/lib/jenkins/jobs/1. Download Dependencies. Invoked by pipeline/config.xml'
dest_upload_container_file_path='/var/lib/jenkins/jobs/3. Upload test app. Invoked by pipeline/config.xml'
if [ -f "$dest_download_container_file_path" ] && [ -f "$dest_upload_container_file_path" ]
then
    echo "  Blob containers have been set before."
    echo "  $instruction_goto_dashboard"
    exit 0
fi

sudo sh -c "echo '$(date): Set container config files' >> $log_file_path"
# Create config file for adding source and dest containers
if [ -z "$SOURCE_CONTAINER_NAME" ] || [ -z "$DEST_CONTAINER_NAME" ]
then
    container_list=`azure storage container list -a $STORAGE_ACCOUNT_NAME -k $STORAGE_ACCOUNT_KEY --json`
    container_list_length=`echo $container_list | jq '. | length'`
    if [ $container_list_length -eq 0 ]
    then
        echo "  You don't have any existing containers now. You can go to Azure portal or use Microsoft Azure Storage Explorer to create one."
    elif [ $container_list_length -eq 1 ]
    then
        SOURCE_CONTAINER_NAME=`echo $container_list | jq -r '.['$container_index'] | .name'`
        DEST_CONTAINER_NAME=$SOURCE_CONTAINER_NAME
    else
        echo $container_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

        container_idx=0
        until [ $container_idx -ge 1 -a $container_idx -le $container_list_length ]
        do
          read -p "  Select the source container by typing an index number from above list and press [Enter]: " container_idx
          if [ $container_idx -ne 0 -o $container_idx -eq 0 2>/dev/null ]
          then
            :
          else
            container_idx=0
          fi
        done
        container_index=$((container_idx-1))

        SOURCE_CONTAINER_NAME=`echo $container_list | jq -r '.['$container_index'] | .name'`

        container_idx=0
        until [ $container_idx -ge 1 -a $container_idx -le $container_list_length ]
        do
          read -p "  Select the destination container by typing an index number from above list and press [Enter]: " container_idx
          if [ $container_idx -ne 0 -o $container_idx -eq 0 2>/dev/null ]
          then
            :
          else
            container_idx=0
          fi
        done
        container_index=$((container_idx-1))

        DEST_CONTAINER_NAME=`echo $container_list | jq -r '.['$container_index'] | .name'`
    fi
fi

echo "  Using source container $SOURCE_CONTAINER_NAME"
echo "  Using destination container $DEST_CONTAINER_NAME"
echo ""

sudo sh -c "echo '$(date): Create temp source container config file' >> $log_file_path"
# Creat config file for adding SOURCE container
tmp_download_container_file_path='/tmp/source_config.xml'
cat <<EOF > $tmp_download_container_file_path
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <com.microsoftopentechnologies.windowsazurestorage.AzureStorageBuilder plugin="windows-azure-storage@0.3.1">
      <storageAccName>${STORAGE_ACCOUNT_NAME}</storageAccName>
      <containerName>${SOURCE_CONTAINER_NAME}</containerName>
      <includeFilesPattern>**/*.*</includeFilesPattern>
      <excludeFilesPattern></excludeFilesPattern>
      <downloadDirLoc>\${BUILD_ID}</downloadDirLoc>
      <flattenDirectories>false</flattenDirectories>
      <includeArchiveZips>false</includeArchiveZips>
    </com.microsoftopentechnologies.windowsazurestorage.AzureStorageBuilder>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

sudo sh -c "echo '$(date): Copy temp source config file to Jenkins directory' >> $log_file_path"
sudo cp $tmp_download_container_file_path "$dest_download_container_file_path"
if [ $? -ne 0 ]
then
  exit 1
else
  echo "  Blob container with name $SOURCE_CONTAINER_NAME was successfully set as the download source."
fi

sudo sh -c "echo '$(date): Create temp dest container config file' >> $log_file_path"
# Create config file for adding DEST container
tmp_upload_container_file_path='/tmp/dest_config.xml'
cat <<EOF > $tmp_upload_container_file_path
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>if [ ! -d &quot;text&quot; ]; then
  mkdir text
fi

cd text
echo &quot;Hello Azure Storage from Jenkins&quot; &gt; hello.txt
date &gt; date.txt</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher plugin="windows-azure-storage@0.3.1">
      <storageAccName>${STORAGE_ACCOUNT_NAME}</storageAccName>
      <containerName>${DEST_CONTAINER_NAME}</containerName>
      <cntPubAccess>false</cntPubAccess>
      <cleanUpContainer>false</cleanUpContainer>
      <allowAnonymousAccess>false</allowAnonymousAccess>
      <uploadArtifactsOnlyIfSuccessful>false</uploadArtifactsOnlyIfSuccessful>
      <doNotFailIfArchivingReturnsNothing>false</doNotFailIfArchivingReturnsNothing>
      <uploadZips>false</uploadZips>
      <doNotUploadIndividualFiles>false</doNotUploadIndividualFiles>
      <filesPath>text/*.txt</filesPath>
      <excludeFilesPath></excludeFilesPath>
      <virtualPath>\${JOB_NAME}/\${BUILD_ID}</virtualPath>
    </com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher>
  </publishers>
  <buildWrappers/>
</project>
EOF

sudo sh -c "echo '$(date): Copy temp dest container config file to Jenkins directory' >> $log_file_path"
sudo cp $tmp_upload_container_file_path "$dest_upload_container_file_path"
if [ $? -ne 0 ]
then
  exit 1
else
  echo "  Blob container with name $DEST_CONTAINER_NAME was successfully set as the upload destination."
fi

echo "  Storage account and containers are all set successfully."
echo "  $instruction_goto_dashboard"

sudo sh -c "echo '$(date): Restart Jenkins' >> $log_file_path"
# Restart Jenkins
sudo service jenkins restart