@description('Name of azure web app')
param siteName string

@description('Tier for Service Plan')
@allowed([
  'Basic'
  'Standard'
])
param servicePlanTier string = 'Standard'

@description('Size for Service Plan')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
])
param servicePlanSku string = 'S2'

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@maxLength(128)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL compute capacity in vCores (2,4,8,16,32)')
@allowed([
  2
  4
  8
  16
  32
])
param databaseSkuCapacity int = 2

@description('Azure database for PostgreSQL sku name ')
@allowed([
  'GP_Gen5_2'
  'GP_Gen5_4'
  'GP_Gen5_8'
  'GP_Gen5_16'
  'GP_Gen5_32'
  'MO_Gen5_2'
  'MO_Gen5_4'
  'MO_Gen5_8'
  'MO_Gen5_16'
  'MO_Gen5_32'
])
param databaseSkuName string = 'GP_Gen5_2'

@description('Azure database for PostgreSQL Sku Size ')
@allowed([
  102400
  51200
])
param databaseSkuSizeMB int = 51200

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
])
param databaseSkuTier string = 'GeneralPurpose'

@description('PostgreSQL version')
@allowed([
  '9.5'
  '9.6'
])
param postgresqlVersion string = '9.6'

@description('Azure database for PostgreSQL sku family')
param databaseskuFamily string = 'Gen5'

@description('Location for all the resources.')
param location string = resourceGroup().location

var databaseName = '${siteName}database'
var serverName = '${siteName}pgserver'
var jdbcSonarUserName = '${administratorLogin}@${serverName}'
var hostingPlanName = '${siteName}serviceplan'

resource site 'Microsoft.Web/sites@2022-03-01' = {
  name: siteName
  location: location
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|SONARQUBE'
    }
    serverFarmId: hostingPlan.id
  }
}

resource config 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: site
  name: 'appsettings'
  dependsOn: [
    database
  ]
  properties: {
    SONARQUBE_JDBC_URL: 'jdbc:postgresql://${server.properties.fullyQualifiedDomainName}:5432/${databaseName}?user=${jdbcSonarUserName}&password=${administratorLoginPassword}&ssl=true'
    SONARQUBE_JDBC_USERNAME: jdbcSonarUserName
    SONARQUBE_JDBC_PASSWORD: administratorLoginPassword
    SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: 'true'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  properties: {
    targetWorkerSizeId: 1
    reserved: true
    targetWorkerCount: 1
  }
  sku: {
    tier: servicePlanTier
    name: servicePlanSku
  }
  kind: 'linux'
}

resource server 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  location: location
  name: serverName
  sku: {
    name: databaseSkuName
    tier: databaseSkuTier
    capacity: databaseSkuCapacity
    size: '51200'
    family: databaseskuFamily
  }
  properties: {
    createMode: 'Default'
    version: postgresqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: databaseSkuSizeMB
    }
  }
}

resource firewall 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  parent: server
  name: '${serverName}firewall'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource database 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = {
  parent: server
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'English_United States.1252'
  }
}
