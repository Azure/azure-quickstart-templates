---
description: This template provisions a basic Logic App preconfigured with the necessary authorization policy settings and HTTP trigger schema required by the Entitlement Management custom extension API for handling access package assignments.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp
languages:
- json
---
# Deploy a sample logic app, to use as Entitlement Management custom extensions

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/identitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp/CredScanResult.svg)

 [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fidentitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fidentitygovernance-entitlementmanagement-extensibility-AccessPackageAssignment-sample-logicapp%2Fazuredeploy.json)

This template provisions a basic Logic App preconfigured with the necessary authorization policy settings and HTTP trigger schema required by the Entitlement Management custom extension API for handling access package assignments.

Below are the parameters that the template expects.

| Name   | Description    |
|:--- |:---|
| logic_app_name  | Name for the logic app. |
| catalogId  | CatalogId of the Azure AD entitlement management catalog, where you are going to use this logic app.  |

Then, the arm template will achieve the following:
 * Create a logic app
 * Add authorization policy settings to verify Entitlement Management call
 * Policy setting has the Entitlement Management first party appid (810dcf14-1858-4bf2-8134-4c369fa3235b), to verify that it is Entitlement Management which is calling this logic app.
 * And finally, adds schema to http trigger to match the message schema that is used by Entitlement Management

`Tags: Microsoft.Logic/workflows, Request, object, string, If, AAD`
