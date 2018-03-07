# Create a simple windows VM and configure backup

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-create-vm-and-configure-backup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-create-vm-and-configure-backup%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy simple Windows VM and Recovery Services Vault configured with the DefaultPolicy for Protection.

To create a new Recovery Services Vault, use this existing template: [Create Recovery Services Vault](https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-vault-create)

To create a Recovery Services Vault with a Weekly Backup Policy, use this existing template: [Create Recovery Services Vault and Weekly Backup Policy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-weekly-backup-policy-create)

To create a Recovery Services Vault with a Daily Backup Policy, use this existing template: [Create Recovery Services Vault and Daily Backup Policy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-recovery-services-daily-backup-policy-create)

For more information, visit [Back up Resource Manager VMs to a Recovery Services vault](https://docs.microsoft.com/azure/backup/backup-azure-vms-first-look-arm)

Refer to this [feature announcement blog post](https://azure.microsoft.com/en-us/blog/backup-create-vm-integration/) to create VM and configure backup via Azure Portal.
