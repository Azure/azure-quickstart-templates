---
description: This template will deploy a Microsoft Purview account to a new or existing resource group.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-purview-deployment
languages:
- json
- bicep
---
# Deploy Microsoft Purview account

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurepurview/azure-purview-deployment/BicepVersion.svg)


[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurepurview%2Fazure-purview-deployment%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurepurview%2Fazure-purview-deployment%2Fazuredeploy.json)

This template deploys a Microsoft Purview account using an Azure Resource Manager (ARM) template.

For more information about Microsoft Purview, [see our overview page](/azure/purview/overview). For more information about deploying Microsoft Purview across your organization, [see our deployment best practices](/azure/purview/deployment-best-practices).

## Prerequisites

* If you don't have an Azure subscription, create a [free subscription](https://azure.microsoft.com/free/) before you begin.

* An [Azure Active Directory tenant](../../active-directory/fundamentals/active-directory-access-create-new-tenant.md) associated with your subscription.

* The user account that you use to sign in to Azure must be a member  of the *contributor* or *owner* role, or an *administrator* of the Azure subscription. To view the permissions that you have in the subscription, go to the [Azure portal](https://portal.azure.com), select your username in the upper-right corner, select the "**...**" icon for more options, and then select **My permissions**. If you have access to multiple subscriptions, select the appropriate subscription.

* No [Azure Policies](/governance/policy/overview) preventing creation of **Storage accounts** or **Event Hub namespaces**. Microsoft Purview will deploy a managed Storage account and Event Hub when it is created. If a blocking policy exists and needs to remain in place, please follow our [Microsoft Purview exception tag guide](/azure/purview/create-azure-purview-portal-faq) and follow the steps to create an exception for Microsoft Purview accounts.

## Deploy a custom template

If your environment meets the prerequisites and you're familiar with using ARM templates, select the **Deploy to Azure** button at the top of the readme. The template will open in the Azure portal.
The template will deploy a Microsoft Purview account into a new or existing resource group in your subscription.

The following resources are defined in the template:

* Microsoft.Purview/accounts

The template performs the following tasks:

* Creates a Microsoft Purview account in the specified resource group.

## Open Microsoft Purview Studio

After your Microsoft Purview account is created, you'll use the Microsoft Purview Studio to access and manage it. There are two ways to open Microsoft Purview Studio:

* Open your Microsoft Purview account in the [Azure portal](https://portal.azure.com). Select the "Open Microsoft Purview Studio" tile on the overview page.
    :::image type="content" source="media/create-catalog-portal/open-purview-studio.png" alt-text="Screenshot showing the Microsoft Purview account overview page, with the Microsoft Purview Studio tile highlighted.":::

* Alternatively, you can browse to [https://web.purview.azure.com](https://web.purview.azure.com), select your Microsoft Purview account, and sign in to your workspace.

## Get started with your Purview resource

After deployment, the first activities are usually:

* [Create a collection](https://learn.microsoft.com/azure/purview/how-to-create-and-manage-collections)
* [Register a resource](https://learn.microsoft.com/azure/purview/microsoft-purview-connector-overview)
* [Scan the resource](https://learn.microsoft.com/azure/purview/concept-scans-and-ingestion)

`Tags: Microsoft.Purview/accounts, SystemAssigned`
