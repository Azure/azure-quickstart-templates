# Create an Azure virtual machine running SQL Server 2014 SP1 Enterprise edition with Azure Key Vault Integration feature enabled.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-keyvault%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-keyvault%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution overview

This template provisions a virtual machine with **SQL Server 2014 SP1 running on Windows Server 2012 R2**. It also enable Azure Key Vault Integration feature.

`Tags: SQL Server, Azure Key Vault, SQL Server 2014 Enterprise`

This template will also create the following resources:

+	A Virtual Network
+	Two Storage Accounts one is used for SQL Server VM, one for SQL Server VM Autobackup
+ 	One public IP address
+	One network interface
+	One network security group

## Azure Key Vault Integration

The Azure Key Vault integration feature will configure your virtual machine to be able to connect to your Azure key vault. It achieves this by installing the latest version of the SQL Server Connector, configuring EKM provider to access Azure Key Vault, and creates the credential to allow you to access your vault. More information on this feature can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-ps-sql-keyvault/).

This template can be used to enable or change the configuration of Azure Key Vault Integration.

If you wish to disable this feature, you must edit *azuredeploy.json* and change "Enable" to be false.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAkvCredentialName|AKV Integration creates a credential within SQL Server, allowing the VM to have access to the key vault. Choose a name for this credential|mycred1|
|sqlAkvUrl|The location of the key vault|https://contosokeyvault.vault.azure.net/|
|servicePrincipalName|Azure Active Directory service principal name. This is also referred to as the Client ID.|fde2b411-33d5-4e11-af04eb07b669ccf2|
|servicePrincipalSecret|Azure Active Directory service principal secret. This is also referred to as the Client Secret.|9VTJSQwzlFepD8XODnzy8n2V01Jd8dAjwm/azF1XDKM=|

## SQL Server IaaS Agent extension

Automated Patching is supported in your virtual machine through the SQL Server IaaS Agent extension. This extension must be installed on the VM to be able to use this feature. When you enable Automated Patching on your virtual machine, the extension will be automatically installed. This extension will also report back the latest status of this feature to you. More information on this extension can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-server-agent-extension/).
