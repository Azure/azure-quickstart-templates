---
description: This template creates Recovery service vault and a Daily Backup Policy that can be used to protect classic and ARM based IaaS VMs.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: recovery-services-weekly-backup-policy-create
languages:
- json
- bicep
---
# Create Weekly Backup Policy for RS Vault to protect IaaSVMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-weekly-backup-policy-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-weekly-backup-policy-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-weekly-backup-policy-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-weekly-backup-policy-create%2Fazuredeploy.json)

This template creates Recovery Services Vault and Backup Policy (Weekly Schedule) for Recovery Services Vault which can be used further to protect classic and ARM based Azure IaaS VMs

To create new Recovery Services Vault, please use this template: [Create Recovery Services Vault](https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-vault-create)

To create new Daily Backup Policy, please use this template: [Create Daily Backup Policy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-daily-backup-policy-create)

For more information, Visit [Back up ARM VMs to a Recovery Services vault](https://azure.microsoft.com/documentation/articles/backup-azure-vms-first-look-arm/)

`Tags: Microsoft.RecoveryServices/vaults, Microsoft.RecoveryServices/vaults/backupPolicies`
