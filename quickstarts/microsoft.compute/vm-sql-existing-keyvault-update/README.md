# Configure the Azure Key Vault Integration feature on any existing Azure Virtual machine with SQL Server Enterprise edition.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-existing-keyvault-update/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-existing-keyvault-update/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-existing-keyvault-update/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-existing-keyvault-update/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-existing-keyvault-update/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-existing-keyvault-update/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-sql-existing-keyvault-update%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-sql-existing-keyvault-update%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-sql-existing-keyvault-update%2Fazuredeploy.json)
  

  

## Solution overview

This template can be used for any Azure virtual machine running SQL Server 2012 or newer, Enterprise edition.

All resources used in this template must be ARM resources.

## Azure Key Vault Integration

The Azure Key Vault integration feature will configure your virtual machine to be able to connect to your Azure key vault. It achieves this by installing the latest version of the SQL Server Connector, configuring EKM provider to access Azure Key Vault, and creates the credential to allow you to access your vault. More information on this feature can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-ps-sql-keyvault/).

This template can be used to enable or change the configuration of Azure Key Vault Integration.

If you wish to disable this feature, you must edit *azuredeploy.json* and change "Enable" to be false.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAkvCredentialName|Specify the name of the credential that this feature will create within SQL Server, allowing the VM to have access to the key vault.|mycred1|
|sqlAkvUrl|The URL for your key vault|https://contosokeyvault.vault.azure.net/|
|servicePrincipalName|Azure Active Directory service principal name. This is also referred to as the Client ID.|fde2b411-33d5-4e11-af04eb07b669ccf2|
|servicePrincipalSecret|Azure Active Directory service principal secret. This is also referred to as the Client Secret.|9VTJSQwzlFepD8XODnzy8n2V01Jd8dAjwm/azF1XDKM=|

## SQL Server IaaS Agent extension

Automated Patching is supported in your virtual machine through the SQL Server IaaS Agent extension. This extension must be installed on the VM to be able to use this feature. When you enable Automated Patching on your virtual machine, the extension will be automatically installed. This extension will also report back the latest status of this feature to you. More information on this extension can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-server-agent-extension/).


