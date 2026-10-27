targetScope = 'subscription'

param accountKind string = 'StorageV2'
param accountType string = ''
param accessTier string = 'Hot'
param containers array = []
param dnsZoneResourceGroupId string = ''
@allowed([
  true
])
param httpsRequired bool = true
param isHnsEnabled bool = false
param largeFileSharesState string = 'Disabled'
param keyName string = ''
param keyVaultId string = ''
param keyVaultUseExisting bool = true
param newKeyVaultName string = ''
param kind string = ''
param location string = 'usgovarizona'
param newWorkloadName string = 'placeholder'
param primaryService string = ''
param replicationStrategy string = 'Standard_LRS'
param saName string = ''
param storageAccountName string
param subnetName string
param tagsByResource object = {}
param umiId string = ''
param umiUseExisting bool = true
param newUmiName string = ''
param existingKeyVaultRoleAssignmentName string = ''
param vnetName string
param vnetRG string
param workloadId string = 'placeholder'
param workloadResourceGroup string
param virtualEnclaveResourceId string = ''
param workloadUseExisting bool
param workloadResourceGroupUseExisting bool
param existingWorkloadTags object = {}
param deploymentid string = substring(uniqueString(utcNow()), 0, 6)
param existingBlobManagedResourceGroupPrivateDnsZone string = ''
param existingFileManagedResourceGroupPrivateDnsZone string = ''
param existingQueueManagedResourceGroupPrivateDnsZone string = ''
param existingTableManagedResourceGroupPrivateDnsZone string = ''
param existingDfsManagedResourceGroupPrivateDnsZone string = ''
param manuallySelectedBlobDnsZone string = ''
param manuallySelectedFileDnsZone string = ''
param manuallySelectedQueueDnsZone string = ''
param manuallySelectedTableDnsZone string = ''
param manuallySelectedDfsDnsZone string = ''

param existingKeyVaultManagedResourceGroupPrivateDnsZone string = ''
param newKeyVaultDnsZoneResourceGroupToCreateIn string = ''
//param enablePurgeProtection bool = true

param privateDnsRegistrationType string = ''
param newDnsZoneResourceGroupToCreateIn string = ''
@allowed([
  'AzureServices'
])
param bypass string = 'AzureServices'
param logAnalyticsWorkspaceId string = ''
param enableTelemetry bool = true
param isMsisrTenant bool = false
param isPlxTenant bool = false

var effectiveAccountKind = empty(kind) ? accountKind : kind
var effectiveReplicationStrategy = empty(accountType) ? replicationStrategy : accountType
var effectiveStorageAccountName = empty(saName) ? storageAccountName : saName
var effectiveBypass = empty(bypass) ? 'AzureServices' : bypass

var safeKeyVaultId = empty(keyVaultId) ? '/subscriptions/sub/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv' : keyVaultId
var keyVaultSubscriptionId = keyVaultUseExisting ? split(safeKeyVaultId, '/')[2] : subscription().subscriptionId
var keyVaultResourceGroup = keyVaultUseExisting ? split(safeKeyVaultId, '/')[4] : workloadResourceGroup
var keyVaultName = keyVaultUseExisting ? split(safeKeyVaultId, '/')[8] : newKeyVaultName
var safeUmiId = empty(umiId) ? '/subscriptions/sub/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/umi' : umiId
var umiSubscriptionId = umiUseExisting ? split(safeUmiId, '/')[2] : subscription().subscriptionId
var umiResourceGroup = umiUseExisting ? split(safeUmiId, '/')[4] : workloadResourceGroup
var umiName = umiUseExisting ? split(safeUmiId, '/')[8] : newUmiName
var assignKeyVaultRole = !keyVaultUseExisting || !umiUseExisting

var privateLinkDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}' // Azure Blobs
var effectiveNewDnsZoneResourceGroupToCreateIn = isPlxTenant && !isMsisrTenant && !empty(virtualEnclaveResourceId) ? vnetRG : newDnsZoneResourceGroupToCreateIn
var effectiveNewKeyVaultDnsZoneResourceGroupToCreateIn = isPlxTenant && !isMsisrTenant && !empty(virtualEnclaveResourceId) ? vnetRG : newKeyVaultDnsZoneResourceGroupToCreateIn
var privateLinkFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}' // Azure Files
var privateLinkQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}' // Azure Queues
var privateLinkTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}' // Azure Tables
var privateLinkDfsDnsZoneName = 'privatelink.dfs.${environment().suffixes.storage}' // Azure Data Lake Storage

var privateLinkKeyVaultDnsZoneName = 'privatelink${replace(environment().suffixes.keyvaultDns, 'vault', 'vaultcore')}' // Key Vault

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

