@description('Location of the blob storage.')
param location string = resourceGroup().location

var contentUri = uri('https://azbotstorage.blob.${environment().suffixes.storage}', '/sample-artifacts/data-factory/moviesDB2.csv')
var csvFilename = last(split(contentUri, '/'))
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
var csvInputFolder = 'input'
var blobContainerName = 'datafactory'

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

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'copyFile'
  location: location
  kind: 'AzurePowerShell'
  dependsOn: [
    blobContainer
  ]
  properties: {
    azPowerShellVersion: '8.0'
    environmentVariables: [
      {
        name: 'storageKey'
        secureValue: storageAccount.listKeys().keys[0].value
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
      {
        name: 'csvFileName'
        value: csvFilename
      }
      {
        name: 'csvInputFolder'
        value: csvInputFolder
      }
    ]
    scriptContent: loadTextContent('./scripts/copy-data.ps1')
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
