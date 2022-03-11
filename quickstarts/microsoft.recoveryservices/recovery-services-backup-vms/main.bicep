@description('Resource group where the virtual machines are located. This can be different than resource group of the vault. ')
param existingVirtualMachinesResourceGroup string

@description('Array of Azure virtual machines. e.g. ["vm1","vm2","vm3"]')
param existingVirtualMachines array

@description('Name of the Recovery Services Vault')
param vaultName string = 'RecoveryServicesVault'

@description('Conditional parameter for New or Existing Vault')
param isNewVault bool = false

@description('Backup policy to be used to backup VMs. Backup POlicy defines the schedule of the backup and how long to retain backup copies. By default every vault comes with a \'DefaultPolicy\' which canbe used here.')
param existingBackupPolicy string = 'DefaultPolicy'

@description('Location for all resources.')
param location string = resourceGroup().location

var backupFabric = 'Azure'
var v2VmType = 'Microsoft.Compute/virtualMachines'
var v2VmContainer = 'iaasvmcontainer;iaasvmcontainerv2;'
var v2Vm = 'vm;iaasvmcontainerv2;'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2021-03-01' = if (isNewVault) {
  name: vaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource protetedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-03-01' = [for item in existingVirtualMachines: {
  name: '${vaultName}/${backupFabric}/${v2VmContainer}${existingVirtualMachinesResourceGroup};${item}/${v2Vm}${existingVirtualMachinesResourceGroup};${item}'
  location: location
  properties: {
    protectedItemType: v2VmType
    policyId: resourceId('Microsoft.RecoveryServices/vaults/backupPolicies', vaultName, existingBackupPolicy)
    sourceResourceId: resourceId(subscription().subscriptionId, existingVirtualMachinesResourceGroup, 'Microsoft.Compute/virtualMachines', item)
  }
  dependsOn: [
    recoveryServicesVault
  ]
}]