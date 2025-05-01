---
description: This template deploys BrowserBox to Azure on either Ubuntu Server 24.04 LTS, Debian 12, or RHEL 9 LVM.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: dosaygo/browserbox
languages:
- json
---

# BrowserBox on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosaygo/browserbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosaygo/browserbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosaygo/browserbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosaygo/browserbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosaygo/browserbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/dosaygo/browserbox/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosaygo%2Fbrowserbox%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosaygo%2Fbrowserbox%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosaygo%2Fbrowserbox%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosaygo%2Fbrowserbox%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdosaygo%2Fbrowserbox%2Fazuredeploy.json)   

This template deploys BrowserBox, a secure browsing environment, on an Ubuntu Server 24.04 LTS, Debian 12, or RHEL 9 LVM on Azure. 

## Features
- Seamless deployment of BrowserBox on Azure.
- Compatible with multiple Linux distributions: Ubuntu 22.04 LTS, Debian 12, RHEL 9 LVM.
- Customizable optional Advanced Settings to suit different requirements.

## Prerequisites
- A valid Azure subscription.
- Familiarity with Azure Resource Manager templates.
- A BrowserBox License Key, [purchasable here](http://getbrowserbox.com), and emailed to you after purchase. 
Contact sales@dosaygo.com for any license questions. 

## Deployment Steps
1. Click on the "Deploy to Azure" button.
2. Purchase a License Key for BrowserBox, it will be emailed to you after payment.
2. Fill in the required parameters (License Key, Resource group, Email).
3. Review and agree to the terms and conditions.
4. Click on "Create" to initiate the deployment.
5. Check your email for the Azure Alerts Notification email containing your BrowserBox **Login Link**. BrowserBox will send you this email using Azure once it completes its installation.

## Post-Deployment Steps

> [!NOTE]
> If you use a Custom Domain (available under the *Advanced Settings* tab in the setup wizard), ensure you monitor your deployment to obtain your Virtual Machine's IP address when that becomes available. Then, make sure you quickly set up the DNS A record that points your custom domain to this IP address. The BrowserBox installer will wait for around 30 minutes for your domain to point to its IP, and then timeout. If this happens you will need to redo your deployment from Step 1. 

Alternately, the default  `bb<random>.<region>.cloudapp.azure.com` requires no additional DNS changes on your part. In that case, simply await the Azure Notification email containing your BrowserBox **Login Link**.

> [!IMPORTANT]
> The Azure Alert email you receive after installation completes contains other useful information about your BrowserBox deployment, including a **Shut Down** link. Ensure you use this link to shut down your BrowserBox application  once you no longer need it. If you don't do this, your license ticket may not be released until the ticket expires 1 day later, meaning you will be unable to restart BrowserBox during until that time. 

Reach out with support questions any time: support@dosaygo.com. 

## License

This template is provided under standard BrowserBox [license terms](https://github.com/BrowserBox/BrowserBox/blob/boss/LICENSE.md)

`Tags: Microsoft.Authorization/roleAssignments, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, Microsoft.Insights/components, Microsoft.Insights/actionGroups, Microsoft.Insights/metricAlerts, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.OperationalInsights/workspaces, CustomScriptExtension`

