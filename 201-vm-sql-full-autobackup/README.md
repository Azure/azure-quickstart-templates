# Create an Azure virtual machine running SQL Server 2014 SP2 Enterprise edition with Automated Backup feature enabled.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-sql-full-autobackup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-sql-full-autobackup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-sql-full-autobackup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-sql-full-autobackup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-sql-full-autobackup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-sql-full-autobackup/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-autobackup%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-autobackup%2Fazuredeploy.json)
  

  

## Solution overview

This template provisions a virtual machine with **SQL Server 2014 SP2 running on Windows Server 2012 R2**. It also enables the Automated Backup feature.

`Tags: SQL Server, Auto Backup, SQL Server 2014 Enterprise`

This template will also create the following resources:

+	A Virtual Network
+	Two Storage Accounts one is used for SQL Server VM, one for SQL Server VM Autobackup
+ 	One public IP address
+	One network interface
+	One network security group

## Automated Backup

The Automated Backup feature can be used to configure an automated backup schedule for SQL databases on an Azure virtual machine running SQL Server. More information on this feature can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-automated-backup/).

This template can be used to enable or change the configuration of Automated Backup.

If you wish to disable Automated Backup, you must edit *azuredeploy.json* and change "Enable" to be false.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutobackupRetentionPeriod|Backup retention period in days, 1-30 days|20|
|sqlAutobackupStorageAccountName|What storage account to use for backups|myExistingBackupStoragAccountName|
|sqlAutobackupEncryptionPassword|a password which will be used to protect the encryption certificates used for encrypting and decrypting your backups|Password123|

## SQL Server IaaS Agent extension

Automated Backup is supported in your virtual machine through the SQL Server IaaS Agent extension. This extension must be installed on the VM to be able to use this feature. When you enable Automated Backup on your virtual machine, the extension will be automatically installed. This extension will also report back the latest status of this feature to you. More information on this extension can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-server-agent-extension/).


