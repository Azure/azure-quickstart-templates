---
description: This template provides a way to deploy a Deployment Environment resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: environment-deployment-1
languages:
- json
---
<<<<<<< Updated upstream:quickstarts/microsoft.devcenter/environment-sandbox/README.md
#  Deploy Azure Deployment Environment (ADE)
=======

# Azure Deployment Environment (ADE)
>>>>>>> Stashed changes:quickstarts/microsoft.devcenter/environment-deployment-1/README.md

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-1/PublicLastTestDate.svg)

![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-1/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-1/FairfaxLastTestDate.svg)

![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-1/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-1/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-deployment-1/CredScanResult.svg)

`Tags: Devcenter, Environment, Deployment Environment, Azure Deployment Environment, ADE, ARM Template, Microsoft.DevCenter/devcenters`

This template provides a way to deploy an Environment including Dev Center, Catalog, Environment Definitions, Environment Type, and Project.

If you're new to **Deployment Environment**, see:

- [Azure Deployment Environment Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments)
- [Quickstarts: Azure Deployment Environment](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Steps to deploy infrastructure for ADE

### NOTE: To fully deploy the necessary infrastructure to create an environment, you must deploy this template, as well the second template named _environment-deployment-2_

1. Create a new resource group or use an existing one

    `New-AzResourceGroup -Name <ResourceGroupName> -Location eastus`

    `az group create --name <ResourceGroupName> --location eastus`

2. Deploy this quickstart template **environment-deployment-1**

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-deployment-1%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-deployment-1%2Fazuredeploy.json)

3. Go to the outputs of the template to retrieve the **devcenterIdentityPrincipalId** and the **projectEnvironmentTypeName** values to use in the second template
