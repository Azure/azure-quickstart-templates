@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool = false

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string = 'ws${uniqueString(resourceGroup().id)}'

@description('The Azure Key Vault name.')
param keyVaultName string

@description('The Azure Key Vault encryption key name.')
param keyName string

@description('The Azure Key Vault resource group name.')
param keyVaultResourceGroupName string

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('Location for all resources.')
param location string = resourceGroup().location

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

resource workspace 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
    parameters: {
      prepareEncryption: {
        value: true
      }
    }
  }
}

module addAccessPolicy './nested_addAccessPolicy.bicep' = {
  name: 'addAccessPolicy'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    principalId: workspace.properties.storageAccountIdentity.principalId
    tenantId: workspace.properties.storageAccountIdentity.tenantId
    keyVaultName: keyVaultName
  }
}

module configureCMKOnWorkspace './nested_configureCMKOnWorkspace.bicep' = {
  name: 'configureCMKOnWorkspace'
  params: {
    managedResourceGroupName: managedResourceGroupName
    workspaceName: workspaceName
    location: location
    pricingTier: pricingTier
    keyVaultName: keyVaultName
    keyName: keyName
    disablePublicIp: disablePublicIp
  }
  dependsOn: [
    addAccessPolicy
  ]
}

output workspace object = workspace.properties
