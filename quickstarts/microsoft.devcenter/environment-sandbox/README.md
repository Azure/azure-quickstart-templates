---
description: This template provides a way to deploy a Deployment Environment resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: environment-sandbox
languages:
- json
---
#  Deploy Azure Deployment Environment (ADE)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/PublicLastTestDate.svg)

![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/FairfaxLastTestDate.svg)

![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/environment-sandbox/CredScanResult.svg)

This template provides a way to deploy an Environment including Dev Center, Catalog, Environment Definitions, Environment Type, and Project.

If you're new to **Deployment Environment**, see:

- [Azure Deployment Environment Documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments)
- [Quickstarts: Azure Deployment Environment](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Steps to deploy backing resources for ADE

1. Create a new resource group or use an existing one

    `New-AzResourceGroup -Name <ResourceGroupName> -Location eastus`

    `az group create --name <ResourceGroupName> --location eastus`

2. Deploy quickstart template

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-sandbox%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fenvironment-sandbox%2Fazuredeploy.json)

3. Get the Dev Center's Identity Principal ID either from the deployment's output or through the portal, and use it as the object ID in the next step

4. Set up the 2 role assignments

    ```
    New-RoleAssignment -Scope /subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -ObjectId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -RoleDefinitionId 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9
    New-RoleAssignment -Scope /subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -ObjectId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -RoleDefinitionId b24988ac-6180-42a0-ab88-20f7382dd24c
    ```

    ```
    az role assignment create --scope /subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX --assignee-principal-type ServicePrincipal --assignee-object-id XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX --role 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9
    az role assignment create --scope /subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX --assignee-principal-type ServicePrincipal --assignee-object-id XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX --role b24988ac-6180-42a0-ab88-20f7382dd24c
    ```

5. Create your environment resource using the developer portal

`Tags: Devcenter, Environment, Deployment Environment, Azure Deployment Environment, ADE, ARM Template, Microsoft.DevCenter/devcenters`
