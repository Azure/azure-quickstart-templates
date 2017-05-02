# Backup Resource Manager VMs to Recovery Services Vault

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-backup-vms%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-backup-vms%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will use existing recovery services vault and backup policy, and enables backup of VMs belonging to same Resource Group. Recovery Services vault and VMs should be in same Geo. When selecting Resource Group to which this template needs to be deployed, please select Resource Group corresponding to the vault. 

To create new Recovery Services Vault, please use this existing template: [Create Recovery Services Vault] (https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-vault-create)

To create Recovery Services Vault and Weekly Backup Policy, please use this existing template: [Create Recovery Services Vault and Weekly Backup Policy] (https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-weekly-backup-policy-create)

To create Recovery Services Vault and Weekly Backup Policy, please use this existing template: [Create Recovery Services Vault and Daily Backup Policy] (https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-daily-backup-policy-create)

For more information, Visit [Back up Resource Manager VMs to a Recovery Services vault] https://docs.microsoft.com/azure/backup/backup-azure-vms-first-look-arm)
