// Supercomputer module: Microsoft Discovery Supercomputer and its node pool.

@description('Azure region for the Supercomputer.')
param location string = resourceGroup().location

@description('Name of the Supercomputer (3-24 characters, alphanumeric and hyphens).')
@minLength(3)
@maxLength(24)
param supercomputerName string = 'sc-${uniqueString(resourceGroup().id)}'

@description('Name of the node pool (1-12 lowercase alphanumeric characters, starting with a letter).')
@minLength(1)
@maxLength(12)
param nodePoolName string = 'nodepool1'

@description('Resource ID of the AKS system subnet used by the Supercomputer.')
param aksSubnetId string

@description('Resource ID of the node pool subnet.')
param nodePoolSubnetId string

@description('Resource ID of the user-assigned managed identity used for cluster, kubelet, and workload identities.')
param managedIdentityResourceId string

@description('VM SKU for the node pool. The SKU and quota must be available in the deployment region. GPU examples: Standard_NC24ads_A100_v4, Standard_NC4as_T4_v3.')
@minLength(1)
param nodePoolVmSize string = 'Standard_D4s_v6'

@description('Maximum number of nodes in the node pool.')
@minValue(1)
param nodePoolMaxNodeCount int = 3

@description('Minimum number of nodes in the node pool (0 allows scale-to-zero).')
@minValue(0)
param nodePoolMinNodeCount int = 0

@description('Scale set priority for the node pool.')
@allowed([
  'Regular'
  'Spot'
])
param nodePoolScaleSetPriority string = 'Regular'

resource supercomputer 'Microsoft.Discovery/supercomputers@2026-06-01' = {
  name: supercomputerName
  location: location
  tags: {
    version: 'v2'
  }
  properties: {
    subnetId: aksSubnetId
    identities: {
      clusterIdentity: {
        id: managedIdentityResourceId
      }
      kubeletIdentity: {
        id: managedIdentityResourceId
      }
      workloadIdentities: {
        '${managedIdentityResourceId}': {}
      }
    }
  }
}

resource nodePool 'Microsoft.Discovery/supercomputers/nodePools@2026-06-01' = {
  parent: supercomputer
  name: nodePoolName
  location: location
  properties: {
    subnetId: nodePoolSubnetId
    vmSize: nodePoolVmSize
    maxNodeCount: nodePoolMaxNodeCount
    minNodeCount: nodePoolMinNodeCount
    scaleSetPriority: nodePoolScaleSetPriority
  }
}

@description('Resource ID of the Supercomputer.')
output resourceId string = supercomputer.id

@description('Resource ID of the node pool.')
output nodePoolId string = nodePool.id
