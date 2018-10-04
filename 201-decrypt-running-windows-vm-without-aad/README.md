# Disable encryption on a running Windows VM which was encrypted without using AAD app credentials

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-windows-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template disables encryption on a running windows VM which was encrypted without using AAD application.

Prerequisites: 
1. Register-AzureRmProviderFeature -ProviderNamespace "Microsoft.Compute" -FeatureName "UnifiedDiskEncryptionForVMs"
2. Wait 10 min till state transitions to 'Registered'
3. Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute

Tags: AzureDiskEncryption

References:
White paper - https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/

