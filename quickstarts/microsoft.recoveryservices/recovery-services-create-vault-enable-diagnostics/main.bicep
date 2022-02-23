@description('Name of the Vault')
param vaultName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specify the workspace region')
@allowed([
  'centralus'
  'eastus'
  'eastus2'
  'northcentralus'
  'northeurope'
  'southcentralus'
  'westcentralus'
  'westeurope'
  'westus'
  'westus2'
  'uaenorth'
  'switzerlandnorth'
  'uksouth'
  'francecentral'
  'norwayeast'
  'koreacentral'
  'australiasoutheast'
  'australiaeast'
  'japaneast'
  'centralindia'
  'southeastasia'
  'eastasia'
  'chinaeast2'
  'canadacentral'
  'brazilsouth'
  'usgovarizona'
  'usgovvirginia'
])
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
      name: 'PerNode'
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

resource vaultName_microsoft_insights_omsWorkspaceName 'Microsoft.RecoveryServices/vaults/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${vaultName}/microsoft.insights/${omsWorkspaceName}'
  properties: {
    name: omsWorkspaceName
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
  dependsOn:[
    recoveryServicesVault
  ]
}
