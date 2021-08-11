@description('Required. The Virtual Network (vNet) Name.')
param virtualNetworkName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array

@description('Required. Name of the Network Security Group.')
@minLength(1)
param networkSecurityGroupName string

@description('Required. Array of Security Rules to deploy to the Network Security Group.')
param networkSecurityGroupSecurityRules array = []

@description('Required. An Array of subnets to deploy to the Virual Network.')
@minLength(1)
param subnets array

// @description('Optional. DNS Servers associated to the Virtual Network.')
// param dnsServers array = []

// @description('Optional. Resource Id of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
// param ddosProtectionPlanId string = ''

// var varDnsServers = {
//   dnsServers: dnsServers
// }
// var ddosProtectionPlan = {
//   id: ddosProtectionPlanId
// }

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vNetAddressPrefixes
    }
    //ddosProtectionPlan: ((!empty(ddosProtectionPlanId)) ? ddosProtectionPlan : json('null'))
    //dhcpOptions: (empty(dnsServers) ? json('null') : varDnsServers)
    //enableDdosProtection: (!empty(ddosProtectionPlanId))
    subnets: [for item in subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
        networkSecurityGroup: (empty(item.networkSecurityGroupName) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', item.networkSecurityGroupName)}"}'))
        //routeTable: (empty(item.routeTableName) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/routeTables', item.routeTableName)}"}'))
        //serviceEndpoints: (empty(item.serviceEndpoints) ? json('null') : item.serviceEndpoints)
        delegations: item.delegations
      }
    }]
  }
  dependsOn: [
    networksecuritygroup
  ]
}

module networksecuritygroup './networksecuritygroup.bicep' = {
  name: networkSecurityGroupName
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    networkSecurityGroupSecurityRules: networkSecurityGroupSecurityRules
  }
}
