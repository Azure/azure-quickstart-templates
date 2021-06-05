# Create a Logic App to send detailed reports on backups via email

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-all-tabs-report/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-all-tabs-report/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-all-tabs-report/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-all-tabs-report/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-all-tabs-report/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/backup-all-tabs-report/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-all-tabs-report%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-all-tabs-report%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fbackup-all-tabs-report%2Fazuredeploy.json)

This template deploys a Logic App that sends periodic reports on backups to a specified set of email addresses. The Logic App runs a set of queries on a specified set of Log Analytics workspaces and exports the returned data as inline charts and CSV attachments.

Following is the information that is exported by this Logic App:

## Summary
The Summary Views provide a high-level overview of your backup estate. You can get a quick glance of the total number of backup items, total cloud storageconsumed, the number of protected instances, and the job success rate for each backup solution used in your environment. For more detailed information about a specific backup artifact type, refer to the detailed views (described below).

## Backup Instances
The Backup Instances views allow you to see information and trends on backup cloud storage consumed by your backup instances. You can also view a detailed list of all your backup instances as a CSV attachment, which provides details on backup policy, storage replication type and backup cloud storage associated with each backup instance.

## Usage
The Usage views allow you to view key billing parameters for your backups. You can view trends on protected instance count and backup cloud storage consumed by each of your billing entities, as well as a detailed list of all your billing entities with information such as protected instance count, storage replication type and backup cloud storage associated with each billing entity.

## Jobs
The Jobs views allow you to view key information and trends on each of the backup and restore jobs that were triggered in your environment in the specified time range. You can get information on the number of failed jobs per day, top causes of job failure, as well as a detailed list of all the backup and restore jobs as a CSV attachment.

## Policies
The Policies views allow you to view information on all of your active policies, such as the number of associated items and the total cloud storage consumed by items backed up under a given policy.

## Optimize
The Optimize views allow you to gain visibility into potential cost-optimization opportunities for your backups. Following are the views available under this section:

### Inactive Resources
Using this view, you can identify those backup items that haven't had a successful backup for a significant duration of time. This could either mean that the underlying machine that's being backed up doesn't exist anymore (and so is resulting in failed backups), or there's some issue with the machine that's preventing backups from being taken reliably. Depending on your scenario, you can choose to either stop backup for the machine (if it doesn't exist anymore) and delete unnecessary backups, which saves costs, or you can fix issues in the machine to ensure that backups are taken reliably.

### Backup Items with a large retention duration
Using this view, you can identify those items that have backups retained for a longer duration than required by your organization. You can specify the threshold retention values as parameters to the template to view all backup instances with retentions larger than the specified thresholds.

### Databases configured for daily full backup
Using this view, you can identify database workloads that have been configured for daily full backup. Often, using daily differential backup along with weekly full backup is more cost-effective.

## Policy Adherence
The Policy Adherence views allow you to easily determine whether all your backup instances have had atleast one successful backup per day. There are 2 axes available for analysis:

### Policy Adherence by Time Period
Using this view, you can identify the number of backup instances that had atleast one successful backup per day on each day/week/month, as well as the number of backup instances which did not have one successful backup per day. Separate views are displayed for items with daily backup policy and items with weekly backup policy.

### Policy Adherence by Backup Instances
Using this view, you can identify the days/weeks on which each backup instance did not have a successful backup. A cell containing '0' indicates that the backup instance did not have a successful backup on that day/week (depending on whether the item is configured for daily backup/weekly backup), while a cell containing '1' indicates that the item had atleast one successful backup in that period. Separate views are displayed for items with daily backup policy, and items with weekly backup policy.

[Learn more](https://aka.ms/AzureBackupReportDoc) about Backup Reports
