# Create Budget to track cost or usage

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F2create-budget%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-budget%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template shows how to create a budget to track cost/usage and get notified whenever a specified threshold is met.

The accompanying PowerShell script shows how to create a resource group and budget under that resource group from the template. Before running the script, edit *azuredeploy.parameters.json* and replace the values marked with *'#####'* and *'YYYY-MM-DD'* and other sample data.

Note - This feature is available to enterprise customers only. You would require an enterprise subscription to create a budget.

See also:

- <a href="https://docs.microsoft.com/en-us/rest/api/consumption/budgets/createorupdatebyresourcegroupname">Create or update a Budget by resource group name</a> for details of the JSON elements relating to a budget.

