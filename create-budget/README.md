# Create Budget to Track Cost or Usage

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-budget/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-budget/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-budget/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-budget/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-budget/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/create-budget/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-budget%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-budget%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template shows how to create a budget to track cost/usage and get notified whenever a specified threshold is met.

Note - This feature is available to enterprise customers only. You would require an enterprise subscription to create a budget.

See also:

- <a href="https://docs.microsoft.com/en-us/rest/api/consumption/budgets/createorupdatebyresourcegroupname">Create or update a Budget by resource group name</a> for details of the JSON elements relating to a budget.

## Important note about parameters:

Before running the script, edit *azuredeploy.parameters.json* and replace the sample data. 

* Budget Name: Name of the Budget. It should be unique within the resource group.

* Amount: The total amount of cost or usage to track with the budget. Any decimal value is allowed.

* Budget Category: The category of the budget, whether the budget tracks cost or usage. Allowed values are "Cost" or "Usage".

* Time Grain: The time covered by a budget. Tracking of the amount will be reset based on the time grain. Allowed values are "Monthly", "Quarterly", "Annually".

* Start Date: The start date must be first of the month in YYYY-MM-DD format and should be less than the end date. Budget start date must be on or after June 1, 2017. Future start date should not be more than three months. Past start date should be selected within the timegrain preiod.

* End Date: Any date after the start date in in YYYY-MM-DD format.

* Operator: The comparison operator. Allowed values are "EqualTo", "GreaterThan", "GreaterThanOrEqualTo".

* Threshold: It is the threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000.

* Contact Emails: The list of email addresses to send the budget notification to when the threshold is exceeded. It accepts array of strings.

* Contact Roles: The list of contact roles to send the budget notification to when the threshold is exceeded. It accepts array of strings.

* Contact Groups: The list of action groups to send the budget notification to when the threshold is exceeded. It accepts array of strings.

* Resources Filter: The list of filters on resources. It accepts array of strings.

* Meters Filter: The list of filters on meters, mandatory for budgets of usage category. It accepts array of strings.



