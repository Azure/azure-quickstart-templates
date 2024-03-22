targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'ade-sandbox-rg'

@description('Name of Dev Center')
@minLength(3)
@maxLength(26)
param devCenterName string = 'ade-sandbox-dc'

@description('Name of Project associated with Dev Center')
@minLength(3)
@maxLength(63)
param projectName string = 'ade-sandbox-project'

@description('Name of Environment Type associated with Dev Center and Project')
@minLength(3)
@maxLength(63)
param environmentTypeName string = 'Sandbox'

@description('User object ID is required to assign the necessary role permission to create an environment. Leave this blank if you want to do so at a later time. For more details on finding the user ID, https://learn.microsoft.com/en-us/partner-center/find-ids-and-domain-names')
param userObjectID string = ''

var location = deployment().location
var guidSeed = guid(userObjectID, location, resourceGroupName, devCenterName, projectName, environmentTypeName)

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
    devCenterName: devCenterName
    projectName: projectName
    environmentTypeName: environmentTypeName
    userObjectID: userObjectID
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
    devCenterName: devCenterName
    resourceGroupName: resourceGroupName
    guidSeed: guidSeed
  }
}
