targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string

@description('Principal/Object ID of the user to assign role assignments to')
param userPrincipalId string

@description('Name of Dev Center')
@minLength(3)
@maxLength(26)
param devcenterName string

@description('Name of Project associated with Dev Center')
@minLength(3)
@maxLength(63)
param projectName string

@description('Name of Environment Type e.g. Sandbox, Dev, Prod')
@minLength(3)
@maxLength(63)
param environmentTypeName string = 'Sandbox'

var location = deployment().location
var guidSeed = guid(userPrincipalId, location, resourceGroupName, devcenterName, projectName, environmentTypeName)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module deployment1 './modules/deployment1.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: guid('Deployment 1', guidSeed)
  dependsOn: [
    resourceGroup
  ]
  params: {
    resourceLocation: location
    devcenterName: devcenterName
    projectName: projectName
    environmentTypeName: environmentTypeName
    principalId: userPrincipalId
    guidSeed: guidSeed
  }
}

module deployment2 './modules/deployment2.bicep' = {
  scope: subscription(subscription().subscriptionId)
  name: guid('Deployment 2', guidSeed)
  dependsOn: [
    deployment1
  ]
  params: {
    devcenterName: devcenterName
    resourceGroupName: resourceGroupName
    guidSeed: guidSeed
  }
}
