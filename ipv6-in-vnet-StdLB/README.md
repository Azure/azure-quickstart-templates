# Create a dual stack IPv4/IPv6 VNET with 2 VMs

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-StdLB/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-StdLB/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-StdLB/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-StdLB/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-StdLB/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ipv6-in-vnet-StdLB/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fipv6-in-vnet%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fipv6-in-vnet%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

**This template demonstrates creation of a dual stack IPv4/IPv6 VNET with 2 dual stack VMs and a STANDARD Load Balancer.**

The template creates the following Azure resources:

- a dual stack IP4/IPv6 Virtual Network (VNET) with a dual stack subnet
- a virtual network interface (NIC) for each VM with both IPv4 and IPv6 endpoints
- an Internet-facing STANDARD Load Balancer with an IPv4 and an IPv6 Public IP addresses
- IPv6  Network Security Group rules (allow HTTP and RDP)
- an IPv6 User-Defined Route to a fictitious Network Virtual Appliance
- an IPv4 Public IP address for each VM to facilitate remote connection to the VM (RDP)
- two virtual machines with both IPv4 and IPv6 endpoints in the VNET/subnet

Note:  Use of this template requires your subscription is registered for the following features:   AllowIPv6VirtualNetwork, AllowIPv6CAOnStandardLB
           The registration process is described in the documentation linked to below.  

For a more information about this template, see [What is IPv6 for Azure Virtual Network?](https://docs.microsoft.com/en-us/azure/virtual-network/ipv6-overview/)

