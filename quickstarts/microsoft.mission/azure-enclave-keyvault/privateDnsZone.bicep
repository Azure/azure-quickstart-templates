param location string
param existingManagedResourceGroupPrivateDnsZone string = ''
param manuallySelectedPrivateDnsZone string
param tagsByResource object
param privateDnsRegistrationType string
param tags object = {}
param virtualEnclaveResourceId string
param privateLinkDnsZoneName string
param vnetName string
param vnetRG string
param deploymentid string
param newDnsZoneResourceGroupToCreateIn string
//param workloadResourceGroup string

//var workloadResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${workloadResourceGroup}'

resource virtualEnclaveExisting 'Microsoft.Mission/virtualEnclaves@2025-05-01-preview' existing = {
  name: split(virtualEnclaveResourceId, '/')[8]
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && existingManagedResourceGroupPrivateDnsZone == '' && newDnsZoneResourceGroupToCreateIn != '') {
  name: privateLinkDnsZoneName
  location: 'global'
}
resource privateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && existingManagedResourceGroupPrivateDnsZone == '' && newDnsZoneResourceGroupToCreateIn != '') {
  name: 'pdns-vnetlink'
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetwork.id
    }
    registrationEnabled: false
  }
  tags: contains(tagsByResource, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks')
    ? tagsByResource['Microsoft.Network/privateDnsZones/virtualNetworkLinks']
    : {}
}

output privateDnsZoneId string = (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && existingManagedResourceGroupPrivateDnsZone == '' && newDnsZoneResourceGroupToCreateIn != '') ? privateDnsZone.id : ''
