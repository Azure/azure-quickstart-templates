@description('Admin username for the backend servers')
param adminUsername string

@description('Password for the admin account on the backend servers')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Size of the virtual machine.')
param vmSize string = 'Standard_B2ms'

var virtualMachine_name = 'myVM'
var virtualNetwork_name = 'myVNet'
var netInterface_name = 'net-int'
var ipconfig_name = 'ipconfig'
var ipPrefix_name = 'public_ip_prefix'
var ipprefix_size = 31
var publicIPAddress_name = 'public_ip'
var nsg_name = 'vm-nsg'
var firewall_name = 'FW-01'
var vnet_prefix = '10.0.0.0/16'
var fw_subnet_prefix = '10.0.0.0/24'
var backend_subnet_prefix = '10.0.1.0/24'
var azureFirewallSubnetId = subnet.id
var azureFirewallSubnetJSON = json('{"id": "${azureFirewallSubnetId}"}')
var azureFirewallIpConfigurations = [for i in range(0, 2): {
  name: 'IpConf${(i + 1)}'
  properties: {
    subnet: (((i + 1) == 1) ? azureFirewallSubnetJSON : json('null'))
    publicIPAddress: {
      id: publicIPAddress[i].id
    }
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = [for i in range(0, 2): {
  name: '${nsg_name}${i + 1}'
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

resource ipprefix 'Microsoft.Network/publicIPPrefixes@2021-08-01' = {
  name: ipPrefix_name
  location: location
  properties: {
    prefixLength: ipprefix_size
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = [for i in range(0, 2): {
  name: '${publicIPAddress_name}${i + 1}'
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetwork_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_prefix
      ]
    }
    subnets: [
      {
        name: 'myBackendSubnet'
        properties: {
          addressPrefix: backend_subnet_prefix
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: virtualNetwork
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: fw_subnet_prefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = [for i in range(0, 2): {
  name: '${virtualMachine_name}${i+1}'
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
      computerName: '${virtualMachine_name}${i+1}'
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
  dependsOn: [
    netInterface[i]
  ]
}]

resource netInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = [for i in range(0, 2): {
  name: '${netInterface_name}${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${ipconfig_name}${i + 1}'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork_name, 'myBackendSubnet')
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
  dependsOn: [
    virtualNetwork
    nsg[i]
  ]
}]

resource firewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: firewall_name
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
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
  dependsOn: [
    publicIPAddress[0]
    publicIPAddress[1]
  ]
}

resource routeTable 'Microsoft.Network/routeTables@2021-08-01' = {
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
