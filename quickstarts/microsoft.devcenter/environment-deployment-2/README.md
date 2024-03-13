---
description: This template provides a way to deploy a Deployment Environment resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: environment-deployment-2
languages:
- json
---

# Azure Deployment Environment (ADE)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-2/PublicLastTestDate.svg)

![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-2/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-2/FairfaxLastTestDate.svg)

![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-2/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-2/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-2/CredScanResult.svg)

`Tags: Devcenter, Environment, Deployment Environment, Azure Deployment Environment, ADE, ARM Template, Microsoft.DevCenter/devcenters`

This template provides a way to deploy the second part of the environment's infrastructure including the Project Environment Type and the role assignments for the Dev Center Identity.

If you're new to **Deployment Environment**, see:

- [Azure Deployment Environment Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments)
- [Quickstarts: Azure Deployment Environment](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Steps to deploy infrastructure for ADE

### NOTE: To fully deploy the necessary infrastructure to create an environment, you must first deploy the template _environment-deploymeny-1_ before deploying this template.

1. Deploy this quickstart template **environment-deployment-2** using the same resource group as what was used in the first template. Also don't forget the **devcenterIdentityPrincipalId** and the **projectEnvironmentTypeName** values from the first template.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-deployment-2%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-deployment-2%2Fazuredeploy.json)

2. Go to the developer portal (link is included in the quickstart documentation for ADE above) and create your environment.
