@description('Name of the Existing Recovery Services Vault (Vault and VM to be protected must be in same GEO)')
param existingRecoveryServicesVaultName string

@description('Array of iaasvm protection containers. This will take different input for classic and ARM vms. e.g. iaasvmcontainer;iaasvmcontainerv2;my-resource-group;my-arm-vm for ARM vm and iaasvmcontainer;iaasvmcontainer;my-classic-vm;my-classic-vm for classic vm')
param existingProtectionContainers array

@description('Array of iaasvm protectable items. This will take different input for classic and ARM vms. e.g. vm;iaasvmcontainerv2;my-resource-group;my-arm-vm for ARM vm and vm;iaasvmcontainer;my-classic-vm;my-classic-vm for classic vm')
param existingProtectableItems array

@description('Array of resourceid of iaasvm protectable items. Provide resourceids of each VMs for which you want to configure protection. e.g. /subscriptions/subscriptionid/resourceGroups/resourceGroupName/providers/Microsoft.Compute/virtualMachines/vmName')
param existingSourceResourceIds array

@description('Name of existing Backup Policy in same Recovery Services Vault.')
param existingBackupPolicyName string

@description('Location for all resources.')
param location string = resourceGroup().location

var backupFabric = 'Azure'
var protectedItemType = 'Microsoft.ClassicCompute/virtualMachines'

resource protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2016-06-01' = [for (item, i) in existingProtectableItems: {
  name: '${existingRecoveryServicesVaultName}/${backupFabric}/${existingProtectionContainers[i]}/${item}'
  location: location
  properties: {
    protectedItemType: protectedItemType
    policyId: resourceId('Microsoft.RecoveryServices/vaults/backupPolicies', existingRecoveryServicesVaultName, existingBackupPolicyName)
    sourceResourceId: existingSourceResourceIds[i]
  }
}]
