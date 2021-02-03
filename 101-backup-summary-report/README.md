# Create a Logic App to send Azure Backup summary reports via email

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-create-with-zones%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-create-with-zones%2Fazuredeploy.json)

This template deploys a Logic App that sends periodic summary reports on your Azure Backup resoures. The Logic App runs a set of queries on a specified set of Log Analytics workspaces and exports the returned data as inline charts and CSV attachments.

The Summary Views provide a high-level overview of your backup estate. You can get a quick glance of the total number of backup items, total cloud storageconsumed, the number of protected instances, and the job success rate for each backup solution used in your environment. For more detailed information about a specific backup artifact type, you can use the other sample ARM templates provided by Azure Backup which provide more detailed views.

[Learn more](https://aka.ms/AzureBackupReportDoc) about Backup Reports







