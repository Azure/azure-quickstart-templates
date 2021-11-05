@description('Server Name for Azure database for PostgreSQL')
param serverName string

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL compute capacity in vCores (2,4,8,16,32)')
param skuCapacity int = 2

@description('Azure database for PostgreSQL sku name ')
param skuName string = 'GP_Gen5_2'

@description('Azure database for PostgreSQL Sku Size ')
param skuSizeMB int = 51200

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'Basic'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'GeneralPurpose'

@description('Azure database for PostgreSQL sku family')
param skuFamily string = 'Gen5'

@description('PostgreSQL version')
@allowed([
  '9.5'
  '9.6'
  '10'
  '10.0'
  '10.2'
  '11'
])
param postgresqlVersion string = '11'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('PostgreSQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('Virtual Network Name')
param virtualNetworkName string = 'azure_postgresql_vnet'

@description('Subnet Name')
param subnetName string = 'azure_postgresql_subnet'

@description('Virtual Network RuleName')
param virtualNetworkRuleName string = 'AllowSubnet'

@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet Address Prefix')
param subnetPrefix string = '10.0.0.0/16'

var firewallrules = [
  {
    Name: 'rule1'
    StartIpAddress: '0.0.0.0'
    EndIpAddress: '255.255.255.255'
  }
  {
    Name: 'rule2'
    StartIpAddress: '0.0.0.0'
    EndIpAddress: '255.255.255.255'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetPrefix
  }
}

resource server 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: skuTier
    capacity: skuCapacity
    size: '${skuSizeMB}'
    family: skuFamily
  }
  properties: {
    createMode: 'Default'
    version: postgresqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: skuSizeMB
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
  }

  resource virtualNetworkRule 'virtualNetworkRules@2017-12-01' = {
    name: virtualNetworkRuleName
    properties: {
      virtualNetworkSubnetId: subnet.id
      ignoreMissingVnetServiceEndpoint: true
    }
  }
}

@batchSize(1)
resource firewallRules 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = [for rule in firewallrules: {
  name: '${server.name}/${rule.Name}'
  properties: {
    startIpAddress: rule.StartIpAddress
    endIpAddress: rule.EndIpAddress
  }
}]
