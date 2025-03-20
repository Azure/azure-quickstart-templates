// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI hub name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string = aiHubName

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Resource ID of the AI Search resource')
param searchId string

@description('Resource ID of the AI Search endpoint')
param searchTarget string

@description('Resource Id of the virtual network to deploy the resource into.')
param vnetResourceId string

@description('Subnet Id to deploy into.')
param subnetResourceId string

@description('Unique Suffix used for name generation')
param uniqueSuffix string

@description('SystemDatastoresAuthMode')
@allowed([
  'identity'
  'accesskey'
])
param systemDatastoresAuthMode string

@description('AI Service Connection Auth Mode')
@allowed([
  'ApiKey'
  'AAD'
])
param connectionAuthMode string

var privateEndpointName = '${aiHubName}-AIHub-PE'
var targetSubResource = [
    'amlworkspace'
]

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId

    // network settings
    provisionNetworkNow: true
    publicNetworkAccess: 'Disabled'
    managedNetwork: {
      isolationMode: 'AllowInternetOutBound'
    }
    systemDatastoresAuthMode: systemDatastoresAuthMode

    // private link settings
    sharedPrivateLinkResources: []
  }
  kind: 'hub'

  
  // Azure Search connection
  resource searchServiceConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-Search'
    properties: {
      category: 'CognitiveSearch'
      target: searchTarget
      #disable-next-line BCP225
      authType: connectionAuthMode 
      isSharedToAll: true
      useWorkspaceManagedIdentity: false
      sharedUserList: []

      credentials: connectionAuthMode == 'ApiKey'
      ? {
          key: '${listAdminKeys(searchId, '2023-11-01')}'
        }
      : null

      metadata: {
        ApiType: 'Azure'
        ResourceId: searchId
      }
    }
  }

  // AI Services connection
  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-AIServices'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget
      #disable-next-line BCP225
      authType: connectionAuthMode 
      isSharedToAll: true
      
      credentials: connectionAuthMode == 'ApiKey'
        ? {
            key: '${listKeys(aiServicesId, '2021-10-01')}'
          }
        : null

      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }

}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetResourceId
    }
    customNetworkInterfaceName: '${aiHubName}-nic-${uniqueSuffix}'
    privateLinkServiceConnections: [
      {
        name: aiHubName
        properties: {
          privateLinkServiceId: aiHub.id
          groupIds: targetSubResource
        }
      }
    ]
  }

}

resource privateLinkApi 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
  tags: {}
  properties: {}
}

resource privateLinkNotebooks 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.notebooks.azure.net'
  location: 'global'
  tags: {}
  properties: {}
}

resource vnetLinkApi 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateLinkApi
  name: '${uniqueString(vnetResourceId)}-api'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetResourceId
    }
    registrationEnabled: false
  }
}

resource vnetLinkNotebooks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateLinkNotebooks
  name: '${uniqueString(vnetResourceId)}-notebooks'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetResourceId
    }
    registrationEnabled: false
  }
}



resource dnsZoneGroupAiHub 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
            privateDnsZoneId: privateLinkApi.id
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
            privateDnsZoneId: privateLinkNotebooks.id
        }
      }
    ]
  }
  dependsOn: [
    vnetLinkApi
    vnetLinkNotebooks
  ]
}

output aiHubID string = aiHub.id
output aiHubName string = aiHub.name
output aiHubPrincipalId string = aiHub.identity.principalId
