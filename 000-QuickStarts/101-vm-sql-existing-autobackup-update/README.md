# Configure SQL Server Automated Backup on any existing Azure virtual machine running SQL Server 2014 Enterprise and Standard.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-existing-autobackup-update%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-existing-autobackup-update%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution overview

This template can be used for any Azure virtual machine running **SQL Server 2014 Enterprise or Standard Edition**.

All resources used in this template must be ARM resources.

## Automated Backup

The Automated Backup feature can be used to configure an automated backup schedule for SQL databases on an Azure virtual machine running SQL Server. More information on this feature can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-automated-backup/).

This template can be used to enable or change the configuration of Automated Backup.

If you wish to disable Automated Backup, you must edit *azuredeploy.json* and change "Enable" to be false.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutobackupRetentionPeriod|Backup retention period in days, Allowed values: 1-30 days|30|
|sqlAutobackupStorageAccountName|The storage account where backups will be stored, Allowed values: any existing Standard_LRS storage account|myExistingBackupStoragAccountName|
|sqlAutobackupEncryptionPassword|The password which will be used to protect the encryption certificate which will be used to encrypt and decrypt your backups. This certificate will be automatically generated and storage on the storage account you provided for backups.|Password123|

## SQL Server IaaS Agent extension

Automated Backup is supported in your virtual machine through the SQL Server IaaS Agent extension. This extension must be installed on the VM to be able to use this feature. When you enable Automated Backup on your virtual machine, the extension will be automatically installed. This extension will also report back the latest status of this feature to you. More information on this extension can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-server-agent-extension/).
