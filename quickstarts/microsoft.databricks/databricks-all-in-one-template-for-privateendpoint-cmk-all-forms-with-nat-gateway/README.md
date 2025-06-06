---
description: This template allows you to create an Azure Databricks workspace with PrivateEndpoint and managed services and CMK with DBFS encryption.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway
languages:
- json
---
# Deploy an Azure Databricks Workspace with PE,CMK all forms

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/BicepVersion.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-privateendpoint-cmk-all-forms-with-nat-gateway%2Fazuredeploy.json)


This template allows you to create a Azure Databricks workspace with privateendpoint and all three forms of customer managed keys (CMK). For more information, see the <a href="https://learn.microsoft.com/en-us/azure/databricks/security/keys/customer-managed-key-managed-services-azure"> Azure Databricks CMK Documentation.

`Tags: Microsoft.Databricks/workspaces, Microsoft.Resources/deployments, Microsoft.KeyVault/vaults/accessPolicies`
