# Deploy an action group to Azure 

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-action-groups/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-action-groups/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-action-groups/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-action-groups/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-action-groups/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-action-groups/CredScanResult.svg" />&nbsp;

This template deploys an [Action Group](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups) to Azure. An action group is a collection of notification preferences defined by the owner of an Azure subscription. Azure Monitor and Service Health alerts use action groups to notify users that an alert has been triggered.

Click the button below to deploy
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonitor-action-groups%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonitor-action-groups%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonitor-action-groups%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

Currently action groups support the following receivers: 
- Email Receivers
- SMS Receivers
- Webhook Receivers
- ITSM Receivers
- Azure App Push Receivers
- Azure Automation RunbookReceivers
- Voice Receivers
- Azure Logic App Receivers
- Azure Function Receivers
- Azure ARM Role Receivers

# Reference
- The latest template for Azure Action Groups can be found [here](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/2019-06-01/actiongroups)
- [Tutorial](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups-create-resource-manager-template) from Azure on how to create action groups via ARM template 
- [Introduction Video](https://azure.microsoft.com/en-us/resources/videos/azure-friday-azure-monitor-action-groups/)
- [Creating action group via Azure Portal](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups)

## Notes
`Tags: Azure Monitor, Azure Action Groups`