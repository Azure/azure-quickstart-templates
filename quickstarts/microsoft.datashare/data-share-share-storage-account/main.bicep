@description('Specify a project name that is used to generate resource names.')
param projectName string

@description('Specify the location for the resources.')
param location string = resourceGroup().location

@description('Specify an email address for receiving data share invitations.')
param invitationEmail string

@description('Specify snapshot schedule recurrence.')
@allowed([
  'Day'
  'Hour'
])
param syncInterval string = 'Day'

@description('Specify snapshot schedule start time.')
param syncTime string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

var storageAccountName = '${projectName}store'
var containerName = '${projectName}container'
var dataShareAccountName = '${projectName}shareaccount'
var dataShareName = '${projectName}share'
var roleAssignmentName = guid(sa.id, storageBlobDataReaderRoleDefinitionId, dataShareAccount.id)
var inviteName = '${dataShareName}invite'
var storageBlobDataReaderRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')

resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${sa.name}/default/${containerName}'
}

resource dataShareAccount 'Microsoft.DataShare/accounts@2021-08-01' = {
  name: dataShareAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource dataShare 'Microsoft.DataShare/accounts/shares@2021-08-01' = {
  parent: dataShareAccount
  name: dataShareName
  properties: {
    shareKind: 'CopyBased'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: sa
  name: roleAssignmentName
  properties: {
    roleDefinitionId: storageBlobDataReaderRoleDefinitionId
    principalId: dataShareAccount.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource dataSet 'Microsoft.DataShare/accounts/shares/dataSets@2021-08-01' = {
  parent: dataShare
  name: containerName
  kind: 'Container'
  dependsOn: [ // this is used to delay this resource until the roleAssignment replicates
    container
    invitation
    synchronizationSetting
  ]
  properties: {
    subscriptionId: subscription().subscriptionId
    resourceGroup: resourceGroup().name
    storageAccountName: sa.name
    containerName: containerName
  }
}

resource invitation 'Microsoft.DataShare/accounts/shares/invitations@2021-08-01' = {
  parent: dataShare
  name: inviteName
  properties: {
    targetEmail: invitationEmail
  }
}

resource synchronizationSetting 'Microsoft.DataShare/accounts/shares/synchronizationSettings@2021-08-01' = {
  parent: dataShare
  name: '${dataShareName}_synchronizationSetting'
  kind: 'ScheduleBased'
  properties: {
    recurrenceInterval: syncInterval
    synchronizationTime: syncTime
  }
}
