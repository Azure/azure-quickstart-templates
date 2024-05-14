@description('The name of the Azure Databricks workspace to create.')
param workspaceName string = 'workspace${uniqueString(resourceGroup().id)}'

@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param enableNoPublicIp bool = true

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('The key vault name used for Customer managed keys for Managed disk.')
param keyVaultName string

@description('The key name used for Customer managed keys for Managed disk.')
param keyName string

@description('The key version used for Customer managed keys for Managed disk.')
param keyVersion string

@description('The resource group name of the key vault used for Customer managed keys for Managed disk')
param keyVaultResourceGroupName string

@description('Whether managed disk will pick up new key version automatically.')
@allowed([
  true
  false
])
param enableAutoRotation bool = false

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
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
    parameters: {
      enableNoPublicIp: {
        value: enableNoPublicIp
      }
    }
  }
}

module addAccessPolicy './nested_addAccessPolicy.bicep' = {
  name: 'addAccessPolicy'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    principalId: reference(workspace.id, '2022-04-01-preview').managedDiskIdentity.principalId
    tenantId: reference(workspace.id, '2022-04-01-preview').managedDiskIdentity.tenantId
    keyVaultName: keyVaultName
  }
}

output workspace object = reference(workspace.id, '2022-04-01-preview')
