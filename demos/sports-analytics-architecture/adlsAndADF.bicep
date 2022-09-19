@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string

@description('Name of ADLS account')
param adlsAccountName string

@description('Name of ADF account')
param adfName string

@description('Name of ADLS Linked Service')
param adlsLinkedServiceName string

@description('Name of ADLS Linked Service')
param azureSQLLinkedServiceName string

@description('Azure SQL Connection String')
param azureSqlCnString string

@description('This is the built-in Storage Blob Data Contributor role')
resource sbdcRoleDefinitionResourceId 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource adlsAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: adlsAccountName
  location: resourceGroup().location
  sku: {name:'Standard_LRS'}
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
  }
}

@description('Assigns the user to Storage Blob Data Contributor Role')
resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: adlsAccount
  name: guid(adlsAccount.id, objectId, sbdcRoleDefinitionResourceId.id)
  properties: {
    roleDefinitionId: sbdcRoleDefinitionResourceId.id
    principalId: objectId
    principalType: 'User'
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
}

@description('Assigns the ADF Managed Identity to Storage Blob Data Contributor Role')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
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
  name: adlsLinkedServiceName
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      accountKey: adlsAccount.listKeys().keys[0].value
      url: adlsAccount.properties.primaryEndpoints.dfs
    }
  }
}

resource azureSqlDatabaseLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (azureSQLLinkedServiceName != 'na'){
  parent: dataFactory
  name: azureSQLLinkedServiceName
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: azureSqlCnString
    }
  }
}

output adfId string = dataFactory.identity.principalId