module resourceGroupTagsModule './resourceGroupTags.bicep' = if (contains(tagsByResource, 'Microsoft.Resources/resourceGroups')) {
  name: 'resourceGroupTags-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  dependsOn: [
    workloadRg
    workloadRgModule
  ]
  params: {
    tags: tagsByResource['Microsoft.Resources/resourceGroups']
  }
}

module enclaveMaintenanceModePreflight './enclaveMaintenanceModePreflight.bicep' = if (!empty(virtualEnclaveResourceId)) {
  name: 'enclaveMaintenanceModePreflight-${deploymentid}'
  params: {
    virtualEnclaveResourceId: virtualEnclaveResourceId
  }
}

resource workloadRg 'Microsoft.Resources/resourceGroups@2021-04-01' = if (!workloadResourceGroupUseExisting && empty(virtualEnclaveResourceId)) {
  name: workloadResourceGroup
  location: location
}

module workloadModule './workload.bicep' = if (!empty(virtualEnclaveResourceId)) {
  name: 'workload-${deploymentid}'
  scope: resourceGroup(!empty(virtualEnclaveResourceId) ? split(virtualEnclaveResourceId, '/')[4] : workloadResourceGroup)
  dependsOn: [
    workloadRg
  ]
  params: {
    location: location
    workloadId: workloadId
    workloadUseExisting: workloadUseExisting
    newWorkloadName: newWorkloadName

    tags: contains(tagsByResource, 'Microsoft.Mission/virtualEnclaves/workloads')
      ? tagsByResource['Microsoft.Mission/virtualEnclaves/workloads']
      : {}
    virtualEnclaveResourceId: virtualEnclaveResourceId
  }
}

module workloadRgModule './workloadResourceGroup.bicep' = if (!workloadResourceGroupUseExisting && !empty(virtualEnclaveResourceId)) {
  name: 'workloadResourceGroup-${deploymentid}'
  scope: resourceGroup(!empty(virtualEnclaveResourceId) ? split(virtualEnclaveResourceId, '/')[4] : workloadResourceGroup)
  params: {
    location: location
    workloadId: workloadModule.outputs.workloadId

    tags: contains(tagsByResource, 'Microsoft.Mission/virtualEnclaves/workloads')
      ? tagsByResource['Microsoft.Mission/virtualEnclaves/workloads']
      : {}
    virtualEnclaveResourceId: virtualEnclaveResourceId
    workloadResourceGroup: workloadResourceGroup
    resourceGroupCollection: workloadModule.outputs.resourceGroupCollection
    existingWorkloadTags: existingWorkloadTags
  }
}

module userAssignedIdentityModule './userAssignedIdentity.bicep' = if (!umiUseExisting) {
  name: 'userAssignedIdentity-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: {
    location: location
    name: newUmiName
  }
  dependsOn: [
    workloadRg
    workloadRgModule
  ]
}

module privateKeyVaultDnsModule './privateDnsZone.bicep' = if (!keyVaultUseExisting) {
  name: 'privateKeyVaultDns-${deploymentid}'
  scope: resourceGroup(empty(effectiveNewKeyVaultDnsZoneResourceGroupToCreateIn) ? vnetRG : effectiveNewKeyVaultDnsZoneResourceGroupToCreateIn)
  dependsOn: [
    enclaveMaintenanceModePreflight
  ]
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingKeyVaultManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    privateLinkDnsZoneName: privateLinkKeyVaultDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: effectiveNewKeyVaultDnsZoneResourceGroupToCreateIn
  }
}

module keyVaultModule './keyVault.bicep' = if (!keyVaultUseExisting) {
  name: 'keyVault-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: {
    location: location
    keyvaultname: newKeyVaultName
    skuname: 'standard'
    tenant_id: subscription().tenantId
    vnetName: vnetName
    vnetRG: vnetRG
    vnetLocation: vnet.location
    privateDnsRegistrationType: privateDnsRegistrationType == 'manuallySelectZone' ? 'defaultManagedResourceGroupZone' : privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingKeyVaultManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    newManagedResourceGroupPrivateDnsZone: !keyVaultUseExisting ? privateKeyVaultDnsModule.outputs.privateDnsZoneId : ''
    subnetName: subnetName
    keys: [
      {
        name: keyName
        keySize: 2048
        keyType: 'RSA'
      }
    ]
    enablePurgeProtection: true
  }
  dependsOn: [
    enclaveMaintenanceModePreflight
    workloadRg
    workloadRgModule
  ]
}

module umiRefModule './getUserAssignedIdentity.bicep' = if (assignKeyVaultRole && umiUseExisting) {
  name: 'umiRef-${deploymentid}'
  scope: resourceGroup(umiSubscriptionId, umiResourceGroup)
  params: {
    name: umiName
  }
}

