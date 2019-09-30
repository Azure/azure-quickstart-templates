# Create an on-demand SFTP Server with persistent storage using an existing storage account

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-sftp-files-existing-storage/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-sftp-files-existing-storage/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-sftp-files-existing-storage/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-sftp-files-existing-storage/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-sftp-files-existing-storage/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-sftp-files-existing-storage/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-aci-sftp-files%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sftp-files%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template demonstrates an on-demand SFTP server using an Azure Container Instance (ACI). This version requires an existing Storage Account and File Share to exist in the same region as the ACI to be created. This File Share is then mounted into the main ACI to provide persistent storage after the container is terminated.

`Tags: Azure Container Instance, az-cli, sftp`

## Deployment steps

Click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repository. Ensure that a Storage Account and a file share have previously been created, as these are required parameters.

## Usage

Once deployed, connect to the public IP of the SFTP ACI and upload files; these files should be placed into the File Share. Once transfers are complete, stop the ACI and the files will remain accessible. You can delete/recreate the ACI and mount the same file share to copy more files.

## Notes

Azure Container Instance is available in selected [locations](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quotas#region-availability). Please use one of the available location for Azure Container Instance resource.
The container image used by this template is hosted on [Docker Hub](https://hub.docker.com/r/atmoz/sftp). It is not affiliated with Microsoft in any way, and usage is at your own risk.

