param managedResourceGroupName string

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string

@description('Location for all resources.')
param location string

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string

@description('The Azure Key Vault name.')
param keyVaultName string

@description('The Azure Key Vault encryption key name.')
param keyName string

@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool

var keyVaultUri = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'
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
      encryption: {
        value: {
          keySource: 'Microsoft.Keyvault'
          keyvaulturi: keyVaultUri
          KeyName: keyName
        }
      }
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
  }
}
