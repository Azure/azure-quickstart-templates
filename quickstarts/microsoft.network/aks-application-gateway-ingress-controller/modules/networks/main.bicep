@description('Specifies the location of AKS cluster.')
param location string

@description('Specifies the name of the virtual network.')
param virtualNetworkName string

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string

@description('Specifies the name of the subnet hosting the system node pool of the AKS cluster.')
param aksSubnetName string

@description('Specifies the address prefix of the subnet hosting the system node pool of the AKS cluster.')
param aksSubnetAddressPrefix string

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string

@description('Specifies the name of the subnet which contains the the Application Gateway.')
param applicationGatewaySubnetName string

@description('Specifies the address prefix of the subnet which contains the Application Gateway.')
param applicationGatewaySubnetAddressPrefix string

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string

@description('Specifies the resource ID of the log analytics workspace')
param workspaceId string

var bastionSubnetName = 'AzureBastionSubnet'
var bastionPublicIpAddressName = '${bastionHostName}PublicIp'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false

    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: vmSubnetNsg.id
          }
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionSubnetNsg.id
          }
        }
      }
    ]
  }
}

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: bastionPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: '${bastionHostName}Nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource vmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: '${vmSubnetName}Nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2024-01-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: virtualNetwork.id != '' ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, bastionSubnetName) : ''
          }
          publicIPAddress: {
            id: bastionPublicIpAddress.id
          }
        }
      }
    ]
  }
}

resource bastionSubnetNsgDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastionSubnetNsg
  name: '${bastionHostName}Nsg-Diag'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource vmSubnetNsgDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vmSubnetNsg
  name: '${vmSubnetName}Nsg-Diag'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource bastionHostDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastionHost
  name: '${bastionHostName}-Diag'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'BastionAuditLogs'
        enabled: true
      }
    ]
  }
}

output virtualNetworkId string = virtualNetwork.id
output aksSubnetId string = virtualNetwork.id != '' ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, aksSubnetName) : ''
output vmSubnetId string = virtualNetwork.id != '' ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, vmSubnetName) : ''
output applicationGatewaySubnetId string = virtualNetwork.id != '' ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, applicationGatewaySubnetName) : ''
output bastionSubnetId string = virtualNetwork.id != '' ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, bastionSubnetName) : ''
