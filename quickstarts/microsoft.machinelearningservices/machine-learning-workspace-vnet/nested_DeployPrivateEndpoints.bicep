param enablePE bool
param defaultPEConnections array
param subnetId string
param privateDnsZoneName object
param privateAznbDnsZoneName object
param vnetId string

@description('Specifies the name of the Azure Machine Learning workspace.')
param workspaceName string

@description('Required if existing VNET location differs from workspace location')
param vnetLocation string

@description('Tags for workspace, will also be populated if provisioning new dependent resources.')
param tagValues object

@allowed([
  'AutoApproval'
  'ManualApproval'
  'none'
])
param privateEndpointType string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = if (enablePE) {
  name: '${workspaceName}-PrivateEndpoint'
  location: vnetLocation
  tags: tagValues
  properties: {
    privateLinkServiceConnections: ((privateEndpointType == 'AutoApproval') ? defaultPEConnections : json('null'))
    manualPrivateLinkServiceConnections: ((privateEndpointType == 'ManualApproval') ? defaultPEConnections : json('null'))
    subnet: {
      id: subnetId
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (privateEndpointType == 'AutoApproval') {
  name: privateDnsZoneName[toLower(environment().name)]
  location: 'global'
  tags: tagValues
  properties: {
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource privateAznbDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (privateEndpointType == 'AutoApproval') {
  name: privateAznbDnsZoneName[toLower(environment().name)]
  location: 'global'
  tags: tagValues
  properties: {
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneVnLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (privateEndpointType == 'AutoApproval') {
  parent: privateDnsZone
  name: uniqueString(vnetId)
  location: 'global'
  tags: tagValues
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource privateAznbDnsZoneVnLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (privateEndpointType == 'AutoApproval') {
  parent: privateAznbDnsZone
  name: uniqueString(vnetId)
  location: 'global'
  tags: tagValues
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = if (privateEndpointType == 'AutoApproval') {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
          privateDnsZoneId: privateAznbDnsZone.id
        }
      }
    ]
  }
}
