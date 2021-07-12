# This template will create a SQL Server 2014 SP1 Enterprise edition with Auto Patching, Auto Backup and Azure Key Vault Integration features enabled.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/vm-sql-full-autobackup-autopatching-keyvault/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/vm-sql-full-autobackup-autopatching-keyvault/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/vm-sql-full-autobackup-autopatching-keyvault/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/vm-sql-full-autobackup-autopatching-keyvault/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/vm-sql-full-autobackup-autopatching-keyvault/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/vm-sql-full-autobackup-autopatching-keyvault/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fvm-sql-full-autobackup-autopatching-keyvault%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fvm-sql-full-autobackup-autopatching-keyvault%2Fazuredeploy.json)
  

  

This template deploys a **SQL SERVER 2014 SP1 Virtual Machine** solution with all necessary components. It also enable Auto Patching, Auto Backup and Azure Key Vault Integration features.

`Tags: SQL Server, Auto Patching, Auto Backup, Azure Key Vault,SQL Server 2014 Enterprise `

## Solution overview and deployed resources

This is an overview of the solution

This template will create a SQL Server 2014 Enterprise edition with Auto Patching, Auto Backup and Azure Key Vault Integration features enabled:

+	A Virtual Network
+	Two Storage Accounts one is used for SQL Server VM, one for SQL Server VM Autobackup 
+ 	One public IP address
+	One network interface
+	One network security group

## SQL Server IaaS Agent

A component that will be installed on the VM when features are enabled and this component is called SQL Server IaaS Agent. It is built in the form of Azure VM Extension meaning all the Azure VM Extension concepts are applicable making it perfect tool for the management of SQL in Azure VMs on scale. You can push this IaaS Agent to a number of VMs at once, you can configure, and you can remove or disable it as well.

## Auto Patching

Many customers told us that they would like to move their patching schedules off business hours. This feature enables you to do exactly this – define the maintenance window that would keep your patch installs in the range you have specified.

When you look on the settings available for the Automated Patching you could find you are familiar with those, because they mimic settings available from the Windows Update Agent (service that drives patching of your Windows machine). Settings are simple and powerful at the same time. All that you need to define to make sure patches are applied when you want is: day of the week, start of the maintenance window, and duration of the maintenance window. It relies on the Windows Update and the Microsoft Update infrastructure and installs any update that matches the ‘Important’ category for the machine.

This feature allows you to patch your Azure Virtual Machines in effective and predictable way even when those VMs are not joined to any domain and not controlled by any patching infrastructure

## Auto Backup

This service enables you to configure a backup schedule on your SQL Server 2014 Enterprise and Standard Virtual Machines in a very convenient manner while ensuring your data is backed up consistently and safely. Automated Backup is configured to backup all existing and new databases for the default instance of SQL Server. This simplifies the usual process of configuring Managed Backup for new databases and then for each existing database by combining it into one simple automated setup.

If you wish to customize the settings, you can specify the retention period, storage account, and whether you want encryption to be enabled. The retention period, as is standard for Managed Backup, can be anywhere between 1 and 30 days. The storage account defaults to the same storage account as the VM, but can be changed to any other storage account. This provides you with a DR option, allowing you to back up your databases to storage in another datacenter. If you decide to encrypt your backups, an encryption certificate will be generated and saved in the same storage account as the backups. In this scenario, you will also need to enter a password which will be used to protect the encryption certificates used for encrypting and decrypting your backups. This allows you to not worry about your backups beyond the configuration of this feature, and also ensures you can trust that your backups are secure.

## Azure Key Vault Integration

There are multiple SQL Server encryption features, such as transparent data encryption (TDE), column level encryption (CLE), and backup encryption. These forms of encryption require you to manage and store the cryptographic keys you use for encryption. The Azure Key Vault (AKV) service is designed to improve the security and management of these keys in a secure and highly available location. The SQL Server Connector enables SQL Server to use these keys from Azure Key Vault.

Azure Key Vault provider is configured on SQL Server as an EKM provider and a new credential is created on the SQL Server that with its keys secured in Azure Key Vault provided in the parameters. User can also create credentials on the server using the same provider and store.

When this feature is enabled, it automatically installs the SQL Server Connector, configures the EKM provider to access Azure Key Vault, and creates the credential to allow you to access your vault.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutopatchingDayOfWeek|Patches installed day. Sunday to Saturday for a specific day; Everyday for daily Patches or Never to disable Auto Patching|Monday|
|sqlAutopatchingStartHour|Begin updates hour|22|
|sqlAutopatchingWindowDuration|Patches must be installed within this duration minutes.|60|
|sqlAutobackupRetentionPeriod|Backup retention period in days, 1-30 days|20|
|sqlAutobackupStorageAccountName|What storage account to use for backups|myExistingBackupStoragAccountName|
|sqlAutobackupEncryptionPassword|a password which will be used to protect the encryption certificates used for encrypting and decrypting your backups|Password123|
|sqlAkvCredentialName|AKV Integration creates a credential within SQL Server, allowing the VM to have access to the key vault. Choose a name for this credential|mycred1|
|sqlAkvUrl|The location of the key vault|https://contosokeyvault.vault.azure.net/|
|servicePrincipalName|Azure Active Directory service principal name. This is also referred to as the Client ID.|fde2b411-33d5-4e11-af04eb07b669ccf2|
|servicePrincipalSecret|Azure Active Directory service principal secret. This is also referred to as the Client Secret.|9VTJSQwzlFepD8XODnzy8n2V01Jd8dAjwm/azF1XDKM=|


