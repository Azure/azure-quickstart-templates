#!/bin/bash

#echo "Usage:
#  1 bash config_azure_jenkins_storage.sh
#  2 bash config_azure_jenkins_storage.sh <Subscription ID>
#  3 bash config_azure_jenkins_storage.sh <Subscription ID> <Storage Account name>
#  4 bash config_azure_jenkins_storage.sh <Subscription ID> <Storage Account name> <Resource Group name>
#  5 bash config_azure_jenkins_storage.sh <Subscription ID> <Storage Account name> <Resource Group name> <Source Container name> <Dest Container name>
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

azure_storage_config_file="com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher.xml"
jenkins_download_job_name="SampleDownload"
jenkins_upload_job_name="SampleAzureUpload"

jenkins_dir="/var/lib/jenkins"
jenkins_jobs_dir="${jenkins_dir}/jobs"

dest_account_file_path="${jenkins_dir}/${azure_storage_config_file}"
dest_download_container_file_path="${jenkins_jobs_dir}/${jenkins_download_job_name}/config.xml"
dest_upload_container_file_path="${jenkins_jobs_dir}/${jenkins_upload_job_name}/config.xml"

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
  subscription_index=0
  if [ $subscriptions_list_count -eq 0 ]
  then
    echo "  You need to sign up an Azure Subscription here: https://azure.microsoft.com"
    exit 1
  elif [ $subscriptions_list_count -gt 1 ]
  then
    echo $subscriptions_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

    while read -r -t 0; do read -r; done #clear stdin
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
  fi
  SUBSCRIPTION_ID=`echo $subscriptions_list | jq -r '.['$subscription_index'] | .id'`
  echo ""
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
        echo "  You don't have any storage accounts. We'll create one for you."

        location_list=`azure location list --json`
        location_list_length=`echo $location_list | jq '. | length'`
        if [ $location_list_length -eq 0 ]
        then
          sudo sh -c "echo '$(date): No valid locations in the subscription' >> $log_file_path"
          echo "  Your subscription doesn't have any valid locations. Please go to Azure portal and update your subscription"
          exit 1
        else
          sudo sh -c "echo '$(date): List locations for selection' >> $log_file_path"
          echo $location_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .displayName)"'

          while read -r -t 0; do read -r; done #clear stdin
          location_idx=0
          until [ $location_idx -ge 1 -a $location_idx -le $location_list_length ]
          do
            read -p "  Select a location by typing an index number from above list and press [Enter]: " location_idx
            if [ $location_idx -ne 0 -o $location_idx -eq 0 2>/dev/null ]
            then
              :
            else
              location_idx=0
            fi
          done
          location_index=$((location_idx-1))

          STORAGE_ACCOUNT_LOCATION=`echo $location_list | jq -r '.['$location_index'] | .name'`
          sudo sh -c "echo '$(date): Picked location for storage account: ${STORAGE_ACCOUNT_LOCATION}' >> $log_file_path"
        fi

        #generate resource group
        my_group_uuid=$(python -c 'import uuid; print str(uuid.uuid4())[:8]')
        MY_GROUP_NAME="jenkins-${my_group_uuid}"
        sudo sh -c "echo '$(date): Create resource group' >> $log_file_path"
        azure group create ${MY_GROUP_NAME} -l ${STORAGE_ACCOUNT_LOCATION} >/dev/null
        if [ $? -ne 0 ]
        then
          sudo sh -c "echo '$(date): Resource group creation failed' >> $log_file_path"
          echo "  Could not auto create a resource group. Please go to Azure portal and create a storage account."
          exit 1
        else
          echo "  Created resource group ${MY_GROUP_NAME}"
        fi

        my_storage_account_uuid=$(python -c 'import uuid; print str(uuid.uuid4())[:8]')
        MY_STORAGE_NAME="jnk${my_storage_account_uuid}"
        echo "  Creating storage account"
        azure storage account create --sku-name ZRS --kind Storage -l ${STORAGE_ACCOUNT_LOCATION} -g ${MY_GROUP_NAME} ${MY_STORAGE_NAME} >/dev/null
        if [ $? -ne 0 ]
        then
          sudo sh -c "echo '$(date): Storage account creation failed' >> $log_file_path"
          echo "  Could not auto create a storage account. Please go to Azure portal and create a storage account."
          exit 1
        else
          echo "  Created storage account ${MY_STORAGE_NAME}"
        fi

        STORAGE_ACCOUNT_NAME=${MY_STORAGE_NAME}
        RESOURCE_GROUP_NAME=${MY_GROUP_NAME}
    else
        storage_account_index=0
        if [ $storage_account_list_length -gt 1 ]
        then
            sudo sh -c "echo '$(date): List storage accounts for selection' >> $log_file_path"
            echo $storage_account_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

            while read -r -t 0; do read -r; done #clear stdin
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
tmp_account_file_path="/tmp/${azure_storage_config_file}"

should_copy_temp=1
storage_account_xml_node="    <com.microsoftopentechnologies.windowsazurestorage.beans.StorageAccountInfo>\n      <storageAccName>${STORAGE_ACCOUNT_NAME}</storageAccName>\n      <storageAccountKey>${STORAGE_ACCOUNT_KEY}</storageAccountKey>\n      <blobEndPointURL>http://blob.core.windows.net/</blobEndPointURL>\n    </com.microsoftopentechnologies.windowsazurestorage.beans.StorageAccountInfo>"
printable_xml_node=$(printf "${storage_account_xml_node}")

