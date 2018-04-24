# Enable encryption on a running Windows VM. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template enables encryption on a running windows VM without needing AAD application. This template assumes that the VM is located in the same region as the resource group. If not, please edit the template to pass appropriate location for the VM sub-resources.

Prerequisites:
1. Azure Disk Encryption securely stores the encryption secrets in a specified Azure Key Vault. Create a KeyVault in the same subscription and same region as the VM.Use the below PS cmdlet for getting the "keyVaultSecretUrl" and "keyVaultResourceId"
    Get-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $rgname
2. Enable AzureDiskEncryption without AAD feature for your subscription
    Register-AzureRmProviderFeature -ProviderNamespace "Microsoft.Compute" -FeatureName  "UnifiedDiskEncryptionForVMs"
    Wait 10 min till state transitions to 'Registered'
    Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute

Tags: AzureDiskEncryption

References:
White paper - https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/

