# OMS monitoring solution for Azure Backup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-oms-monitoring/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-oms-monitoring/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-oms-monitoring/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-oms-monitoring/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-oms-monitoring/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-oms-monitoring/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-oms-monitoring%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-oms-monitoring%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-oms-monitoring%2Fazuredeploy.json)



This template deploys **OMS Monitoring solution for Azure backup** on an OMS log analytics workspace. This allows you to monitor key backup parameters such as backup and restore jobs, backup alerts and Cloud storage usage across Recovery services vaults

`Tags: Azure Backup, OMS Log Analytics, Monitoring`

## Prerequisites

You need to configure the OMS log analytics workspace to receive backup related data from Azure Recovery Services vaults. To do so, loggin into Azure portal –> Click “Monitor” service –> “Diagnostic settings” in Settings section –> Specify the relevant Subscription, Resource Group and Recovery Services Vault. In the Diagnostic settings window, as shown below, in addition to specifying a storage account, you can select “Send data to log analytics” and then select the relevant OMS workspace. You can choose any existing log analytics workspace such that all vaults pump the data to the same workspace

Please select the relevant log, “AzureBackupReport” in this case, to be sent to the log analytics workspace. Click “Save” to save the setting.

![alt text](images/DiagnosticSettings.JPG "Azure log analytics workspace diagnostic setting")
<br>

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-oms-monitoring%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-oms-monitoring%2Fazuredeploy.json)



<br>
## Solution overview and deployed resources

Upon deploying the solution, you would view an overview tile which reflects backup jobs and their status.

![alt text](images/OverviewTile.JPG "OMS Monitoring solution for Azure backup monitoring tile")

Clicking on the solution would let you explore Alerts, backups, restores, Cloud Storage and active data source details.

![alt text](images/KeyBackupJobsParameters.jpg "OMS Monitoring solution for Azure backup alerts, backups, restores")

![alt text](images/ActiveDatasources.png "OMS Monitoring solution for Azure backup active data sources distribution")

![alt text](images/CloudStorageInGB.png "OMS Monitoring solution for Azure backup cloud storage distribution")

You can click on each tile to get more details about the queries used to create it and you can configure it as per your requirement. Clicking further on values appearing in the tiles will lead you to Log analytics screen where you can raise alerts for configurable event thresholds and automate actions to be performed when those thresholds are met/crossed.

![alt text](images/LogAnalyticsScreen.JPG "OMS Monitoring solution for Azure backup Log search")

More information about configuring alerts can be found [here](https://docs.microsoft.com/azure/log-analytics/log-analytics-tutorial-response)


