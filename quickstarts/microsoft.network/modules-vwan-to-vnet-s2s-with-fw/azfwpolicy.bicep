param location string = resourceGroup().location
param policyname string

@description('Specify custom DNS Servers for Azure Firewall')
param dnsservers array = [
  '168.63.129.16'
]

resource policy 'Microsoft.Network/firewallPolicies@2020-06-01' = {
  name: policyname
  location: location
  properties: {
    threatIntelMode: 'Alert'
    dnsSettings: {
      servers: dnsservers
      enableProxy: true
    }
  }
}

resource platformrcgroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-06-01' = {
  name: '${policy.name}/Platform-Rules'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Allow-Azure-KMS'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Azure-KMS-Service'
            description: 'Allow traffic from all Address Spaces to Azure platform KMS Service'
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '1688'
            ]
            destinationIpGroups: []
            destinationAddresses: []
            destinationFqdns: [
              'kms.core.windows.net'
            ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Allow-Windows-Update'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Http'
            description: 'Allow traffic from all sources to Azure platform KMS Service'
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            targetFqdns: []
            fqdnTags: [
              'WindowsUpdate'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Https'
            description: 'Allow traffic from all sources to Azure platform KMS Service'
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: []
            fqdnTags: [
              'WindowsUpdate'
            ]
          }
        ]
      }
    ]
  }
}

output name string = policy.name
output id string = policy.id
