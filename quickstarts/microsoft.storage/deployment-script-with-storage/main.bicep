@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the managed identity resource.')
param identityName string = 'managedIdentity'

@description('The subscription id of the managed identity resource.')
param identitySubscriptionId string = subscription().subscriptionId

@description('The resource group name of the managed identity resource.')
param identityResourceGroup string = resourceGroup().name

@description('Controls whether the script is re-run or not on a subsequent deployment.')
param forceUpdateTag string = utcNow()

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identitySubscriptionId, identityResourceGroup)
  name: identityName
}

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'dscript${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource dScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'scriptWithStorage'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.0.80'
    storageAccountSettings: {
      storageAccountName: stg.name
      storageAccountKey: stg.listKeys().keys[0].value
    }
    scriptContent: loadTextContent('./script.sh')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    forceUpdateTag: forceUpdateTag
  }
}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: dScript
  name: 'default'
}

// print logs from script after template is finished deploying
output scriptLogs string = logs.properties.log
