@description('Location of all resources to be deployed')
param location string = resourceGroup().location

@description('Custom Script to execute')
param installScriptUri string

param acceptTerms bool = false

@description('Random Value for Caching')
param utcValue string = utcNow()

param publisher string = 'bitnami'
param offer string = 'opencart-chart'
param plan string = 'default'

var identityName = 'scratch${uniqueString(resourceGroup().id)}'
var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleAssignmentName = guid(identityName, roleDefinitionId)

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}

resource identityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: resourceGroup()
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource customScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (acceptTerms) {
  name: 'customScript'
  location: location
  dependsOn: [
    identityRoleAssignDeployment
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', identityName)}': {
      }
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.15.0'
    timeout: 'PT30M'
    environmentVariables:  [
      {
        name: 'RESOURCEGROUP'
        secureValue: resourceGroup().name
      }
      {
        name: 'SUBSCRIPTION_ID'
        secureValue: subscription().subscriptionId
      }
      {
        name: 'PUBLISHER'
        secureValue: publisher
      }
      {
        name: 'OFFER'
        secureValue: offer
      }
      {
        name: 'PLAN'
        secureValue: plan
      }
      {
        name: 'CONFIG_GUID'
        secureValue: guid(utcValue)
      }    
    ]
    primaryScriptUri: installScriptUri
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}
