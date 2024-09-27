---
description: This template allows you to create Azure Virtual Desktop resources such as host pool, application group, workspace, a test session host and its extensions with Microsoft Entra ID join
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-virtual-desktop
languages:
- bicep
- json
---
# Creates AVD with Microsoft Entra ID Join

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Fazure-virtual-desktop%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Fazure-virtual-desktop%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Fazure-virtual-desktop%2Fazuredeploy.json)

This template allows you to create Azure Virtual Desktop resources such as host pool, application group, workspace, a test session host and its extensions with Microsoft Entra ID join. Modify parameters file to change default values. This is tested with a new azure azure Vnet/subnet.

[Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview)

`Tags: network, virtual network, subnet, host pool, application group, workspace, virtual machine network interface, virtual machine, virtual machine extensions, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.DesktopVirtualization/hostPools@2021, Microsoft.DesktopVirtualization/applicationGroups, Microsoft.DesktopVirtualization/workspaces, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions`