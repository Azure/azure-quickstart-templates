---
description: This template deploys BrowserBox to Azure on either Ubuntu Server 22.04 LTS, Debian 11, or RHEL 8.7 LVM.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: dosyago/browserbox
languages:
- json
---

# BrowserBox on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosyago/browserbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosyago/browserbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosyago/browserbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosyago/browserbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosyago/browserbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosyago/browserbox/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosyago%2Fbrowserbox%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosyago%2Fbrowserbox%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosyago%2Fbrowserbox%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosyago%2Fbrowserbox%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosyago%2Fbrowserbox%2Fazuredeploy.json)   

This template deploys BrowserBox, a secure browsing environment, on an Ubuntu Server 22.04 LTS, Debian 11, or RHEL 8.7 LVM on Azure. 

## Features
- Seamless deployment of BrowserBox on Azure.
- Compatible with multiple Linux distributions: Ubuntu 22.04 LTS, Debian 11, RHEL 8.7 LVM.
- Customizable optional Advanced Settings to suit different requirements.

## Prerequisites
- A valid Azure subscription.
- Familiarity with Azure Resource Manager templates.

## Deployment Steps
1. Click on the "Deploy to Azure" button.
2. Fill in the required parameters (Resource group, Email).
3. Review and agree to the terms and conditions.
4. Click on "Create" to initiate the deployment.

## Post-Deployment Steps
- If you used a Custom Domain, rather than the default random `bb<random>.<region>.cloudapp.azure.com` domain that will by default be generated for you, ensure you configure a DNS A record pointing to the public IP of the deployed VM. You can configure Custom Domain settings under Advanced Settings. 

Reach out with support questions any time: support@dosyago.com. 

## License

This template is provided under standard open-source [license terms](https://github.com/BrowserBox/BrowserBox/blob/boss/LICENSE.md)

`Tags: Microsoft.Authorization/roleAssignments, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, Microsoft.Insights/components, Microsoft.Insights/actionGroups, Microsoft.Insights/metricAlerts, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.OperationalInsights/workspaces, CustomScriptExtension`

