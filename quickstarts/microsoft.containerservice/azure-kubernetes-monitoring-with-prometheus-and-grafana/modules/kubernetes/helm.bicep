@description('Location of all resources to be deployed')
param location string = resourceGroup().location

//@description('The base URI where artifacts required by this template are located')
//param _artifactsLocation string = deployment().properties.templateLink.uri
//var installScriptUri = uri(_artifactsLocation, 'scripts/helm.sh${_artifactsLocationSasToken}')
//param _artifactsLocationSasToken string = ''


param clusterName string

param utcValue string = utcNow()

@description('Public Helm Repo Name')
param helmRepo string = 'prometheus-community'

@description('Public Helm Repo URL')
param helmRepoURL string = 'https://prometheus-community.github.io/helm-charts'

@description('Public Helm App')
param helmApp string = 'prometheus-community/kube-prometheus-stack'

@description('Public Helm App Name')
param helmAppName string = 'prometheus'

var helmRoleDefinitionId   = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var helmRoleAssignmentName = guid(helmRoleDefinitionId, helmManagedIdentity.id, resourceGroup().id)

resource helmManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'helmIdentityName'
  location: location
}

resource helmIdentityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: helmRoleAssignmentName
  properties: {
    roleDefinitionId: helmRoleDefinitionId 
    principalId     : helmManagedIdentity.properties.principalId
    principalType   : 'ServicePrincipal'
  }
}

resource helmCustomScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'helmCustomScript'
  location: location
  dependsOn: [
    helmIdentityRoleAssignDeployment
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${helmManagedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.63.0'
    timeout: 'PT300M'
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
    scriptContent: loadTextContent('../../scripts/helm.sh')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output helmOutput string = helmCustomScript.properties.outputs.plsName
