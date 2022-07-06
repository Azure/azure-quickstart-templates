---
description: This template shows how to create a budget under a subscription.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-budget-onefilter
languages:
- json
- bicep
---
# Create a Budget with Filter

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.consumption/create-budget-onefilter/BicepVersion.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.consumption%2Fcreate-budget-onefilter%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.consumption%2Fcreate-budget-onefilter%2Fazuredeploy.json)

This template shows how to create a budget to track cost or usage and get notified whenever a specified threshold is met. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/cost-management-billing/costs/quick-create-budget-template) article.

**Note** This feature is only available to enterprise customers. An enterprise subscription is required to create a budget.

For more information, see [Budgets - Create Or Update](https://docs.microsoft.com/rest/api/consumption/budgets/createorupdate).

## Important note about parameters

Before running the script, edit *azuredeploy.parameters.json* and replace the sample data.

- **Budget Name**: Name of the budget. It should be unique within the resource group.
- **Amount**: The total amount of cost or usage to track with the budget. Any decimal value is allowed.
- **Time Grain**: The time covered by a budget. Tracking of the amount will be reset based on the time grain. Allowed values are: _Monthly_, _Quarterly_, _Annually_.
- **Start Date**: The start date must be first of the month in `YYYY-MM-DD` format and should be less than the end date. Budget start date must be on or after June 1, 2017. Future start date shouldn't be more than three months. Past start date should be selected within the **Time Grain** period.
- **End Date**: Any date after the start date in in `YYYY-MM-DD` format.
- **First Threshold**: It's the first threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It's always percent and has to be between 0.01 and 1000.
- **Second Threshold**: It's the second threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It's always percent and has to be between 0.01 and 1000.
- **Contact Emails**: The list of email addresses to send the budget notification to when the threshold is exceeded. It accepts array of strings.
- **Contact Groups**: The list of action groups to send the budget notification to when the threshold is exceeded. It accepts array of strings.
- **Resource Groups Filter**: The list of filters on resource groups. It accepts array of strings. This should not be an empty array.

`Tags: Microsoft.Consumption/budgets`
