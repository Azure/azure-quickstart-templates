# Deploy Azure Purview with Azure Resource Manager (ARM)

This template deploys an Azure Purview account using an Azure Resource Manager (ARM) template.

For more information about Azure Purview, [see our overview page](/azure/purview/overview). For more information about deploying Azure Purview across your organization, [see our deployment best practices](/azure/purview/deployment-best-practices).

## Prerequisites

* If you don't have an Azure subscription, create a [free subscription](https://azure.microsoft.com/free/) before you begin.

* An [Azure Active Directory tenant](../../active-directory/fundamentals/active-directory-access-create-new-tenant.md) associated with your subscription.

* The user account that you use to sign in to Azure must be a member  of the *contributor* or *owner* role, or an *administrator* of the Azure subscription. To view the permissions that you have in the subscription, go to the [Azure portal](https://portal.azure.com), select your username in the upper-right corner, select the "**...**" icon for more options, and then select **My permissions**. If you have access to multiple subscriptions, select the appropriate subscription.

* No [Azure Policies](/governance/policy/overview) preventing creation of **Storage accounts** or **Event Hub namespaces**. Azure Purview will deploy a managed Storage account and Event Hub when it is created. If a blocking policy exists and needs to remain in place, please follow our [Azure Purview exception tag guide](/azure/purview/create-azure-purview-portal-faq) and follow the steps to create an exception for Azure Purview accounts.

## Deploy a custom template

If your environment meets the prerequisites and you're familiar with using ARM templates, select the **Deploy to Azure** button. The template will open in the Azure portal.
The template will deploy an Azure Purview account into a new or existing resource group in your subscription.

[![Deploy to Azure](../media/template-deployments/deploy-to-azure.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurepurview%2Fazure-purview-deployment%2Fazuredeploy.json)

The following resources are defined in the template:

* Microsoft.Purview/accounts

The template performs the following tasks:

* Creates an Azure Purview account in the specified resource group.

## Open Azure Purview Studio

After your Azure Purview account is created, you'll use the Azure Purview Studio to access and manage it. There are two ways to open Azure Purview Studio:

* Open your Azure Purview account in the [Azure portal](https://portal.azure.com). Select the "Open Azure Purview Studio" tile on the overview page.
    :::image type="content" source="media/create-catalog-portal/open-purview-studio.png" alt-text="Screenshot showing the Azure Purview account overview page, with the Azure Purview Studio tile highlighted.":::

* Alternatively, you can browse to [https://web.purview.azure.com](https://web.purview.azure.com), select your Azure Purview account, and sign in to your workspace.

## Get started with your Purview resource

After deployment, the first activities are usually:

* Create a collection
* Register a resource
* Scan the resource

At this time, these actions aren't able to be taken through an Azure Resource Manager template. Follow the guides above to get started!

## Clean up resources

To clean up the resources deployed in this quickstart, delete the resource group, which deletes the resources in the resource group.
You can do this either through the Azure portal, or using the PowerShell script below.

```azurepowershell-interactive
$resourceGroupName = Read-Host -Prompt "Enter the resource group name"
Remove-AzResourceGroup -Name $resourceGroupName
Write-Host "Press [ENTER] to continue..."
```
