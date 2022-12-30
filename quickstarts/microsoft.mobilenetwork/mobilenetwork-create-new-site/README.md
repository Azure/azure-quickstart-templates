---
description: This template creates a new site with associated 5G packet core resources. It can optionally be deployed to a Kubernetes cluster running on an Azure Stack Edge device.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: mobilenetwork-create-new-site
languages:
- bicep
- json
---
# Create a new mobile network site

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-new-site/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-create-new-site%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-create-new-site%2Fazuredeploy.json)

This template deploys a new site for an existing mobile network.

## Prerequisites

By default this template does not deploy any resources to the Azure Stack Edge Pro device. If you want to deploy to an Azure Stack Edge Pro device, you must follow the pre-requisite instructions in the [Private 5G Core documentation](https://docs.microsoft.com/azure/private-5g-core/complete-private-mobile-network-prerequisites) before starting the deployment, so that you can specify the customLocation parameter.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: Azure Private 5G Core, Resource Manager templates, ARM templates, Microsoft.MobileNetwork/mobileNetworks/sites, Microsoft.MobileNetwork/packetCoreControlPlanes/packetCoreDataPlanes/attachedDataNetworks, Microsoft.MobileNetwork/packetCoreControlPlanes/packetCoreDataPlanes, Microsoft.MobileNetwork/packetCoreControlPlanes, Microsoft.MobileNetwork/mobileNetworks/dataNetworks, Microsoft.MobileNetwork/mobileNetworks`