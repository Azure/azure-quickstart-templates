param vWANhubs array
param sourceIPAddressSpaces array
param destinationIPAddressSpaces array
param firewallSNATprivateRanges string[]

var NetworkRuleCollectionGroupPriority = 50000
var DefaultNetworkRuleCollectionGroup = 'DefaultNetworkRuleCollectionGroup'

resource hub1FirewallPolicy 'Microsoft.Network/firewallPolicies@2023-04-01' = {
  name: vWANhubs[0].fwpolicyname
  location: vWANhubs[0].location
  properties: {
    sku: {
      tier: vWANhubs[0].fwtier
    }
    snat: {
      privateRanges: firewallSNATprivateRanges
    }

    threatIntelMode: vWANhubs[0].threatintelmode
  }
}

resource hub2FirewallPolicy 'Microsoft.Network/firewallPolicies@2023-04-01' = {
  name: vWANhubs[1].fwpolicyname
  location: vWANhubs[1].location
  properties: {
    sku: {
      tier: vWANhubs[1].fwtier
    }
    threatIntelMode: vWANhubs[1].threatintelmode
    snat: {
      privateRanges: firewallSNATprivateRanges
    }
  }
}

resource hub2FirewallPolicyDefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-04-01' = {
  parent: hub2FirewallPolicy
  name: DefaultNetworkRuleCollectionGroup
  properties: {
    priority: NetworkRuleCollectionGroupPriority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'DefaultAllowRule'
            ipProtocols: [
              'TCP'
              'UDP'
              'ICMP'
              'Any'
            ]
            sourceAddresses: sourceIPAddressSpaces
            destinationAddresses: destinationIPAddressSpaces
            destinationPorts: [
              '*'
            ]
          }
        ]
        name: 'NetworkCollectionAllowDefault'
        priority: NetworkRuleCollectionGroupPriority
      }
    ]
  }
}

resource hub1FirewallPolicyDefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-04-01' = {
  parent: hub1FirewallPolicy
  name: DefaultNetworkRuleCollectionGroup
  properties: {
    priority: NetworkRuleCollectionGroupPriority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'DefaultAllowRule'
            ipProtocols: [
              'TCP'
              'UDP'
              'ICMP'
              'Any'
            ]
            sourceAddresses: sourceIPAddressSpaces
            destinationAddresses: destinationIPAddressSpaces
            destinationPorts: [
              '*'
            ]
          }
        ]
        name: 'NetworkCollectionAllowDefault'
        priority: NetworkRuleCollectionGroupPriority
      }
    ]
  }
}

output fwPolicyArrayIDs array = [
  hub1FirewallPolicy.id
  hub2FirewallPolicy.id
]
