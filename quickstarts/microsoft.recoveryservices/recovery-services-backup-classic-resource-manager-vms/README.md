# Backup ARM and Classic IaaSVMs to Recovery Services Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-classic-resource-manager-vms/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-classic-resource-manager-vms/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-classic-resource-manager-vms/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-classic-resource-manager-vms/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-classic-resource-manager-vms/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-backup-classic-resource-manager-vms/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-backup-classic-resource-manager-vms%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-backup-classic-resource-manager-vms%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-backup-classic-resource-manager-vms%2Fazuredeploy.json) 

This template will use existing recovery services vault and policy, and enables protection of classic and ARM based IaaSVMs. VM and vault - both must be in same GEO.

To create new Recovery Services Vault, please use this existing template: [Create Recovery Services Vault] (https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-vault-create)

To create Recovery Services Vault and Weekly Backup Policy, please use this existing template: [Create Recovery Services Vault and Weekly Backup Policy] (https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-weekly-backup-policy-create)

To create Recovery Services Vault and Daily Backup Policy, please use this existing template: [Create Recovery Services Vault and Daily Backup Policy] (https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-daily-backup-policy-create)

For more information, Visit [Back up ARM VMs to a Recovery Services vault] (https://azure.microsoft.com/en-us/documentation/articles/backup-azure-vms-first-look-arm/)


