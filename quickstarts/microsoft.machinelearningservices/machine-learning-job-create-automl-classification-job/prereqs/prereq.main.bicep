@description('Specifies the name of the Azure Machine Learning workspace.')
param workspaceName string

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('The name for the storage account to created and associated with the workspace.')
param storageAccountName string = 'sa${uniqueString(resourceGroup().id)}'

@description('The name for the key vault to created and associated with the workspace.')
param keyVaultName string = 'kv${uniqueString(resourceGroup().id)}'

@description('Specifies the tenant ID of the subscription. Get using Get-AzureRmSubscription cmdlet or Get Subscription API.')
param tenantId string = subscription().tenantId

@description('The name for the application insights to created and associated with the workspace.')
param applicationInsightsName string = 'ai${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the Azure Machine Learning compute instance to be deployed.')
param computeName string

@description('The VM size for compute instance')
param vmSize string = 'Standard_DS3_v2'

@description('Name of the resource group which holds the VNET to which you want to inject your compute instance in.')
param vnetResourceGroupName string = ''

@description('Name of the vnet which you want to inject your compute instance in.')
param vnetName string = ''

@description('Name of the subnet inside the VNET which you want to inject your compute instance in.')
param subnetName string = ''

@description('AAD object id of the user to which compute instance is assigned to.')
param objectId string

@description('inline command.')
param inlineCommand string = 'ls'

@description('Specifies the cmd arguments of the creation script in the storage volume of the Compute Instance.')
param creationScript_cmdArguments string = ''

var subnet = {
  id: resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
}

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource keyVaultResource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

resource applicationInsightsResource 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource workspaceResource 'Microsoft.MachineLearningServices/workspaces@2020-03-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountResource.id
    keyVault: keyVaultResource.id
    applicationInsights: applicationInsightsResource.id
  }
}

resource computeResource 'Microsoft.MachineLearningServices/workspaces/computes@2021-07-01' = {
  parent: workspaceResource
  name: computeName
  location: location
  properties: {
    computeType: 'ComputeInstance'
    properties: {
      vmSize: vmSize
      subnet: (((!empty(vnetResourceGroupName)) && (!empty(vnetName)) && (!empty(subnetName))) ? subnet : json('null'))
      personalComputeInstanceSettings: {
        assignedUser: {
          objectId: objectId
          tenantId: tenantId
        }
      }
      setupScripts: {
        scripts: {
          creationScript: {
            scriptSource: 'inline'
            scriptData: base64(inlineCommand)
            scriptArguments: creationScript_cmdArguments
          }
        }
      }
    }
  }
}

output workspaceName string = workspaceName
output computeName string = computeName
