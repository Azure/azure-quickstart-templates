@description('Location for all resources.')
param location string = resourceGroup().location

@description('Resource name prefix.')
param resourcePrefix string = 'natfw-${uniqueString(resourceGroup().id)}'

@description('Admin username for the virtual machine.')
param adminUsername string = 'azureuser'

@description('SSH public key for the virtual machine.')
@secure()
param adminSshKey string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_DS1_v2'

// Hub Virtual Network
resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: '${resourcePrefix}-vnet-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.64/26'
          natGateway: {
            id: natGateway.id
          }
        }
      }
    ]
  }
}

// Spoke Virtual Network
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: '${resourcePrefix}-vnet-spoke'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-private'
        properties: {
          addressPrefix: '10.1.0.0/24'
          routeTable: {
            id: routeTableSpoke.id
          }
        }
      }
    ]
  }
}

// Azure Bastion
resource bastion 'Microsoft.Network/bastionHosts@2024-01-01' = {
  name: '${resourcePrefix}-bastion'
  location: location
  sku: {
    name: 'Developer'
  }
  properties: {
    virtualNetwork: {
      id: hubVirtualNetwork.id
    }
  }
}

// Public IP for Azure Firewall
resource firewallPublicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${resourcePrefix}-public-ip-firewall'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Firewall Policy
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
  name: '${resourcePrefix}-firewall-policy'
  location: location
  properties: {}
}

// Network Rule Collection Group for Firewall Policy
resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  name: 'DefaultNetworkRuleCollectionGroup'
  parent: firewallPolicy
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'spoke-to-internet'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'allow-web'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.1.0.0/24'
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

// Azure Firewall
resource firewall 'Microsoft.Network/azureFirewalls@2024-05-01' = {
  name: '${resourcePrefix}-firewall'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'AzureFirewallIpConfiguration'
        properties: {
          publicIPAddress: {
            id: firewallPublicIP.id
          }
          subnet: {
            id: '${hubVirtualNetwork.id}/subnets/AzureFirewallSubnet'
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
  dependsOn: [
    networkRuleCollectionGroup
  ]
}

// Public IP for NAT Gateway
resource natGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${resourcePrefix}-public-ip-nat'
  location: location
  sku: {
    name: 'StandardV2'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// NAT Gateway
resource natGateway 'Microsoft.Network/natGateways@2024-05-01' = {
  name: '${resourcePrefix}-nat-gateway'
  location: location
  sku: {
    name: 'StandardV2'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGatewayPublicIP.id
      }
    ]
  }
}

// Virtual Network Peering - Hub to Spoke
resource hubToSpokeVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  name: 'vnet-hub-to-vnet-spoke'
  parent: hubVirtualNetwork
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVirtualNetwork.id
    }
  }
}

// Virtual Network Peering - Spoke to Hub
resource spokeToHubVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  name: 'vnet-spoke-to-vnet-hub'
  parent: spokeVirtualNetwork
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVirtualNetwork.id
    }
  }
}

// Route Table for Spoke Network
resource routeTableSpoke 'Microsoft.Network/routeTables@2024-05-01' = {
  name: '${resourcePrefix}-route-table-spoke'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'route-to-hub'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

// Network Security Group for VM
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourcePrefix}-nsg-vm'
  location: location
  properties: {}
}

// Network Interface for VM
resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${resourcePrefix}-nic-vm-spoke'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${spokeVirtualNetwork.id}/subnets/subnet-private'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

// Variables for Linux VM configuration
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminSshKey
      }
    ]
  }
}

// Virtual Machine in Spoke Network
resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${resourcePrefix}-vm-spoke'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${resourcePrefix}-vm'
      adminUsername: adminUsername
      linuxConfiguration: linuxConfiguration
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface.id
        }
      ]
    }
  }
}

// Outputs
output hubVnetId string = hubVirtualNetwork.id
output spokeVnetId string = spokeVirtualNetwork.id
output firewallPrivateIP string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output natGatewayPublicIP string = natGatewayPublicIP.properties.ipAddress
output vmPrivateIP string = vmNetworkInterface.properties.ipConfigurations[0].properties.privateIPAddress
output bastionFqdn string = bastion.properties.dnsName
output resourceGroupName string = resourceGroup().name
output vmName string = virtualMachine.name
