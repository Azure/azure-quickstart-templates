// Creates an Azure Container Registry with Azure Private Link endpoint
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Container registry name')
param containerRegistryName string

var containerRegistryNameCleaned = replace(containerRegistryName, '-', '')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: containerRegistryNameCleaned
  location: location
  tags: tags
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
    }
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
  }
}

output containerRegistryId string = containerRegistry.id
