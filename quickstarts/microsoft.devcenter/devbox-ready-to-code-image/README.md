# Build Ready-To-Code Dev Box Images

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-ready-to-code-image%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-ready-to-code-image%2Fazuredeploy.json)

This template demonstrates building Ready-To-Code images containing everything a developer needs (configuration, source, packages, binaries) to minimize the time used for setting up a new Dev Box.

## Sample overview and deployed resources

The sample uses Dev Box Image Template to build 3 images demonstrating its various configuration options. For each image the template creates the following Azure resources:
- **Azure Image Builder Template**: the image factory used for building an image version.
- **Deployment Script**: that managed building of an image and reports results.
- **VM Image Definition**: where the final image is placed.

## Prerequisites
The sample requires the following Azure resources (defined in [prereqs](./prereqs/prereq.main.bicep))
- **Builder Identity**: Azure User-Assigned Managed Identity used for deploying resources described above. In the sample for simplicity the identity is given `Contributor` access to the resource group where all resources are created. To better lock down image building it is recommended configure the identity with more scoped set of permissions, for example as described [here](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/image-builder#create-a-user-assigned-managed-identity-and-grant-permissions). Make sure to register Azure Resource Providers needed by `Azure Image Builder` as described [here](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/image-builder#register-the-providers).
- **Image Identity**: Azure User-Assigned Managed Identity used to clone repositories from private `Azure DevOps` projects during an image configuration, as well as to download packages for the repositories. GitHub repositories configured for an image are assumed to be public, as well as their packages.
- **Azure Compute Gallery**: where the Dev Box Image Template creates `VM Image Definitions` for images.

## Setting up Azure DevOps image building pipeline

-

## Sample images

-

## Dev Box Image Template parameters

-

## Repository Configuration

-

## Notes

-

`Tags: DevCenter, Dev Box, ARM Template, Microsoft.DevCenter/devcenters, Azure Image Builder, Ready-To-Code`
