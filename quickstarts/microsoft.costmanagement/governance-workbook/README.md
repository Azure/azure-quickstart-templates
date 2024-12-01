---
description: This template creates a new Azure Monitor workbook for governance based on the Cloud Adoption Framework.
page_type: sample
products:
- azure
- azure-advisor
- azure-app-service
- azure-app-service-web
- azure-application-gateway
- azure-automation
- azure-backup
- azure-database-mysql
- azure-database-postgresql
- azure-functions
- azure-key-vault
- azure-load-balancer
- azure-logic-apps
- azure-policy
- azure-resource-manager
- azure-sql-database
- azure-sql-managed-instance
- azure-storage-accounts
- azure-virtual-machines
- azure-virtual-network
- azure-web-apps
- microsoft-defender
urlFragment: governance-workbook
languages:
- bicep
- json
---

# FinOps governance workbook

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/governance-workbook/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Fgovernance-workbook%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Fgovernance-workbook%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Fgovernance-workbook%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Fgovernance-workbook%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Fgovernance-workbook%2Fazuredeploy.json)

This template creates a new Azure Monitor workbook for **governance**.

The governance workbook is an Azure Monitor workbook that provides a comprehensive overview of the governance posture of your Azure environment. It includes the standard metrics aligned with the Cloud Adoption Framework for all disciplines and has the capability to identify and apply recommendations to address non-compliant resources.

To learn more about the governance workbook, the roadmap, or how to contribute, see [FinOps toolkit documentation](https://aka.ms/finops/toolkit).

<br>

## 📗 How to use this template

Once your workbook is deployed, you can use it by navigating to one of the following destinations:

1. From Azure Monitor:
   1. Select [**Workbooks**](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/workbooks) in the menu.
   2. Verify your subscription is selected in the **Subscription** filter.
   3. Select the **Governance** workbook.
2. From the resource group:
   1. Select the workbook resource.
   2. Select **Workbook** in the menu.
3. From [Azure workbooks](https://portal.azure.com/#browse/microsoft.insights%2Fworkbooks):
   1. Select the **Governance** workbook.
   2. Select **Workbook** in the menu.

> ℹ️ _**Pro tip:** If you navigate to the workbook resource (2 or 3 above), consider adding the workbook as a favorite using the star icon to the right of the resource name to make it easier to find in the future. Favorite resources can be opened directly from the Resources > Favorite section of the Azure portal default home page._

<br>

## 🧰 About the FinOps toolkit

The governance workbook is part of the [FinOps toolkit](https://aka.ms/finops/toolkit), an open source collection of FinOps solutions that help you manage and optimize your cost, usage, and carbon.

To contribute to the FinOps toolkit, [join us on GitHub](https://aka.ms/ftk).

<br>

`Tags: governance, finops, cost, optimization, Microsoft.Insights/workbooks`
