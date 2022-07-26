@description('Location of all resources to be deployed')
param location string = resourceGroup().location

@description('Custom Script to execute')
param installScriptUri string

@description('Random Value for Caching')
param utcValue string = utcNow()

resource helm 'Microsoft.Resources/deploymentScripts@2019-10-01-preview' = {
  name: 'helm'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', 'dsId')}': {
      }
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.10.1'
    timeout: 'PT30M'
    environmentVariables: [
      {
        name: 'RESOURCEGROUP'
        secureValue: resourceGroup().name
      }
    ]
    primaryScriptUri: installScriptUri
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}
