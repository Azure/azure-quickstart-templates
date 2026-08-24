// Modular Microsoft Discovery deployment.
//
// This orchestrator wires together six independent modules. Each "deploy*" switch
// lets you either provision a component here, or bring your own existing resource
// and pass its identifiers in. This makes it easy to drop the Discovery-specific
// pieces (Supercomputer, Workspace) into an existing landing zone that already owns
// the network, identity, or storage.
//
// Bring-your-own patterns:
//   * Existing network  -> deployNetwork = false, supply existingSubnetIds
//   * Existing identity -> deployManagedIdentity = false, supply existingManagedIdentityResourceId + PrincipalId
//   * Existing storage  -> deployStorage = false, supply existingStorageAccountResourceId

import { discoverySubnetIds, workspaceFeatureTags } from 'modules/types.bicep'

@description('Location for all resources. Microsoft Discovery is currently supported in East US, Sweden Central, and UK South; deploy into a supported region. All resources for a deployment must share the same region.')
param location string = resourceGroup().location

// ---------------------------------------------------------------------------
// Networking
// ---------------------------------------------------------------------------

@description('Provision the virtual network and subnets. Set false to bring your own network.')
param deployNetwork bool = true

@description('Name of the virtual network (when deployNetwork = true).')
param vnetName string = 'discovery-vnet'

@description('Address space for the virtual network (when deployNetwork = true).')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet IDs to use when bringing your own network (deployNetwork = false).')
param existingSubnetIds discoverySubnetIds?

// ---------------------------------------------------------------------------
// Identity
// ---------------------------------------------------------------------------

@description('Provision the user-assigned managed identity. Set false to bring your own.')
param deployManagedIdentity bool = true

@description('Name of the managed identity (when deployManagedIdentity = true). 3-128 characters: letters, numbers, hyphens, and underscores.')
@minLength(3)
@maxLength(128)
param managedIdentityName string = 'uami-${uniqueString(resourceGroup().id)}'

@description('Resource ID of an existing managed identity (when deployManagedIdentity = false). Must be a Microsoft.ManagedIdentity/userAssignedIdentities resource ID.')
param existingManagedIdentityResourceId string = ''

@description('Optional principal (object) ID override for an existing managed identity. Leave empty to read it automatically from existingManagedIdentityResourceId.')
param existingManagedIdentityPrincipalId string = ''

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

@description('Provision the Azure storage account and container. Set false to bring your own.')
param deployStorage bool = true

@description('Globally unique storage account name (when deployStorage = true).')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stg${uniqueString(resourceGroup().id)}'

@description('Replication SKU for the storage account (when deployStorage = true).')
@allowed([
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
])
param storageAccountSku string = 'Standard_GRS'

@description('Name of the blob container for Discovery outputs. Discovery expects a container named "discoveryoutputs". Must be 3-63 lowercase letters, numbers, and hyphens.')
@minLength(3)
@maxLength(63)
param blobContainerName string = 'discoveryoutputs'

@description('Resource ID of an existing storage account (when deployStorage = false). Must be in this resource group for role assignment.')
param existingStorageAccountResourceId string = ''

// ---------------------------------------------------------------------------
// RBAC
// ---------------------------------------------------------------------------

@description('Assign Storage Blob Data Contributor to the identity on the storage account. Set false if the storage account is in another resource group.')
param assignStorageRole bool = true

@description('Optional Entra ID group object ID to grant Discovery Platform Contributor for existing user groups.')
param discoveryContributorGroupObjectId string = ''

// ---------------------------------------------------------------------------
// Supercomputer
// ---------------------------------------------------------------------------

@description('Name of the Supercomputer.')
@minLength(3)
@maxLength(24)
param supercomputerName string = 'sc-${uniqueString(resourceGroup().id)}'

@description('Name of the node pool.')
@minLength(1)
@maxLength(12)
param nodePoolName string = 'nodepool1'

@description('VM SKU for the node pool.')
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

// ---------------------------------------------------------------------------
// Workspace
// ---------------------------------------------------------------------------

@description('Name of the Workspace.')
@minLength(3)
@maxLength(24)
param workspaceName string = 'ws-${uniqueString(resourceGroup().id)}'

@description('Workbench feature tags for the Workspace.')
param workspaceFeatures workspaceFeatureTags = {
  enableGhcpAiFeatures: true
  enableExtensions: true
  networkIsolation: true
}

@description('Name of the chat model deployment.')
@minLength(3)
@maxLength(24)
param chatModelDeploymentName string = 'gpt-5-4'

@description('Chat model format. Microsoft Discovery uses the OpenAI model format.')
@allowed([
  'OpenAI'
])
param chatModelFormat string = 'OpenAI'

@description('Chat model name to deploy. Discovery Engine tasks require the primary deployment to use gpt-5.4 (with deployment name gpt-5-4).')
@minLength(1)
@maxLength(64)
param chatModelName string = 'gpt-5.4'

@description('Name of the Discovery storage container resource.')
@minLength(3)
@maxLength(24)
param storageContainerName string = 'stc-${uniqueString(resourceGroup().id)}'

