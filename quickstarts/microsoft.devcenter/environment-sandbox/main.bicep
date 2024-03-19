targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string

@description('Location to create resources in')
@allowed(
  [
    'australiaeast'
    'brazilsouth'
    'canadacentral'
    'centralindia'
    'centraluseuap'
    'eastasia'
    'eastus'
    'eastus2'
    'japaneast'
    'koreacentral'
    'northeurope'
    'southafricanorth'
    'southcentralus'
    'southeastasia'
    'switzerlandnorth'
    'uksouth'
    'westeurope'
    'westus2'
    'westus3'
  ]
)
param resourceLocation string = 'westus3'

@description('Principal/object ID of the user to assign role assignments to')
param principalId string

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

@description('GUID used as name of role assignment')
param guidSeed string = newGuid()

var devcenterResourceId = resourceId(subscription().subscriptionId, resourceGroupName, 'Microsoft.DevCenter/devcenters', devcenterName)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module deployment1 './modules/deployment1.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: guid('Deployment 1', guidSeed)
  dependsOn: [
    resourceGroup
  ]
  params: {
    resourceLocation: resourceLocation
    devcenterName: devcenterName
    projectName: projectName
    environmentTypeName: environmentTypeName
    principalId: principalId
    guidSeed: guidSeed
    devcenterResourceId: devcenterResourceId
  }
}

module deployment2 './modules/deployment2.bicep' = {
  scope: subscription(subscription().subscriptionId)
  name: guid('Deployment 2', guidSeed)
  dependsOn: [
    deployment1
  ]
  params: {
    guidSeed: guidSeed
    devcenterResourceId: devcenterResourceId
  }
}
