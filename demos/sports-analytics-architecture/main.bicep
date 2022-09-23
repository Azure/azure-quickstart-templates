@description('Resource Location.')
param location string = resourceGroup().location

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
param deployEh bool = true

@description('Name of the Azure Event Hub')
param eventHubName string

@description('Do you want to deploy a new Azure SQL Database (true or false)?')
param deploySqlDb bool = true

@description('Do you want to enable No Public IP (NPIP) for your Azure Databricks workspace? (true or false)')
param databricksNpip bool = true

@description('Do you want to deploy a new Azure Key Vault instance? (true or false)')
param deployAkv bool = true

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

var akvRoleName = 'Key Vault Secrets User'

var akvRoleIdMapping = {
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = if(deployEh) {
  name: '${eventHubName}ns'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = if(deployEh) {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = if(deploySqlDb) {
  name: azureSqlServerName
  location: location
  properties: {
    minimalTlsVersion: '1.2'
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    administrators:{
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: false
      login: principalName
      sid: principalObjectId
      tenantId: subscription().tenantId
    }
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01' = if(deploySqlDb) {
  parent: sqlServer
  name: azureSqlDatabaseName
  location: location
  sku: {
    capacity: 8
    family:'Gen5'
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = if(deploySqlDb) {
  parent: sqlServer
  name: 'Allow Azure Services'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

@description('This is the built-in Storage Blob Data Contributor role')
resource sbdcRoleDefinitionResourceId 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource adlsAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: adlsAccountName
  location: location
  sku: {name:'Standard_LRS'}
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
  }
}

@description('Assigns the user to Storage Blob Data Contributor Role')
resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: adlsAccount
  name: guid(adlsAccount.id, principalObjectId, sbdcRoleDefinitionResourceId.id)
  properties: {
    roleDefinitionId: sbdcRoleDefinitionResourceId.id
    principalId: principalObjectId
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

@description('Assigns the ADF Managed Identity to Storage Blob Data Contributor Role')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: adlsAccount
  name: guid(adlsAccount.id, dataFactory.id, sbdcRoleDefinitionResourceId.id)
  properties: {
    roleDefinitionId: sbdcRoleDefinitionResourceId.id
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource adlsLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: '${adlsAccountName}-linkedService'
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      accountKey: adlsAccount.listKeys().keys[0].value
      url: adlsAccount.properties.primaryEndpoints.dfs
    }
  }
}

resource azureSqlDatabaseLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if(deploySqlDb){
  parent: dataFactory
  name: '${azureSqlServerName}-linkedService'
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: 'Data Source=${azureSqlServerName}${environment().suffixes.sqlServerHostname};Initial Catalog=${azureSqlDatabaseName};User ID = ${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};'
    }
  }
}

resource databricksWorkspace 'Microsoft.Databricks/workspaces@2018-04-01' = {
  name: azureDatabricksName
  location: location
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId: managedResourceGroup.id
    parameters: {
      enableNoPublicIp: {
        value: databricksNpip
      }
    }
  }
}

resource managedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope: subscription()
  name: 'databricks-rg-${azureDatabricksName}-${uniqueString(azureDatabricksName, resourceGroup().id)}'
}

resource akv 'Microsoft.KeyVault/vaults@2022-07-01' = if (deployAkv) {
  name: akvName
  location: location
  properties: {
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource userAkvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (deployAkv) {
  name: guid(akvRoleIdMapping[akvRoleName],principalObjectId,akv.id)
  scope: akv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', akvRoleIdMapping[akvRoleName])
    principalId: principalObjectId
  }
}

resource spAkvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(akvRoleIdMapping[akvRoleName],dataFactory.id,akv.id)
  scope: akv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', akvRoleIdMapping[akvRoleName])
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource azureKeyVaultLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if(deployAkv){
  parent: dataFactory
  name: '${akvName}-linkedService'
  properties: {
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: akv.properties.vaultUri
    }
  }
}
