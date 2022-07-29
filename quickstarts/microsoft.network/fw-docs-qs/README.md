---
description: This template creates an Azure Firewall with two public IP addresses and two Windows Server 2019 servers to test.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: fw-docs-qs
languages:
- json
- bicep
---
# Create an Azure Firewall with multiple IP public addresses

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fw-docs-qs/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffw-docs-qs%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffw-docs-qs%2Fazuredeploy.json)

This template deploys an **Azure Firewall** with multiple public IP addresses allocated from a public IP Prefix. The firewall has NAT rules to allow RDP traffic to the two test virtual machines.

The backend virtual machines are *Standard_B2ms* virtual machines running Windows Server 2019.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

This template is used by the Azure Firewall documentation [quickstart](https://docs.microsoft.com/azure/firewall/quick-create-multiple-ip-template) article.

`Tags: Azure Firewall, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPPrefixes, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Compute/virtualMachines, Microsoft.Network/networkInterfaces, Microsoft.Network/azureFirewalls, Allow, Dnat, Microsoft.Network/routeTables`
