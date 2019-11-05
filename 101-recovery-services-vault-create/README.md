# Create Recovery Services Vault

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-recovery-services-vault-create/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-recovery-services-vault-create/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-recovery-services-vault-create/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-recovery-services-vault-create/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-recovery-services-vault-create/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-recovery-services-vault-create/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-vault-create%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-recovery-services-vault-create%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

### This template creates a Recovery Services Vault which will be used further for Backup and SiteRecovery.

A disaster recovery and data protection strategy keeps your business running when unexpected events occur.

The Backup service is Microsoft's born in the cloud backup solution to backup data that's located on-premises and in Azure. It replaces your existing on-premises or offsite backup solution with a reliable, secure and cost competitive cloud backup solution. It also provides the flexibility of protecting your assets running in the cloud. You can backup Windows Servers, Windows Clients, Hyper-V VMs, Microsoft workloads, Azure Virtual Machines (Windows and Linux) with its in-built resilience and high SLAs. [Learn more](http://aka.ms/backup-learn-more/).

The Site Recovery service ensures your servers, virtual machines, and apps are resilient by replicating them so that when disasters and outages occur you can easily fail over to your replicated environment and continue working. When services are resumed you simply failback to your primary location with uninterrupted access. Site Recovery helps protect a wide range of Microsoft and third-party workloads. [Learn more](http://aka.ms/asr-learn-more/).

#### Storage Type Selection
A Recovery Services vault can only change storage options before any backups have been configured. Once any backup is configured, the storage type cannot be changed. Hence use the conditional parameter to opt-in or opt-out change the storage type [Learn more](https://docs.microsoft.com/en-us/azure/backup/backup-azure-backup-faq#can-i-change-from-grs-to-lrs-after-a-backup)

