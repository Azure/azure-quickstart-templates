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
var managedIdentityName = 'StorageStaticWebsiteEnabler'
var deploymentScriptName = 'EnableStorageStaticWebsite'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
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

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentityName, storageAccountContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: storageAccountContributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
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
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '5.4'
    scriptContent: '''
    param (
      [string] $ResourceGroupName,
      [string] $StorageAccountName,
      [string] $IndexDocument,
      [string] $ErrorDocument404Path
    )

    $ErrorActionPreference = 'Stop'
    
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
    $ctx = $storageAccount.Context
    Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument404Path
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT4H'
    arguments: '-ResourceGroupName ${resourceGroup().name} -StorageAccountName ${accountName} -IndexDocument ${indexDocument} -ErrorDocument404Path ${errorDocument404Path}'
  }
}

output staticWebsiteHostName string = replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
output storageResourceId string = storageAccount.id
output storageLocation string = storageAccount.location
