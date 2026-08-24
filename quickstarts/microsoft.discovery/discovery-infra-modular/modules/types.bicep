// Shared user-defined types for the modular Microsoft Discovery deployment.
// Import with: import { discoverySubnetIds } from 'modules/types.bicep'

@export()
@description('Resource IDs of the six subnets a Microsoft Discovery deployment consumes. Supply these when bringing your own virtual network. A virtual network can be associated with only one Discovery workspace.')
type discoverySubnetIds = {
  @description('Subnet for the Supercomputer node pool. Requires the Microsoft.Storage service endpoint.')
  @minLength(1)
  nodePoolSubnetId: string

  @description('Subnet used by the Supercomputer AKS system. Requires the Microsoft.Storage service endpoint.')
  @minLength(1)
  aksSubnetId: string

  @description('Subnet delegated to Microsoft.App/environments for the Workspace. Requires the Microsoft.Storage service endpoint.')
  @minLength(1)
  workspaceSubnetId: string

  @description('Subnet that hosts private endpoints.')
  @minLength(1)
  privateEndpointSubnetId: string

  @description('Subnet delegated to Microsoft.App/environments for agents. Requires the Microsoft.Storage service endpoint.')
  @minLength(1)
  agentSubnetId: string

  @description('Subnet delegated to Microsoft.App/environments for search.')
  @minLength(1)
  searchSubnetId: string
}

@export()
@description('Workspace workbench feature tags aligned with the Discovery portal quickstart.')
type workspaceFeatureTags = {
  @description('Enable GitHub Copilot and AI features (discovery.workbench.enableGhcpAiFeatures tag).')
  enableGhcpAiFeatures: bool

  @description('Enable the VS Code Extension Marketplace (discovery.workbench.enableExtensions tag).')
  enableExtensions: bool

  @description('Workspace network isolation mode (NetworkIsolation tag).')
  networkIsolation: bool
}
