# Backup Azure File Share to Recovery Services Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-file-share/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-file-share/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-file-share/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-file-share/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-file-share/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-file-share/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-backup-file-share%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-backup-file-share%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-backup-file-share%2Fazuredeploy.json)

This template configures protection for an existing Azure file share by specifying appropriate details for the Recovery Services vault and backup policy. It optionally creates a new Recovery Services vault and backup policy, and registers the storage account containing the file share to the Recovery Services vault.

## Overview and deployed resources

The following resources are deployed as part of the solution.

### Microsoft.RecoveryServices

The Microsoft.RecoveryServices resource provider is used to create resources of the following types.

+ **Vault**: A Recovery Services vault to which the file share backup takes place. (If using an existing vault, new vault creation can be disabled by setting the ``isNewVault`` parameter to ``false``).
+ **Backup policy**: A backup policy associated with the vault that specifies the backup schedule and the retention range. (If using an existing backup policy, new backup policy creation can be disabled by setting the ``isNewPolicy`` parameter to ``false``).
+ **Protection container**: A logical container for backup associated with the storage account containing the file share that is created while registering to the vault. (If storage account is already registered to the vault, registration can be skipped by setting the ``registerStorageAccount`` parameter to ``false``).
+ **Protected item**: The protected item corresponding to the file share created after configure protection has completed.

## Prerequisites

Users need to have an existing storage account with an existing file share present in it. For creating a new storage account and file share, use the template provided in the prereqs folder, or refer to the [create an Azure storage account with file share](https://github.com/Azure/azure-quickstart-templates/tree/master/101-storage-file-share) template.

## Deployment steps

You can click the **Deploy to Azure** button at the beginning of this document. You may alternatively download the template and [deploy it using PowerShell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell#deploy-local-template) or use your preferred method of ARM template deployment.

`Tags: file share, backup, recovery services, configure protection`
