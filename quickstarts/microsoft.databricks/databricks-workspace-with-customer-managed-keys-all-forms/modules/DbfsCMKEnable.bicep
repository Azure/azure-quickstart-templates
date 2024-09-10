param managedResourceGroupName string
param trimmedDiskCmkKeyVaultUrl string
param msCmkKeyVaultUrl string
param dbfsCmkKeyVaultUrl string

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string

@description('Location for all resources.')
param location string

@description('The pricing tier of workspace.')
@allowed([
  'premium'
])
param pricingTier string

@description('Name of the Customer Managed Key used to encrypt managed disks data')
param diskCmkKeyName string

@description('Version of the Customer Managed Key used to encrypt managed disks data')
param diskCmkKeyVersion string

param diskCmkEnableAutoRotation bool

@description('Name of the Customer Managed Key used to encrypt managed services data')
param msCmkKeyName string

@description('Version of the Customer Managed Key used to encrypt managed services data')
param msCmkKeyVersion string

@description('Name of the Customer Managed Key used to encrypt DBFS data')
param dbfsCmkKeyName string

@description('Version of the Customer Managed Key used to encrypt DBFS data')
param dbfsCmkKeyVersion string

@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param enableNoPublicIp bool
param requireInfrastructureEncryption bool

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
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
            keyVaultUri: trimmedDiskCmkKeyVaultUrl
            keyName: diskCmkKeyName
            keyVersion: diskCmkKeyVersion
          }
          rotationToLatestKeyVersionEnabled: diskCmkEnableAutoRotation
        }
        managedServices: {
          keySource: 'Microsoft.Keyvault'
          keyVaultProperties: {
            keyVaultUri: msCmkKeyVaultUrl
            keyName: msCmkKeyName
            keyVersion: msCmkKeyVersion
          }
        }
      }
    }
    parameters: {
      prepareEncryption: {
        value: true
      }
      encryption: {
        value: {
          keySource: 'Microsoft.Keyvault'
          keyvaulturi: dbfsCmkKeyVaultUrl
          KeyName: dbfsCmkKeyName
          keyversion: dbfsCmkKeyVersion
        }
      }
      enableNoPublicIp: {
        value: enableNoPublicIp
      }
      requireInfrastructureEncryption: {
        value: requireInfrastructureEncryption
      }
    }
  }
}
