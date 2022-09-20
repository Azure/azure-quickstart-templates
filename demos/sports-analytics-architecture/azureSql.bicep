@description('Resource location')
param location string

@description('Name of the SQL logical server')
param serverName string

@description('The name of the SQL Database.')
param sqlDBName string

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

@description('AAD Admin Username')
param principalName string

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param principalId string

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators:{
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: false
      login: principalName
      principalType: 'User'
      sid: principalId
      tenantId: subscription().tenantId
    }
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    capacity: 8
    family:'Gen5'
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  parent: sqlServer
  name: 'Allow Azure Services'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output cnString string = 'Data Source=${serverName}${environment().suffixes.sqlServerHostname};Initial Catalog=${sqlDBName};User ID = ${administratorLogin};Password=${administratorLoginPassword};'
