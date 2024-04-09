@description('Admin username for the backend servers')
param adminUsername string

@description('Password for the admin account on the backend servers')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Size of the virtual machine.')
param vmSize string = 'Standard_B2ms'

var virtualMachineName = 'myVM'
var virtualNetworkName = 'myVNet'
var networkInterfaceName = 'net-int'
var ipConfigName = 'ipconfig'
var ipPrefixName = 'public_ip_prefix'
var ipPrefixSize = 31
var publicIpAddressName = 'public_ip'
var nsgName = 'vm-nsg'
var firewallName = 'FW-01'
var vnetPrefix = '10.0.0.0/16'
var fwSubnetPrefix = '10.0.0.0/24'
var backendSubnetPrefix = '10.0.1.0/24'
var azureFirewallSubnetId = subnet.id
var azureFirewallIpConfigurations = [for i in range(0, 2): {
  name: 'IpConf${(i + 1)}'
  properties: {
    subnet: ((i == 0) ? json('{"id": "${azureFirewallSubnetId}"}') : null)
    publicIPAddress: {
      id: publicIPAddress[i].id
    }
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [for i in range(0, 2): {
  name: '${nsgName}${i + 1}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}]

resource ipprefix 'Microsoft.Network/publicIPPrefixes@2023-09-01' = {
  name: ipPrefixName
  location: location
  properties: {
    prefixLength: ipPrefixSize
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = [for i in range(0, 2): {
  name: '${publicIpAddressName}${i + 1}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    publicIPPrefix: {
      id: ipprefix.id
    }
    idleTimeoutInMinutes: 4
  }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      {
        name: 'myBackendSubnet'
        properties: {
          addressPrefix: backendSubnetPrefix
          routeTable: {
            id: routeTable.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: virtualNetwork
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: fwSubnetPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = [for i in range(0, 2): {
  name: '${virtualMachineName}${i+1}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 127
      }
    }
    osProfile: {
      computerName: '${virtualMachineName}${i+1}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: netInterface[i].id
        }
      ]
    }
  }
}]

resource netInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in range(0, 2): {
  name: '${networkInterfaceName}${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${ipConfigName}${i + 1}'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          primary: true
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsg[i].id
    }
  }
}]

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Deny'
    ipConfigurations: azureFirewallIpConfigurations
    applicationRuleCollections: [
      {
        name: 'web'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'wan-address'
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
                'getmywanip.com'
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              name: 'google'
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
              ]
              sourceAddresses: [
                '10.0.1.0/24'
              ]
            }
            {
              name: 'wupdate'
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
              fqdnTags: [
                'WindowsUpdate'
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
      }
    ]
    natRuleCollections: [
      {
        name: 'Coll-01'
        properties: {
          priority: 100
          action: {
            type: 'Dnat'
          }
          rules: [
            {
              name: 'rdp-01'
              protocols: [
                'TCP'
              ]
              translatedAddress: '10.0.1.4'
              translatedPort: '3389'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                publicIPAddress[0].properties.ipAddress
              ]
              destinationPorts: [
                '3389'
              ]
            }
            {
              name: 'rdp-02'
              protocols: [
                'TCP'
              ]
              translatedAddress: '10.0.1.5'
              translatedPort: '3389'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                publicIPAddress[1].properties.ipAddress
              ]
              destinationPorts: [
                '3389'
              ]
            }
          ]
        }
      }
    ]
  }
}

resource routeTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-01'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'fw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.4'
        }
      }
    ]
  }
}

output name string = firewall.name
output resourceId string = firewall.id
output location string = location
output resourceGroupName string = resourceGroup().name
