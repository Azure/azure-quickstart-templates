# Enable encryption on a running Windows VM. 

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm-without-aad/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm-without-aad/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm-without-aad/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm-without-aad/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm-without-aad/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-encrypt-running-windows-vm-without-aad/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template enables encryption on a running windows VM without needing an AAD application.

Prerequisites: Create a KeyVault in the same subscription and region as the VM and set EnabledForDiskEncryption access policy
1. Set-AzureRmKeyVaultAccessPolicy -ResourceGroupName <rgName> -VaultName <vaultName> -EnabledForDiskEncryption

Tags: AzureDiskEncryption

References:
White paper - https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/


