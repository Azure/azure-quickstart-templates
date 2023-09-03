---
description: This template allows you to update the version of an existing packet core.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: mobilenetwork-update-packet-core-control-plane
languages:
- bicep
- json
---
# Update a packet core control plane

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-update-packet-core-control-plane/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-update-packet-core-control-plane%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-update-packet-core-control-plane%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-update-packet-core-control-plane%2Fazuredeploy.json)

This template allows you to update the version of an existing packet core.

## Prerequisites

By default this template does not deploy any resources to the Azure Stack Edge Pro device. If you want to deploy to an Azure Stack Edge Pro device, you must follow the pre-requisite instructions in the [Private 5G Core documentation](https://docs.microsoft.com/azure/private-5g-core/complete-private-mobile-network-prerequisites) before starting the deployment, so that you can specify the customLocation parameter.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: Azure Private 5G Core, Resource Manager templates, ARM templates, Microsoft.MobileNetwork/packetCoreControlPlanes, Microsoft.MobileNetwork/mobileNetworks`