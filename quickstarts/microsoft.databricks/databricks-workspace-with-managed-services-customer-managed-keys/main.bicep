@description('The name of the Azure Databricks workspace to create.')
param workspaceName string = 'default'

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('Specifies whether to deploy Azure Databricks workspace with secure cluster connectivity (SCC) enabled or not (No Public IP)')
param enableNoPublicIp bool = true

@description('The object ID of the AzureDatabricks enterprise application.')
param ObjectID string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The key vault name used for customer-managed key for managed services')
param keyVaultName string

@description('The key vault URI used for customer-managed key for managed services')
param keyvaultUri string

@description('The key name used for customer-managed key for managed services')
param keyName string

@description('The key version used for customer-managed key for managed services')
param keyVersion string

@description('The resource group name of the key vault used for customer-managed key for managed services')
param keyVaultResourceGroupName string

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'

module addAccessPolicy './nested_addAccessPolicy.bicep' = {
  name: 'addAccessPolicy'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    ObjectID: ObjectID
  }
}

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: '${subscription().id}/resourceGroups/${trimmedMRGName}'
    encryption: {
      entities: {
        managedServices: {
          keySource: 'Microsoft.Keyvault'
          keyVaultProperties: {
            keyVaultUri: keyvaultUri
            keyName: keyName
            keyVersion: keyVersion
          }
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

output workspace object = workspace.properties
