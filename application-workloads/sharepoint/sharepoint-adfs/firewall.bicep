@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

param virtualNetworkName string
param addressPrefix string
param http_port int = 8080
param https_port int = 8443
@description('Tags to apply on the resources.')
param tags object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-10-01' existing = {
  scope: resourceGroup()
  name: virtualNetworkName
}

resource bastion_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-10-01' = {
  parent: virtualNetwork
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: addressPrefix
    defaultOutboundAccess: false
  }
}

resource firewall_policy_proxy 'Microsoft.Network/firewallPolicies@2024-10-01' = {
  name: 'firewall-policy-proxy'
  location: location
  tags: tags
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    explicitProxy: {
      enableExplicitProxy: true
      httpPort: http_port
      httpsPort: https_port
      enablePacFile: false
    }
  }
}

resource firewall_proxy_rules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-10-01' = {
  name: 'rules'
  parent: firewall_policy_proxy
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'proxy-allow-all-outbound'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        priority: 100
        rules: [
          {
            ruleType: 'ApplicationRule'
            sourceAddresses: [
              '*'
            ]
            targetFqdns: [
              '*'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
              {
                port: 80
                protocolType: 'Http'
              }
            ]
          }
        ]
      }
    ]
  }
}

module firewall 'br/public:avm/res/network/azure-firewall:0.9.1' = {
  name: 'firewall'
  params: {
    name: 'firewall'
    location: location
    azureSkuTier: 'Standard'
    virtualNetworkResourceId: virtualNetwork.id
    firewallPolicyId: firewall_policy_proxy.id
    threatIntelMode: 'Alert'
    publicIPAddressObject: {
      name: 'firewall-pip'
      publicIPAllocationMethod: 'Static'
      publicIPPrefixResourceId: ''
      skuName: 'Standard'
      skuTier: 'Regional'
    }
  }
}
