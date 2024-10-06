@description('Location of all resources to be deployed')
param location string = resourceGroup().location

param utcValue string = utcNow()

@description('Private link service type')
param privateLinkServicenType string = 'Microsoft.Network/privateLinkServices'

@description('Private link service Name')
param privateLinkServicenName string

param helmOutput string

var identityName       = 'scratch${uniqueString(resourceGroup().id)}'
var roleDefinitionId   = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleAssignmentName = guid(roleDefinitionId, managedIdentity.id, resourceGroup().id)

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: identityName
  location: location
}

resource identityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId 
    principalId     : managedIdentity.properties.principalId
    principalType   : 'ServicePrincipal'
  }
}

resource customScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
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
    azCliVersion: '2.63.0'
    timeout: 'PT300M'
    environmentVariables: [
      {
        name: 'PRIVATE_LINK_SERVICE_NAME'
        secureValue: privateLinkServicenName
      }
      {
        name: 'PRIVATE_LINK_SERVICE_RG'
        secureValue: resourceGroup().name
      }
      {
        name: 'PRIVATE_LINK_SERVICE_TYPE'
        secureValue: privateLinkServicenType
      }
      {
        name: 'PLS_RESOURSENAME'
        secureValue: helmOutput
      }
    ]
    scriptContent: loadTextContent('../../scripts/privatelinkapproval.sh')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
