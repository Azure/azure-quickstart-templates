@description('The name of the Azure Container Registry')
param AcrName string = 'cr${uniqueString(resourceGroup().id)}'

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('Azure RoleId that are required for the DeploymentScript resource to import images')
param rbacRoleNeeded string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor is needed to build ACR tasks

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('Name of the Managed Identity resource')
param managedIdentityName string = 'id-ContainerRegistryBuild'

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate')
param initialScriptDelay string = '30s'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

param gitRepositoryUrl string = 'https://github.com/Gordonby/eShopModernizing.git'

param gitBranch string = 'main'

param gitRepoDirectory string = 'eShopLegacyWebFormsSolution'

param imageTag string = string(dateTimeToEpoch(utcNow()))

param acrBuildPlatform string = 'windows'

var repo = '${gitRepositoryUrl}#${gitBranch}:${gitRepoDirectory}'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: AcrName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource newDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = if (!useExistingManagedIdentity) {
  name: managedIdentityName
  location: location
}

resource existingDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (useExistingManagedIdentity ) {
  name: managedIdentityName
  scope: resourceGroup(existingManagedIdentitySubId, existingManagedIdentityResourceGroupName)
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if (!empty(rbacRoleNeeded)) {
  name: guid(acr.id, rbacRoleNeeded, useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id)
  scope: acr
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', rbacRoleNeeded)
    principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource createImportImage 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ACR-Build-${repo}-${imageTag}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id}': {}
    }
  }
  kind: 'AzureCLI'
  dependsOn: [
    rbac
  ]
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.30.0'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'acrName'
        value: acr.name
      }
      {
        name: 'acrResourceGroup'
        value: resourceGroup().name
      }
      {
        name: 'tag'
        value: imageTag
      }
      {
        name: 'repo'
        value: repo
      }
      {
        name: 'platform'
        value: acrBuildPlatform
      }
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -e
      
      echo "Waiting on RBAC replication ($initialDelay)"
      sleep $initialDelay
      
      az acr build -g $acrResourceGroup -r $acrName -t $tag $repo --platform $platform
    '''
    cleanupPreference: cleanupPreference
  }
}
