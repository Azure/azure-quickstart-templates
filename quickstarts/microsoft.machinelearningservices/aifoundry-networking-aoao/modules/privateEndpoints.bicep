// Imports
import {getVirtualNetworkIdFromSubnetId, getVirtualNetworkNameFromSubnetId} from './functions.bicep'

// Parameters
@description('Specifies the resource ID of the subnet where private endpoints will be created.')
param subnetId string

@description('Specifies the name of the private endpoint to the blob storage account.')
param blobStorageAccountPrivateEndpointName string

@description('Specifies the name of the private endpoint to the file storage account.')
param fileStorageAccountPrivateEndpointName string

@description('Specifies the resource id of the Azure Storage Account.')
param storageAccountId string

@description('Specifies the name of the private endpoint to the Key Vault.')
param keyVaultPrivateEndpointName string

@description('Specifies the resource id of the Azure Key vault.')
param keyVaultId string

@description('Specifies the resource id of the Azure Hub Workspace.')
param hubWorkspaceId string

@description('Specifies the resource id of the Azure AI Services.')
param aiServicesId string

@description('Specifies whether to create a private endpoint for the Azure Container Registry')
param createAcrPrivateEndpoint bool = false

@description('Specifies the name of the private endpoint to the Azure Container Registry.')
param acrPrivateEndpointName string

@description('Specifies the resource id of the Azure Container Registry.')
param acrId string

@description('Specifies the name of the private endpoint to the Azure Hub Workspace.')
param hubWorkspacePrivateEndpointName string

@description('Specifies the name of the private endpoint to the Azure AI Services.')
param aiServicesPrivateEndpointName string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var virtualNetworkName = getVirtualNetworkNameFromSubnetId(subnetId)

// Existing virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: virtualNetworkName
}

// Private DNS Zones
resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${toLower(environment().name) == 'azureusgovernment' ? 'azurecr.us' : 'azurecr.io'}'
  location: 'global'
  tags: tags
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${toLower(environment().name) == 'azureusgovernment' ? 'vaultcore.usgovcloudapi.net' : 'vaultcore.azure.net'}'
  location: 'global'
  tags: tags
}

resource mlApiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.${toLower(environment().name) == 'azureusgovernment' ? 'ml.azure.us' : 'azureml.ms'}'
  location: 'global'
  tags: tags
}

resource mlNotebooksPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.notebooks.${toLower(environment().name) == 'azureusgovernment' ? 'usgovcloudapi.net' : 'azureml.net'}'
  location: 'global'
  tags: tags
}

resource cognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.cognitiveservices.${toLower(environment().name) == 'azureusgovernment' ? 'azure.us' : 'azure.com'}'
  location: 'global'
  tags: tags
}

resource openAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.openai.${toLower(environment().name) == 'azureusgovernment' ? 'azure.us' : 'azure.com'}'
  location: 'global'
  tags: tags
}

// Virtual Network Links
resource acrPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: acrPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource blobPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource filePrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: filePrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource keyVaultPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: keyVaultPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource mlApiPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: mlApiPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource mlNotebooksPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: mlNotebooksPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource cognitiveServicesPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: cognitiveServicesPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource openAiPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: openAiPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// Private Endpoints
resource blobStorageAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: blobStorageAccountPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobStorageAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccountId
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

resource blobStorageAccountPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  parent: blobStorageAccountPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
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

resource fileStorageAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: fileStorageAccountPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: fileStorageAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccountId
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

resource fileStorageAccountPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  parent: fileStorageAccountPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
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

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource keyVaultPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  parent: keyVaultPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}

resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = if (createAcrPrivateEndpoint) {
  name: acrPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: acrPrivateEndpointName
        properties: {
          privateLinkServiceId: acrId
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource acrPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = if (createAcrPrivateEndpoint) {
  parent: acrPrivateEndpoint
  name: 'acrPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: acrPrivateDnsZone.id
        }
      }
    ]
  }
}

resource hubWorkspacePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: hubWorkspacePrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: hubWorkspacePrivateEndpointName
        properties: {
          privateLinkServiceId: hubWorkspaceId
          groupIds: [
            'amlworkspace'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource hubWorkspacePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: hubWorkspacePrivateEndpoint
  name: 'hubWorkspacePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(mlApiPrivateDnsZone.name, '.', '-')
        properties: {
            privateDnsZoneId: mlApiPrivateDnsZone.id
        }
      }
      {
        name: replace(mlNotebooksPrivateDnsZone.name, '.', '-')
        properties: {
            privateDnsZoneId: mlNotebooksPrivateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    mlApiPrivateDnsZoneVirtualNetworkLink
    mlNotebooksPrivateDnsZoneVirtualNetworkLink
  ]
}

resource aiServicesPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: aiServicesPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: aiServicesPrivateEndpointName
        properties: {
          privateLinkServiceId: aiServicesId
          groupIds: [
            'account'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource aiServicesPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: aiServicesPrivateEndpoint
  name: 'default'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: replace(cognitiveServicesPrivateDnsZone.name, '.', '-')
        properties:{
          privateDnsZoneId: cognitiveServicesPrivateDnsZone.id
        }
      }
      {
        name: replace(openAiPrivateDnsZone.name, '.', '-')
        properties:{
          privateDnsZoneId: openAiPrivateDnsZone.id
        }
      }
    ]
  }
}
