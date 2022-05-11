@description('Name of the Vault')
param vaultName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specify the workspace region')
param workspaceLocation string

var omsWorkspaceName = '${uniqueString(resourceGroup().id)}ws'
var storageAccountName = '${uniqueString(resourceGroup().id)}storage'
var storageAccountType = 'Standard_LRS'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2021-07-01' = {
  name: vaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource omsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: omsWorkspaceName
  location: workspaceLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {}
}

resource vaultName_microsoft_insights_omsWorkspaceName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: recoveryServicesVault
  name: omsWorkspaceName
  properties: {
    storageAccountId: storageAccount.id
    workspaceId: omsWorkspace.id
    logs: [
      {
        category: 'AzureBackupReport'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}
