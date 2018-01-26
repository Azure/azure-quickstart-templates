# This template enables enables encryption on a Linux Virtual Machine Scale Set

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-vmss-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-vmss-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template enables encryption on a running Virtual Machine Scale Set of Linux VMs.

AzureDiskEncryption for VMSS is currently in preview. Consuming this feature requires enabling the preview feature on the subscription and setting up a key vault with 'EnabledForDiskEncryption' access policy using the Azure powershell cmdlets below 
1. Register-AzureRmProviderFeature -FeatureName "UnifiedDiskEncryption" -ProviderNamespace "Microsoft.Compute"
2. Set-AzureRmKeyVaultAccessPolicy -ResourceGroupName <rgName> -VaultName <vaultName> -EnabledForDiskEncryption"

__Note: The VMSS encryption preview does not yet support image upgrade or reimage. Do not use this if you will need to upgrade your OS image in an encrypted scale set.__
