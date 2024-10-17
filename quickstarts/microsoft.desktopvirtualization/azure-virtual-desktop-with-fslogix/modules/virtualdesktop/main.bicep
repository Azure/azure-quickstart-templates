@description('Location for all resources.')
param location string = resourceGroup().location

@description('Host pool resource name')
param hostPoolName string
@description('Application groups resource name')
param applicationGroupName string
@description('Workspace resource name')
param workspaceName string
@description('Host pool resource property configuration')
param hostPoolProperties object
@description('Application group resource property configuration')
param applicationGroupProperties object
@description('Workspace resource property configuration')
param workspaceProperties object
@description('Azure AVD Application group role assignment')
param avdRoleDefinitionId string
@description('Group object ids')
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


output hostPoolId string = hostPool.id
output token string = reference(hostPool.id).registrationInfo.token 
