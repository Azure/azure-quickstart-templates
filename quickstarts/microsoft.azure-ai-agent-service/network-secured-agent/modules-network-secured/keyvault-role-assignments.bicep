// Assigns the necessary roles to the AI project

param keyvaultName string
param UAIPrincipalId string
param suffix string

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
  scope: resourceGroup()
}

resource keyVaultSecretOfficer 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  scope: keyvault
}

// search roles
resource keyVaultContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
  scope: resourceGroup()
}

resource keyVaultContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(suffix, keyVaultContributor.id, keyvault.id)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: keyVaultContributor.id
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretOfficerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(suffix, keyVaultSecretOfficer.id, keyvault.id)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: keyVaultSecretOfficer.id
    principalType: 'ServicePrincipal'
  }
}
