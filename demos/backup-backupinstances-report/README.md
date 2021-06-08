# Create a Logic App to send information on backup instances protected using Azure Backup via email

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-backupinstances-report/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-backupinstances-report/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-backupinstances-report/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-backupinstances-report/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-backupinstances-report/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-backupinstances-report/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-backupinstances-report%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-backupinstances-report%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-backupinstances-report%2Fazuredeploy.json)

This template deploys a Logic App that sends periodic reports on backup instances to a specified set of email addresses. The Logic App runs a set of queries on a specified set of Log Analytics workspaces and exports the returned data as inline charts and CSV attachments.

Following is the information that is exported by this Logic App:

1. Inline 
a. Trend of Backup Instances count over time 
b. Trend of Backup Cloud Storage (GB) over time

2. Attachment
List of all backup instances with details on policy, backup storage consumed, storage replication type etc. 

[Learn more](https://aka.ms/AzureBackupReportDoc) about Backup Reports

## Prerequisites

This template needs an existing LogAnalytics workspace to query.







