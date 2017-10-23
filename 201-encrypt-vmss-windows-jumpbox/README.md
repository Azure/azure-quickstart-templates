# This template deploys VM Scale Set of Windows VMs with a jumpbox and enables encryption on Windows VMSS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-vmss-windows-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-vmss-windows-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a simple VM Scale Set of Windows VMs using the latest patched version of serveral Windows versions. This template also deploys a jumpbox with a public IP address in the same virtual network. You can connect to the jumpbox via this public IP address, then connect from there to VMs in the scale set via private IP addresses.
This template enables encryption on the VM Scale Set of Windows VMs.

AzureDiskEncryption for VMSS is currently in preview. Consuming this feature requires enabling the preview feature on the subscription and setting up a key vault with 'EnabledForDiskEncryption' access policy using the Azure powershell cmdlets below 
1. Register-AzureRmProviderFeature -FeatureName "UnifiedDiskEncryption" -ProviderNamespace "Microsoft.Compute"
2. Set-AzureRmKeyVaultAccessPolicy -ResourceGroupName <rgName> -VaultName <vaultName> -EnabledForDiskEncryption"

__Note: The VMSS encryption preview does not yet support image upgrade or reimage. Do not use this if you will need to upgrade your OS image in an encrypted scale set.__

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.
