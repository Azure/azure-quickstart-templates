---
description: This template allows you to create an Azure Databricks workspace with Privateendpoint and all three forms of CMK.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk
languages:
- bicep
- json
---
# Deploy an Azure Databricks Workspace with privateendpoint, managed svc & CMK & DBFS encryption

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-all-3-forms-customer-managed-keys/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-workspace-with-vnet-privatendpoint-with-all-three-forms-cmk%2Fazuredeploy.json)

This template allows you to create a Azure Databricks workspace with privateendpoint and all three forms of customer managed keys (CMK). For more information, see the <a href="https://learn.microsoft.com/en-us/azure/databricks/security/keys/customer-managed-key-managed-services-azure"> Azure Databricks CMK Documentation.

`Tags: Microsoft.Databricks/workspaces, Microsoft.Resources/deployments, Microsoft.KeyVault/vaults/accessPolicies`
