# Create a Logic App to send information on backup policy adherence via email

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-policyadherence-report/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-policyadherence-report/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-policyadherence-report/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-policyadherence-report/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-policyadherence-report/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-policyadherence-report/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-policyadherence-report%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-policyadherence-report%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-policyadherence-report%2Fazuredeploy.json)

This template deploys a Logic App that sends periodic reports on backup policy adherence to a specified set of email addresses. The Logic App runs a set of queries on a specified set of Log Analytics workspaces and exports the returned data as inline charts and CSV attachments.

The Policy Adherence views allow you to easily determine whether all your backup instances have had atleast one successful backup per day. There are 2 axes available for analysis:

### Policy Adherence by Time Period
Using this view, you can identify the number of backup instances that had atleast one successful backup per day on each day/week/month, as well as the number of backup instances which did not have one successful backup per day. Separate views are displayed for items with daily backup policy and items with weekly backup policy.

### Policy Adherence by Backup Instances
Using this view, you can identify the days/weeks on which each backup instance did not have a successful backup. A cell containing '0' indicates that the backup instance did not have a successful backup on that day/week (depending on whether the item is configured for daily backup/weekly backup), while a cell containing '1' indicates that the item had atleast one successful backup in that period. Separate views are displayed for items with daily backup policy, and items with weekly backup policy.

[Learn more](https://aka.ms/AzureBackupReportDoc) about Backup Reports
