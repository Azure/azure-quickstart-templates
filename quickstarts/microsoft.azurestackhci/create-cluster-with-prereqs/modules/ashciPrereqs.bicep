
param location string

param clusterWitnessStorageAccountName string
param keyVaultName string
param softDeleteRetentionDays int
param logsRetentionInDays int
param tenantId string
param hciResourceProviderObjectId string
param arcNodeResourceIds array
param deploymentPrefix string
param deploymentUsername string
@secure()
param deploymentUserPassword string
param localAdminUser string
@secure()
param localAdminPassword string
param arbDeploymentSpnAppId string
@secure()
param arbDeploymentSpnPassword string

// secret names for the Azure Key Vault - these cannot be changed
var localAdminSecretName = 'LocalAdminCredential'
var domainAdminSecretName = 'AzureStackLCMUserCredential'
var arbDeploymentSpnName = 'DefaultARBApplication'
var storageWitnessName = 'WitnessStorageKey'

// create base64 encoded secret values to be stored in the Azure Key Vault
var deploymentUserSecretValue = base64('${deploymentUsername}:${deploymentUserPassword}')
var localAdminSecretValue = base64('${localAdminUser}:${localAdminPassword}')
var arbDeploymentSpnValue = base64('${arbDeploymentSpnAppId}:${arbDeploymentSpnPassword}')

var storageAccountType = 'Standard_LRS'

var diagnosticStorageAccountName = '${deploymentPrefix}diag'

var azureConnectedMachineResourceManagerRoleID = '/providers/Microsoft.Authorization/roleDefinitions/f5819b54-e033-4d82-ac66-4fec3cbf3f4c'
var readerRoleID = '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
var azureStackHCIDeviceManagementRole = '/providers/Microsoft.Authorization/roleDefinitions/865ae368-6a45-4bd1-8fbf-0d5151f56fc1'
var keyVaultSecretUserRoleID = '/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'

resource diagnosticStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: diagnosticStorageAccountName
  location: location
  sku: {
    name: storageAccountType
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource witnessStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: clusterWitnessStorageAccountName
  location: location
  sku: {
    name: storageAccountType
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionDays
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    accessPolicies: []
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
  dependsOn: [
    diagnosticStorageAccount
  ]
}

resource keyVaultName_Microsoft_Insights_service 'Microsoft.Insights/diagnosticsettings@2016-09-01' = {
  name: 'service'
  location: location
  scope: keyVault
  properties: {
    storageAccountId: diagnosticStorageAccount.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
}

resource SPConnectedMachineResourceManagerRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('ConnectedMachineResourceManagerRolePermissions',resourceGroup().id)
  scope: resourceGroup()
  properties:  {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/f5819b54-e033-4d82-ac66-4fec3cbf3f4c'
    principalId: hciResourceProviderObjectId
    principalType: 'ServicePrincipal'
  }
}

resource NodeAzureConnectedMachineResourceManagerRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, azureConnectedMachineResourceManagerRoleID)
  properties:  {
    roleDefinitionId: azureConnectedMachineResourceManagerRoleID
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]
resource NodeazureStackHCIDeviceManagementRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, azureStackHCIDeviceManagementRole)
  properties:  {
    roleDefinitionId: azureStackHCIDeviceManagementRole
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource NodereaderRoleIDPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, readerRoleID)
  properties:  {
    roleDefinitionId: readerRoleID
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource KeyVaultSecretsUserPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, keyVaultSecretUserRoleID)
  scope: keyVault
  properties:  {
    roleDefinitionId: keyVaultSecretUserRoleID
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource keyVaultName_domainAdminSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: domainAdminSecretName
  properties: {
    contentType: 'Secret'
    value: deploymentUserSecretValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_localAdminSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: localAdminSecretName
  properties: {
    contentType: 'Secret'
    value: localAdminSecretValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_arbDeploymentSpn 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: arbDeploymentSpnName
  properties: {
    contentType: 'Secret'
    value: arbDeploymentSpnValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_storageWitness 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: storageWitnessName
  properties: {
    contentType: 'Secret'
    value: base64(witnessStorageAccount.listKeys().keys[0].value)
    attributes: {
      enabled: true
    }
  }
}

