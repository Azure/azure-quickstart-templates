@description('Location of the blob storage.')
param location string = resourceGroup().location

@description('Name of the Azure storage account that contains the input/output data.')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string = 'blob${uniqueString(resourceGroup().id)}'

@description('Name of the managed identity created to access the Azure Storage account.')
param managedIdentityName string = 'blob${uniqueString(resourceGroup().id)}'

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('The file name that contains the content for the Data Factory')
param csvFilename string = 'moviesDB2.csv'

var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var bootstrapRoleAssignmentName  = guid(resourceGroup().id, managedIdentity.id, roleDefinitionId)
var contentUri = uri(_artifactsLocation, '${csvFilename}${_artifactsLocationSasToken}')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccountName}/default/${blobContainerName}'
  dependsOn: [
    storageAccount
  ]
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
}

resource bootstrapRoleAssignmentId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: bootstrapRoleAssignmentName 
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: reference(managedIdentity.id, '2022-01-31-preview').principalId
    principalType: 'ServicePrincipal'
  }
}

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'copyFile'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {
      }
    }
  }
  dependsOn: [
    bootstrapRoleAssignmentId
  ]
  properties: {
    azPowerShellVersion: '8.0'
    arguments: '-name FileCreationScript'
    environmentVariables: [
      {
        name: 'RGName'
        value: resourceGroup().name
      }
      {
        name: 'SAName'
        value: storageAccountName
      }
      {
        name: 'ContainerName'
        value: blobContainerName
      }
      {
        name: 'contentUri'
        value: contentUri
      }
    ]
    scriptContent: loadTextContent('./scripts/copy-data.ps1')
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
