# Create Budget to Track Cost or Usage

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-budget/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-budget/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-budget/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-budget/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-budget/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-budget/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-budget%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-budget%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-budget%2Fazuredeploy.json)

This template creates a budget (email notifications for up to three thresholds).

## Parameters :
- Budget Name: Name of the budget (Unique within the resource group).
- Budget Amount: The amount of cost or usage that is equivalent to 100%.
- Time Span: The timespan for the tracked budget (Monthly, Quarterly, Annually).
- Start Date: The start date must be first of the month in YYYY-MM-DD format and should be less than the end date.
- End Date: The end date in YYYY-MM-DD format.
- First Threshold: The first triggering threshold for the tracked budget (for example 50 (for 50%)).
- Second Threshold: The second triggering threshold for the tracked budget (for example 75 (for 75%)).
- Thirds Threshold: The third triggering threshold for the tracked budget (for example 90 (for 90%)).
- Contact Roles: The roles that should receive the threshold alert or notification.
- Contact Emails: The email addresses that should receive the threshold alert or notification.
- Contact Groups: The action groups that will process the budget notification.

See also : 
[Tutorial: Create and manage Azure budgets.](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)


> PS : The contributor role is required at the Subscription Level when deploying this template.
