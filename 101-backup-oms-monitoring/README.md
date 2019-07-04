# OMS monitoring solution for Azure Backup

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-backup-oms-monitoring%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-backup-oms-monitoring%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys **OMS Monitoring and Reporting solution for Azure backup** on a Log Analytics workspace. This allows you to monitor key backup parameters such as backup and restore jobs, backup alerts and Cloud storage usage across Recovery services vaults

`Tags: Azure Backup, OMS Log Analytics, Monitoring`

> [!IMPORTANT]
> This is an updated, multi-view template for LA-based Monitoring and Reporting in Azure Backup. Users who were using our earlier solution are required to deploy the new template by clicking the 'Deploy to Azure' button above. Please note that users who were using the earlier solution (titled 'Azure Backup Monitoring Solution') will continue to see it in their workspaces even after deploying the new solution. However, the old solution may provide inaccurate results due to some minor schema changes in the backend. **Users are hence advised to deploy the new template and explicitly delete the 'Azure Backup Monitoring Solution' view from their workspaces**.

## Prerequisites

You need to configure the OMS log analytics workspace to receive backup related data from Azure Recovery Services vaults. To do so, login into Azure portal –> Click “Monitor” service –> “Diagnostic settings” in Settings section –> Specify the relevant Subscription, Resource Group and Recovery Services Vault. In the Diagnostic settings window, as shown below, in addition to specifying a storage account, you can select “Send data to log analytics” and then select the relevant OMS workspace. You can choose any existing log analytics workspace such that all vaults pump the data to the same workspace

Please select the relevant log, “AzureBackupReport” in this case, to be sent to the log analytics workspace. Click “Save” to save the setting.

![alt text](images/DiagnosticSettings.JPG "Azure log analytics workspace diagnostic setting")
<br>




<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-backup-oms-monitoring%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-backup-oms-monitoring%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>


## Solution overview and deployed resources

Upon deploying the solution, you would view an overview tile which reflects backup jobs and their status.

![alt text](images/la-azurebackup-overview.png "OMS Monitoring and Reporting solution for Azure Backup overview blade")

Clicking on the solution would let you explore Alerts, Backups, Restores, Cloud Storage and Active Data source details.

![alt text](images/la-azurebackup-alertsazure.png "OMS Monitoring and Reporting solution for Azure Backup alerts")

![alt text](images/la-azurebackup-backupjobsnonlog.png "OMS Monitoring and Reporting solution for Azure Backup non log jobs")


You can click on each tile to get more details about the queries used to create it and you can configure it as per your requirement. Clicking further on values appearing in the tiles will lead you to Log analytics screen where you can raise alerts for configurable event thresholds and automate actions to be performed when those thresholds are met/crossed.

![alt text](images/LogAnalyticsScreen.JPG "OMS Monitoring solution for Azure backup Log search")

More information about configuring alerts can be found [here](https://docs.microsoft.com/azure/log-analytics/log-analytics-tutorial-response)
