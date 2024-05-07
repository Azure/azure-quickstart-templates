@description('Specifies the name of the key vault.')
param keyVaultName string = 'kv${uniqueString(resourceGroup().id)}'

@description('Specifies the SKU to use for the key vault.')
param keyVaultSku object = {
  name: 'standard'
  family: 'A'
}

@description('Specifies the Azure location where the resources should be created.')
param location string = resourceGroup().location

var managedIdentityName = 'my-managed-identity'

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    tenantId: tenant().tenantId
    sku: keyVaultSku
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

@description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

module roleAssignment 'modules/role-assignment.bicep' = {
  name: 'role-assignment'
  params: {
    keyVaultName: keyVault.name
    roleAssignmentName: guid(keyVault.id, managedIdentity.properties.principalId, keyVaultAdministratorRoleDefinition.id)
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
  }
}
