---
description: This template creates a virtual network with 3 subnets (server subnet, jumpbox subet and AzureFirewall subnet), a jumpbox VM with public IP, A server VM, UDR route to point to Azure Firewall for the Server Subnet and an Azure Firewall with 1 or more Public IP addresses, 1 sample application rule, 1 sample network rule and default private ranges
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azurefirewall-sandbox-linux
languages:
- bicep
- json
---
# Create a sandbox setup of Azure Firewall with Linux VMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-sandbox-linux/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-sandbox-linux%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-sandbox-linux%2Fazuredeploy.json)

This template creates a virtual network with 3 subnets (server subnet, jumpbox subnet and AzureFirewall subnet), a jumpbox VM running Ubuntu Linux with public IP and RDP access,
A server VM running Ubuntu Linux with only a private IP, UDR route to point to AzureFirewall for the ServerSubnet and an AzureFirewall with 1 sample application rule and 1 sample network rule.
Azure Firewall is a managed cloud-based network security service that protects your Azure Virtual Network resources.
It is a fully stateful firewall as a service with built-in high availability and unrestricted cloud scalability.
You can centrally create, enforce, and log application and network connectivity policies across subscriptions and virtual network.
Azure Firewall uses one or more static public IP addresses for your virtual network resources allowing outside firewalls to identify traffic originating from your virtual network.
The service is fully integrated with Azure Monitor for logging and analytics. Learn more at https://docs.microsoft.com/azure/firewall.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/routeTables, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Network/azureFirewalls, Allow`