@description('Name of the project.')
@minLength(3)
@maxLength(24)
param projectName string = 'prj-${uniqueString(resourceGroup().id)}'

// ---------------------------------------------------------------------------
// Modules
// ---------------------------------------------------------------------------

module network 'modules/network.bicep' = if (deployNetwork) {
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
  }
}

// Resolve subnet IDs from either the new network or the bring-your-own input.
var subnets discoverySubnetIds = deployNetwork ? network!.outputs.subnetIds : existingSubnetIds!

module identity 'modules/identity.bicep' = if (deployManagedIdentity) {
  params: {
    location: location
    managedIdentityName: managedIdentityName
  }
}

// When bringing your own identity, read the principal ID from the existing UAMI so
// callers only supply its resource ID. This also fails clearly if a non-identity
// resource ID is passed by mistake (the reference resolves to a missing UAMI).
resource existingManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = if (!deployManagedIdentity && !empty(existingManagedIdentityResourceId)) {
  name: last(split(existingManagedIdentityResourceId, '/'))
  scope: resourceGroup(
    split(existingManagedIdentityResourceId, '/')[2],
    split(existingManagedIdentityResourceId, '/')[4]
  )
}

var managedIdentityResourceId = deployManagedIdentity
  ? identity!.outputs.resourceId
  : existingManagedIdentityResourceId
var managedIdentityPrincipalId = deployManagedIdentity
  ? identity!.outputs.principalId
  : (empty(existingManagedIdentityPrincipalId)
      ? existingManagedIdentity!.properties.principalId
      : existingManagedIdentityPrincipalId)

module storage 'modules/storage.bicep' = if (deployStorage) {
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
    blobContainerName: blobContainerName
    // Storage VNet rules require each listed subnet to have the Microsoft.Storage
    // service endpoint. We only add rules for the subnets we create (deployNetwork),
    // which network.bicep configures with that endpoint. For bring-your-own networks
    // we skip the rules, since we can't guarantee the endpoint is present and the
    // account uses defaultAction 'Allow'. The search subnet is intentionally excluded
    // (Discovery does not require the storage endpoint there).
    allowedSubnetIds: deployNetwork
      ? [
          subnets.nodePoolSubnetId
          subnets.aksSubnetId
          subnets.workspaceSubnetId
          subnets.agentSubnetId
        ]
      : []
  }
}

var storageAccountResourceId = deployStorage ? storage!.outputs.resourceId : existingStorageAccountResourceId
var resolvedStorageAccountName = deployStorage
  ? storage!.outputs.name
  : last(split(existingStorageAccountResourceId, '/'))

module rbac 'modules/rbac.bicep' = {
  params: {
    principalId: managedIdentityPrincipalId
    storageAccountName: resolvedStorageAccountName
    assignStorageRole: assignStorageRole
    discoveryContributorGroupObjectId: discoveryContributorGroupObjectId
  }
}

module supercomputer 'modules/supercomputer.bicep' = {
  params: {
    location: location
    supercomputerName: supercomputerName
    nodePoolName: nodePoolName
    aksSubnetId: subnets.aksSubnetId
    nodePoolSubnetId: subnets.nodePoolSubnetId
    managedIdentityResourceId: managedIdentityResourceId
    nodePoolVmSize: nodePoolVmSize
    nodePoolMaxNodeCount: nodePoolMaxNodeCount
    nodePoolMinNodeCount: nodePoolMinNodeCount
    nodePoolScaleSetPriority: nodePoolScaleSetPriority
  }
}

module workspace 'modules/workspace.bicep' = {
  params: {
    location: location
    workspaceName: workspaceName
    featureTags: workspaceFeatures
    managedIdentityResourceId: managedIdentityResourceId
    supercomputerId: supercomputer.outputs.resourceId
    agentSubnetId: subnets.agentSubnetId
    privateEndpointSubnetId: subnets.privateEndpointSubnetId
    workspaceSubnetId: subnets.workspaceSubnetId
    chatModelDeploymentName: chatModelDeploymentName
    chatModelFormat: chatModelFormat
    chatModelName: chatModelName
    storageContainerName: storageContainerName
    storageAccountResourceId: storageAccountResourceId
    projectName: projectName
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

@description('Resource ID of the Supercomputer.')
output supercomputerId string = supercomputer.outputs.resourceId

@description('Resource ID of the node pool.')
output nodePoolId string = supercomputer.outputs.nodePoolId

@description('Resource ID of the Workspace.')
output workspaceId string = workspace.outputs.workspaceId

@description('Resource ID of the chat model deployment.')
output chatModelDeploymentId string = workspace.outputs.chatModelDeploymentId

@description('Resource ID of the Discovery storage container.')
output storageContainerId string = workspace.outputs.storageContainerId

@description('Resource ID of the project.')
output projectId string = workspace.outputs.projectId

@description('Resource ID of the managed identity in use.')
output managedIdentityId string = managedIdentityResourceId

@description('Resource ID of the storage account in use.')
output storageAccountId string = storageAccountResourceId
