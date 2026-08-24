using 'main.bicep'

// Bring-your-own-network example: reuse an existing landing-zone virtual network
// and only deploy the Discovery-specific resources (identity, storage, Supercomputer,
// Workspace).
//
// Can this be deployed with just this one param file? Yes — this single file drives
// the entire deployment (no edits to main.bicep, no extra steps). BUT it must be
// configured first: it is NOT deployable as shipped because the subnet IDs below are
// placeholders. Before deploying you must:
//   1. Replace every existingSubnetIds value with your real subnet resource IDs
//      (the ones below use a 0000... subscription and "hub-vnet" as examples).
// Every other parameter is optional and fully documented inline below.
//
// The template CONSUMES these subnets; it does not create or reconfigure them. The
// subnets must already exist and already meet Discovery's requirements:
//   * workspaceSubnet, agentSubnet, searchSubnet -> delegated to Microsoft.App/environments
//   * nodePool, aks, workspace, agent             -> Microsoft.Storage service endpoint

param location = 'swedencentral'

param deployNetwork = false
param existingSubnetIds = {
  nodePoolSubnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/discovery-nodepool'
  aksSubnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/discovery-aks'
  workspaceSubnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/discovery-workspace'
  privateEndpointSubnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/discovery-pe'
  agentSubnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/discovery-agent'
  searchSubnetId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/discovery-search'
}

param deployManagedIdentity = true
// To reuse an existing identity instead, set deployManagedIdentity = false and supply
// the UAMI's RESOURCE ID (a Microsoft.ManagedIdentity/userAssignedIdentities id — NOT
// a subnet or other resource). The principal ID is read from that identity
// automatically; only set existingManagedIdentityPrincipalId to override it.
// param deployManagedIdentity = false
// param existingManagedIdentityResourceId = '/subscriptions/.../resourceGroups/identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/discovery-uami'
// param existingManagedIdentityPrincipalId = '11111111-1111-1111-1111-111111111111'

// deployStorage — create the Azure storage account and blob container for Discovery
// outputs.
//   * Leave as-is (true): this deployment creates the storage account for you.
//   * Set to false to reuse an existing account; then also set
//     existingStorageAccountResourceId, and set assignStorageRole = false if that
//     account lives in a different resource group.
// The parameter is always used, so it is safe to leave in the file either way.
param deployStorage = true

// discoveryContributorGroupObjectId — OPTIONAL. Grants an existing Entra ID group the
// "Microsoft Discovery Platform Contributor" role at the resource-group scope.
//   * Not using it? Leave this line commented out (as shipped). The parameter
//     defaults to '' in main.bicep, which skips the group role assignment entirely,
//     so there is nothing to configure or clean up.
//   * Using it? Uncomment the line below and replace the GUID with a REAL group
//     object ID, e.g. az ad group show --group "<group-name>" --query id -o tsv
//   * Do NOT deploy with a placeholder/sample GUID uncommented — the role assignment
//     fails because no group with that object ID exists.
// param discoveryContributorGroupObjectId = '00000000-0000-0000-0000-000000000000'
