param location string = resourceGroup().location
param vnetname string

@description('Specifies the VNet Address Prefix.')
param addressprefix string = '10.0.1.0/24'

@description('Specifies the Subnet Address Prefix for the server subnet')
param serversubnetprefix string = '10.0.1.0/26'

@description('Specifies the Subnet Address Prefix for the bastion subnet')
param bastionsubnetprefix string = '10.0.1.64/26'

@description('Specifies the Subnet Address Prefix for the GatewaySubnet')
param gatewaysubnetprefix string = '10.0.1.128/26'

@description('Specifies the Subnet Address Prefix for the AzureFirewallSubnet')
param firewallsubnetprefix string = '10.0.1.192/26'

var servernsgname = '${vnetname}-snet-servers-nsg'
var bastionnsgname = '${vnetname}-AzureBastionSubnet-nsg'
var bastionnsgrules = {
  securityRules: [
    {
      name: 'bastion-in-allow'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationPortRange: '443'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound'
      }
    }
    {
      name: 'bastion-control-in-allow'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: 'GatewayManager'
        destinationPortRanges: [
          '443'
          '4443'
        ]
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 120
        direction: 'Inbound'
      }
    }
    {
      name: 'bastion-in-deny'
      properties: {
        protocol: '*'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 4096
        direction: 'Inbound'
      }
    }
    {
      name: 'bastion-vnet-ssh-out-allow'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationPortRange: '22'
        destinationAddressPrefix: 'VirtualNetwork'
        access: 'Allow'
        priority: 100
        direction: 'Outbound'
      }
    }
    {
      name: 'bastion-vnet-rdp-out-allow'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationPortRange: '3389'
        destinationAddressPrefix: 'VirtualNetwork'
        access: 'Allow'
        priority: 110
        direction: 'Outbound'
      }
    }
    {
      name: 'bastion-azure-out-allow'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationPortRange: '443'
        destinationAddressPrefix: 'AzureCloud'
        access: 'Allow'
        priority: 120
        direction: 'Outbound'
      }
    }
  ]
}

resource servernsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: servernsgname
  location: location
}

resource bastionnsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: bastionnsgname
  location: location
  properties: {
    securityRules: bastionnsgrules.securityRules
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnetname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressprefix
      ]
    }
    subnets: [
      {
        name: 'snet-servers'
        properties: {
          addressPrefix: serversubnetprefix
          networkSecurityGroup: {
            id: servernsg.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionsubnetprefix
          networkSecurityGroup: {
            id: bastionnsg.id
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaysubnetprefix
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallsubnetprefix
        }
      }
    ]
  }
}

output id string = vnet.id
output subnets array = vnet.properties.subnets
output vnetaddress array = any(vnet.properties.addressSpace.addressPrefixes)
