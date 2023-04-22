@description('Server Name for Azure database for PostgreSQL Flexible Server')
param serverName string

@description('Name for DNS Private Zone')
param dnsZoneName string 

@description('Fully Qualified DNS Private Zone')
param dnsZoneFqdn string = '${dnsZoneName}.postgres.database.azure.com'

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL sku name ')
param skuName string = 'Standard_D2ds_v4'

@description('Azure database for PostgreSQL storage Size ')
param StorageSizeGB int = 32

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
  'Burstable'
])
param SkuTier string = 'GeneralPurpose'

@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
  '14'
])
param postgresqlVersion string = '14'

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

@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.0.0.0/24'

@description('Subnet Address Prefix')
param postgresqlSubnetPrefix string = '10.0.0.0/28'

@description('Composing the subnetId')
var postgresqlSubnetId =  '${vnetLink.properties.virtualNetwork.id}/subnets/${subnetName}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }

resource subnet 'subnets@2021-05-01' = {
    name: subnetName
    properties: {
      addressPrefix: postgresqlSubnetPrefix
      delegations: [
        {
          name: 'dlg-Microsoft.DBforPostgreSQL-flexibleServers'
          properties: {
            serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        }
      ]
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneFqdn
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: vnet.name
  parent: dnszone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource postgresqlDbServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: SkuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: {
      storageSizeGB: StorageSizeGB
    }
    createMode: 'Default'
    version: postgresqlVersion
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: postgresqlSubnetId
      privateDnsZoneArmResourceId: dnszone.id
    }
  }
}

output postgreSQLHostname string = '${serverName}.${dnszone.name}'
output postgreSQLSubnetId string = postgresqlSubnetId
output vnetId string = vnet.id
output privateDnsId string = dnszone.id
output privateDnsName string = dnszone.name
