@description('Location of all resources to be deployed')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access artifacts')
@secure()
param _artifactsLocationSasToken string = ''

param clusterName string = ''

param utcValue string = utcNow()

@description('Public Helm Repo Name')
param helmRepo string = 'azure-marketplace'

@description('Public Helm Repo URL')
param helmRepoURL string = 'https://marketplace.azurecr.io/helm/v1/repo'

@description('Public Helm App')
param helmApp string = 'azure-marketplace/wordpress'

@description('Public Helm App Name')
param helmAppName string = 'my-wordpress'

var installScriptUri = uri(_artifactsLocation, 'scripts/helm.sh${_artifactsLocationSasToken}')

var identityName       = 'scratch${uniqueString(resourceGroup().id)}'
var roleDefinitionId   = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleAssignmentName = guid(roleDefinitionId, managedIdentity.id, resourceGroup().id)

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}

resource identityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: resourceGroup()
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId 
    principalId     : managedIdentity.properties.principalId
    principalType   : 'ServicePrincipal'
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
      {
        name: 'CLUSTER_NAME'
        secureValue: clusterName
      }
      {
        name: 'HELM_REPO'
        secureValue: helmRepo
      }
      {
        name: 'HELM_REPO_URL'
        secureValue: helmRepoURL
      }
      {
        name: 'HELM_APP'
        secureValue: helmApp
      }
      {
        name: 'HELM_APP_NAME'
        secureValue: helmAppName
      }
    ]
    primaryScriptUri: installScriptUri
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}
