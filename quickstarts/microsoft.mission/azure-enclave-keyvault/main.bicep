targetScope = 'subscription'
param enablePurgeProtection bool = false
param keys array = []
param keyvaultname string
param location string = 'usgovarizona'
param newWorkloadName string = 'placeholder'
param skuname string
param softDeleteRetentionInDays int = 90
param subnetName string
param tagsByResource object = {}
param tenant_id string = tenant().tenantId
param vnetName string
param vnetRG string
param workloadId string = 'placeholder'
param workloadResourceGroup string
param virtualEnclaveResourceId string = ''
param workloadUseExisting bool
param workloadResourceGroupUseExisting bool
param deploymentid string = substring(uniqueString(utcNow()), 0, 6)
param existingManagedResourceGroupPrivateDnsZone string = ''
param manuallySelectedPrivateDnsZone string = ''
param privateDnsRegistrationType string = ''
param newDnsZoneResourceGroupToCreateIn string = ''
param enableDiagnostics bool = false
param workspaceId string = ''
param enableTelemetry bool = true
param isMsisrTenant bool = false

var privateLinkDnsZoneName = 'privatelink${replace(environment().suffixes.keyvaultDns, 'vault', 'vaultcore')}' // Key Vault

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
  }
}

module privateDnsModule './privateDnsZone.bicep' = {
  name: 'privateDns-${deploymentid}'
  scope: resourceGroup(empty(newDnsZoneResourceGroupToCreateIn) ? vnetRG : newDnsZoneResourceGroupToCreateIn)
  params: {
    location: location
    tagsByResource: tagsByResource
    virtualEnclaveResourceId: virtualEnclaveResourceId
    privateDnsRegistrationType: privateDnsRegistrationType
    existingManagedResourceGroupPrivateDnsZone: existingManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: manuallySelectedPrivateDnsZone
    privateLinkDnsZoneName: privateLinkDnsZoneName
    vnetName: vnetName
    vnetRG: vnetRG
    deploymentid: deploymentid
    newDnsZoneResourceGroupToCreateIn: newDnsZoneResourceGroupToCreateIn
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

var newManagedResourceGroupPrivateDnsZone = privateDnsModule.outputs.privateDnsZoneId

module keyvaultModule './keyVault.bicep' = {
  name: 'keyVault-${deploymentid}'
  dependsOn: [
    workloadRg
    workloadModule
    workloadRgModule
  ]
  scope: resourceGroup(workloadResourceGroup)
  params: {
    enablePurgeProtection: enablePurgeProtection
    keys: keys
    keyvaultname: keyvaultname
    location: location
    skuname: skuname
    softDeleteRetentionInDays: softDeleteRetentionInDays
    subnetName: subnetName
    tagsByResource: tagsByResource
    tenant_id: tenant_id
    vnetName: vnetName
    vnetRG: vnetRG
    privateDnsRegistrationType: privateDnsRegistrationType
    vnetLocation: vnet.location
    existingManagedResourceGroupPrivateDnsZone: existingManagedResourceGroupPrivateDnsZone
    manuallySelectedPrivateDnsZone: manuallySelectedPrivateDnsZone
    newManagedResourceGroupPrivateDnsZone: newManagedResourceGroupPrivateDnsZone
    enableDiagnostics: enableDiagnostics
    workspaceId: workspaceId
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
    name: 've.sc2.kv.97c081ef-4a88-4448-944c-2d74b9e6387f.ver${deployment().properties.template.contentVersion}'
  }
}
