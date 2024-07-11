@description('Username for client and server Virtual Machines.')
param adminUsername string

@description('Password for client and server Virtual Machines.')
@secure()
param adminPassword string

@description('Location for all resources, the location must support Availability Zones if required.')
param location string = resourceGroup().location

@description('Size of client and server VMs.')
param vmSize string = 'Standard_D2s_v3'
param routeTableName string = 'route-table'
param virtualNetworkName string = 'vnet'
param clientVirtualMachineName string = 'client-vm'
param serverVirtualMachineName string = 'server-vm'
param firewallPublicIpName string = 'fw-pip'
param clientPublicIpName string = 'client-pip'
param serverPublicIpName string = 'server-pip'
param firewallName string = 'firewall'
param clientNetworkInterfaceName string = 'client-nic'
param serverNetworkInterfaceName string = 'server-nic'
param networkSecurityGroupName string = 'vnet-nsg'

var vnetAddressPrefix = '10.0.0.0/16'
var serversSubnetPrefix = '10.0.2.0/24'
var serverPrefix = '10.0.2.4/32'
var clientPrefix = '10.0.2.5/32'
var azureFirewallSubnetPrefix = '10.0.1.0/26'
var firewallPrivateIP = '10.0.1.4'
var serverPrivateIP = '10.0.2.4'
var clientPrivateIP = '10.0.2.5'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh-allow'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource clientPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: clientPublicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: firewallPublicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource serverPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: serverPublicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource routeTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: routeTableName
  location: location
  properties: {
    routes: [
      {
        name: 'to-server'
        properties: {
          addressPrefix: serverPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      {
        name: 'to-client'
        properties: {
          addressPrefix: clientPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
    ]
  }
}

resource clientVirtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: clientVirtualMachineName
  location: location
  tags: { 
    AzSecPackAutoConfigReady: true 
  }
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftCBLMariner'
        offer: 'cbl-mariner'
        sku: 'cbl-mariner-2-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${clientVirtualMachineName}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
    }
    osProfile: {
      computerName: clientVirtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration:{
          patchSettings: { 
          patchMode: 'AutomaticByPlatform'
          }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: clientNetworkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource serverVirtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: serverVirtualMachineName
  location: location
  tags: { 
    AzSecPackAutoConfigReady: true 
  }
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftCBLMariner'
        offer: 'cbl-mariner'
        sku: 'cbl-mariner-2-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${serverVirtualMachineName}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
    }
    osProfile: {
      computerName: serverVirtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration:{
          patchSettings: { 
          patchMode: 'AutomaticByPlatform'
          }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: serverNetworkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource toClientRoute 'Microsoft.Network/routeTables/routes@2023-09-01' = {
  parent: routeTable
  name: 'to-client'
  properties: {
    addressPrefix: clientPrefix
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewallPrivateIP
  }
}

resource toServerRoute 'Microsoft.Network/routeTables/routes@2023-09-01' = {
  parent: routeTable
  name: 'to-server'
  properties: {
    addressPrefix: serverPrefix
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewallPrivateIP
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    ipConfigurations: [
      {
        name: 'fw-pip'
        properties: {
          publicIPAddress: {
            id: firewallPublicIp.id
          }
          subnet: {
            id: firewallSubnet.id
          }
        }
      }
    ]
    networkRuleCollections: [
      {
        name: 'net-col'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'allow-all'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      }
    ]
  }
}

resource clientNetworkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: clientNetworkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: clientPrivateIP
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: clientPublicIp.id
          }
          subnet: {
            id: serverSubnet.id
          }
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
      {
        name: 'ServerSubnet'
        properties: {
          addressPrefix: serversSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          routeTable: {
            id: routeTable.id
          }
        }
      }
    ]
  }
}

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: virtualNetwork
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: azureFirewallSubnetPrefix
  }
}

resource serverNetworkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: serverNetworkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: serverPrivateIP
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: serverPublicIp.id
          }
          subnet: {
            id: serverSubnet.id
          }
        }
      }
    ]
  }
}

resource serverSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: virtualNetwork
  name: 'ServerSubnet'
  properties: {
    addressPrefix: serversSubnetPrefix
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    routeTable: {
      id: routeTable.id
    }
  }
}
