# Create a Logic App to send information on your backup and restore jobs via email

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-jobs-report/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-jobs-report/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-jobs-report/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-jobs-report/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-jobs-report/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-jobs-report/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-jobs-report%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-jobs-report%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-jobs-report%2Fazuredeploy.json)

This template deploys a Logic App that sends periodic reports on your backup and restore jobs to a specified set of email addresses. The Logic App runs a set of queries on a specified set of Log Analytics workspaces and exports the returned data as inline charts and CSV attachments.

You can use this template to view key information and trends on each of the backup and restore jobs that were triggered in your environment in the specified time range. You can get information on the number of failed jobs per day, top causes of job failure, as well as a detailed list of all the backup and restore jobs as a CSV attachment.

Following is the information that is exported by this Logic App:

* Inline
  * Jobs by Status over time
  * Jobs by Operation
  * Jobs by Failure Code
* Attachment
  * List of backup and restore jobs in selected time range

[Learn more](https://aka.ms/AzureBackupReportDoc) about Backup Reports
