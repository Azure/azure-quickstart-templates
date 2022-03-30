@description('The name of the Azure Container Registry')
param AcrName string = 'cr${uniqueString(resourceGroup().id)}'

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('An array of Azure RoleId that are required for the DeploymentScript resource')
param RbacRolesNeeded array = [
  'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor is needed to import ACR
]

@description('Name of the Managed Identity resource')
param managedIdName string = 'id-ContainerRegistryImport'

@description('An array of fully qualified images names to import')
param images array = [
  'docker.io/bitnami/external-dns:latest'
]

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: AcrName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource depScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdName
  location: location
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for roleDefId in RbacRolesNeeded: {
  name: guid(acr.id, roleDefId, depScriptId.id)
  scope: acr
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefId)
    principalId: depScriptId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

resource createAddCertificate 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for image in images: {
  name: 'ACR-Import-Certificate-${replace(replace(image,':',''),'/','-')}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${depScriptId.id}': {}
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
        name: 'AcrName'
        value: AcrName
      }
      {
        name: 'imageName'
        value: image
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -e

      echo "Importing Image: $imageName into ACR: $AcrName"
      az acr import -n $AcrName --source $imageName --force
    '''
    cleanupPreference: cleanupPreference
  }
}]

