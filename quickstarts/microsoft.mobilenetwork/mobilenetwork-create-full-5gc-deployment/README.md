---
description: This template creates all resources required to deploy a Private 5G Core, including provisioning sims and creating sample QoS policy. It can optionally be deployed to a Kubernetes cluster running on an Azure Stack Edge device.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: mobilenetwork-create-full-5gc-deployment
languages:
- bicep
- json
---
# Create a full 5G Core deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mobilenetwork/mobilenetwork-create-full-5gc-deployment/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-create-full-5gc-deployment%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mobilenetwork%2Fmobilenetwork-create-full-5gc-deployment%2Fazuredeploy.json)

This template deploys a Private 5G Core. The Private 5G Core is a deployed with a sample SIM and default policy.

## Prerequisites

By default this template does not deploy any resources to the Azure Stack Edge. If you want to deploy to an Azure Stack Edge then you must follow the pre-requisite instructions in the Private 5G Core [documentation](https://docs.microsoft.com/azure/private-5g-core/complete-private-mobile-network-prerequisites) before starting the deployment so that you can specify the customLocation parameter.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: Azure Private 5G Core, Resource Manager templates, ARM templates, Microsoft.MobileNetwork/mobileNetworks/dataNetworks, Microsoft.MobileNetwork/mobileNetworks/slices, Microsoft.MobileNetwork/mobileNetworks/services, Microsoft.MobileNetwork/mobileNetworks/simPolicies, Microsoft.MobileNetwork/mobileNetworks/sites, Microsoft.MobileNetwork/packetCoreControlPlanes/packetCoreDataPlanes/attachedDataNetworks, Microsoft.MobileNetwork/packetCoreControlPlanes/packetCoreDataPlanes, Microsoft.MobileNetwork/mobileNetworks, Microsoft.MobileNetwork/sims, Microsoft.MobileNetwork/packetCoreControlPlanes`
