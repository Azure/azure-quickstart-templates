# This template setup Azure Key Vault on any existing Azure Virtual machine with SQL Server Standard or Enterprise edition.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-keyvault-update%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-keyvault-update%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution overview and deployed resources

+	This template will create a SQL Server 2014 IaasExtension Resource to update an existing SQL Server 2014 Virtual Machine

This template setup Azure Key Vault on any existing Azure Virtual machine with SQL Server Standard or Enterprise edition. 

There are multiple SQL Server encryption features, such as transparent data encryption (TDE), column level encryption (CLE), and backup encryption. These forms of encryption require you to manage and store the cryptographic keys you use for encryption. The Azure Key Vault (AKV) service is designed to improve the security and management of these keys in a secure and highly available location. The SQL Server Connector enables SQL Server to use these keys from Azure Key Vault.

Azure Key Vault provider is configured on SQL Server as an EKM provider and a new credential is created on the SQL Server that with its keys secured in Azure Key Vault provided in the parameters. User can also create credentials on the server using the same provider and store.

When this feature is enabled, it automatically installs the SQL Server Connector, configures the EKM provider to access Azure Key Vault, and creates the credential to allow you to access your vault.


## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAkvCredentialName|AKV Integration creates a credential within SQL Server, allowing the VM to have access to the key vault. Choose a name for this credential|mycred1|
|sqlAkvUrl|The location of the key vault|https://contosokeyvault.vault.azure.net/|
|servicePrincipalName|Azure Active Directory service principal name. This is also referred to as the Client ID.|fde2b411-33d5-4e11-af04eb07b669ccf2|
|servicePrincipalSecret|Azure Active Directory service principal secret. This is also referred to as the Client Secret.|9VTJSQwzlFepD8XODnzy8n2V01Jd8dAjwm/azF1XDKM=|


## SQL Server IaaS Agent

This feature is part of the new component that will be installed on the VM when features are enabled and this component is called SQL Server IaaS Agent. It is built in the form of Azure VM Extension meaning all the Azure VM Extension concepts are applicable making it perfect tool for the management of SQL in Azure VMs on scale. You can push this IaaS Agent to a number of VMs at once, you can configure, and you can remove or disable it as well.