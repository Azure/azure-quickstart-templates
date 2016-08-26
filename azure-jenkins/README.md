# Create a new instance of Jenkins running on an Ubuntu VM in Azure.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a new VM with an instance of Jenkins installed and ready to configure for deploying your application to Azure. The deployed Linux VM will have Ubuntu 14.04 LTS, openjdk-7, Azure CLI and Jenkins 2.7.2.

The template will create two VMs in your subscription. The first (name ImageTransferVM) is solely responsible for handling setup operations. Once the deployment has completed you can remove this VM and it's associated resoures. Follow https://azure.microsoft.com/en-us/documentation/articles/resource-group-portal/
to delete resources from azure resourcegroup.

The second VM will be the actual instance of Jenkins. Once the second VM has been deployed, you will need to ssh into the machine to complete the configuration of Jenkins.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document to deploy using the scripts in the root of this repo.

## Azure Storage Jenkins plugin configure steps
1. After the VM is provisioned, a script (/otc/config_storage.sh) need to be executed manually once you ssh into the VM. IF the script
   is not in /tmp, download the file using command [sudo wget -O ./config_storage.sh    "https://raw.githubusercontent.com/arroyc/azure-quickstart-templates/master/azure-jenkins/setup-scripts/config_storage.sh"]

   The script will guide you to set up the storage account needed for Azure Storage Jenkins plugin.
2. The script will:
   1. Ask you to login to your Azure account.
   2. Once you login, there will be a list of subscriptions printed in the Console and ask you to select the subscription you want to use. If you have only one subscription, it will be selected as default automatically.
   3. After subscription is set, there will be a list of storage accounts printed and ask you to select one you want to use. If you have only one storage account under selected subscription, it will be selected automatically.
   4. After storage account is set, there will be a list of containers printed and ask you to select one as source container.
   5. After source container is set, you will need to continue to select the destination container. If you have only one container in the selected storage account, it will be set as both source and destination container.
3. Once the script is finished, storage account setup for Azure storage Jenkins plugin is done.

## Use Azure Storage Jenkins plugin
1. After storage account is set for the plugin, you can go to the Jenkins dashboard by navigating to the IP address plus the port number. E.g., your VM's IP address is 10.10.2.2, then open a browser and input 10.10.2.2:8080 and enter.
2. You should see two Jenkins jobs and a Jenkins pipeline in the dashboard. The two Jenkins jobs are named *AzureStorageDownloadJob* and *AzureStorageUploadJob*. The Jenkins pipeline is named *AzureStoragePipeline*.
3. Open *AzureStoragePipeline* and click **Build Now** on the left navigation bar. The pipeline will:
   1. Build *AzureStorageDownloadJob*, which will download all files from the source container you configured.
   2. Build the app, which currently just output something to logs.
   3. Build *AzrueStorageUploadJob*, which will excute a Shell script that creates two text files and upload the two files to the destination container you configured.
4. After a build is finished, you can hover over the green status square, click on the button named **Logs** that shows up and check the logs.
* You can always add/delete/edit you storage account, download action and upload action.
   * To configure storage account, go to *Manage Jenkins* | *Configure System* | *Microsoft Azure Storage Account Configuration* and fill out the needed information.
   * To configure download action, go to *AzrueStorageDownloadJob* | *Configure* and scroll down to **Build** section and make the needed changes.
   * To configure download action, go to *AzrueStorageUploadJob* | *Configure* and scroll down to **Post-Build Actions** section and make the needed changes.
   * [Find more detailed instructions here](https://github.com/jenkinsci/windows-azure-storage-plugin)

## Note

This template use a base image which will be updated regularly to include new features for azure plugin on jenkins. Readme will be updated accordingly.

DO NOT CHANGE ANYTHING in the setup-scripts
