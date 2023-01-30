---
description: This template allows you to create an Azure Databricks workspace with managed services and CMK.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: databricks-workspace-with-managed-svc-customer-managed-keys
languages:
- json
---
# Deploy an Azure Databricks Workspace with managed svc & CMK

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-workspace-with-managed-svc-customer-managed-keys/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-workspace-with-managed-svc-customer-managed-keys%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-workspace-with-vnet-injection%2Fazuredeploy.json) 
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-workspace-with-managed-svc-customer-managed-keys%2Fazuredeploy.json)

This template allows you to create a Azure Databricks workspace with managed services and customer managed keys (CMK). For more information, see the <a href="https://learn.microsoft.com/en-us/azure/databricks/security/keys/customer-managed-key-managed-services-azure"> Azure Databricks CMK Documentation.

`Tags: Microsoft.Databricks/workspaces, Microsoft.Resources/deployments, Microsoft.KeyVault/vaults/accessPolicies`
