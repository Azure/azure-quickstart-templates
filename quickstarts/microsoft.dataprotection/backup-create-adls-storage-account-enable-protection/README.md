---
description: Template that creates azure datalake storage account and enable operational and vaulted backup via Backup Vault
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: backup-create-adls-storage-account-enable-protection
languages:
- bicep
- json
---
# Create Azure Data Lake Storage Account & enable protection via Backup Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-adls-storage-account-enable-protection/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-adls-storage-account-enable-protection%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-adls-storage-account-enable-protection%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-adls-storage-account-enable-protection%2Fazuredeploy.json)

### This template creates Azure Data Lake Storage Account and enables blobs protection via Azure Backup.

A disaster recovery and data protection strategy keeps your business running when unexpected events occur.

The Backup service is Microsoft's born in the cloud backup solution to backup data that's located on-premises and in Azure. It replaces your existing on-premises or offsite backup solution with a reliable, secure and cost competitive cloud backup solution. It also provides the flexibility of protecting your assets running in the cloud. [Learn more](http://aka.ms/backup-learn-more/).

### Overview of Azure Datalake backup
Azure Backup provides vaulted backup solution for Azure Data Lake. [Learn more](https://learn.microsoft.com/en-us/azure/backup/azure-data-lake-storage-backup-overview)

Azure Data Lake Storage vaulted backup is a streamlined, cloud-native solution to back up and restore general-purpose v2 storage accounts with a hierarchical namespace. It allows selective backup and restoration of containers, and store backups in a dedicated vault for granular control.

#### Vaulted Backup
Vaulted backup uses the platform capability of **object replication** to copy data to the Backup vault. Object replication asynchronously copies block blobs between a source storage account and a destination storage account. The contents of the blob, any versions associated with the blob, and the blob's metadata and properties are all copied from the source container to the destination container.

When you configure protection, Azure Backup allocates a destination storage account (Backup vault's storage account managed by Azure Backup) and enables object replication policy at container level on both destination and source storage account. When a backup job is triggered, the Azure Backup service creates a recovery point marker on the source storage account and polls the destination account for the recovery point marker replication. Once the replication point marker is present on the destination, a recovery point is created.

#### Delete a Backup Vault
You can't delete a Backup vault with any of the following dependencies:
- You can't delete a vault that contains protected data sources (for example, Azure database for PostgreSQL servers, Azure Blobs, Azure Datalake accounts, Azure Disks).
- You can't delete a vault that contains backup data.
If you try to delete the vault without removing the dependencies, you'll encounter the following error messages:
Cannot delete the Backup vault as there are existing backup instances or backup policies in the vault. Delete all backup instances and backup policies that are present in the vault and then try deleting the vault.
Here are the steps for [Delete a Backup Vault](https://docs.microsoft.com/azure/backup/backup-vault-overview#delete-a-backup-vault)

`Tags: Microsoft.DataProtection/backupVaults, systemAssigned, [parameters('vaultStorageRedundancy')], Microsoft.DataProtection/backupVaults/backupPolicies, Microsoft.Storage/storageAccounts, Microsoft.Authorization/roleAssignments, Microsoft.DataProtection/backupVaults/backupInstances`
