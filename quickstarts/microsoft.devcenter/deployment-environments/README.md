---
description: This template provides a way to configure Deployment Environments.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: deployment-environments
languages:
- bicep
- json
---
#  Configure Deployment Environments service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/deployment-environments/BicepVersion.svg)

## Overview

The templates below provide an easy way to deploy the infrastructure needed to create an Environment resource, which includes:

- Dev Center
- Catalog
- Dev Center Environment Type
- Project
- Project Environment Type
- Role Assignments:
  - Deployment Environment User (project-resource-scope)
  - User Access Administrator (subscription-scope)
  - Contributor (subscription-scope)

If you're new to **Deployment Environments**, see:

- [Azure Deployment Environments Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments)
- [Quickstarts: Azure Deployment Environments](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Deployment steps

### ARM

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdeployment-environments%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdeployment-environments%2Fazuredeploy.json)

### Bicep

You can use VS Code to deploy **main.bicep**:

- [Deploying Bicep via VS Code](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-vscode)

### 

After the infrastructure is set up, open the Developer Portal following the documentation links above to create your Deployment Environments resource.

---

`Tags: Devcenter, Environments, Deployment Environments, Azure Deployment Environments, ADE, ARM Template, Microsoft.DevCenter/devcenters`
