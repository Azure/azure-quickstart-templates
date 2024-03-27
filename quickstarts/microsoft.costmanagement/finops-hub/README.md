---
description: This template creates a new FinOps hub instance, including Data Lake storage and a Data Factory.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: finops-hub
languages:
- bicep
- json
---
# FinOps hub

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2Fazuredeploy.json)

This template creates a new **FinOps hub** instance. FinOps hubs are a foundation you can use to build homegrown cost management and optimization solutions.

FinOps hubs include:

- Data Lake storage to host cost data.
- Data Factory for data processing and orchestration.
- Key Vault for storing secrets.

To learn more about FinOps hubs, the roadmap, or how to contribute , see [FinOps hubs documentation](https://aka.ms/finops/hubs).

<br>

## 📋 Prerequisites

Please ensure the following prerequisites are met before deploying this template:

1. You must have permission to create the deployed resources mentioned above.
2. The Microsoft.EventGrid resource provider must be registered in your subscription. See [Register a resource provider](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider) for details.
   > ⚠️ _If you forget this step, the deployment will succeed, but the data will not be ready. To fix, register the EventGrid RP, start the `msexports` pipeline trigger, re-run your Cost Management export, wait ~20 minutes, and refresh the data in your reports or custom tools._

To use FinOps hubs, you can either leverage the available Power BI reports or connect directly to the included storage account. To learn more, see [FinOps hubs documentation](https://aka.ms/finops/hubs).

If you run into any issues, see [Troubleshooting FinOps hubs](https://aka.ms/finops/hubs/troubleshoot).

<br>

## 📗 How to use this template

1. Register the Microsoft.EventGrid and Microsoft.CostManagementExports resource providers
   > See [Register a resource provider](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider) for details.
2. Deploy the template
   > [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2FcreateUiDefinition.json) &nbsp; [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-hub%2FcreateUiDefinition.json)
3. [Create a new cost export](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal) using the following settings:
   - **Metric** = `Amortized cost`
   - **Export type** = `Daily export of month-to-date costs`
   - **File partitioning** = On
   - **Overwrite data** = Off
     <blockquote class="note" markdown="1">
       _While most settings are required, overwriting is optional. We recommend **not** overwriting files so you can monitor your ingestion pipeline using the [Data ingestion](https://aka.ms/ftk/DataIngestion) report. If you do not plan to use that report, please enable overwriting._
     </blockquote>
   - **Storage account** = (Use subscription/resource from step 1)
   - **Container** = `msexports`
   - **Directory** = (Use the resource ID of the scope<sup>1</sup> you're exporting without the first "/")
4. Run your export using the **Run now** command
   > Your data should be available within 15 minutes or so, depending on how big your account is.
5. Connect to the data in Azure Data Lake Storage
   > Consider using [available Power BI reports](https://aka.ms/finops/hubs/reports)

If you run into any issues, see [Troubleshooting FinOps hubs](https://aka.ms/finops/hubs/troubleshoot).

_<sup>1) A "scope" is an Azure construct that contains resources or enables purchasing services, like a resource group, subscription, management group, or billing account. The resource ID for a scope will be the Azure Resource Manager URI that identifies the scope (e.g., "/subscriptions/###" for a subscription or "/providers/Microsoft.Billing/billingAccounts/###" for a billing account). To learn more, see [Understand and work with scopes](https://aka.ms/costmgmt/scopes).</sup>_

<br>

## 🧰 About the FinOps toolkit

FinOps hubs are part of the [FinOps toolkit](https://aka.ms/finops/toolkit), an open-source collection of FinOps solutions that help you manage and optimize your cloud costs.

To contribute to the FinOps toolkit, [join us on GitHub](https://aka.ms/ftk).

<br>

`Tags: finops, cost, Microsoft.CostManagement/exports, Microsoft.Storage/storageAccounts, Microsoft.DataFactory/factories`
