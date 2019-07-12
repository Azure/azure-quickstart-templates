# Create Recovery Services Vault and Enable Diagnostics

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-create-vault-enable-diagnostics%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-create-vault-enable-diagnostics%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

### This template creates a Recovery Services Vault and enables diagnostics for Azure Backup.

A disaster recovery and data protection strategy keeps your business running when unexpected events occur.

The Backup service is Microsoft's born in the cloud backup solution to backup data that's located on-premises and in Azure. It replaces your existing on-premises or offsite backup solution with a reliable, secure and cost competitive cloud backup solution. It also provides the flexibility of protecting your assets running in the cloud. You can backup Windows Servers, Windows Clients, Hyper-V VMs, Microsoft workloads, Azure Virtual Machines (Windows and Linux) with its in-built resilience and high SLAs. [Learn more](http://aka.ms/backup-learn-more/).

To know more about Azure Backup Reporting feature refer [this documentation](https://docs.microsoft.com/en-us/azure/backup/backup-azure-configure-reports)

This template creates new storage account and oms workspace as part of deployment where diagnostic data gets pushed. If you want to use existing storage account and workspace, skip those resources from template and supply appropriate resource ids of existing storage account and oms workspace.