@description('Location of the deploymentScript resource.')
param location string = resourceGroup().location

@description('Name of the storageAccount to copy the blob to.')
param storageAccountName string

@description('Name of the blob container to create and copy blob to.')
param containerName string

@description('Uri of the source or staged blob to copy.')
@secure()
param contentUri string

@description('Account key for the permission to copy the blob to the storage account, if not provided will attempt with listKeys().')
@secure()
param storageAccountKey string = ''

// get the last part of the uri and remove the sasToken if needed
var csvFilename = first(split(last(split(contentUri, '/')), '?'))

// storageAccount must exist, container will be created
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'copyFile'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '8.0'
    environmentVariables: [
      {
        name: 'storageAccountKey'
        secureValue: empty(storageAccountKey) ? storageAccount.listKeys().keys[0].value : storageAccountKey // user must have permission to get the keys of the storageAccount
      }
      {
        name: 'storageAccountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: containerName
      }
      {
        name: 'contentUri'
        value: contentUri
      }
      {
        name: 'csvFileName'
        value: csvFilename
      }
    ]
    scriptContent: loadTextContent('./scripts/copy-data.ps1')
    timeout: 'PT4H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
