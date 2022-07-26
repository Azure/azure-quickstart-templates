@description('Location of all resources to be deployed')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access artifacts')
@secure()
param _artifactsLocationSasToken string = ''
param utcValue string = utcNow()

var installScriptUri = uri(_artifactsLocation, 'scripts/helm.sh${_artifactsLocationSasToken}')

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
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource customScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'customScript'
  location: location
  dependsOn: [
    identityRoleAssignDeployment
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.10.1'
    timeout: 'PT30M'
    environmentVariables: [
      {
        name: 'RESOURCEGROUP'
        secureValue: resourceGroup().name
      }
    ]
    primaryScriptUri: installScriptUri
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}
