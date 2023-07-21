@description('naming prefix of the objects in the resource. it can be an empty string.')
param prefix string = ''

@description('First Azure region with Availability Zone')
@allowed([
  'canadacentral'
  'francecentral'
  'germanywestcentral'
  'japaneast'
  'centralus'
  'northeurope'
  'southeastasia'
  'eastus'
  'uksouth'
  'australiaeast'
  'eastus2'
  'westeurope'
  'southcentralus'
  'westus2'
])
param location1 string

@description('Second Azure region with Availability Zone')
@allowed([
  'canadacentral'
  'francecentral'
  'germanywestcentral'
  'japaneast'
  'centralus'
  'northeurope'
  'southeastasia'
  'eastus'
  'uksouth'
  'australiaeast'
  'eastus2'
  'westeurope'
  'southcentralus'
  'westus2'
])
param location2 string

@description('Arbitrary name for the Azure Virtual Network 1')
param vNet1Name string = '${prefix}vnet1'

@description('Arbitrary name for the Azure Virtual Network 2')
param vNet2Name string = '${prefix}vnet2'

@description('CIDR block representing the address space of the Azure VNet 1')
param vNet1AddressPrefix string = '10.1.0.0/16'

@description('CIDR block representing the address space of the Azure VNet 2')
param vNet2AddressPrefix string = '10.2.0.0/16'

@description('Arbitrary name for the Azure subnet1 in VNet1')
param subnet11Name string = 'subnet11'

@description('Arbitrary name for the Azure subnet2 in VNet1')
param subnet12Name string = 'subnet12'

@description('Arbitrary name for the Azure subnet1 in VNet2')
param subnet21Name string = 'subnet21'

@description('Arbitrary name for the Azure subnet2 in VNet2')
param subnet22Name string = 'subnet22'

@description('CIDR block for subnet1 in VNet1- it is a subset of vNet1AddressPrefix address space')
param subnet11Prefix string = '10.1.1.0/24'

@description('CIDR block for subnet2 in VNet1- it is a subset of vNet1AddressPrefix address space')
param subnet12Prefix string = '10.1.2.0/24'

@description('CIDR block for gateway subnet- it is a subset of vNet1AddressPrefix address space')
param gateway1SubnetPrefix string = '10.1.3.0/24'

@description('CIDR block for subnet1 in VNet2- it is a subset of vNet2AddressPrefix address space')
param subnet21Prefix string = '10.2.1.0/24'

@description('CIDR block for subnet2 in VNet2- it is a subset of vNet2AddressPrefix address space')
param subnet22Prefix string = '10.2.2.0/24'

@description('CIDR block for gateway subnet- it is a subset of vNet2AddressPrefix address space')
param gateway2SubnetPrefix string = '10.2.3.0/24'

@description('Arbitrary name for the new gateway1')
param gateway1Name string = '${prefix}gw1'

@description('Arbitrary name for the new gateway2')
param gateway2Name string = '${prefix}gw2'

@description('Arbitrary name for public IP1 resource used for the new azure gateway1')
param gateway1PublicIP1Name string = '${gateway1Name}IP1'

@description('Arbitrary name for public IP2 resource used for the new azure gateway1')
param gateway1PublicIP2Name string = '${gateway1Name}IP2'

@description('Arbitrary name for public IP1 resource used for the new azure gateway2')
param gateway2PublicIP1Name string = '${gateway2Name}IP1'

@description('Arbitrary name for public IP2 resource used for the new azure gateway2')
param gateway2PublicIP2Name string = '${gateway2Name}IP2'

@description('The Sku of the Gateway')
@allowed([
  'VpnGw1AZ'
  'VpnGw2AZ'
  'VpnGw3AZ'
  'VpnGw4AZ'
  'VpnGw5AZ'
])
param gatewaySku string = 'VpnGw2AZ'

@allowed([
  'Generation1'
  'Generation2'
])
param vpnGatewayGeneration string = 'Generation2'

@description('BGP Autonomous System Number of the VPN Gateway1 in VNet1')
param asnGtw1 int = 65001

@description('BGP Autonomous System Number of the VPN Gateway2 in VNet2')
param asnGtw2 int = 65002

@description('Arbitrary name for gateway resource representing VPN gateway1-public IP1')
param localGatewayName11 string = '${prefix}localGateway11'

@description('Arbitrary name for gateway resource representing VPN gateway1-publicIP2')
param localGatewayName12 string = '${prefix}localGateway12'

@description('Arbitrary name for gateway resource representing VPN gateway2-publicIP1')
param localGatewayName21 string = '${prefix}localGateway21'

@description('Arbitrary name for gateway resource representing VPN gateway2-publicIP2')
param localGatewayName22 string = '${prefix}localGateway22'

@description('Arbitrary name for the new connection between VPN gateway1 and the remote VPN Gateway2-public IP1')
param connectionName11_21 string = '${gateway1Name}-to-${gateway2PublicIP1Name}'

@description('Arbitrary name for the new connection between VPN gateway1 and the remote VPN Gateway2-public IP2')
param connectionName12_22 string = '${gateway1Name}-to-${gateway2PublicIP2Name}'

