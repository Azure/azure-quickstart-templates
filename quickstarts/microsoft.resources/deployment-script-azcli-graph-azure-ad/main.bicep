@description('The name of the user-assigned managed identity that has permission to create Azure AD applications.')
param managedIdentityName string

@description('The name of the resource group that contains the user-assigned managed identity.')
param managedIdentityResourceGroupName string = resourceGroup().name

@description('The display name of the application to create in Azure AD.')
param azureADApplicationName string

@description('The location that the Azure resources should be deployed to.')
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
  scope: resourceGroup(managedIdentityResourceGroupName)
}

resource createAzureADApplicationScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createAzureADApplication'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: '1'
    azCliVersion: '2.40.0'
    environmentVariables: [
      {
        name: 'AzureADApplicationName'
        value: azureADApplicationName
      }
    ]
    scriptContent: loadTextContent('scripts/create-application.sh')
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output applicationObjectId string = createAzureADApplicationScript.properties.outputs.applicationObjectId
output applicationClientId string = createAzureADApplicationScript.properties.outputs.applicationClientId
output servicePrincipalObjectId string = createAzureADApplicationScript.properties.outputs.servicePrincipalObjectId
