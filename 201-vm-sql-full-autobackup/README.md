# This template will create a SQL Server 2014 SP1 Enterprise edition with Auto Backup feature enabled.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-full-autobackup%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-full-autobackup%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a **SQL SERVER 2014 SP1 Virtual Machine** solution with all necessary components. It also enable Auto Backup feature.

`Tags: SQL Server, Auto Backup, SQL Server 2014 Enterprise`

## Solution overview and deployed resources

This is an overview of the solution

This template will create a SQL Server 2014 Enterprise edition with Auto Backu feature enabled:

+	A Virtual Network
+	Two Storage Accounts one is used for SQL Server VM, one for SQL Server VM Autobackup 
+ 	One public IP address
+	One network interface
+	One network security group

## SQL Server IaaS Agent

A component that will be installed on the VM when features are enabled and this component is called SQL Server IaaS Agent. It is built in the form of Azure VM Extension meaning all the Azure VM Extension concepts are applicable making it perfect tool for the management of SQL in Azure VMs on scale. You can push this IaaS Agent to a number of VMs at once, you can configure, and you can remove or disable it as well.

## Auto Backup

This service enables you to configure a backup schedule on your SQL Server 2014 Enterprise and Standard Virtual Machines in a very convenient manner while ensuring your data is backed up consistently and safely. Automated Backup is configured to backup all existing and new databases for the default instance of SQL Server. This simplifies the usual process of configuring Managed Backup for new databases and then for each existing database by combining it into one simple automated setup.

If you wish to customize the settings, you can specify the retention period, storage account, and whether you want encryption to be enabled. The retention period, as is standard for Managed Backup, can be anywhere between 1 and 30 days. The storage account defaults to the same storage account as the VM, but can be changed to any other storage account. This provides you with a DR option, allowing you to back up your databases to storage in another datacenter. If you decide to encrypt your backups, an encryption certificate will be generated and saved in the same storage account as the backups. In this scenario, you will also need to enter a password which will be used to protect the encryption certificates used for encrypting and decrypting your backups. This allows you to not worry about your backups beyond the configuration of this feature, and also ensures you can trust that your backups are secure.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutobackupRetentionPeriod|Backup retention period in days, 1-30 days|20|
|sqlAutobackupStorageAccountName|What storage account to use for backups|myExistingBackupStoragAccountName|
|sqlAutobackupEncryptionPassword|a password which will be used to protect the encryption certificates used for encrypting and decrypting your backups|Password123|

