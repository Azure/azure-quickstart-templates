# This template enables encryption on a running VM Scale Set of Windows VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-vmss-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-vmss-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template enables encryption on a running VM Scale Set of Windows VMs.

__Note: The VMSS encryption preview does not yet support image upgrade or reimage. Do not use this if you will need to upgrade your OS image in an encrypted scale set.__

AzureDiskEncryption for VMSS is currently in preview. Consuming this feature requires enabling the preview feature on the subscription and setting up a key vault with 'EnabledForDiskEncryption' access policy using the Azure powershell cmdlets below 
1. Register-AzureRmProviderFeature -FeatureName "UnifiedDiskEncryption" -ProviderNamespace "Microsoft.Compute"
2. Wait 10 min till state transitions to 'Registered' . Confirm by running "Get-AzureRmProviderFeature -ProviderNamespace Microsoft.Compute -FeatureName UnifiedDiskEncryption"
3. Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute
4. Create a KeyVault in the same region and same subscription as the VMSS
5. Set-AzureRmKeyVaultAccessPolicy -ResourceGroupName <rgName> -VaultName <vaultName> -EnabledForDiskEncryption"


