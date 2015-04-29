# Create a new Sharepoint Farm with 3 VMs

This template creates three new Azure VMs, each with a public IP address and load balancer and a VNet, it configures one VM to be an AD DC for a new Forest and Domain, one with SQL Server domain joined and a third VM with a Sharepoint farm and  site, all VMs have public facing RDP

There are a number of issues\workarounds in this template and the associated DSC Script:

1. This template is entirely serial due to some issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently, this will be fixed in the future

Click the button below to deploy

<a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li><li>"Standard_ZRS"</li></ul> |
| deploymentLocation  | Location where to deploy the resource <br><ul>**Allowed Values**<li>West US</li><li>East US</li><li>**West Europe (default)**</li><li>East Asia</li><li>Southeast Asia</li>|
| virtualNetworkName | Name of the Virtual Network |
| virtualNetworkAddressRange | Virtual Network Address Range <br> <ul><li>10.0.0.0/16 **(default)**</li></ul> |
| adSubnet | Address prefix for adSubnetName <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| sqlSubnet | Address prefix for adSubnetName <br> <ul><li>10.0.1.0/24 **(default)**</li></ul> |
| spSubnet | Address prefix for adSubnetName <br> <ul><li>10.0.2.0/24 **(default)**</li></ul> |
| adNicIPAddress | The IP address of the new AD VM  <br> <ul><li>**10.0.0.4 (default)**</li></ul> |
| publicIPAddressName | Name of the public IP address to create |
| adVMName | Name for the AD VM |
| sqlVMName | Name for the SQL VM |
| spVMName | Name for the SP VM |
| adminUsername | Admin username for the VM **This will also be used as the domain admin user name**|
| adminPassword | Admin password for the VM **This will also be used as the domain admin password and the SafeMode password** |
| adVMSize | Size of the AD VM <br> <ul>**Allowed Values**<li>Standard_A0 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| sqlVMSize | Size of the SQL VM <br> <ul>**Allowed Values**<li>Standard_A2 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| spVMSize | Size of the SP VM <br> <ul>**Allowed Values**<li>Standard_A3 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| adImageName | Name of image to use for the AD VM <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd **(default)**</li></ul>|
| sqlImageName | Name of image to use for the SQL VM <br> <ul><li>fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2048.0-Ent-ENU-Win2012R2-cy15su04 **(default)**</li></ul>|
| spImageName | Name of image to use for the SP VM <br> <ul><li>c6e0f177abd8496e934234bd27f46c5d__SharePoint-2013-Trial-1-20-2015 **(default)**</li></ul>|
| vmContainerName | The container name in the storage account where VM disks are stored|
| domainName | The FQDN of the AD Domain created |
| sqlServerServiceAccountUserName | The SQL Server Service account name |
| sqlServerServiceAccountPassword | The SQL Server Service account password |
| sharePointSetupUserAccountUserName | The Sharepoint Setup account name|
| sharePointSetupUserAccountPassword |The Sharepoint Setup account password |
| sharePointFarmAccountUserName | The Sharepoint Farm account name |
| sharePointFarmAccountPassword | The Sharepoint Farm account password |
| sharePointFarmPassphrasePassword | The Sharepoint Farm Passphrase |
| databaseName | The Sharepoint Config Database Name|
| administrationContentDatabaseName | The Sharepoint Admin Site Database Name |
| spSiteTemplateName | The Sharepoint Content Site Template Name |
| RDPPort | The public RDP port for the VMs |
| adDNSPrefix | The DNS prefix for the public IP address used by the Load Balancer for AD |
| adSQLPrefix | The DNS prefix for the public IP address used by the Load Balancer for SQL |
| adSPPrefix | The DNS prefix for the public IP address used by the Load Balancer for SP |
| AssetLocation | The location of resources such as templates and DSC modules that the script is dependent <br> <ul><li> **https://raw.githubusercontent.com/azurermtemplates/azurermtemplates/master/sharepoint-three-vm (default)**</li></ul> |


