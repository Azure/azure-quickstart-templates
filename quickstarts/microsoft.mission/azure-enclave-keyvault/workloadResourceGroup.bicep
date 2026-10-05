@description('The location for the workload resource.')
param location string

@description('The name of the workload resource.')
param workloadId string

@description('The metadata to be applied to the workload resource.')
param tags object = {}

@description('The existing workload metadata to preserve when attaching a resource group.')
param existingWorkloadTags object = {}

@description('The resource ID of the target virtual enclave.')
param virtualEnclaveResourceId string

param workloadResourceGroup string

param resourceGroupCollection array

var workloadResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${workloadResourceGroup}'

var normalizedResourceGroupCollection = map(resourceGroupCollection, resourceGroupId => toLower(resourceGroupId))
var workloadResourceGroupAlreadyAttached = contains(normalizedResourceGroupCollection, toLower(workloadResourceGroupId))
var updatedResourceGroupCollection = workloadResourceGroupAlreadyAttached
  ? resourceGroupCollection
  : union(resourceGroupCollection, [workloadResourceGroupId])

resource virtualEnclave 'Microsoft.Mission/virtualEnclaves@2026-03-01-preview' existing = {
  name: split(virtualEnclaveResourceId, '/')[8]
}

resource updatedWorkload 'Microsoft.Mission/virtualEnclaves/workloads@2026-03-01-preview' = {
  parent: virtualEnclave
  name: split(workloadId, '/')[10]
  location: location
  tags: union(existingWorkloadTags, tags)
  properties: {
    resourceGroupCollection: updatedResourceGroupCollection
  }
}

//output workloadResourceGroupName string = workload.properties.resourceGroupName
output workloadId string = updatedWorkload.id
output updatedResourceGroupCollection array = updatedWorkload.properties.resourceGroupCollection
