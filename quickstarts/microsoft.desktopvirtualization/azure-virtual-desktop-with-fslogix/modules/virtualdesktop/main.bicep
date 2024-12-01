param location string

param hostPoolName string
param applicationGroupName string
param workspaceName string
param hostPoolProperties object
param applicationGroupProperties object
param workspaceProperties object
param avdRoleDefinitionId string
param GroupObjectIds array

param fslogixEnabled bool

param subnetId string
param numberOfSessionHost int = 2
param virtualMachine object
@secure()
param adminUsername string
@secure()
param adminPassword string
param activeDirectoryAuthenticationEnabled bool
param DomainName string?
param DomainJoinOUPath string?
param ADAdministratorAccountUsername string?
@secure()
param ADAdministratorAccountPassword string?
param artifactsLocation string

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

module sessionHost '../sessionhost/main.bicep' = {
  name: 'sessionHostComponent'
  params: {
    location: location
    subnetId: subnetId
    numberOfSessionHost: numberOfSessionHost
    virtualMachine: virtualMachine
    adminUsername: adminUsername
    adminPassword: adminPassword
    hostPoolName: hostPoolName
    activeDirectoryAuthenticationEnabled: activeDirectoryAuthenticationEnabled
    fslogixEnabled: fslogixEnabled
    DomainName: DomainName
    DomainJoinOUPath: DomainJoinOUPath
    ADAdministratorAccountUsername: ADAdministratorAccountUsername
    ADAdministratorAccountPassword: ADAdministratorAccountPassword
    artifactsLocation: artifactsLocation
    hostPoolRegistrationInfoToken: hostPool.listRegistrationTokens().value[0].token
  }
}

output hostPoolId string = hostPool.id
