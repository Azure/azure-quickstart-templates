---
description: Deploy UDR and NSG to support Azure SQL Managed Instance and deploy the Managed Instance 
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-sql-managed-instance
languages:
- json
---
# Deploy SQL Managed Instance with Networking

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azure-sql-managed-instance/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azure-sql-managed-instance/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azure-sql-managed-instance/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azure-sql-managed-instance/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azure-sql-managed-instance/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azure-sql-managed-instance/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fazure-sql-managed-instance%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fazure-sql-managed-instance%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fazure-sql-managed-instance%2Fazuredeploy.json)

**NOTE**: For the first instance in a subnet, deployment time is typically much longer than in the case of the subsequent instances and can take up to 6 hours to complete.

`Tags: Microsoft.Resources/deployments, Microsoft.Sql/managedInstances, SystemAssigned, Microsoft.Network/networkSecurityGroups, Microsoft.Network/routeTables, Microsoft.Network/virtualNetworks`
