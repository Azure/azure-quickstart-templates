---
description: This template uses DeploymentScript to orchestrate ACR to build your container image from code repo.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: deployment-script-azcli-acr-build
languages:
- json
- bicep
---
# Build container images with ACR Tasks

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-acr-build/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-acr-build%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-acr-build%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-acr-build%2Fazuredeploy.json)   

## Sample overview

This template leverages the Container Build capability in Azure Container Registry to build and store your container from source code repository.

A new Azure Container Registry will be created, and the Deployment Script resource is used to initiate the container build.

See the [Acr Build module](https://github.com/Azure/bicep-registry-modules/blob/main/modules/deployment-scripts/build-acr/README.md) in the Bicep Registry for more information.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: Acr, Build, AzureCli, Microsoft.ContainerRegistry/registries, Microsoft.Resources/deployments, Microsoft.ManagedIdentity/userAssignedIdentities, Microsoft.Authorization/roleAssignments, Microsoft.Resources/deploymentScripts, UserAssigned`
