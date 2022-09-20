targetScope = 'subscription'

@description('Resource Location.')
@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
  'westus3'
  'centralus'
  'northcentralus'
  'southcentralus'
  'northeurope'
  'westeurope'
  'uksouth'
  'francecentral'
  'brazilsouth'
  'canadaeast'
  'canadacentral'
  'australiaeast'
  'centralindia'
  'japaneast'
  'uaecentral'
])
param location string = 'eastus2'

@description('Resource Group Name')
param resourceGroupName string

@description('Your Azure AD user identity (this identity will be granted admin rights to the Azure SQL instance).')
param principalName string

@description('Object ID for your Azure AD user identity (see the README.md file in the Azure Quickstart guide for instructions on how to get your Azure AD user object ID).')
param principalObjectId string

@description('Name of the Azure Data Lake Storage Gen2 account')
param adlsAccountName string

@description('Name of the Azure Data Factory instance')
param adfName string

@description('Name of the Azure Databricks workspace')
param azureDatabricksName string

@description('Do you want to deploy a new Azure Event Hub for streaming use cases? (true or false)')
param deployEh bool

@description('Name of the Azure Event Hub')
param eventHubName string

@description('Do you want to deploy a new Azure SQL Database (true or false)?')
param deploySqlDb bool

@description('Do you want to enable No Public IP (NPIP) for your Azure Databricks workspace? (true or false)')
param databricksNpip bool

@description('Do you want to deploy a new Azure Key Vault instance? (true or false)')
param deployAkv bool

@description('Name of the Azure Key Vault')
param akvName string

@description('Name of Azure SQL logical server')
param azureSqlServerName string

@description('Name of the SQL Database')
param azureSqlDatabaseName string

@description('SQL administrator Username')
param sqlAdministratorLogin string

@description('SQL administrator Password')
@secure()
param sqlAdministratorLoginPassword string

resource bicepRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  properties: {}
}

module eventHub 'eventHub.bicep' = if(deployEh) {
  scope: bicepRG
  name: 'eventHub'
  params: {
    location: location
    projectName: eventHubName
  }
}

module sqlDatabase 'azureSql.bicep' = if(deploySqlDb) {
  name: 'sqlDatabase'
  scope: bicepRG
  params: {
    location: location
    serverName: azureSqlServerName
    sqlDBName: azureSqlDatabaseName
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    principalName: principalName
    principalId: principalObjectId
  }
}

module adlsAndAdf 'adlsAndADF.bicep' = {
  name: 'adlsAndAdf'
  scope: bicepRG
  params: {
    location: location
    objectId: principalObjectId
    adlsAccountName: adlsAccountName
    adfName: adfName
    adlsLinkedServiceName: '${adlsAccountName}-linkedService'
    azureSQLLinkedServiceName: deploySqlDb ?'${azureSqlServerName}-linkedService' : 'na'
    azureSqlCnString: deploySqlDb ? 'Data Source=${azureSqlServerName}${environment().suffixes.sqlServerHostname};Initial Catalog=${azureSqlDatabaseName};User ID = ${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};' : 'na'
  }
}

module azureDatabricksws 'databricks.bicep' = {
  name: 'databricks'
  scope: bicepRG
  params: {
    location: location
    disablePublicIp: databricksNpip
    workspaceName: azureDatabricksName
  }
}

module akv 'akv.bicep' = if (deployAkv) {
  name: 'akv'
  scope: bicepRG
  params: {
    location: location
    objectId: principalObjectId
    spId: adlsAndAdf.outputs.adfId
    akvAccountName: akvName
  }
}
