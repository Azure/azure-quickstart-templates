metadata description = 'Creates an experiment workspace'
param name string
param location string = resourceGroup().location
param tags object = {}
param logAnalyticsWorkspaceName string
param storageAccountName string
param identityName string

resource expIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

// Noite: no intellisense during private preview period
#disable-next-line BCP081
resource expWorkspace 'Microsoft.Experimentation/experimentWorkspaces@2024-11-30-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'Regular'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${expIdentity.id}': {} }
  }
  properties: {
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id
    logsExporterStorageAccountResourceId: storageAccount.id
  }
}


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview'  existing = {
  name: logAnalyticsWorkspaceName
}

resource storageAccount  'Microsoft.Storage/storageAccounts@2022-09-01'  existing = {
  name: storageAccountName
}

output expWorkspaceId string = expWorkspace.properties.expWorkspaceId
output expWorkspaceName string = expWorkspace.name
output expWorkspaceIdentityPrincipalId string = expIdentity.properties.principalId
