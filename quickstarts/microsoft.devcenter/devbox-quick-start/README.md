---
description: This template provides a quick and easy way to set up resouces required to start deploying Dev Boxes.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: devbox-quick-start
languages:
- bicep
- json
---
# Setup Resources To Deploy Dev Boxes

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-quick-start/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-quick-start%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-quick-start%2Fazuredeploy.json)

# Overview

This template provides a quick way to set up the resouces needed to begin deploying a new Dev Box. The resources include:

- Dev Center
- Dev Box Project
- Dev Box Definition (currently only 1 option is available).
- Dev Box Pool with a Microsoft Hosted Network. [Learn more on MHNs](https://learn.microsoft.com/en-us/azure/dev-box/how-to-manage-dev-box-pools#create-a-dev-box-pool). 

If you're new to **Dev Box**, see:

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Quickstarts: Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Devcenter, Dev Box, ARM Template, Microsoft.DevCenter/devcenters`
