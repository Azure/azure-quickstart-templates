@description('Application name used as prefix for the Azure Quantum workspace and its associated Storage account.')
param appName string

@description('Location of the Azure Quantum workspace and its associated Storage account.')
@allowed([
  'eastus'
  'japaneast'
  'japanwest'
  'northeurope'
  'uksouth'
  'ukwest'
  'westcentralus'
  'westeurope'
  'westus'
  'westus2'
])
param location string

var quantumWorkspaceName = '${appName}-ws'
var storageAccountName = '${appName}${substring(uniqueString(resourceGroup().id), 0, 5)}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource quantumWorkspace 'Microsoft.Quantum/Workspaces@2019-11-04-preview' = {
  name: quantumWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    providers: [
      {
        providerId: 'Microsoft'
        providerSku: 'DZH3178M639F'
        applicationName: '${quantumWorkspaceName}-Microsoft'
      }
    ]
    storageAccount: storageAccount.id
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(quantumWorkspace.id, '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c', storageAccount.id)
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: reference(quantumWorkspace.id, '2019-11-04-preview', 'full').identity.principalId
  }
}

output subscription_id string = subscription().subscriptionId
output resource_group string = resourceGroup().name
output name string = quantumWorkspace.name
output location string = quantumWorkspace.location
output tenant_id string = subscription().tenantId
