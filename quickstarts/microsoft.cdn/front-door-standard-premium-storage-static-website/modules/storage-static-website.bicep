@description('The location into which the Azure Storage resources should be deployed.')
param location string

@description('The name of the Azure Storage account to create. This must be globally unique.')
param accountName string

@description('The name of the SKU to use when creating the Azure Storage account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Premium_LRS'
])
param skuName string

@description('The name of the page to display when a user navigates to the root of your static website.')
param indexDocument string

@description('The name of the page to display when a user attempts to navigate to a page that does not exist in your static website.')
param errorDocument404Path string

var storageAccountContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab') // as per https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab
var storageAccountStorageBlobDataContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // as per https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=ba92f5b4-2d11-453d-a403-e96b0029c9fe
var managedIdentityName = 'StorageStaticWebsiteEnabler'
var deploymentScriptName = 'EnableStorageStaticWebsite'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentity.id, storageAccountContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: storageAccountContributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignmentStorageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentity.id, storageAccountStorageBlobDataContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: storageAccountStorageBlobDataContributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    roleAssignmentContributor
    roleAssignmentStorageBlobDataContributor
  ]
  properties: {
    azPowerShellVersion: '5.4'
    scriptContent: loadTextContent('../scripts/enable-storage-static-website.ps1')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT4H'
    arguments: '-ResourceGroupName ${resourceGroup().name} -StorageAccountName ${accountName} -IndexDocument ${indexDocument} -ErrorDocument404Path ${errorDocument404Path}'
  }
}

output staticWebsiteHostName string = replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
output storageResourceId string = storageAccount.id
output storageLocation string = storageAccount.location
