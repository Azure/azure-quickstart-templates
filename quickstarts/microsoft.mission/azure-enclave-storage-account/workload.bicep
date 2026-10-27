@description('The location for the workload resource.')
param location string

@description('The name of the workload resource.')
param workloadId string

@description('The metadata to be applied to the workload resource.')
param tags object = {}
param newWorkloadName string

@description('The resource ID of the target virtual enclave.')
param virtualEnclaveResourceId string

param workloadUseExisting bool = false

resource virtualEnclave 'Microsoft.Mission/virtualEnclaves@2026-03-01-preview' existing = {
  name: split(virtualEnclaveResourceId, '/')[8]
}

resource workloadNew 'Microsoft.Mission/virtualEnclaves/workloads@2026-03-01-preview' = if (!workloadUseExisting) {
  parent: virtualEnclave
  name: newWorkloadName
  location: location
  tags: tags
}

resource workloadExisting 'Microsoft.Mission/virtualEnclaves/workloads@2026-03-01-preview' existing = if (workloadUseExisting) {
  parent: virtualEnclave
  name: split(workloadId, '/')[10]
}

//output workloadResourceGroupName string = workload.properties.resourceGroupName
output workloadId string = workloadUseExisting ? workloadExisting.?id ?? '' : workloadNew.?id ?? ''
output resourceGroupCollection array = workloadUseExisting ? workloadExisting.?properties.?resourceGroupCollection ?? [] : workloadNew.?properties.?resourceGroupCollection ?? []