@description('Arbitrary name for the new connection between VPN gateway2 and the remote VPN Gateway1-public IP1')
param connectionName21_11 string = '${gateway2Name}-to-${gateway1PublicIP1Name}'

@description('Arbitrary name for the new connection between VPN gateway2 and the remote VPN Gateway1-public IP2')
param connectionName22_12 string = '${gateway2Name}-to-${gateway1PublicIP2Name}'

@description('Shared key (PSK) for IPSec tunnels')
param sharedKey string = '_your_Pre-Shared-Secret'

@description('name of the VM in subnet1 in VNet1')
param vm1Name string = '${prefix}vm1'

@description('name of the VM in subnet1 in VNet2')
param vm2Name string = '${prefix}vm2'

@description('Size of the Virtual Machine')
@allowed([
  'Standard_B1ls'
  'Standard_B1s'
  'Standard_D2s_v3'
  'Standard_D16s_v3'
])
param vmSize string = 'Standard_B1s'

@description('administrator username of the VMs')
param adminUsername string

@description('administrator password of the VMs')
@secure()
param adminPassword string

@description('dns name of public IP1 of the VPN Gateway1. Must be lowercase. It should match with the regex: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.')
param dnsLabelgtw1PubIP1 string = toLower('gtw1-ip1-${uniqueString(resourceGroup().id)}')

@description('dns name of public IP2 of the VPN Gateway1. Must be lowercase. It should match with the regex: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.')
param dnsLabelgtw1PubIP2 string = toLower('gtw1-ip2-${uniqueString(resourceGroup().id)}')

@description('dns name of public IP1 of the VPN Gateway2. Must be lowercase. It should match with the regex: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.')
param dnsLabelgtw2PubIP1 string = toLower('gtw2-ip1-${uniqueString(resourceGroup().id)}')

@description('dns name of public IP2 of the VPN Gateway2. Must be lowercase. It should match with the regex: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.')
param dnsLabelgtw2PubIP2 string = toLower('gtw2-ip2-${uniqueString(resourceGroup().id)}')

@description('Availability zone for the public IP addresses.')
@allowed([
  '1'
  '2'
  '3'
])
param publicIpZone string = '1'

var gateway1subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vNet1Name, 'GatewaySubnet')
var gateway2subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vNet2Name, 'GatewaySubnet')
var subnet11Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', vNet1Name, subnet11Name)
var subnet21Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', vNet2Name, subnet21Name)

var nsg1Name = '${prefix}nsg1'
var nsg2Name = '${prefix}nsg2'
var nic1Name = '${vm1Name}-nic'
var nic2Name = '${vm2Name}-nic'
var vm1PublicIPName = '${vm1Name}-pubIP'
var vm2PublicIPName = '${vm2Name}-pubIP'
var imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-focal'
  sku: '20_04-lts'
  version: 'latest'
}

resource nsg1 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  location: location1
  name: nsg1Name
  properties: {
    securityRules: [
      {
        name: 'SSH-rule'
        properties: {
          description: 'allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 500
          direction: 'Inbound'
        }
      }
      {
        name: 'RDP-rule'
        properties: {
          description: 'allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 510
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsg2 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: nsg2Name
  location: location2
  properties: {
    securityRules: [
      {
        name: 'SSH-rule'
        properties: {
          description: 'allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 500
          direction: 'Inbound'
        }
      }
      {
        name: 'RDP-rule'
        properties: {
          description: 'allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 510
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vNet1 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vNet1Name
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNet1AddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet11Name
        properties: {
          addressPrefix: subnet11Prefix
          networkSecurityGroup: {
            id: nsg1.id
          }
        }
      }
      {
        name: subnet12Name
        properties: {
          addressPrefix: subnet12Prefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gateway1SubnetPrefix
        }
      }
    ]
  }
}

resource vNet2 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vNet2Name
  location: location2
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNet2AddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet21Name
        properties: {
          addressPrefix: subnet21Prefix
          networkSecurityGroup: {
            id: nsg2.id
          }
        }
      }
      {
        name: subnet22Name
        properties: {
          addressPrefix: subnet22Prefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gateway2SubnetPrefix
        }
      }
    ]
  }
}

resource gateway1PublicIP1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: gateway1PublicIP1Name
  location: location1
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabelgtw1PubIP1
    }
  }
  zones: [
    publicIpZone
  ]
}

resource gateway1PublicIP2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: gateway1PublicIP2Name
  location: location1
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabelgtw1PubIP2
    }
  }
  zones: [
    publicIpZone
  ]
}

resource gateway2PublicIP1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: gateway2PublicIP1Name
  location: location2
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabelgtw2PubIP1
    }
  }
  zones: [
    publicIpZone
  ]
}

resource gateway2PublicIP2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: gateway2PublicIP2Name
  location: location2
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabelgtw2PubIP2
    }
  }
  zones: [
    publicIpZone
  ]
}

