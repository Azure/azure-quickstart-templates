@description('Specify a DDoS protection plan name.')
param ddosProtectionPlanName string

@description('Specify a DDoS virtual network name.')
param virtualNetworkName string

@description('Specify a location for the resources.')
param location string = resourceGroup().location

@description('Specify the virtual network address prefix')
param vnetAddressPrefix string = '172.17.0.0/16'

@description('Specify the virtual network subnet prefix')
param subnetPrefix string = '172.17.0.0/24'

@description('Enable DDoS protection plan.')
param ddosProtectionPlanEnabled bool = true

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2020-11-01' = {
  name: ddosProtectionPlanName
  location: location
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
    enableDdosProtection: ddosProtectionPlanEnabled
    ddosProtectionPlan: {
      id: ddosProtectionPlan.id
    }
  }
}
