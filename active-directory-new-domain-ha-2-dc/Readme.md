# Create a 2 new Windows VMs, create a new AD Forest, Domain and 2 DCs in an availability set

This template will deploy 2 new VMs (along with a new VNet, Storage Account and Load Balancer) and create a new  AD forest and domain, each VM will be created as a DC for the new domain and will be placed in an availability set. Each VM will also have an RDP endpoint added with a public load balanced IP address.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Factive-directory-new-domain-ha-2-dc%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li><li>"Standard_RAGRS"</li><li>"Standard_ZRS"</li><li>"Premium_RS"</li></ul> |
| deploymentLocation  | Location where to deploy the resource <br><ul>**Allowed Values**<li>West US</li><li>East US</li><li>**West Europe (default)**</li><li>East Asia</li><li>Southeast Asia</li>|
| virtualNetworkName | Name of the Virtual Network |
| virtualNetworkAddressRange | Virtual Network Address Range <br> <ul><li>10.0.0.0/16 **(default)**</li></ul> |
| adSubnetName | Name of Subnet for AD VM  |
| adSubnet | Address prefix for adSubnetName <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| adPDCNicName | The name of the NIC attached to the new PDC |
| adPDCNicIPAddress | The IP address of the new AD PDC  <br> <ul><li>**10.0.0.4 (default)**</li></ul> |
| adBDCNicName | The name of the NIC attached to the new BDC |
| adBDCNicIPAddress | The IP address of the new AD BDC  <br> <ul><li>**10.0.0.5 (default)**</li></ul> |
| publicIPAddressName | Name of the public IP address to create |
| publicIPAddressType | Type of Public IP Address <br> <ul>**Allowed Values**<li>Dynamic **(default)**</li><li>Static</li></ul>|
| adPDCVMName | Name for the PDC |
| adBDCVMName | Name for the BDC |
| adminUsername | Admin username for the VM **This will also be used as the domain admin user name**|
| adminPassword | Admin password for the VM **This will also be used as the domain admin password and the SafeMode password** |
| adVMSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_D1 </li><li>Standard_DS1</li><li>Standard_D2**(default)**</li><li>Standard_DS2</li><li>Standard_D3</li><li>Standard_DS3</li><li>Standard_D4</li><li>Standard_DS11</li><li>Standard_D11</li><li>Standard_DS11</li><li>Standard_D12</li><li>Standard_DS12</li><li>Standard_D13</li><li>Standard_DS13</li><li>Standard_D14</li><li>Standard_DS14</li></ul>|
| imagePublisher| The name of the pulisher of the Image ||
| imageOffer| The Image Offer|
| imageSKU| The Image SKU|| vmContainerName | The container name in the storage account where VM disks are stored|
| adAvailabilitySetName | The name of the availability set that the AD VM is created in|
| domainName | The FQDN of the AD Domain created |
| dnsPrefix | The DNS prefix for the public IP address used by the Load Balancer |
| pdcRDPPort | The public RDP port for the PDC VM |
| bdcRDPPort | The public RDP port for the BDC VM |
| AssetLocation | The location of resources such as templates and DSC modules that the script is dependent <br> <ul><li> **https://raw.githubusercontent.com/azurermtemplates/azurermtemplates/master/activedirectorynewdomain-ha-2-dc (default)**</li></ul> |


# Known Issues

+	This template is entirely serial due to some concurrency issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently, this will be fixed in the near future