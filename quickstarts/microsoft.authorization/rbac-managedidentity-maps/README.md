# RBAC - Grant Azure AD authorization access on Azure Maps for a Managed Identity

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/rbac-managedidentity-maps/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/rbac-managedidentity-maps/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/rbac-managedidentity-maps/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/rbac-managedidentity-maps/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/rbac-managedidentity-maps/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/rbac-managedidentity-maps/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Frbac-managedidentity-maps%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Frbac-managedidentity-maps%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Frbac-managedidentity-maps%2Fazuredeploy.json)

  

This template assigns Azure Maps Data Reader access for a Manaaged Identity on an Azure Maps account in a resource group. It **does not assign the identity** to an Azure resource such as `Azure App Service` or `Azure Virtual Machines`. Inputs to this template are following fields:

## Enable Service to Service authentication to Azure Maps

This template will grant a service principal access to Azure Maps. Using Azure Managed identity in your application code removes the complexity of managing credentials in a deployed Azure service. Running your application in an App Service or other Azure service which supports Managed Identity enables a restricted endpoint to retrieve access tokens for Service to Service authorization.

## Parameter #5: 'GUID' represent randomly generated GUID

These values should be unique per element as they represent the id of the role assignment. They can be generated any way you prefer.

## For Automation on role assignments you must assign 'User Access Administrator'

For automation scenarios without a user's principal, the built in role you must assign your automation is "User Access Adminstrator". This role with grant access to add and remove role assignments. The other option can be to create a [custom role definition](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles) with the permissions `Microsoft.Authorization/roleAssignments/write` and `Microsoft.Authorization/roleAssignments/delete`.


