# IIS VMs and SQL VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/iis-2vm-sql-1vm/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/iis-2vm-sql-1vm/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/iis-2vm-sql-1vm/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/iis-2vm-sql-1vm/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/iis-2vm-sql-1vm/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/iis-2vm-sql-1vm/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fiis-2vm-sql-1vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" />
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fiis-2vm-sql-1vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png" />
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fiis-2vm-sql-1vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates one or two Windows Server 2012R2 VM(s) with IIS configured using DSC. It also installs one SQL Server 2014 standard edition VM, a VNET with two subnets, NSG, load balancer, NATing and probing rules.

## Resources
The following resources are created by this template:
- 1 or 2 Windows 2012R2 IIS Web Servers.
- 1 SQL Server 2014 running on premium or standard storage.
- 1 virtual network with 2 subnets with NSG rules.
- 1 Availability Set for IIS servers.
- 1 Load balancer with NATing rules.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/iis-2vm-sql-1vm/images/resources.png" />


## Architecture Diagram
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/iis-2vm-sql-1vm/images/architecture.png" />


