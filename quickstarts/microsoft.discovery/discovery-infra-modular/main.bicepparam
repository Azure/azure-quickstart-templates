using 'main.bicep'

// Greenfield deployment: provisions network, identity, storage, RBAC,
// Supercomputer, and Workspace end to end. Replace GEN-UNIQUE values with your own
// globally unique names before deploying.

param location = 'swedencentral'

// Networking (created here)
param deployNetwork = true
param vnetName = 'discovery-vnet'
param vnetAddressPrefix = '10.0.0.0/16'

// Identity (created here)
param deployManagedIdentity = true

// Storage (created here) - storageAccountName must be globally unique
param deployStorage = true
param storageAccountSku = 'Standard_GRS'
param blobContainerName = 'discoveryoutputs'

// RBAC
param assignStorageRole = true
// Optionally grant an existing Entra ID group Discovery Platform Contributor:
// param discoveryContributorGroupObjectId = '00000000-0000-0000-0000-000000000000'

// Supercomputer
param nodePoolName = 'nodepool1'
param nodePoolVmSize = 'Standard_D4s_v6'
param nodePoolMaxNodeCount = 3
param nodePoolMinNodeCount = 0
param nodePoolScaleSetPriority = 'Regular'

// Workspace
param workspaceFeatures = {
  enableGhcpAiFeatures: true
  enableExtensions: true
  networkIsolation: true
}
param chatModelDeploymentName = 'gpt-5-4'
param chatModelFormat = 'OpenAI'
param chatModelName = 'gpt-5.4'
