# Create Storage Account and enable protection with Azure Backup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-storage-account-enable-protection/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-storage-account-enable-protection%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-storage-account-enable-protection%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-storage-account-enable-protection%2Fazuredeploy.json)   

### This template create storage account and enables blobs protection via Azure Backup.

A disaster recovery and data protection strategy keeps your business running when unexpected events occur.

The Backup service is Microsoft's born in the cloud backup solution to backup data that's located on-premises and in Azure. It replaces your existing on-premises or offsite backup solution with a reliable, secure and cost competitive cloud backup solution. It also provides the flexibility of protecting your assets running in the cloud. [Learn more](http://aka.ms/backup-learn-more/).

### Operational backup for Azure Blobs

Operational backup for Azure Blobs is a managed, local data protection solution that lets you protect your block blobs from various data loss scenarios like blob corruptions, blob deletions, and accidental storage account deletion. The data is stored locally within the source storage account itself and can be restored to a selected point in time whenever needed. So this provides a simple, secure, and cost-effective means to protect your blobs. [Learn more](https://docs.microsoft.com/en-us/azure/backup/blob-backup-overview)

#### Delete a Backup Vault
You can't delete a Backup vault with any of the following dependencies:
- You can't delete a vault that contains protected data sources (for example, Azure database for PostgreSQL servers, Azure Blobs, Azure Disks).
- You can't delete a vault that contains backup data.
If you try to delete the vault without removing the dependencies, you'll encounter the following error messages:
Cannot delete the Backup vault as there are existing backup instances or backup policies in the vault. Delete all backup instances and backup policies that are present in the vault and then try deleting the vault.
Here are the steps for [Delete a Backup Vault](https://docs.microsoft.com/en-us/azure/backup/backup-vault-overview#delete-a-backup-vault)
