targetScope = 'subscription'

@description('Prefix used to name all landing zone resources.')
param prefix string = 'alz'

@description('Azure region into which the landing zone is deployed.')
param location string = deployment().location

@description('Tags applied to every resource group created by this template.')
param tags object = {}

@description('Names of the platform resource groups for connectivity, monitoring and security.')
param resourceGroupNames object = {
  connectivity: 'rg-${prefix}-connectivity'
  monitoring: 'rg-${prefix}-monitoring'
  security: 'rg-${prefix}-security'
}

@description('Deploy Azure Firewall into the hub network. Incurs significant cost.')
param enableFirewall bool = false

@description('Deploy Azure Bastion into the hub network. Incurs significant cost.')
param enableBastion bool = false

@description('Deploy a VPN Gateway into the hub network. Incurs significant cost.')
param enableVpnGateway bool = false

@description('Deploy a NAT Gateway for controlled outbound connectivity from the spokes.')
param enableNatGateway bool = false

@description('Deploy a Log Analytics workspace for centralised monitoring.')
param enableMonitoring bool = false

@description('Address space of the hub virtual network in CIDR notation.')
param hubAddressSpace string = '10.0.0.0/16'

@description('Subnet address prefixes for the hub virtual network.')
param hubSubnetCidrs object = {
  firewall: '10.0.0.0/24'
  gateway: '10.0.1.0/24'
  bastion: '10.0.2.0/26'
  dns: '10.0.3.0/24'
  management: '10.0.4.0/24'
}

@description('Spoke environments to deploy. Defaults to one non-production and one production spoke.')
param spokeConfigurations array = [
  {
    name: 'nonprod'
    environment: 'nonprod'
    resourceGroupName: 'rg-${prefix}-nonprod-network'
    addressSpace: '10.20.0.0/16'
    subnetCidrs: {
      frontend: '10.20.1.0/24'
      application: '10.20.2.0/24'
      database: '10.20.3.0/24'
      privateEndpoints: '10.20.4.0/24'
      management: '10.20.5.0/24'
    }
  }
  {
    name: 'prod'
    environment: 'prod'
    resourceGroupName: 'rg-${prefix}-prod-network'
    addressSpace: '10.30.0.0/16'
    subnetCidrs: {
      frontend: '10.30.1.0/24'
      application: '10.30.2.0/24'
      database: '10.30.3.0/24'
      privateEndpoints: '10.30.4.0/24'
      management: '10.30.5.0/24'
    }
  }
]

var baseTags = union({
  deployedBy: 'bicep'
}, tags)

var enabledSpokes = spokeConfigurations

// Platform resource groups
resource connectivityRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupNames.connectivity
  location: location
  tags: baseTags
}

resource spokeRgs 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for spoke in enabledSpokes: {
    name: spoke.resourceGroupName
    location: location
    tags: baseTags
  }
]

resource monitoringRg 'Microsoft.Resources/resourceGroups@2024-03-01' = if (enableMonitoring) {
  name: resourceGroupNames.monitoring
  location: location
  tags: baseTags
}

// Hub virtual network
module hubNetwork 'modules/hubNetwork.bicep' = {
  name: 'hub'
  scope: resourceGroup(resourceGroupNames.connectivity)

  dependsOn: [
    connectivityRg
  ]

  params: {
    prefix: prefix
    location: location
    tags: baseTags
    hubVnetName: 'vnet-${prefix}-hub'
    hubAddressSpace: hubAddressSpace
    hubSubnetCidrs: hubSubnetCidrs
    enableFirewall: enableFirewall
    enableBastion: enableBastion
    enableVpnGateway: enableVpnGateway
  }
}

// Spoke virtual networks
module spokeNetworks 'modules/spokeNetwork.bicep' = [
  for (spoke, i) in enabledSpokes: {
    name: 'spoke-${i}'
    scope: resourceGroup(spoke.resourceGroupName)

    dependsOn: [
      spokeRgs
      hubNetwork
    ]

    params: {
      prefix: prefix
      location: location
      tags: baseTags
      spokeName: spoke.name
      environmentName: spoke.environment
      vnetName: 'vnet-${prefix}-${spoke.name}'
      addressSpace: spoke.addressSpace
      subnetCidrs: spoke.subnetCidrs
      enableNatGateway: enableNatGateway
    }
  }
]

// Hub to spoke peering
module hubToSpokePeering 'modules/vnetPeering.bicep' = [
  for (spoke, i) in enabledSpokes: {
    name: 'hub-to-${spoke.name}'
    scope: resourceGroup(resourceGroupNames.connectivity)

    dependsOn: [
      spokeNetworks
    ]

    params: {
      localVnetName: hubNetwork.outputs.hubVnetName
      peeringName: 'peer-hub-${spoke.name}'
      remoteVnetId: spokeNetworks[i].outputs.spokeVnetId
      allowGatewayTransit: enableVpnGateway
    }
  }
]

// Spoke to hub peering
module spokeToHubPeering 'modules/vnetPeering.bicep' = [
  for (spoke, i) in enabledSpokes: {
    name: 'spoke-to-hub-${spoke.name}'
    scope: resourceGroup(spoke.resourceGroupName)

    dependsOn: [
      spokeNetworks
    ]

    params: {
      localVnetName: 'vnet-${prefix}-${spoke.name}'
      peeringName: 'peer-${spoke.name}-hub'
      remoteVnetId: hubNetwork.outputs.hubVnetId
      useRemoteGateways: enableVpnGateway
    }
  }
]

// Optional Log Analytics workspace
module monitoring 'modules/monitoring.bicep' = if (enableMonitoring) {
  name: 'monitoring'
  scope: resourceGroup(resourceGroupNames.monitoring)

  dependsOn: [
    monitoringRg
  ]

  params: {
    location: location
    workspaceName: 'law-${prefix}-${location}'
    tags: baseTags
  }
}

// Outputs
output hubVnetId string = hubNetwork.outputs.hubVnetId
output spokeVnetIds array = [for (spoke, i) in enabledSpokes: spokeNetworks[i].outputs.spokeVnetId]
