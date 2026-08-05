@description('The location for the workload resource.')
param location string

@description('The name of the workload resource.')
param workloadId string

@description('The metadata to be applied to the workload resource.')
param tags object = {}

@description('The resource ID of the target virtual enclave.')
param virtualEnclaveResourceId string

param workloadResourceGroup string

param resourceGroupCollection array

var workloadResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${workloadResourceGroup}'

var updatedResourceGroupCollection = concat(resourceGroupCollection, [workloadResourceGroupId])

resource virtualEnclave 'Microsoft.Mission/virtualEnclaves@2025-05-01-preview' existing = {
  name: split(virtualEnclaveResourceId, '/')[8]
}

resource workload 'Microsoft.Mission/virtualEnclaves/workloads@2025-05-01-preview' existing = {
  parent: virtualEnclave
  name: split(workloadId, '/')[10]
}

resource updatedWorkload 'Microsoft.Mission/virtualEnclaves/workloads@2025-05-01-preview' = {
  parent: virtualEnclave
  name: split(workloadId, '/')[10]
  location: location
  tags: tags[?'Microsoft.Mission/virtualEnclaves'] ?? {}
  properties: {
    resourceGroupCollection: updatedResourceGroupCollection
  }
}

//output workloadResourceGroupName string = workload.properties.resourceGroupName
output workloadId string = updatedWorkload.id
output updatedResourceGroupCollection array = updatedWorkload.properties.resourceGroupCollection
