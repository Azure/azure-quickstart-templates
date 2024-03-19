@description('Name of Azure Web App')
param siteName string = 'sonarqube-${uniqueString(resourceGroup().id)}'

@description('The version of the Sonarqube container image to use. Only versions of Sonarqube known to be compatible with Azure App Service Web App for Containers are available.')
@allowed([
  '7.7-community'
  '7.6-community'
  '7.5-community'
  '7.4-community'
  '7.1'
  '7.1-alpine'
  '7.0'
  '7.0-alpine'
  '6.7.5'
  '6.7.5-alpine'
  '6.7.4'
  '6.7.4-alpine'
  '6.7.3'
  '6.7.3-alpine'
  '6.7.2'
  '6.7.2-alpine'
  '6.7.1'
  '6.7.1-alpine'
  'latest'
])
param sonarqubeImageVersion string = '7.7-community'

@description('App Service Plan Pricing Tier')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1V2'
  'P2V2'
  'P2V3'
])
param servicePlanPricingTier string = 'S2'

@description('App Service Capacity')
@minValue(1)
@maxValue(3)
param servicePlanCapacity int = 1

@description('Azure SQL Server Administrator Username')
@minLength(1)
param sqlServerAdministratorUsername string

@description('Azure SQL Server Administrator Password')
@minLength(12)
@maxLength(128)
@secure()
param sqlServerAdministratorPassword string

@description('Azure SQL Database SKU Name')
@allowed([
  'GP_Gen4_1'
  'GP_Gen4_2'
  'GP_Gen4_3'
  'GP_Gen4_4'
  'GP_Gen4_5'
  'GP_Gen4_6'
  'GP_Gen4_7'
  'GP_Gen4_8'
  'GP_Gen4_9'
  'GP_Gen4_10'
  'GP_Gen4_16'
  'GP_Gen4_24'
  'GP_Gen5_2'
  'GP_Gen5_4'
  'GP_Gen5_6'
  'GP_Gen5_8'
  'GP_Gen5_10'
  'GP_Gen5_12'
  'GP_Gen5_14'
  'GP_Gen5_16'
  'GP_Gen5_18'
  'GP_Gen5_20'
  'GP_Gen5_24'
  'GP_Gen5_32'
  'GP_Gen5_40'
  'GP_Gen5_80'
  'GP_S_Gen5_1'
  'GP_S_Gen5_2'
  'GP_S_Gen5_4'
])
param sqlDatabaseSkuName string = 'GP_S_Gen5_2'

@description('Azure SQL Database Storage Max Size in GB')
@minValue(1)
@maxValue(1024)
param sqlDatabaseSkuSizeGB int = 16

@description('Location for all the resources.')
param location string = resourceGroup().location

var databaseName = 'sonarqube'
var sqlServerName = '${siteName}-sql'
var servicePlanName = '${siteName}-asp'
var servicePlanPricingTiers = {
  F1: {
    tier: 'Free'
  }
  B1: {
    tier: 'Basic'
  }
  B2: {
    tier: 'Basic'
  }
  B3: {
    tier: 'Basic'
  }
  S1: {
    tier: 'Standard'
  }
  S2: {
    tier: 'Standard'
  }
  S3: {
    tier: 'Standard'
  }
  P1V2: {
    tier: 'Standard'
  }
  P2V2: {
    tier: 'Standard'
  }
  P2V3: {
    tier: 'Standard'
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: servicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: servicePlanPricingTier
    tier: servicePlanPricingTiers[servicePlanPricingTier].tier
    capacity: servicePlanCapacity
  }
  kind: 'linux'
}

resource site 'Microsoft.Web/sites@2023-01-01' = {
  name: siteName
  location: location
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|sonarqube:${sonarqubeImageVersion}'
    }
    serverFarmId: servicePlan.id
  }
}

resource siteAppSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: site
  name: 'appsettings'
  properties: {
    SONARQUBE_JDBC_URL: 'jdbc:sqlserver://${sqlServer.properties.fullyQualifiedDomainName};databaseName=${databaseName};encrypt=true;trustServerCertificate=false;hostNameInCertificate=${replace(sqlServer.properties.fullyQualifiedDomainName, '${sqlServerName}.', '*.')};loginTimeout=30;'
    SONARQUBE_JDBC_USERNAME: sqlServerAdministratorUsername
    SONARQUBE_JDBC_PASSWORD: sqlServerAdministratorPassword
    'sonar.path.data': '/home/sonarqube/data'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  location: location
  name: sqlServerName
  properties: {
    administratorLogin: sqlServerAdministratorUsername
    administratorLoginPassword: sqlServerAdministratorPassword
    version: '12.0'
  }
}

resource sqlServerFirewall 'Microsoft.Sql/servers/firewallrules@2021-11-01' = {
  parent: sqlServer
  name: '${sqlServerName}firewall'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: sqlDatabaseSkuName
    tier: 'GeneralPurpose'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CS_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: (((sqlDatabaseSkuSizeGB * 1024) * 1024) * 1024)
  }
}