resource gateway1 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = {
  name: gateway1Name
  location: location1
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gateway1subnetRef
          }
          publicIPAddress: {
            id: gateway1PublicIP1.id
          }
        }
        name: 'vnetGateway1Config1'
      }
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gateway1subnetRef
          }
          publicIPAddress: {
            id: gateway1PublicIP2.id
          }
        }
        name: 'vnetGateway1Config2'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
    activeActive: true
    vpnGatewayGeneration: vpnGatewayGeneration
    bgpSettings: {
      asn: asnGtw1
    }
  }
  dependsOn: [

    vNet1
  ]
}

resource gateway2 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = {
  name: gateway2Name
  location: location2
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gateway2subnetRef
          }
          publicIPAddress: {
            id: gateway2PublicIP1.id
          }
        }
        name: 'vnetGateway2Config1'
      }
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gateway2subnetRef
          }
          publicIPAddress: {
            id: gateway2PublicIP2.id
          }
        }
        name: 'vnetGateway2Config2'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
    activeActive: true
    vpnGatewayGeneration: vpnGatewayGeneration
    bgpSettings: {
      asn: asnGtw2
    }
  }
  dependsOn: [

    vNet2
  ]
}

resource localGateway11 'Microsoft.Network/localNetworkGateways@2023-02-01' = {
  name: localGatewayName11
  location: location2
  properties: {
    fqdn: gateway1PublicIP1.properties.dnsSettings.fqdn
    bgpSettings: {
      asn: asnGtw1
      bgpPeeringAddress: first(split(gateway1.properties.bgpSettings.bgpPeeringAddress, ','))
      peerWeight: 0
    }
  }
}

resource localGateway12 'Microsoft.Network/localNetworkGateways@2023-02-01' = {
  name: localGatewayName12
  location: location2
  properties: {
    fqdn: gateway1PublicIP2.properties.dnsSettings.fqdn
    bgpSettings: {
      asn: asnGtw1
      bgpPeeringAddress: last(split(gateway1.properties.bgpSettings.bgpPeeringAddress, ','))
      peerWeight: 0
    }
  }
}

resource localGateway21 'Microsoft.Network/localNetworkGateways@2023-02-01' = {
  name: localGatewayName21
  location: location1
  properties: {
    fqdn: gateway2PublicIP1.properties.dnsSettings.fqdn
    bgpSettings: {
      asn: asnGtw2
      bgpPeeringAddress: first(split(gateway2.properties.bgpSettings.bgpPeeringAddress, ','))
      peerWeight: 0
    }
  }
}

resource localGateway22 'Microsoft.Network/localNetworkGateways@2023-02-01' = {
  name: localGatewayName22
  location: location1
  properties: {
    fqdn: gateway2PublicIP2.properties.dnsSettings.fqdn
    bgpSettings: {
      asn: asnGtw2
      bgpPeeringAddress: last(split(gateway2.properties.bgpSettings.bgpPeeringAddress, ','))
      peerWeight: 0
    }
  }
}

resource connectionName11_21_resource 'Microsoft.Network/connections@2023-02-01' = {
  name: connectionName11_21
  location: location1
  properties: {
    virtualNetworkGateway1: {
      id: gateway1.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localGateway21.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
    enableBgp: true
  }
}

resource connectionName12_22_resource 'Microsoft.Network/connections@2023-02-01' = {
  name: connectionName12_22
  location: location1
  properties: {
    virtualNetworkGateway1: {
      id: gateway1.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localGateway22.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
    enableBgp: true
  }
}

resource connectionName21_11_resource 'Microsoft.Network/connections@2023-02-01' = {
  name: connectionName21_11
  location: location2
  properties: {
    virtualNetworkGateway1: {
      id: gateway2.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localGateway11.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
    enableBgp: true
  }
}

resource connectionName22_12_resource 'Microsoft.Network/connections@2023-02-01' = {
  name: connectionName22_12
  location: location2
  properties: {
    virtualNetworkGateway1: {
      id: gateway2.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localGateway12.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
    enableBgp: true
  }
}

resource vm1PublicIP 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: vm1PublicIPName
  location: location1
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vm2PublicIP 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: vm2PublicIPName
  location: location2
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic1 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: nic1Name
  location: location1
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vm1PublicIP.id
          }
          subnet: {
            id: subnet11Ref
          }
        }
      }
    ]
  }
  dependsOn: [

    vNet1
  ]
}

resource nic2 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: nic2Name
  location: location2
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vm2PublicIP.id
          }
          subnet: {
            id: subnet21Ref
          }
        }
      }
    ]
  }
  dependsOn: [

    vNet2
  ]
}

resource vm1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vm1Name
  location: location1
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vm1Name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imageReference.publisher
        offer: imageReference.offer
        sku: imageReference.sku
        version: imageReference.version
      }
      osDisk: {
        name: '${vm1Name}-OSdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vm2Name
  location: location2
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vm2Name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imageReference.publisher
        offer: imageReference.offer
        sku: imageReference.sku
        version: imageReference.version
      }
      osDisk: {
        name: '${vm2Name}-OSdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
  }
}
