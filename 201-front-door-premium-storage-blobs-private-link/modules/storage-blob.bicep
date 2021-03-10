@description('The location into which the deployment script resources should be deployed.')
param location string

@description('The name of the Azure Storage account that has already been created.')
param accountName string

@description('The name of the Azure Storage blob container that should contain the blob.')
param blobContainerName string

@description('The name of the blob to create with some dummy content.')
param blobName string

var storageAccountStorageBlobDataContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // as per https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=ba92f5b4-2d11-453d-a403-e96b0029c9fe
var managedIdentityName = 'StorageBlobCreator'
var deploymentScriptName = 'CreateStorageBlob'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: accountName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignmentStorageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentityName, storageAccountStorageBlobDataContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: storageAccountStorageBlobDataContributorRoleDefinitionId
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
    roleAssignmentStorageBlobDataContributor
  ]
  properties: {
    azPowerShellVersion: '5.4'
    scriptContent: '''
    param (
      [string] $ResourceGroupName,
      [string] $StorageAccountName,
      [string] $BlobContainerName,
      [string] $BlobName
    )

    $ErrorActionPreference = 'Stop'

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
    $ctx = $storageAccount.Context

    New-Item $BlobName
    Set-Content $BlobName '<h1>Welcome</h1>'
    Set-AzStorageBlobContent -Context $ctx -Container $BlobContainerName -File $BlobName -Blob $BlobName -Properties @{'ContentType' = 'text/html'}
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT4H'
    arguments: '-ResourceGroupName ${resourceGroup().name} -StorageAccountName ${accountName} -BlobContainerName ${blobContainerName} -BlobName ${blobName}'
  }
}
