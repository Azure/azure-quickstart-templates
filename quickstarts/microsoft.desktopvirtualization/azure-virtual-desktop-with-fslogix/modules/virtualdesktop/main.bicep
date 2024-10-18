param location string

param hostPoolName string
param applicationGroupName string
param workspaceName string
param hostPoolProperties object
param applicationGroupProperties object
param workspaceProperties object
param avdRoleDefinitionId string
param GroupObjectIds array

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-04-08-preview' = {
  location: location
  name: hostPoolName
  properties: {
    friendlyName: hostPoolProperties.friendlyName
    description: hostPoolProperties.description
    hostPoolType: hostPoolProperties.hostPoolType
    personalDesktopAssignmentType: hostPoolProperties.personalDesktopAssignmentType
    maxSessionLimit: hostPoolProperties.maxSessionLimit
    loadBalancerType: hostPoolProperties.loadBalancerType
    validationEnvironment: hostPoolProperties.validationEnvironment
    preferredAppGroupType: hostPoolProperties.preferredAppGroupType
    publicNetworkAccess: hostPoolProperties.publicNetworkAccess
    customRdpProperty: hostPoolProperties.customRdpProperty
    directUDP: hostPoolProperties.directUDP
    managedPrivateUDP: hostPoolProperties.managedPrivateUDP
    managementType: hostPoolProperties.managementType
    publicUDP: hostPoolProperties.publicUDP
    relayUDP: hostPoolProperties.relayUDP
    startVMOnConnect: hostPoolProperties.startVMOnConnect
    registrationInfo: {
      expirationTime: hostPoolProperties.registrationInfo.expirationTime
      registrationTokenOperation: hostPoolProperties.registrationInfo.registrationTokenOperation
    }
  }
}

resource applicationGroups 'Microsoft.DesktopVirtualization/applicationGroups@2024-04-08-preview' = {
  location: location
  name: applicationGroupName
  properties: union(applicationGroupProperties, {hostPoolArmPath: hostPool.id})
}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2024-04-08-preview' = {
  location: location
  name: workspaceName
  properties: union(workspaceProperties, {applicationGroupReferences: [applicationGroups.id]})
}

resource roleAssignmentAVDUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = [ for (objectId, ind) in GroupObjectIds: {
  scope: applicationGroups
  name: guid(resourceGroup().id, applicationGroups.id, 'Desktop Virtualization User', objectId)
  properties: {
    roleDefinitionId: avdRoleDefinitionId
    principalType: 'Group'
    principalId: objectId
  }
}]


var registrationToken = hostPool.listRegistrationTokens().value[0].token
output hostPoolId string = hostPool.id
output token string = registrationToken
