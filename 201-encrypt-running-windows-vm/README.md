# Enable encryption on a running Windows VM. 

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template enables encryption on a running windows vm using AAD client secret. This template assumes that the VM is located in the same region as the resource group. If not, please edit the template to pass appropriate location for the VM sub-resources.

Prerequisites:
1. Azure Disk Encryption securely stores the encryption secrets in a specified Azure Key Vault. 
Use the below PS cmdlet for getting the "keyVaultSecretUrl" and "keyVaultResourceId"
Get-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $rgname 

Incase : If deployment fails with the the error code: Access Denied or conflict : extension not supported or VM has reported a failure when processing extension 'AzureDiskEncryption'. Error message: "Failed to configure bitlocker as expected; use the below PD cmdlet for removing the unsuccessful disk encryption extension and re-do the template deployment for success.
Remove-AzureRmVMExtension -ResourceGroupName $rgname -Name "extensionname" -VMName $vmname
Reference:  https://social.msdn.microsoft.com/Forums/SECURITY/en-US/f77af0b4-d06e-468a-816d-c894f08af125/error-user-encryption-settings-in-the-vm-model-are-not-supported-please-upgrade-azure-disk?forum=AzureDiskEncryption
https://blogs.msdn.microsoft.com/azuresecurity/2016/02/10/azure-disk-encryption-error-related-to-azure-powershell-1-1-0/


References:
White paper - https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/
http://blogs.msdn.com/b/azuresecurity/archive/2015/11/16/explore-azure-disk-encryption-with-azure-powershell.aspx
http://blogs.msdn.com/b/azuresecurity/archive/2015/11/21/explore-azure-disk-encryption-with-azure-powershell-part-2.aspx