var effectiveUmiPrincipalId = !umiUseExisting
  ? userAssignedIdentityModule.?outputs.?principalId ?? ''
  : umiRefModule.?outputs.?principalId ?? ''

module roleAssignmentModule './keyVaultRoleAssignment.bicep' = if (assignKeyVaultRole) {
  name: 'roleAssignment-${deploymentid}'
  scope: resourceGroup(keyVaultSubscriptionId, keyVaultResourceGroup)
  params: {
    principalId: effectiveUmiPrincipalId
    roleDefinitionId: 'e147488a-f6f5-4113-8e2d-b22465e65bf6' // Key Vault Crypto Service Encryption User
    resourceName: keyVaultName
    existingRoleAssignmentName: existingKeyVaultRoleAssignmentName
  }
  dependsOn: [
    keyVaultModule
  ]
}

module rbacPropagationDelay1 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay1-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  dependsOn: [roleAssignmentModule]
  params: { trigger: deploymentid }
}

module rbacPropagationDelay2 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay2-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay1.?outputs.?done ?? '' }
}

module rbacPropagationDelay3 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay3-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay2.?outputs.?done ?? '' }
}

module rbacPropagationDelay4 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay4-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay3.?outputs.?done ?? '' }
}

module rbacPropagationDelay5 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay5-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay4.?outputs.?done ?? '' }
}

module rbacPropagationDelay6 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay6-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay5.?outputs.?done ?? '' }
}

module rbacPropagationDelay7 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay7-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay6.?outputs.?done ?? '' }
}

module rbacPropagationDelay8 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay8-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay7.?outputs.?done ?? '' }
}

module rbacPropagationDelay9 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay9-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay8.?outputs.?done ?? '' }
}

module rbacPropagationDelay10 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay10-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay9.?outputs.?done ?? '' }
}

module rbacPropagationDelay11 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay11-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay10.?outputs.?done ?? '' }
}

module rbacPropagationDelay12 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay12-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay11.?outputs.?done ?? '' }
}

module rbacPropagationDelay13 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay13-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay12.?outputs.?done ?? '' }
}

module rbacPropagationDelay14 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay14-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay13.?outputs.?done ?? '' }
}

module rbacPropagationDelay15 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay15-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay14.?outputs.?done ?? '' }
}

module rbacPropagationDelay16 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay16-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay15.?outputs.?done ?? '' }
}

module rbacPropagationDelay17 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay17-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay16.?outputs.?done ?? '' }
}

module rbacPropagationDelay18 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay18-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay17.?outputs.?done ?? '' }
}

module rbacPropagationDelay19 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay19-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay18.?outputs.?done ?? '' }
}

module rbacPropagationDelay20 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay20-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay19.?outputs.?done ?? '' }
}

module rbacPropagationDelay21 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay21-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay20.?outputs.?done ?? '' }
}

module rbacPropagationDelay22 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay22-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay21.?outputs.?done ?? '' }
}

module rbacPropagationDelay23 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay23-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay22.?outputs.?done ?? '' }
}

module rbacPropagationDelay24 './rbacPropagationDelay.bicep' = if (assignKeyVaultRole) {
  name: 'rbacPropagationDelay24-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  params: { trigger: rbacPropagationDelay23.?outputs.?done ?? '' }
}

module privateBlobDnsModule './privateDnsZone.bicep' = {
  name: 'privateBlobDns-${deploymentid}'
  scope: resourceGroup(empty(effectiveNewDnsZoneResourceGroupToCreateIn) ? vnetRG : effectiveNewDnsZoneResourceGroupToCreateIn)
  dependsOn: [
    enclaveMaintenanceModePreflight
  ]
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingBlobManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    privateLinkDnsZoneName: privateLinkDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: effectiveNewDnsZoneResourceGroupToCreateIn
  }
}

module privateFileDnsModule './privateDnsZone.bicep' = {
  name: 'privateFileDns-${deploymentid}'
  scope: resourceGroup(empty(effectiveNewDnsZoneResourceGroupToCreateIn) ? vnetRG : effectiveNewDnsZoneResourceGroupToCreateIn)
  dependsOn: [
    enclaveMaintenanceModePreflight
  ]
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingFileManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    privateLinkDnsZoneName: privateLinkFileDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: effectiveNewDnsZoneResourceGroupToCreateIn
  }
}

