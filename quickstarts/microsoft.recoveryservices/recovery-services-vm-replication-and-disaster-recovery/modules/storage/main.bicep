param location string

param storageAccountName string
param virtualNetworkId string
param subnetId string

var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var filePrivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var queuePrivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(storageAccountName)
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: filePrivateDnsZoneName
  location: 'global'
}

resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: queuePrivateDnsZoneName
  location: 'global'
}

resource blobPrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetworkId, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource filePrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: filePrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetworkId, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource queuePrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: queuePrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetworkId, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-blob-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-blob-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-file-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-file-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource queuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-queue-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-queue-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource blobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: blobPrivateEndpoint
  name: 'blob'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource filePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: filePrivateEndpoint
  name: 'file'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: filePrivateDnsZone.id
        }
      }
    ]
  }
}

resource queuePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: queuePrivateEndpoint
  name: 'queue'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: queuePrivateDnsZone.id
        }
      }
    ]
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
