@description('Name of the SQL server')
param sqlServerName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL Server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL Server.')
@secure()
param sqlAdministratorLoginPassword string

@description('The name of the auditing storage account.')
param storageAccountName string = 'sqlaudit${uniqueString(resourceGroup().id)}'

@description('Enable Auditing to storage behind Virtual Network or firewall rules. The user deploying the template must have an administrator or owner permissions.')
param isStorageBehindVnet bool = false

@description('Enable Auditing of Microsoft support operations (DevOps)')
param isMSDevOpsAuditEnabled bool = false

var storageBlobContributor = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var uniqueRoleGuid = guid(storageAccount.id, storageBlobContributor, sqlServer.id)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: (isStorageBehindVnet ? 'Deny' : 'Allow')
    }
  }
}

resource storageAccount_Microsoft_Authorization_uniqueRoleGuid 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (isStorageBehindVnet) {
  scope: storageAccount
  name: uniqueRoleGuid
  properties: {
    roleDefinitionId: storageBlobContributor
    principalId: sqlServer.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  location: location
  name: sqlServerName
  identity: (isStorageBehindVnet ? json('{"type":"SystemAssigned"}') : null)
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
  tags: {
    displayName: sqlServerName
  }
}

resource sqlServer_DefaultAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-08-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: storageAccount.properties.primaryEndpoints.blob
    storageAccountAccessKey: (isStorageBehindVnet ? null : storageAccount.listKeys().keys[0].value)
    storageAccountSubscriptionId: subscription().subscriptionId
    isStorageSecondaryKeyInUse: false
  }
}

resource sqlServer_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-08-01-preview' = if (isMSDevOpsAuditEnabled) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    storageEndpoint: storageAccount.properties.primaryEndpoints.blob
    storageAccountAccessKey: (isStorageBehindVnet ? null : storageAccount.listKeys().keys[0].value)
    storageAccountSubscriptionId: subscription().subscriptionId
  }
  dependsOn: [
    storageAccount_Microsoft_Authorization_uniqueRoleGuid
  ]
}
