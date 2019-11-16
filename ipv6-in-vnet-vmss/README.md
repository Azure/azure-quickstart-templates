# Create a dual stack IPv4/IPv6 VNET with 2 VMs

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-vmss/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-vmss/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-vmss/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-vmss/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-vmss/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-vmss/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fipv6-in-vnet-vmss%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fipv6-in-vnet-vmss%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

**This template demonstrates use of VM Scale Sets with a dual stack IPv4/IPv6 VNET and Std Load Balancer.**

The template creates the following Azure resources:

- a VM Scale Set with 2 instances (by default)
- the instances reside in a dual stack IP4/IPv6 Virtual Network (VNET) with a dual stack subnet
- a VMSS Network Profile with both IPv4 and IPv6 endpoints
- an Internet-facing Standard Load Balancer with both IPv4 and an IPv6 Public IP addresses
- Network Security Group rules- including an IPv6-specific example

For a more information about this template, see [What is IPv6 for Azure Virtual Network?](https://docs.microsoft.com/en-us/azure/virtual-network/ipv6-overview/)