if [ -e "$dest_account_file_path" ]
then
  #copy original file
  cp $dest_account_file_path $tmp_account_file_path
  escaped_storage_key=$(echo ${STORAGE_ACCOUNT_KEY} | sed -e s/+'/\\\+'/g -e s_/'_\\\/'_g)
  grep -Pz "(?s)<storageAccName>${STORAGE_ACCOUNT_NAME}</storageAccName>.[\n\t\r ]*<storageAccountKey>${escaped_storage_key}</storageAccountKey>" $tmp_account_file_path >/dev/null

  if [ $? -ne 0 ]
  then
    #the current storage account doesn't existing, we should add it
    sudo sh -c "echo '$(date): Append storage account' >> $log_file_path"
    cat $tmp_account_file_path | sed -zr "s|</com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>([\n\t\r ]*</)|</com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>\n${storage_account_xml_node}\1|" > ${tmp_account_file_path}2
    #remove empty accounts
    cat ${tmp_account_file_path}2 | sed -zr "s|<com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>[\n\t\r ]*<storageAccName>[\n\t\t ]*</storageAccName>[\n\t\r ]*<storageAccountKey>[^\n]*</storageAccountKey>[\n\t\r ]*<blobEndPointURL>[^\n]*</blobEndPointURL>[\n\t\r ]*</com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>[\t ]*[\n\r]*([\t ]*<com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>)|\1|" > ${tmp_account_file_path}

    rm ${tmp_account_file_path}2

    #sed -zr "s|<com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>[\n\t\r ]*<storageAccName>[\n\t\t ]*</storageAccName>[\n\t\r ]*<storageAccountKey>.*</storageAccountKey>[\n\t\r ]*<blobEndPointURL>.*</blobEndPointURL>[\n\t\r ]*</com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>[\t ]*[\n\r]*([\t ]*<com\.microsoftopentechnologies\.windowsazurestorage\.beans\.StorageAccountInfo>)|\1|" broken
  else
    sudo sh -c "echo '$(date): Storage account is already there' >> $log_file_path"
    echo "  The storage account is already set for the Jenkins Azure Storage plugin"
    should_copy_temp=0
  fi
else
  #the original file is not there, we'll create the temporary
  sudo sh -c "echo '$(date): Create temp storage account config file' >> $log_file_path"
  printable_xml_node=$(printf "${storage_account_xml_node}")

  cat <<EOF > $tmp_account_file_path
<?xml version='1.0' encoding='UTF-8'?>
<com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher_-WAStorageDescriptor plugin="windows-azure-storage@0.3.1">
  <storageAccounts>
${printable_xml_node}
  </storageAccounts>
</com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher_-WAStorageDescriptor>
EOF
fi

if [ $should_copy_temp -eq 1 ]
then
  #copy the temp file back
  sudo sh -c "echo '$(date): Copy temp config file to Jenkins directory' >> $log_file_path"
  sudo cp $tmp_account_file_path $dest_account_file_path
  if [ $? -ne 0 ]
  then
    rm ${tmp_account_file_path}
    exit 1
  else
    echo "  The storage account was successfully added to Jenkins Azure Storage plugin."
    echo ""
  fi
fi

rm ${tmp_account_file_path}

if [ -f "$dest_download_container_file_path" ] && [ -f "$dest_upload_container_file_path" ]
then
  echo "  Blob containers have been set before."
  echo "  $instruction_goto_dashboard"
  sudo sh -c "echo '$(date): Restart Jenkins' >> $log_file_path"
  # Restart Jenkins
  sudo service jenkins restart
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
        sudo sh -c "echo '$(date): Container missing' >> $log_file_path"
        echo "  You don't have any existing containers. We'll create one for you"

        my_container_uuid=$(python -c 'import uuid; print str(uuid.uuid4())[:8]')
        MY_CONTAINER_NAME="jnkst${my_container_uuid}"

        echo "  Creating container"
        azure storage container create -a ${STORAGE_ACCOUNT_NAME} -k ${STORAGE_ACCOUNT_KEY} ${MY_CONTAINER_NAME} > /dev/null
        if [ $? -ne 0 ]
        then
          sudo sh -c "echo '$(date): Container creation failed' >> $log_file_path"
          echo "  Could not auto create a container. Please go to Azure portal and create a container."
          exit 1
        else
          echo "  Created container ${MY_CONTAINER_NAME}"
        fi
        SOURCE_CONTAINER_NAME=${MY_CONTAINER_NAME}
        DEST_CONTAINER_NAME=${MY_CONTAINER_NAME}
    elif [ $container_list_length -eq 1 ]
    then
        SOURCE_CONTAINER_NAME=`echo $container_list | jq -r '.['$container_index'] | .name'`
        DEST_CONTAINER_NAME=$SOURCE_CONTAINER_NAME
    else
        echo $container_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

        while read -r -t 0; do read -r; done #clear stdin
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

        while read -r -t 0; do read -r; done #clear stdin
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