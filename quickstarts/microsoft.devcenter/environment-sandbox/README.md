---
description: This template provides a way to deploy a Deployment Environment resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: environment-sandbox
languages:
- bicep
- json
---
#  Deploy Azure Deployment Environment (ADE)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/BicepVersion.svg)

## Overview

The templates below provide an easy way to deploy the infrastructure needed to create an Environment resource, which includes:

- Dev Center
- Catalog
- Environment Definitions
- Dev Center Environment Type
- Project
- Project Environment Type
- Role Assignments:
  - Deployment Environment User (project-resource-scope)
  - User Access Administrator (subscription-scope)
  - Contributor (subscription-scope)

If you're new to **Deployment Environment**, see:

- [Azure Deployment Environment Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments)
- [Quickstarts: Azure Deployment Environment](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Deployment steps

### ARM

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-sandbox%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-sandbox%2Fazuredeploy.json)

### Bicep

You can use VSCode to deploy **main.bicep**:

- [Deploying Bicep via VSCode](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-vscode)

### 

After the infrastructure is set up, open the Developer Portal following the documentation links above to create your environment resource.

---

`Tags: Devcenter, Environment, Deployment Environment, Azure Deployment Environment, ADE, ARM Template, Microsoft.DevCenter/devcenters`
