# Create a High Availabilty SharePoint Farm with 9 VMs using the Powershell DSC Extension

This template will create a SQL Server 2014 Always On Availability Group using the PowerShell DSC Extension it creates the following resources:

+	A Virtual Network
+	Three Storage Accounts one is used for AD VMs, one for SQL Server VMs and one for SP VMs
+	Three external and one internal load balancers
+	A NAT Rule to allow RDP to one VM which can be used as a jumpbox, a load balancer rule for ILB for a SQL Listener, a load balancer rule for HTTP traffic on port 80 for SharePoint and a NAT rule for Sharepoint Central Admin access
+ 	Three public IP addresses, one for RDP access, one for the SharePoint site and one for SharePoint Central Admin.
+	Two VMs as Domain Controllers for a new Forest and Domain
+	Two VMs in a Windows Server Cluster running SQL Server 2014 with an availability group, an additional VM acts as a File Share Witness for the Cluster
+	Two SharePoint App Servers
+	Two SharePoint Web Servers
+	Four Availability Sets one for the AD VMs, one for the SQL and Witness VMs, one for the SharePoint App Servers and one for the SharePoint Web Servers the SQL\Witness Availability Set is configured with three Update Domains and three Fault Domains to ensure that quorum can always be attained.

## Notes

+	The default settings for storage are to deploy using **premium storage**, the AD witness and SP VMs use a P10 Disk and the SQL VMs use two P30 disks each, these sizes can be changed by changing the relevant variables. In addition there is a P10 Disk used for each VMs OS Disk.

+ 	In default settings for compute require that you have at least 19 cores of free quota to deploy.

+	This template creates an Always On Listener but the deployed Sharepoint Farm does not use it at present, SharePoint is configured as decribed at https://technet.microsoft.com/en-us/library/dd207314(v=office.14).aspx#Configure3, this will be changed in the future.

+	Public Endpoints are created for the SharePoint site that this template creates and for the Central Admin site, however no permissions are given to any user for the new SharePoint site created, these will need to be added from the Central Admin site.

+ 	The images used to create this deployment are
	+ 	AD - Latest Windows Server 2012 R2 Image
	+ 	SQL Server - Latest SQL Server 2014 on Windows Server 2012 R2 Image
	+ 	Witness - Latest Windows Server 2012 R2 Image
	+	SharePoint - Latest SharePoint server 2013 trial image on Windows Server 2012 R2

+ 	The image configuration is defined in variables - details below - but the scripts that configure this deployment have only been tested with these versions and may not work on other images.

+ 	Once deployed access can be gained at the following addresses:

	+	**SharePoint Website** - http://parameter(dnsPrefix).parameter(location).cloudapp.azure.com
	+	**Central Admin Website** - http://parameter(spCentralAdminDNSPrefix).parameter(location).cloudapp.azure.com
	+	**RDP Jump Box** - mstsc -v parameter(rdpDNSPrefix).parameter(location).cloudapp.azure.com

## Known Issues

+ **This template has a lot of serial behaviour due to some issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently, this will be fixed in the future, as a result of this it can take a while to run (around 2 hours) it will take  longer if premium storage is not used**


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-server-farm-ha%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Parameters