module privateQueueDnsModule './privateDnsZone.bicep' = {
  name: 'privateQueueDns-${deploymentid}'
  scope: resourceGroup(empty(effectiveNewDnsZoneResourceGroupToCreateIn) ? vnetRG : effectiveNewDnsZoneResourceGroupToCreateIn)
  dependsOn: [
    enclaveMaintenanceModePreflight
  ]
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingQueueManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    privateLinkDnsZoneName: privateLinkQueueDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: effectiveNewDnsZoneResourceGroupToCreateIn
  }
}

module privateTableDnsModule './privateDnsZone.bicep' = {
  name: 'privateTableDns-${deploymentid}'
  scope: resourceGroup(empty(effectiveNewDnsZoneResourceGroupToCreateIn) ? vnetRG : effectiveNewDnsZoneResourceGroupToCreateIn)
  dependsOn: [
    enclaveMaintenanceModePreflight
  ]
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingTableManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    privateLinkDnsZoneName: privateLinkTableDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: effectiveNewDnsZoneResourceGroupToCreateIn
  }
}

module privateDfsDnsModule './privateDnsZone.bicep' = {
  name: 'privateDfsDns-${deploymentid}'
  scope: resourceGroup(empty(effectiveNewDnsZoneResourceGroupToCreateIn) ? vnetRG : effectiveNewDnsZoneResourceGroupToCreateIn)
  dependsOn: [
    enclaveMaintenanceModePreflight
  ]
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingDfsManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: ''
    privateLinkDnsZoneName: privateLinkDfsDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: effectiveNewDnsZoneResourceGroupToCreateIn
  }
}

module storageAccountModule './storageAccount.bicep' = {
  name: 'storageAccount-${deploymentid}'
  dependsOn: [
    enclaveMaintenanceModePreflight
    workloadRg
    workloadModule
    workloadRgModule
    rbacPropagationDelay24
    userAssignedIdentityModule
  ]
  scope: resourceGroup(workloadResourceGroup)
  params: {
    accountKind: effectiveAccountKind
    accessTier: accessTier
    containers: containers
    httpsRequired: httpsRequired
    isHnsEnabled: isHnsEnabled
    largeFileSharesState: largeFileSharesState
    keyName: keyName

    keyVaultId: keyVaultUseExisting ? keyVaultId : keyVaultModule.outputs.keyVaultId
    location: location
    replicationStrategy: effectiveReplicationStrategy
    storageAccountName: effectiveStorageAccountName
    subnetName: subnetName
    tagsByResource: tagsByResource
    umiId: umiUseExisting ? umiId : userAssignedIdentityModule.outputs.id
    vnetName: vnetName
    vnetRG: vnetRG
    vnetLocation: vnet.location
    privateDnsRegistrationType: privateDnsRegistrationType
    existingBlobManagedResourceGroupPrivateDnsZone: existingBlobManagedResourceGroupPrivateDnsZone
    existingFileManagedResourceGroupPrivateDnsZone: existingFileManagedResourceGroupPrivateDnsZone
    existingQueueManagedResourceGroupPrivateDnsZone: existingQueueManagedResourceGroupPrivateDnsZone
    existingTableManagedResourceGroupPrivateDnsZone: existingTableManagedResourceGroupPrivateDnsZone
    existingDfsManagedResourceGroupPrivateDnsZone: existingDfsManagedResourceGroupPrivateDnsZone
    manuallySelectedBlobDnsZone: manuallySelectedBlobDnsZone
    manuallySelectedFileDnsZone: manuallySelectedFileDnsZone
    manuallySelectedQueueDnsZone: manuallySelectedQueueDnsZone
    manuallySelectedTableDnsZone: manuallySelectedTableDnsZone
    manuallySelectedDfsDnsZone: manuallySelectedDfsDnsZone

    newBlobManagedResourceGroupPrivateDnsZone: privateBlobDnsModule.outputs.privateDnsZoneId
    newFileManagedResourceGroupPrivateDnsZone: privateFileDnsModule.outputs.privateDnsZoneId
    newQueueManagedResourceGroupPrivateDnsZone: privateQueueDnsModule.outputs.privateDnsZoneId
    newTableManagedResourceGroupPrivateDnsZone: privateTableDnsModule.outputs.privateDnsZoneId
    newDfsManagedResourceGroupPrivateDnsZone: privateDfsDnsModule.outputs.privateDnsZoneId
    bypass: effectiveBypass
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module telemetry './telemetry.bicep' = if (enableTelemetry && !isMsisrTenant) {
  name: 'telemetry-${deploymentid}'
  scope: resourceGroup(workloadResourceGroup)
  dependsOn: [
    workloadRg
    workloadRgModule
  ]
  params: {
    enableTelemetry: enableTelemetry
    name: 've.sc2.sa.97c081ef-4a88-4448-944c-2d74b9e6387f.ver${deployment().properties.template.contentVersion}'
  }
}
