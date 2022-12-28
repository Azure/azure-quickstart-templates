@description('The name of the Azure Databricks workspace to create.')
param workspaceName string = 'workspace${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('The key vault name used for BYOK.')
param keyVaultName string

@description('The key name used for BYOK.')
param keyName string

@description('The key version used for BYOK.')
param keyVersion string

@description('The resource group name of the key vault used for BYOK')
param keyVaultResourceGroupName string

@description('Whether managed disk will pick up new key version automatically.')
@allowed([
  true
  false
])
param enableAutoRotation bool = false

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

resource workspace 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
    encryption: {
      entities: {
        managedDisk: {
          keySource: 'Microsoft.Keyvault'
          keyVaultProperties: {
            keyVaultUri: uri('https://${keyVaultName}${environment().suffixes.keyvaultDns}', '/')
            keyName: keyName
            keyVersion: keyVersion
          }
          rotationToLatestKeyVersionEnabled: enableAutoRotation
        }
      }
    }
  }
}

module addAccessPolicy './nested_addAccessPolicy.bicep' = {
  name: 'addAccessPolicy'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    principalId: workspace.properties.managedDiskIdentity.principalId
    tenantId: workspace.properties.managedDiskIdentity.tenantId
    keyVaultName: keyVaultName
  }
}

output workspace object = workspace.properties
