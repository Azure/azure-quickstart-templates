# Create a new Sharepoint Farm with 3 VMs

This template creates three new Azure VMs, each with a public IP address and load balancer and a VNet, it configures one VM to be an AD DC for a new Forest and Domain, one with SQL Server domain joined and a third VM with a Sharepoint farm and  site, all VMs have public facing RDP

Click the button below to deploy


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-three-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li><li>Standard_RAGRS</li><li>Standard_ZRS</li><li>Premium_LRS</li></ul> |
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
| adVMSize | Size of the AD VM <br> <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2**(default)**</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
| sqlVMSize | Size of the SQL VM <br> <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2**(default)**</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
| spVMSize | Size of the SharePoint VM <br> <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2</li><li>Standard_DS2</li><li>Standard_D3**(default)**</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
| adImagePublisher| The name of the pulisher of the AD Image |
| adImageOffer| The Offer Name for the Image used by AD|
| adImageSKU| The Image SKU for the AD Image|
| sqlImagePublisher| The name of the pulisher of the SQL Image |
| sqlImageOffer| The Offer Name for the Image used by SQL|
| sqlImageSKU| The Image SKU for the SQL Image|
| spImagePublisher| The name of the pulisher of the SharePoint Image |
| spImageOffer| The Offer Name for the Image used by SharePoint|
| spImageSKU| The Image SKU for the SharePoint Image|
| vmContainerName | The container name in the storage account where VM disks are stored|
| domainName | The FQDN of the AD Domain created |
| sqlServerServiceAccountUserName | The SQL Server Service account name |
| sqlServerServiceAccountPassword | The SQL Server Service account password |
| sharePointSetupUserAccountUserName | The Sharepoint Setup account name|
| sharePointSetupUserAccountPassword |The Sharepoint Setup account password |
| sharePointFarmAccountUserName | The Sharepoint Farm account name |
| sharePointFarmAccountPassword | The Sharepoint Farm account password |
| sharePointFarmPassphrasePassword | The Sharepoint Farm Passphrase |
| configDatabaseName | The Sharepoint Config Database Name|
| administrationContentDatabaseName | The Sharepoint Admin Site Database Name |
| contentDatabaseName | The Sharepoint Content Database Name|
| spSiteTemplateName | The Sharepoint Content Site Template Name |
| RDPPort | The public RDP port for the VMs |
| adDNSPrefix | The DNS prefix for the public IP address used by the Load Balancer for AD |
| adSQLPrefix | The DNS prefix for the public IP address used by the Load Balancer for SQL |
| adSPPrefix | The DNS prefix for the public IP address used by the Load Balancer for SP |
| AssetLocation | The location of resources such as templates and DSC modules that the script is dependent <br> <ul><li> **https://raw.githubusercontent.com/azurermtemplates/azurermtemplates/master/sharepoint-three-vm (default)**</li></ul> |

#Known Issues

This template has a lot of serial behaviour due to some concurrency issues with the DSC extensions, this will be fixed in the future which will make execution time much shorter

