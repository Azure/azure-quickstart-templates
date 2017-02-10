# Deployment of RHEL 7.2 with full disk encryption

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-full-disk-encrypted-rhel-unmanaged%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-full-disk-encrypted-rhel-unmanaged%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-full-disk-encrypted-rhel-unmanaged%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a fully-encrypted RHEL 7.2 VM in Azure. The VM consists of:

- 30 GB encrypted OS drive.
- A 200 GB RAID-0 array mounted at `/mnt/raidencrypted`.

## Prerequisites:

Azure Disk Encryption securely stores the encryption secrets in a specified Azure Key Vault. You will need client ID and client secret of an AAD application to enable key vault authentication.

The [AzureDiskEncryptionPreRequisiteSetup.ps1](https://github.com/Azure/azure-powershell/blob/dev/src/ResourceManager/Compute/Commands.Compute/Extension/AzureDiskEncryption/Scripts/AzureDiskEncryptionPreRequisiteSetup.ps1) script can be used to create the Key Vault and assign appropriate access policies.

## Monitoring progress

It will take roughly one hour to encrypt the OS drive. You can monitor the encryption progress by calling `Get-AzureRmVmDiskEncryptionStatus` PowerShell cmdlet as shown below.

    C:\> Get-AzureRmVmDiskEncryptionStatus -ResourceGroupName $ResourceGroupName -VMName $VMName
    -ExtensionName $ExtensionName

    OsVolumeEncrypted          : EncryptionInProgress
    DataVolumesEncrypted       : EncryptionInProgress
    OsVolumeEncryptionSettings : Microsoft.Azure.Management.Compute.Models.DiskEncryptionSettings
    ProgressMessage            : OS disk encryption started

Once the cmdlet shows the message `VMRestartPending`, like the one show below, reboot the VM.

    C:\> Get-AzureRmVmDiskEncryptionStatus -ResourceGroupName $ResourceGroupName -VMName $VMName
    -ExtensionName $ExtensionName
    
    OsVolumeEncrypted          : VMRestartPending
    DataVolumesEncrypted       : Encrypted
    OsVolumeEncryptionSettings : Microsoft.Azure.Management.Compute.Models.DiskEncryptionSettings
    ProgressMessage            : OS disk successfully encrypted, please reboot the VM

After you reboot the VM, this will be the final layout:

    # lsblk
    NAME                                     MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
    fd0                                        2:0    1     4K  0 disk
    sda                                        8:0    0    30G  0 disk
    ├─sda1                                     8:1    0   500M  0 part
    └─sda2                                     8:2    0  29.5G  0 part
      └─osencrypt                            253:0    0  29.5G  0 crypt /
    sdb                                        8:16   0    14G  0 disk
    └─sdb1                                     8:17   0    14G  0 part  /mnt/resource
    sdc                                        8:32   0    48M  0 disk
    └─sdc1                                     8:33   0    47M  0 part
    sdd                                        8:48   0   100G  0 disk
    └─md0                                      9:0    0 199.9G  0 raid0
      └─a717a295-61e2-4de9-9b27-689f3f6d5831 253:1    0 199.9G  0 crypt /mnt/encryptedraid
    sde                                        8:64   0   100G  0 disk
    └─md0                                      9:0    0 199.9G  0 raid0
      └─a717a295-61e2-4de9-9b27-689f3f6d5831 253:1    0 199.9G  0 crypt /mnt/encryptedraid

`/` will be mounted mounted from a AES-256 bit encrypted drive:

    # cryptsetup status osencrypt
    /dev/mapper/osencrypt is active and is in use.
      type:    n/a
      cipher:  aes-xts-plain64
      keysize: 256 bits
      device:  /dev/sda2
      offset:  0 sectors
      size:    61888512 sectors
      mode:    read/write

While `/mnt/encryptedraid` will point to the 200 GB RAID array:

    # df -h
    Filesystem             Size  Used Avail Use% Mounted on
    /dev/mapper/osencrypt   30G  1.8G   28G   6% /
    devtmpfs               3.4G     0  3.4G   0% /dev
    tmpfs                  3.5G     0  3.5G   0% /dev/shm
    tmpfs                  3.5G  8.3M  3.4G   1% /run
    tmpfs                  3.5G     0  3.5G   0% /sys/fs/cgroup
    /dev/sdb1               14G  2.1G   11G  16% /mnt/resource
    tmpfs                  697M     0  697M   0% /run/user/1000
    /dev/dm-1              197G   61M  187G   1% /mnt/encryptedraid

If you run the `Get-AzureRmVmDiskEncryptionStatus` cmdlet again, you will see updated encryption status:

    C:\> Get-AzureRmVmDiskEncryptionStatus -ResourceGroupName $ResourceGroupName -VMName $VMName
    -ExtensionName $ExtensionName

    OsVolumeEncrypted          : Encrypted
    DataVolumesEncrypted       : Encrypted
    OsVolumeEncryptionSettings : Microsoft.Azure.Management.Compute.Models.DiskEncryptionSettings
    ProgressMessage            : [KeyVault URL of LUKS passphrase secret]

## References:

- [White paper](https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/)
- [Explore Azure Disk Encryption with Azure Powershell](https://blogs.msdn.microsoft.com/azuresecurity/2015/11/16/explore-azure-disk-encryption-with-azure-powershell/)
- [Explore Azure Disk Encryption with Azure PowerShell – Part 2](http://blogs.msdn.com/b/azuresecurity/archive/2015/11/21/explore-azure-disk-encryption-with-azure-powershell-part-2.aspx)
