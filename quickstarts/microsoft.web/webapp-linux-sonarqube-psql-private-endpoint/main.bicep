targetScope = 'resourceGroup'

@description('Name of Azure Web App')
param siteName string

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('Database administrator login name')
@minLength(1)
@secure()
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@maxLength(128)
@secure()
param administratorLoginPassword string

@description('The tier of the particular SKU, e.g. Burstable.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param postgresFlexibleServersSkuTier string

@description('The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.')
@allowed([
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_D16s_v3'
  'Standard_D32s_v3'
  'Standard_D48s_v3'
  'Standard_D64s_v3'
  'Standard_D2ds_v4'
  'Standard_D4ds_v4'
  'Standard_D8ds_v4'
  'Standard_D16ds_v4'
  'Standard_D32ds_v4'
  'Standard_D48ds_v4'
  'Standard_D64ds_v4'
  'Standard_E2s_v3'
  'Standard_E4s_v3'
  'Standard_E8s_v3'
  'Standard_E16s_v3'
  'Standard_E32s_v3'
  'Standard_E48s_v3'
  'Standard_E64s_v3'
  'Standard_E2ds_v4'
  'Standard_E4ds_v4'
  'Standard_E8ds_v4'
  'Standard_E16ds_v4'
  'Standard_E20ds_v4'
  'Standard_E32ds_v4'
  'Standard_E48ds_v4'
  'Standard_E64ds_v4'
])
param postgresFlexibleServersSkuName string

@description('The version of a PostgreSQL server')
@allowed([
  '11'
  '12'
  '13'
])
param postgresFlexibleServersversion string

@description('The mode to create a new PostgreSQL server.')
@allowed([
  'Create'
  'Default'
  'PointInTimeRestore'
  'Update'
])
param createMode string

@description('Sku and size of App Service Plan (F1 does not support virtual network integration)')
@allowed([
 'B1'
 'B2'
 'B3'
 'D1'
 'I1'
 'I1v2'
 'I2v2'
 'I3v2'
 'P1V2'
 'P1V3'
 'P2V2'
 'P2V3'
 'P3V2'
 'P3V3'
 'S1'
 'S2'
 'S3'
])
param appServicePlanSkuName string

var appServicePlanName = '${siteName}serviceplan'
var virtualNetworkName = '${siteName}-vnet'
var privateDNSZoneName = '${siteName}.private.postgres.database.azure.com'
var privateDNSZoneLinkName = '${siteName}privatelink'
var postgresFlexibleServersName = '${siteName}postgres'



resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'appNet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: [
            {
              name: 'appDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
        }
      }
      {
        name: 'dbNet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'dbDelegation'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
    ]
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-01-01' = {
  name: privateDNSZoneName
  location: 'global'
}

resource privateDNSZoneRecordA 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateDNSZone
  name: uniqueString(siteName)
  properties: {
    ttl: 30
    aRecords: [
      {
        ipv4Address: '10.0.1.4'
      }
    ]
  }
}


resource privateDNSZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: privateDNSZoneLinkName
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource postgresFlexibleServers 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: postgresFlexibleServersName
  location: location
  sku: {
    name: postgresFlexibleServersSkuName
    tier: postgresFlexibleServersSkuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    createMode: createMode
    network: {
      delegatedSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, 'dbNet')
      privateDnsZoneArmResourceId: privateDNSZone.id
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    version: postgresFlexibleServersversion
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: appServicePlanSkuName
  }
}

resource webApplication 'Microsoft.Web/sites@2021-03-01' = {
  name: siteName
  location: location
  properties: {
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, 'appNet')
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|sonarqube'
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '9000'
        }
        {
          name: 'SONAR_ES_BOOTSTRAP_CHECKS_DISABLE'
          value: 'true'
        }
        {
          name: 'SONAR_JDBC_URL'
          value: 'jdbc:postgresql://${postgresFlexibleServers.properties.fullyQualifiedDomainName}:5432/postgres'
        }
        {
          name: 'SONAR_JDBC_USERNAME'
          value: administratorLogin
        }
        {
          name: 'SONAR_JDBC_PASSWORD'
          value: administratorLoginPassword
        }
      ]
    }
  }
}

