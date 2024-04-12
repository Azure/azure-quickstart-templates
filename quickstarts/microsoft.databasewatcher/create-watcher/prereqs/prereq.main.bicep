@description('The name of the SQL logical server')
param serverName string = uniqueString('sql', resourceGroup().id)

@description('Location for all resources')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server')
param administratorLogin string

@description('The administrator password of the SQL logical server')
@secure()
param administratorLoginPassword string

@description('The name of the key vault')
param keyVaultName string = uniqueString('akv', resourceGroup().id)

resource server 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

output logicalServerSubscriptionId string = subscription().subscriptionId
output logicalServerResourceGroupName string = resourceGroup().name
output logicalServerName string = serverName
output keyVaultSubscriptionId string = subscription().subscriptionId
output keyVaultResourceGroupName string = resourceGroup().name
output keyVaultName string = keyVaultName
