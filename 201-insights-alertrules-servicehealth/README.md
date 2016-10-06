# Create an Azure service alert for a resource group 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-insights-alertrules-servicehealth%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-insights-alertrules-servicehealth%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to add an Azure service alert to a resource group. These are alerts about incidents affecting Azure services that may impact resources in the resource group. Such alerts are managed through the Azure Resource Manager Insights API.

There are 3 types of alert:
* Active
* InProgress
* Resolved
Each of them must be added separately.

It is an ARM template implementation of the [Create or update an alert rule](https://msdn.microsoft.com/en-us/library/azure/dn933805.aspx) operation in the Azure Resource Manager Insights API. The creation of these alerts in C# is described in this [post](https://code.msdn.microsoft.com/How-To-Setup-Email-Alerts-c26cdc55) by Matt Loflin.