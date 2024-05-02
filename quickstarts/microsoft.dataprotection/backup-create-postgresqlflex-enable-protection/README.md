---
description: Template that creates a PostgreSQL Flexible Server and enables protection via Backup Vault
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: backup-create-postgresqlflex-enable-protection
languages:
- bicep
- json
---
# Create PgFlex server & enable protection via Backup Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dataprotection/backup-create-postgresqlflex-enable-protection/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-postgresqlflex-enable-protection%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dataprotection%2Fbackup-create-postgresqlflex-enable-protection%2Fazuredeploy.json)

### This template creates a postgresql flexible server and enables protection via Azure Backup.

A disaster recovery and data protection strategy keeps your business running when unexpected events occur.

The Backup service is Microsoft's born in the cloud backup solution to backup data that's located on-premises and in Azure. It replaces your existing on-premises or offsite backup solution with a reliable, secure and cost competitive cloud backup solution. It also provides the flexibility of protecting your assets running in the cloud. [Learn more](http://aka.ms/backup-learn-more/).

### Overview of Azure PostgreSQL Flexible Servers Backup

Azure Database for PostgreSQL flexible server Backup is a native, cloud-based backup solution that protects your data in postgresql flexible servers. It's a simple, secure, and cost-effective solution that enables you to configure protection for postgresql flexible servers in a few steps. It assures that you can recover your data in a disaster scenario. [Learn more](https://learn.microsoft.com/en-us/azure/backup/backup-azure-database-postgresql-flex-overview).

### Delete a Backup Vault

You can't delete a Backup Vault with any of the following dependencies:

- You can't delete a vault that contains protected data sources (for example, Azure database for PostgreSQL servers, Azure Blobs, Azure Disks).
- You can't delete a vault that contains backup data.

If you try to delete the vault without removing the dependencies, you'll encounter the following error messages:
Cannot delete the Backup vault as there are existing backup instances or backup policies in the vault. Delete all backup instances and backup policies that are present in the vault and then try deleting the vault.

Here are the steps for [Delete a Backup Vault](https://docs.microsoft.com/azure/backup/backup-vault-overview#delete-a-backup-vault).

`Tags: Microsoft.DataProtection/backupVaults, systemAssigned, [parameters('vaultStorageRedundancy')], Microsoft.DataProtection/backupVaults/backupPolicies, Microsoft.DBforPostgreSQL/flexibleServers, Microsoft.Authorization/roleAssignments, Microsoft.DataProtection/backupVaults/backupInstances`