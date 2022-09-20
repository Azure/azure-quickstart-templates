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
param resourceGroupName string = 'bicepRg'

@description('Your Azure AD user identity (this identity will be granted admin rights to the Azure SQL instance).')
param principalName string = 'jaswitze@microsoft.com'

@description('Object ID for your Azure AD user identity (see the README.md file in the Azure Quickstart guide for instructions on how to get your Azure AD user object ID).')
param principalObjectId string = '8f07d5e5-fbee-43d7-84d6-a3f623f01e85'

@description('Name of the Azure Data Lake Storage Gen2 account')
param adlsAccountName string = 'bicepadls'

@description('Name of the Azure Data Factory instance')
param adfName string = 'bicepADF-js11'

@description('Name of the Azure Databricks workspace')
param azureDatabricksName string = 'bicep-databricks-ws'

@description('Do you want to deploy a new Azure Event Hub for streaming use cases? (true or false)')
param deployEh bool = false

@description('Name of the Azure Event Hub')
param eventHubName string = 'bicep-eventHub'

@description('Do you want to deploy a new Azure SQL Database (true or false)?')
param deploySqlDb bool = true

@description('Do you want to enable No Public IP (NPIP) for your Azure Databricks workspace? (true or false)')
param databricksNpip bool = false

@description('Do you want to deploy a new Azure Key Vault instance? (true or false)')
param deployAkv bool = true

@description('Name of Azure SQL logical server')
param azureSqlServerName string = 'bicep-sqlServer'

@description('Name of the SQL Database')
param azureSqlDatabaseName string = 'Sample DB'

@description('SQL administrator Username')
param sqlAdministratorLogin string = 'username123!'

@description('SQL administrator Password')
@secure()
param sqlAdministratorLoginPassword string = 'sqlUserPass188-'

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
    azureSqlCnString: deploySqlDb ? sqlDatabase.outputs.cnString : 'na'
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
    akvAccountName: 'bicep-akv-${uniqueString(bicepRG.id)}'
  }
}
