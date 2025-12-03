@description('Location for all resources')
param location string = resourceGroup().location

@description('Virtual network address prefix')
param virtualNetworkAddressPrefix string = '10.1.0.0/16'

@description('Azure Firewall subnet address prefix')
param azureFirewallSubnetPrefix string = '10.1.1.0/26'

@description('Workload subnet address prefix')
param workloadSubnetPrefix string = '10.1.2.0/24'

@description('Admin username for the virtual machine')
param adminUsername string = 'azureuser'

@description('Admin password for the virtual machine')
@secure()
param adminPassword string

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

@description('Name prefix for all resources')
param resourcePrefix string = 'fw-ddos'

@description('DNS label prefix for the public IP address')
param dnsLabelPrefix string = toLower('${resourcePrefix}-${uniqueString(resourceGroup().id)}')

// DDoS Protection Plan
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-05-01' = {
  name: '${resourcePrefix}-ddos-plan'
  location: location
  properties: {}
  tags: {
    purpose: 'DDoS Protection'
    environment: 'tutorial'
  }
}

// Public IP for Azure Firewall
resource firewallPublicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${resourcePrefix}-fw-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${dnsLabelPrefix}-fw'
    }
    ddosSettings: {
      protectionMode: 'Enabled'
      ddosProtectionPlan: {
        id: ddosProtectionPlan.id
      }
    }
  }
  tags: {
    purpose: 'Azure Firewall Public IP'
    environment: 'tutorial'
  }
}

// Public IP for Virtual Machine
resource vmPublicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${resourcePrefix}-vm-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${dnsLabelPrefix}-vm'
    }
    ddosSettings: {
      protectionMode: 'Enabled'
      ddosProtectionPlan: {
        id: ddosProtectionPlan.id
      }
    }
  }
  tags: {
    purpose: 'Virtual Machine Public IP'
    environment: 'tutorial'
  }
}

// Route Table for Workload Subnet
resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: '${resourcePrefix}-rt-workload'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'route-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.1.1.4' // Azure Firewall private IP
        }
      }
    ]
  }
  tags: {
    purpose: 'Force traffic through Azure Firewall'
    environment: 'tutorial'
  }
}

// Virtual Network with DDoS Protection
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: '${resourcePrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '168.63.129.16' // Azure DNS
      ]
    }
    enableDdosProtection: true
    ddosProtectionPlan: {
      id: ddosProtectionPlan.id
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Workload-SN'
        properties: {
          addressPrefix: workloadSubnetPrefix
          routeTable: {
            id: routeTable.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
  tags: {
    purpose: 'Virtual Network with DDoS Protection'
    environment: 'tutorial'
  }
}

// Firewall Policy
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
  name: '${resourcePrefix}-fw-policy'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    dnsSettings: {
      enableProxy: true
    }
  }
  tags: {
    purpose: 'Azure Firewall Policy'
    environment: 'tutorial'
  }
}

// Network Rule Collection Group
resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Net-Col01'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowWebRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.1.2.0/24'
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
        ]
      }
    ]
  }
}

// Application Rule Collection Group
resource applicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'App-Col01'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'AllowWebsitesRule'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              'www.google.com'
              'www.microsoft.com'
              'www.bing.com'
            ]
            sourceAddresses: [
              '10.1.2.0/24'
            ]
          }
        ]
      }
    ]
  }
  dependsOn: [
    networkRuleCollectionGroup
  ]
}

// DNAT Rule Collection Group
resource dnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  parent: firewallPolicy
  name: 'DefaultDnatRuleCollectionGroup'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        name: 'Dnat-Col01'
        priority: 200
        action: {
          type: 'Dnat'
        }
        rules: [
          {
            ruleType: 'NatRule'
            name: 'RDPRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              firewallPublicIP.properties.ipAddress
            ]
            destinationPorts: [
              '3389'
            ]
            translatedAddress: '10.1.2.4'
            translatedPort: '3389'
          }
        ]
      }
    ]
  }
  dependsOn: [
    applicationRuleCollectionGroup
  ]
}

// Azure Firewall
resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-05-01' = {
  name: '${resourcePrefix}-fw'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    ipConfigurations: [
      {
        name: 'FW-config'
        properties: {
          publicIPAddress: {
            id: firewallPublicIP.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, 'AzureFirewallSubnet')
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
  tags: {
    purpose: 'Azure Firewall with DDoS Protection'
    environment: 'tutorial'
  }
  dependsOn: [
    dnatRuleCollectionGroup
  ]
}

// Network Interface for Virtual Machine
resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${resourcePrefix}-vm-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.2.4'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, 'Workload-SN')
          }
          publicIPAddress: {
            id: vmPublicIP.id
          }
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
  tags: {
    purpose: 'Virtual Machine Network Interface'
    environment: 'tutorial'
  }
}

// Virtual Machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${resourcePrefix}-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${resourcePrefix}-vm'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        name: '${resourcePrefix}-vm-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface.id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  tags: {
    purpose: 'Test Virtual Machine'
    environment: 'tutorial'
  }
}

// Outputs
output firewallPublicIP string = firewallPublicIP.properties.ipAddress
output firewallFQDN string = firewallPublicIP.properties.dnsSettings.fqdn
output vmPublicIP string = vmPublicIP.properties.ipAddress
output vmFQDN string = vmPublicIP.properties.dnsSettings.fqdn
output firewallPrivateIP string = '10.1.1.4'
output virtualNetworkName string = virtualNetwork.name
output ddosProtectionPlanId string = ddosProtectionPlan.id
output adminUsername string = adminUsername
output rdpConnectionString string = 'mstsc /v:${firewallPublicIP.properties.ipAddress}:3389'
