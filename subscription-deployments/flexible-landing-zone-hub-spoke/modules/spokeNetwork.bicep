targetScope = 'resourceGroup'

param prefix string
param location string
param tags object
param spokeName string
param environmentName string
param vnetName string
param addressSpace string = '10.20.0.0/16'
param subnetCidrs object = {
  frontend: '10.20.1.0/24'
  application: '10.20.2.0/24'
  database: '10.20.3.0/24'
  privateEndpoints: '10.20.4.0/24'
  management: '10.20.5.0/24'
}
param enableNatGateway bool = false
param enablePrivateEndpoints bool = true

resource frontendNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-${prefix}-${spokeName}-frontend'
  location: location
  tags: tags
}

resource applicationNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-${prefix}-${spokeName}-app'
  location: location
  tags: tags
}

resource databaseNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-${prefix}-${spokeName}-db'
  location: location
  tags: tags
}

resource managementNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-${prefix}-${spokeName}-mgmt'
  location: location
  tags: tags
}

resource privateEndpointsNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = if (enablePrivateEndpoints) {
  name: 'nsg-${prefix}-${spokeName}-pe'
  location: location
  tags: tags
}

resource natPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (enableNatGateway) {
  name: 'pip-${prefix}-${spokeName}-nat'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = if (enableNatGateway) {
  name: 'nat-${prefix}-${spokeName}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natPublicIp.id
      }
    ]
  }
}

var frontendSubnetProperties = union({
  addressPrefix: subnetCidrs.?frontend ?? '10.20.1.0/24'
  networkSecurityGroup: {
    id: frontendNsg.id
  }
}, enableNatGateway ? {
  natGateway: {
    id: natGateway.id
  }
} : {})

var applicationSubnetProperties = union({
  addressPrefix: subnetCidrs.?application ?? '10.20.2.0/24'
  networkSecurityGroup: {
    id: applicationNsg.id
  }
}, enableNatGateway ? {
  natGateway: {
    id: natGateway.id
  }
} : {})

var baseSubnets = [
  {
    name: 'snet-frontend'
    properties: frontendSubnetProperties
  }
  {
    name: 'snet-application'
    properties: applicationSubnetProperties
  }
  {
    name: 'snet-database'
    properties: {
      addressPrefix: subnetCidrs.?database ?? '10.20.3.0/24'
      networkSecurityGroup: {
        id: databaseNsg.id
      }
    }
  }
  {
    name: 'snet-management'
    properties: {
      addressPrefix: subnetCidrs.?management ?? '10.20.5.0/24'
      networkSecurityGroup: {
        id: managementNsg.id
      }
    }
  }
]

var privateEndpointSubnet = enablePrivateEndpoints ? [
  {
    name: 'snet-private-endpoints'
    properties: {
      addressPrefix: subnetCidrs.?privateEndpoints ?? '10.20.4.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      networkSecurityGroup: {
        id: privateEndpointsNsg.id
      }
    }
  }
] : []

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: union(tags, {
    environment: environmentName
  })
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: concat(baseSubnets, privateEndpointSubnet)
  }
}

output spokeVnetId string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
output frontendSubnetId string = '${spokeVnet.id}/subnets/snet-frontend'
output applicationSubnetId string = '${spokeVnet.id}/subnets/snet-application'
output databaseSubnetId string = '${spokeVnet.id}/subnets/snet-database'
output managementSubnetId string = '${spokeVnet.id}/subnets/snet-management'
output privateEndpointsSubnetId string = enablePrivateEndpoints ? '${spokeVnet.id}/subnets/snet-private-endpoints' : ''
