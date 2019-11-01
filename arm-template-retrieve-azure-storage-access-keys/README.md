# Retrieve Azure Storage access keys in ARM template

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/arm-template-retrieve-azure-storage-access-keys/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/arm-template-retrieve-azure-storage-access-keys/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/arm-template-retrieve-azure-storage-access-keys/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/arm-template-retrieve-azure-storage-access-keys/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/arm-template-retrieve-azure-storage-access-keys/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/arm-template-retrieve-azure-storage-access-keys/CredScanResult.svg" />&nbsp;

This template will create a Storage account, after which it will create a API connection by dynamically retrieving the primary key of the Storage account. The API connection is then used in a Logic App as a trigger polling for blob changes. The complete scenario can be found on <https://blog.eldert.net/retrieve-azure-storage-access-keys-in-arm-template>.

Tags: arm, storage, security

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Farm-template-retrieve-azure-storage-access-keys%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Farm-template-retrieve-azure-storage-access-keys%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

