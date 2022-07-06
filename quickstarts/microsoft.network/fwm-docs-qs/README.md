---
description: This template creates a secured virtual hub using Azure Firewall to secure your cloud network traffic destined to the Internet.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: fwm-docs-qs
languages:
- json
- bicep
---
# Secured virtual hubs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/fwm-docs-qs/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffwm-docs-qs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffwm-docs-qs%2Fazuredeploy.json)

This template creates a secured virtual hub using Azure Firewall to secure your cloud network traffic destined to the Internet. The firewall has an application rule that allows web traffic to `www.microsoft.com`.

The jump server and workload server virtual machines are *Standard_D2s_v3* virtual machines running Windows Server 2019.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

This template is used by the Azure Firewall Manager documentation [quickstart](https://docs.microsoft.com/azure/firewall-manager/quick-secure-virtual-hub) article.

`Tags: Azure Firewall Manager, Microsoft.Network/virtualWans, Standard, Microsoft.Network/virtualHubs, Microsoft.Network/virtualHubs/hubVirtualNetworkConnections, Microsoft.Network/firewallPolicies, Microsoft.Network/firewallPolicies/ruleCollectionGroups, Allow, Microsoft.Network/azureFirewalls, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Compute/virtualMachines, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/routeTables, Microsoft.Network/virtualHubs/hubRouteTables`
