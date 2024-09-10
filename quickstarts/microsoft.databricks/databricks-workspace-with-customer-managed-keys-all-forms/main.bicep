@description('Location for all resources.')
param location string

@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param enableNoPublicIp bool = true

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string

@description('The pricing tier of workspace.')
@allowed([
  'premium'
])
param pricingTier string = 'premium'

@description('The object id of AzureDatabricks application in your tenant. Application ID: 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d')
param azureDatabricksAppObjectId string
param requireInfrastructureEncryption bool = false

@description('Resource Group of the Key Vault that contains the CMK for managed services encryption')
param msCmkKeyVaultResourceGroup string = ''

@description('Name of the Key Vault that contains the CMK for managed services encryption ')
param msCmkKeyVaultName string = ''

@description('Name of the Customer Managed Key used to encrypt managed services data')
param msCmkKeyName string = ''

@description('Version of the Customer Managed Key used to encrypt managed services data')
param msCmkKeyVersion string = ''

@description('Resource Group of the Key Vault that contains the CMK for managed disks encryption')
param dbfsCmkKeyVaultResourceGroup string = ''

@description('Name of the Key Vault that contains the CMK used for DBFS encryption')
param dbfsCmkKeyVaultName string = ''

@description('Name of the Customer Managed Key used to encrypt DBFS data')
param dbfsCmkKeyName string = ''

@description('Version of the Customer Managed Key used to encrypt DBFS data')
param dbfsCmkKeyVersion string = ''

@description('Resource Group of the Key Vault that contains the CMK for managed disks encryption')
param diskCmkKeyVaultResourceGroup string = ''

@description('Name of the Key Vault that contains the CMK used for managed disks encryption')
param diskCmkKeyVaultName string = ''

@description('Name of the Customer Managed Key used to encrypt managed disks data')
param diskCmkKeyName string = ''

@description('Version of the Customer Managed Key used to encrypt managed disks data')
param diskCmkKeyVersion string = ''

@description('The key vault url used for Customer managed keys for Managed disk')
param diskCmkKeyVaultUrl string = ''

param diskCmkEnableAutoRotation bool = false

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'
var msCmkKeyVaultUrl = uri('https://${msCmkKeyVaultName}${environment().suffixes.keyvaultDns}', '/')
var dbfsCmkKeyVaultUrl = uri('https://${dbfsCmkKeyVaultName}${environment().suffixes.keyvaultDns}', '/')
var trimmedDiskCmkKeyVaultUrl = replace(diskCmkKeyVaultUrl, '.net/', '.net/')

module DatabricksManagedServicesCMKAccessPolicy './modules/ManagedServicesCMKAccessPolicy.bicep' = {
  name: 'DatabricksManagedServicesCMKAccessPolicy'
  scope: resourceGroup(msCmkKeyVaultResourceGroup)
  params: {
    msCmkKeyVaultName: msCmkKeyVaultName
    azureDatabricksAppObjectId: azureDatabricksAppObjectId
  }
}

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      enableNoPublicIp: {
        value: enableNoPublicIp
      }
      prepareEncryption: {
        value: true
      }
      requireInfrastructureEncryption: {
        value: requireInfrastructureEncryption
      }
    }
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
  }
  dependsOn: [
    DatabricksManagedServicesCMKAccessPolicy
  ]
}

module DatabricksDbfsCMKAccessPolicy './modules/DbfsCMKAccessPolicy.bicep' = {
  name: 'DatabricksDbfsCMKAccessPolicy'
  scope: resourceGroup(dbfsCmkKeyVaultResourceGroup)
  params: {
    principalId: workspace.properties.storageAccountIdentity.principalId
    tenantId: workspace.properties.storageAccountIdentity.tenantId
    dbfsCmkKeyVaultName: dbfsCmkKeyVaultName
  }
}

module DatabricksManagedDiskCMKAccessPolicy './modules/ManagedDiskCMKAccessPolicy.bicep' = {
  name: 'DatabricksManagedDiskCMKAccessPolicy'
  scope: resourceGroup(diskCmkKeyVaultResourceGroup)
  params: {
    principalId: workspace.properties.managedDiskIdentity.principalId
    tenantId: workspace.properties.managedDiskIdentity.tenantId
    diskCmkKeyVaultName: diskCmkKeyVaultName
  }
  dependsOn: [
    DatabricksDbfsCMKAccessPolicy
  ]
}

module DatabricksDbfsCMKEnable './modules/DbfsCMKEnable.bicep' = {
  name: 'DatabricksDbfsCMKEnable'
  params: {
    managedResourceGroupName: managedResourceGroupName
    trimmedDiskCmkKeyVaultUrl: trimmedDiskCmkKeyVaultUrl
    msCmkKeyVaultUrl: msCmkKeyVaultUrl
    dbfsCmkKeyVaultUrl: dbfsCmkKeyVaultUrl
    workspaceName: workspaceName
    location: location
    pricingTier: pricingTier
    diskCmkKeyName: diskCmkKeyName
    diskCmkKeyVersion: diskCmkKeyVersion
    diskCmkEnableAutoRotation: diskCmkEnableAutoRotation
    msCmkKeyName: msCmkKeyName
    msCmkKeyVersion: msCmkKeyVersion
    dbfsCmkKeyName: dbfsCmkKeyName
    dbfsCmkKeyVersion: dbfsCmkKeyVersion
    enableNoPublicIp: enableNoPublicIp
    requireInfrastructureEncryption: requireInfrastructureEncryption
  }
  dependsOn: [
    workspace
    DatabricksDbfsCMKAccessPolicy
  ]
}

output workspaceId string = workspace.properties.workspaceId
output workspaceURL string = workspace.properties.workspaceUrl
output workspaceResourceId string = workspace.id
