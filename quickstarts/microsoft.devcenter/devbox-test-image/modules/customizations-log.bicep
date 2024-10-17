param guidId string = newGuid()
param location string = resourceGroup().location
param builderIdentity string
param imageBuildStagingResourceGroupName string

var builderIdentityParts = split(builderIdentity, '/')
var builderIdentitySubscription = builderIdentityParts[2]
var builderIdentityResourceGroup = builderIdentityParts[4]
var builderIdentityName = last(builderIdentityParts)

resource builderIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: builderIdentityName
  scope: resourceGroup(builderIdentitySubscription, builderIdentityResourceGroup)
}

// Get unique suffix from the builder identity id that is in the format of identity-builder-<uniqueSuffix>
var uniqueSuffix = split(builderIdentityName, '-')[2]

resource logsStorage 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: 'logs${uniqueSuffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
  }
}

var storageBlobDataContributorRoleDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)

resource logsStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(builderIdentity, storageBlobDataContributorRoleDefinitionId, resourceGroup().id, subscription().id)
  scope: logsStorage
  properties: {
    principalId: builderIdentityResource.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributorRoleDefinitionId
  }
}

resource copyCustomizationsLogScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'copy-customizations-log-script-${uniqueString(resourceGroup().name)}'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${builderIdentity}': {}
    }
  }
  dependsOn: [
    logsStorageRoleAssignment
  ]
  properties: {
    forceUpdateTag: guidId
    azPowerShellVersion: '9.7'
    environmentVariables: [
      {
        name: 'imageBuildStagingResourceGroupName'
        value: imageBuildStagingResourceGroupName
      }
      {
        name: 'logsStorageAccountName'
        value: logsStorage.name
      }
    ]
    scriptContent: loadTextContent('../tools/get-customizations-log.ps1')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: copyCustomizationsLogScript
  name: 'default'
}

output copyCustomizationsLogScriptResult string = logs.properties.log
