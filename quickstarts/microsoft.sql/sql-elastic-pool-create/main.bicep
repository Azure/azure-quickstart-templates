@description('The SQL Server administrator login')
param administratorLogin string

@description('The SQL Server administrator login password.')
@secure()
param administratorLoginPassword string

@description('The SQL Server name.')
param serverName string

@description('The Elastic Pool name.')
param elasticPoolName string

@description('The Elastic Pool edition.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'GP_Gen5'
  'BC_Gen5'
])
param edition string = 'Standard'

@description('The Elastic Pool DTU or nomber of vcore.')
param capacity int

@description('The Elastic Pool database capacity min.')
param databaseCapacityMin int = 0

@description('The Elastic Pool database capacity max.')
param databaseCapacityMax int

@description('The SQL Databases names.')
param databasesNames array = [
  'db1'
  'db2'
]

@description('The SQL Database collation.')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Location for all resources.')
param location string = resourceGroup().location

var editionToSkuMap = {
  Basic: {
    name: 'BasicPool'
    tier: 'Basic'
  }
  Standard: {
    name: 'StandardPool'
    tier: 'Standard'
  }
  Premium: {
    name: 'PremiumPool'
    tier: 'Premium'
  }
  GP_Gen5: {
    family: 'Gen5'
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
  }
  BC_Gen5: {
    family: 'Gen5'
    name: 'BC_Gen5'
    tier: 'BusinessCritical'
  }
}
var skuName = editionToSkuMap[edition].name
var skuTier = editionToSkuMap[edition].tier

resource server 'Microsoft.Sql/servers@2020-02-02-preview' = {
  location: location
  name: serverName
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

resource serverName_elasticPool 'Microsoft.Sql/servers/elasticPools@2020-02-02-preview' = {
  parent: server
  location: location
  name: elasticPoolName
  sku: {
    name: skuName
    tier: skuTier
    capacity: capacity
  }
  properties: {
    perDatabaseSettings: {
      minCapacity: databaseCapacityMin
      maxCapacity: databaseCapacityMax
    }
  }
}

resource serverName_databasesNames 'Microsoft.Sql/servers/databases@2020-02-02-preview' = [
  for item in databasesNames: {
    parent: server
    name: item
    location: location
    sku: {
      name: 'ElasticPool'
      tier: skuTier
      capacity: 0
    }
    properties: {
      collation: databaseCollation
      elasticPoolId: serverName_elasticPool.id
    }
  }
]

resource serverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallrules@2020-02-02-preview' = {
  parent: server
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}
