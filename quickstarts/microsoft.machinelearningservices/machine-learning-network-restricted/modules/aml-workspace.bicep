// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AML name')
param amlWorkspaceName string

@description('AML display name')
param amlWorkspaceFriendlyName string = amlWorkspaceName

@description('AML description')
param amlWorkspaceDescription string

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

@description('Resource Id of the virtual network to deploy the resource into.')
param vnetResourceId string

@description('Subnet Id to deploy into.')
param subnetResourceId string

@description('Unique Suffix used for name generation')
param uniqueSuffix string

var privateEndpointName = '${amlWorkspaceName}-amlWorkspace-PE'
var targetSubResource = [
    'amlworkspace'
]

resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: amlWorkspaceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: amlWorkspaceFriendlyName
    description: amlWorkspaceDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId

    // network settings
    publicNetworkAccess: 'Disabled'
    managedNetwork: {
      isolationMode: 'AllowInternetOutBound'
    }

    // private link settings
    sharedPrivateLinkResources: []
  }
  kind: 'Default'

  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: '${amlWorkspaceName}-connection-AIServices'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiServicesId, '2021-10-01').key1}'
      }
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
    customNetworkInterfaceName: '${amlWorkspaceName}-nic-${uniqueSuffix}'
    privateLinkServiceConnections: [
      {
        name: amlWorkspaceName
        properties: {
          privateLinkServiceId: amlWorkspace.id
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



resource dnsZoneGroupamlWorkspace 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
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

output amlWorkspaceID string = amlWorkspace.id