|Name|Description                                        |
|:----|:-------------------------------------------------|
|newStorageAccountNamePrefix|The prefix of the new storage account created to store the VMs disks,different storage accounts will be created for AD,SQL and Sharepoint VMs. The same storage account type is used for all machines|
|storageAccountType|Type of the storage account<ul><li>**Allowed Values**</li><li>Standard_LRS</li><li>Standard_GRS</li><li>Standard_RAGRS</li><li>Standard_ZRS</li><li>Premium_LRS **(default)**</li></ul>|
|location|Location where to deploy the resource <ul>**Allowed Values**<li>West US</li><li>East US</li><li>West Europe</li><li>East Asia</li><li>Southeast Asia</li>|
|virtualNetworkAddressRange|Virtual Network Address Range <ul><li>10.0.0.0/16 **(default)**</li></ul>|
|staticSubnet|Address prefix for subnet that Static IP addresses are taken from <ul><li>10.0.0.0/24 **(default)**</li></ul>|
|sqlSubnet|Address prefix for subnet that SQL Server and Witness IP addresses are taken from <ul><li>10.0.1.0/24 **(default)**</li></ul>|
|spwebSubnet|Address prefix for subnet that SharePoint Web Server addresses are taken from <ul><li>10.0.2.0/24 **(default)**</li></ul>|
|spAppSubnet|Address prefix for subnet that SharePoint App Server  are taken from <ul><li>10.0.3.0/24 **(default)**</li></ul>|
|adPDCNicIPAddress|The IP address of the new AD PDC <ul><li>**10.0.0.4 (default)**</li></ul>|
|adBDCNicIPAddress|The IP address of the new AD BDC <ul><li>**10.0.0.5 (default)**</li></ul>|
|sqlLBNicIPAddress|The IP address of the ILB used for SQL Listener <ul><li>**10.0.0.6 (default)**</li></ul>|
|adminUsername|Admin username for the VM **This will also be used as the domain admin user name**|
|adminPassword|Admin password for the VM **This will also be used as the domain admin password and the SafeMode password **|
|adVMSize|Size of the AD VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1 **(default)**</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|sqlVMSize|Size of the SQL VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3 **(default)**</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|witnessVMSize|Size of the SQL VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1 **(default)**</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|spVMSize|Size of the SharePoint VM <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2</li><li>Standard_DS2 **(default)**</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
|domainName|The FQDN of the AD Domain created|
|dnsPrefix|The DNS prefix for the public IP address used by the Load Balancer for SharePoint Web site access|
|rdpDNSPrefix|The DNS prefix for the public IP address used by the Load Balancer for RDP Access|
|spCentralAdminDNSPrefix|The DNS prefix for the public IP address used by the Load Balancer for SharePoint Central Admin Access|
|assetLocation|The location of resources such as templates and DSC modules that the script is dependent on|
|sqlServerServiceAccountUserName|The SQL Server Service account name|
|sqlServerServiceAccountPassword|The SQL Server Service account password|
|sharePointSetupUserAccountUserName|The Sharepoint Setup account name|
|sharePointSetupUserAccountPassword|The Sharepoint Setup account password|
|sharePointFarmAccountUserName|The Sharepoint Farm account name|
|sharePointFarmAccountPassword|The Sharepoint Farm account password|
|sharePointFarmPassphrasePassword|The Sharepoint Farm Passphrase|
|configDatabaseName|The Sharepoint Configuration Database Name|
|administrationContentDatabaseName|The Sharepoint Admin Site Database Name|
|contentDatabaseName|The Sharepoint Content Database Name|
|spSiteTemplateName|The Sharepoint Content Site Template Name|



## Notable Variables

|Name|Description|
|:---|:---------------------|
|virtualNetworkName|Name of the Virtual Network|
|adPDCVMName|The name of the Primary Domain Controller|
|adBDCVMName|The name of the Backup\Second Domain Controller|
|sqlVMName|The prefix for the SQL VM Names|
|sqlwVMName|The name of the File Share Witness|
|spwebVMName|The Prefix of the SharePoint Web Server VMs|
|spappVMName|The Prefix of the SharePoint App Server VMs|
|rdpPort|The public RDP port for first VM|
|windowsImagePublisher|The name of the pulisher of the AD and Witness Image|
|windowsImageOffer|The Offer Name for the Image used by AD and Witness VMs|
|windowsImageSKU|The Image SKU for the AD and Witness Image|
|sqlImagePublisher|The name of the pulisher of the SQL Image|
|sqlImageOffer|The Offer Name for the Image used by SQL|
|sqlImageSKU|The Image SKU for the SQL Image|
|spImagePublisher|The name of the pulisher of the SharePoint Image|
|spImageOffer|The Offer Name for the Image used by SharePoint|
|spImageSKU|The Image SKU for the SharePoint Image|
|windowsDiskSize|The size of the VHD allocated for AD and Witness VMs Data Disk|
|sqlDiskSize|The size of the the VHD allocated for SQL VMs Data and Log Disks|
|spDiskSize|The size of the VHD allocated for the SP VMs Data Disk|



