@description('Required. Use existing virtual network and subnet.')
param useExistingVnetandSubnet bool = false

@description('Required. Resource Group name of virtual network if using existing vnet and subnet.')
param vNetResourceGroupName string = resourceGroup().name

@description('Required. The Virtual Network (vNet) Name.')
param virtualNetworkName string = 'vnet-asev3'

@description('Required. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array = [
  '172.16.0.0/16'
]

@description('Required. The subnet Name of ASEv3.')
param subnetAddressPrefix string = '172.16.0.0/24'

@description('Required. The subnet Name of ASEv3.')
param subnetName string = 'snet-asev3'

@description('Required. The subnet properties.')
param subnets array = [
  {
    name: 'snet-asev3'
    addressPrefix: '172.16.0.0/24'
    delegations: [
      {
        name: 'Microsoft.Web.hostingEnvironments'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroupName: 'nsg-asev3'
  }
]

@description('Required. Name of ASEv3.')
param aseName string

@description('Required. Dedicated host count of ASEv3.')
param dedicatedHostCount string = '0'

@description('Required. Zone redundant of ASEv3.')
param zoneRedundant bool = false

@description('Optional. Create a private DNS zone for ASEv3.')
param createPrivateDNS bool = true
@description('Required. Load balancer mode: 0-external load balancer, 3-internal load balancer for ASEv3.')
@allowed([
  0
  3
])
param internalLoadBalancingMode int = 3

@description('Required. Name of the Network Security Group.')
@minLength(1)
param networkSecurityGroupName string = 'nsg-asev3'

@description('Required. Array of Security Rules to deploy to the Network Security Group.')
param networkSecurityGroupSecurityRules array = []

var uniStr = '${uniqueString(resourceGroup().id)}'
var virtualNetworkId = resourceId(vNetResourceGroupName, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetId = resourceId(vNetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var privateDNSZoneName = asev3.properties.dnsSuffix

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = if (!useExistingVnetandSubnet) {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [for item in networkSecurityGroupSecurityRules: {
      name: item.name
      properties: {
        description: item.properties.description
        access: item.properties.access
        destinationAddressPrefix: ((item.properties.destinationAddressPrefix == '') ? json('null') : item.properties.destinationAddressPrefix)
        destinationAddressPrefixes: ((length(item.properties.destinationAddressPrefixes) == 0) ? json('null') : item.properties.destinationAddressPrefixes)
        destinationPortRanges: ((length(item.properties.destinationPortRanges) == 0) ? json('null') : item.properties.destinationPortRanges)
        destinationPortRange: ((item.properties.destinationPortRange == '') ? json('null') : item.properties.destinationPortRange)
        direction: item.properties.direction
        priority: int(item.properties.priority)
        protocol: item.properties.protocol
        sourceAddressPrefix: ((item.properties.sourceAddressPrefix == '') ? json('null') : item.properties.sourceAddressPrefix)
        sourcePortRanges: ((length(item.properties.sourcePortRanges) == 0) ? json('null') : item.properties.sourcePortRanges)
        sourcePortRange: item.properties.sourcePortRange
      }
    }]
  }
}

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = if (!useExistingVnetandSubnet) {
  name: virtualNetworkName
  location: location
  dependsOn: [
    networksecuritygroup
  ]
  properties: {
    addressSpace: {
      addressPrefixes: vNetAddressPrefixes
    }
    subnets: [for item in subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
        networkSecurityGroup: (empty(item.networkSecurityGroupName) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', item.networkSecurityGroupName)}"}'))
        delegations: item.delegations
      }
    }]
  }
}

module subnet 'modules/subnet.bicep' = if (useExistingVnetandSubnet) {
  name: '${subnetName}-subnet-delegation-${uniStr}'
  scope: resourceGroup(vNetResourceGroupName)
  params: {
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
  }
}

resource asev3 'Microsoft.Web/hostingEnvironments@2020-12-01' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  dependsOn: [
    virtualnetwork
  ] 
  properties: {
    dedicatedHostCount: dedicatedHostCount
    zoneRedundant: zoneRedundant
    internalLoadBalancingMode: internalLoadBalancingMode
    virtualNetwork: {
      id: subnetId
    } 
  }
}

module privatednszone 'modules/privatednszone.bicep' = if (createPrivateDNS && internalLoadBalancingMode == 3) {
  name: 'private-dns-zone-deployment-${uniStr}'
  params: {
    privateDNSZoneName: privateDNSZoneName
    virtualNetworkId: virtualNetworkId
    aseName: aseName
  }
}
