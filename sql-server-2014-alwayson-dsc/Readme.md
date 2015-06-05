# Create a SQL Server 2014 Always On Availability Group with PowerShell DSC Extension

This template will create a SQL Server 2014 Always On Availability Group using the PowerShell DSC Extension it creates the following resources:

+	A Virtual Network
+	Three Storage Accounts
+	One external and one internal load balancer
+	Two VMs configured as Domain Controllers for a new forest with a single domain
+	Three VMs in a Windows Server Cluster, two VMs run SQL Server 2014 with an availability group and the third is a File Share Witness for the Cluster
+	Two Availability Sets one for the AD VMs, the other for the SQL and Witness VMs, the second Availability Set is configured with three Update Domains and three Fault Domains

The external load balancer creates an RDP NAT rule to allow connectivity to the first VM created, in order to access other VMs in the deployment this VM should be used as a jumpbox.

A SQL Server always on listener is created using the internal load balancer.

# Known Issues

This template is entirely serial due to some issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently. This issue will be fixed as soon as possible.

## Notes

+	The default settings for storage are to deploy using **premium storage**, the AD VMs use a P10 Disk and the SQL VMs use two P30 disks each, these sizes can be changed by changing the relevant variables. In addition there is a P10 Disk used for each VMs OS Disk.

+ 	In default settings for compute require that you have at least 19 cores of free quota to deploy.

+ 	The images used to create this deployment are
	+ 	AD - Latest Windows Server 2012 R2 Image
	+ 	SQL Server - Latest SQL Server 2014 on Windows Server 2012 R2 Image
	+ 	Witness - Latest Windows Server 2012 R2 Image

+ 	The image configuration is defined in variables - details below - but the scripts that configure this deployment have only been tested with these versions and may not work on other images.


Click the button below to deploy from the portal

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsql-server-2014-alwayson-dsc%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


## Deploying from PowerShell 

For details on how to install and configure Azure Powershell see [here].(https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

Launch a PowerShell console

Ensure that you are in Resource Manager Mode

```PowerShell

Switch-AzureMode AzureResourceManager

```
Change working folder to the folder containing this template

```PowerShell

New-AzureResourceGroup -Name "<new resourcegroup name>" -Location "<new resourcegroup location>"  -TemplateParameterFile .\azuredeploy-parameters.json -TemplateFile .\azuredeploy.json

```

You will be prompted for the following parameters

+ **newStorageAccountNamePrefix:** - specify the prefix for the new storage account names
+ **locationFromTemplate:** - specify a valid location for the deployment
+ **adminPassword:** - the administrator password for the VMs and Domain
+ **sqlServerServiceAccountPassword:** the password for the account that SQL Server will run as
+ **dnsPrefix:** the DNS prefix for the public IP address used for RDP

## Parameters

|Name|Description                                        |
|:----|:-------------------------------------------------|
|newStorageAccountNamePrefix|The prefix of the new storage account created to store the VMs disks,three different storage are created and the VMs disks are spread across them|
|storageAccountType|Type of the storage account<ul><li>**Allowed Values**</li><li>Standard_LRS</li><li>Standard_GRS</li><li>Standard_RAGRS</li><li>Premium_LRS **(default)**</li></ul>|
|location|Location where to deploy the resource <ul>**Allowed Values**<li>West US **(default)**</li><li>East US</li><li>West Europe</li><li>East Asia</li><li>Southeast Asia</li>|
|virtualNetworkAddressRange|Virtual Network Address Range <ul><li>10.0.0.0/16 **(default)**</li></ul>|
|staticSubnet|Address prefix for subnet that Static IP addresses are taken from <ul><li>10.0.0.0/24 **(default)**</li></ul>|
|sqlSubnet|Address prefix for subnet that SQL Server and Witness IP addresses are taken from <ul><li>10.0.1.0/24 **(default)**</li></ul>|
|adminUsername|Admin username for the VM **This will also be used as the domain admin user name**  **Default is sqlAdministrator**|
|adminPassword|Admin password for the VM **This will also be used as the domain admin password and the SafeMode password **|
|adVMSize|Size of the AD VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1 **(default)**</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|sqlVMSize|Size of the SQL VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3 **(default)**</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|witnessVMSize|Size of the SQL VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1 **(default)**</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|sqlServerServiceAccountUserName|The SQL Server Service account name|
|sqlServerServiceAccountPassword|The SQL Server Service account password|
|assetLocation|The location of resources such as templates and DSC modules that the script is dependent on|
|dnsPrefix|The DNS prefix for the public IP address used by the Load Balancer for SharePoint Web site access|
| dataBaseNames | An array of database names. Each database will be created and added to the Always On Availability Group Created |

## Notable Variables

|Name|Description|
|:---|:---------------------|
|virtualNetworkName|Name of the Virtual Network|
|adPDCVMName|The name of the Primary Domain Controller|
|adBDCVMName|The name of the Backup\Second Domain Controller|
|sqlVMName|The prefix for the SQL VM Names|
|sqlwVMName|The name of the File Share Witness|
|spwebVMName|The Prefix of the SharePoint Web Server VMs|
|rdpPort|The public RDP port for first VM|
|windowsImagePublisher|The name of the pulisher of the AD and Witness Image|
|windowsImageOffer|The Offer Name for the Image used by AD and Witness VMs|
|windowsImageSKU|The Image SKU for the AD and Witness Image|
|sqlImagePublisher|The name of the pulisher of the SQL Image|
|sqlImageOffer|The Offer Name for the Image used by SQL|
|sqlImageSKU|The Image SKU for the SQL Image|
|windowsDiskSize|The size of the VHD allocated for AD and Witness VMs Data Disk|
|sqlDiskSize|The size of the VHD allocated for SQL VMs Data and Log Disks|
|domainName|The name of the new AD Domain created|




