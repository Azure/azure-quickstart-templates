@description('Enable Pick Streaming')
param addPixelStreamingPorts bool = false

var nsgRules = {
  'nsgRules-RDP': !addPixelStreamingPorts ? [
    {
      name: 'RDP'
      properties: {
        priority: 1010
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
    ] : [
    {
      name: 'RDP'
      properties: {
        priority: 1010
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
    {
      name: 'PixelStream'
      properties: {
        priority: 1020
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '80'
      }
    }
  ]
  'nsgRules-Teradici': !addPixelStreamingPorts ? [
    {
      name: 'RDP'
      properties: {
        priority: 1010
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
    {
      name: 'PCoIPtcp'
      properties: {
        priority: 1020
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '4172'
      }
    }
    {
      name: 'PCoIPudp'
      properties: {
        priority: 1030
        protocol: 'UDP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '4172'
      }
    }
    {
      name: 'CertAuthHTTPS'
      properties: {
        priority: 1040
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '443'
      }
    }
    {
      name: 'TeradiciCom'
      properties: {
        priority: 1050
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '60443'
      }
    }
  ] : [
   {
      name: 'RDP'
      properties: {
        priority: 1010
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
    {
      name: 'PCoIPtcp'
      properties: {
        priority: 1020
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '4172'
      }
    }
    {
      name: 'PCoIPudp'
      properties: {
        priority: 1030
        protocol: 'UDP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '4172'
      }
    }
    {
      name: 'CertAuthHTTPS'
      properties: {
        priority: 1040
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '443'
      }
    }
    {
      name: 'TeradiciCom'
      properties: {
        priority: 1050
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '60443'
      }
    }
    {
      name: 'PixelStream'
      properties: {
        priority: 1060
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '80'
      }
    }
  ]
  'nsgRules-Parsec': !addPixelStreamingPorts ? [
    {
      name: 'RDP'
      properties: {
        priority: 1010
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
  ] : [
    {
      name: 'RDP'
      properties: {
        priority: 1010
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
    {
      name: 'PixelStream'
      properties: {
        priority: 1020
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '80'
      }
    }
  ]
}

output nsgRules object = nsgRules
