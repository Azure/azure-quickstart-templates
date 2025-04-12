@description('Name of the Azure Storage account.')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Sku on which to run the Azure Storage account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSku string = 'Standard_LRS'

@description('Indicates the type of storage account.')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param storageAccountKind string = 'StorageV2'

@description('Set the name of the container to create in the Storage account.')
param storageAccountContainerName string = 'my-container'

@description('Name of the Logic Apps API connection used to connect to the Azure Storage account.')
param storageConnectionName string = 'storageconnection${uniqueString(resourceGroup().id)}'

@description('Name of the Logic App.')
param logicAppName string = 'logicapp${uniqueString(resourceGroup().id)}'

@description('The polling interval used to check for items on the Storage account.')
param logicAppPollingIntervalInMinutes int = 30

@description('Location where resources reside.')
param location string = resourceGroup().location

@description('Azure Management URI')
param azureMgmtUri string = ''

resource storageConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: storageConnectionName
  location: location
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
    }
    parameterValues: {
      accountName: storageAccountName
      accessKey: storageAccount.listkeys().keys[0].value
    }
    testLinks: [
      {
        requestUri: uri(
          azureMgmtUri,
          'subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${storageConnectionName}/extensions/proxy/testconnection?api-version=2018-07-01-preview'
        )
        method: 'get'
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_blob_is_added_or_modified_(properties_only)': {
          recurrence: {
            frequency: 'Minute'
            interval: logicAppPollingIntervalInMinutes
          }
          splitOn: '@triggerBody()'
          metadata: {
            JTJmbXktY29udGFpbmVy: '/${storageAccountContainerName}'
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/datasets/default/triggers/batch/onupdatedfile'
            queries: {
              folderId: 'JTJmbXktY29udGFpbmVy'
              maxFileCount: 10
            }
          }
        }
      }
      actions: {
        Process_blobs: {
          type: 'Scope'
        }
      }
    }
    parameters: {
      '$connections': {
        value: {
          azureblob: {
            connectionId: storageConnection.id
            connectionName: 'azureblob'
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
          }
        }
      }
    }
    state: 'Enabled'
  }
}

output logicAppName string = logicApp.name
output logicAppId string = logicApp.id
output location string = logicApp.location
output resourceGroupName string = resourceGroup().name
