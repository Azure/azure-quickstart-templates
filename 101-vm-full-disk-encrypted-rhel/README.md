# Deployment of RHEL 7.2 with full disk encryption

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-full-disk-encrypted-rhel%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-full-disk-encrypted-rhel%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a full-encrypted RHEL 7.2 VM in Azure. The VM consists of:

- 30 GB encrypted OS drive.
- A 2TB RAID0 array mounted at /mnt/raidencrypted.

## Prerequisites:

Azure Disk Encryption securely stores the encryption secrets in a specified Azure Key Vault. You will need client ID and client secret of an AAD application to enable key vault authentication.

The [AzureDiskEncryptionPreRequisiteSetup.ps1](https://github.com/Azure/azure-powershell/blob/dev/src/ResourceManager/Compute/Commands.Compute/Extension/AzureDiskEncryption/Scripts/AzureDiskEncryptionPreRequisiteSetup.ps1) script can be used to create the Key Vault and assign appropriate access policies.

Use the below PS cmdlet for getting the "keyVaultSecretUrl" and "keyVaultResourceId"

    Get-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $rgname

## Monitoring progress

It will take roughly 45 minutes to encrypt the OS drive. You can monitor the encryption progress by calling `Get-AzureRmVmDiskEncryptionStatus` PowerShell cmdlet as shown below.

    OsVolumeEncrypted          : EncryptionInProgress
    DataVolumesEncrypted       : NotMounted
    OsVolumeEncryptionSettings : Microsoft.Azure.Management.Compute.Models.DiskEncryptionSettings
    ProgressMessage            : OS disk encryption started

Once the cmdlet shows the message `VMRestartPending`, like the one show below, reboot the VM.

    C:\> Get-AzureRmVmDiskEncryptionStatus  -ResourceGroupName $ResourceGroupName -VMName $VMName
    -ExtensionName $ExtensionName
    
    OsVolumeEncrypted          : VMRestartPending
    DataVolumesEncrypted       : NotMounted
    OsVolumeEncryptionSettings : Microsoft.Azure.Management.Compute.Models.DiskEncryptionSettings
    ProgressMessage            : OS disk successfully encrypted, please reboot the VM

## References:

- [White paper](https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/)
- [Explore Azure Disk Encryption with Azure Powershell](https://blogs.msdn.microsoft.com/azuresecurity/2015/11/16/explore-azure-disk-encryption-with-azure-powershell/)
- [Explore Azure Disk Encryption with Azure PowerShell – Part 2](http://blogs.msdn.com/b/azuresecurity/archive/2015/11/21/explore-azure-disk-encryption-with-azure-powershell-part-2.aspx)
