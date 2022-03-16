@description('Admin username for the backend servers')
param adminUsername string

@description('Password for the admin account on the backend servers')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Size of the virtual machine.')
param vmSize string = 'Standard_B2ms'

var virtualMachines_myVM_name = 'myVM'
var virtualNetworks_myVNet_name_var = 'myVNet'
var net_interface = 'net-int'
var ipconfig_name = 'ipconfig'
var publicIPAddress_var = 'public_ip'
var nsg_name = 'vm-nsg'
var applicationGateways_myAppGateway_name_var = 'myAppGateway'
var vnet_prefix = '10.0.0.0/16'
var ag_subnet_prefix = '10.0.0.0/24'
var backend_subnet_prefix = '10.0.1.0/24'

resource nsg_name_1 'Microsoft.Network/networkSecurityGroups@2020-11-01' = [for i in range(0, 2): {
  name: concat(nsg_name, (i + 1))
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

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = [for i in range(0, 3): {
  name: concat(publicIPAddress_var, i)
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}]

resource virtualNetworks_myVNet_name 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworks_myVNet_name_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_prefix
      ]
    }
    subnets: [
      {
        name: 'myAGSubnet'
        properties: {
          addressPrefix: ag_subnet_prefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'myBackendSubnet'
        properties: {
          addressPrefix: backend_subnet_prefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource virtualMachines_myVM_name_1 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0, 2): {
  name: concat(virtualMachines_myVM_name, (i + 1))
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
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
      computerName: concat(virtualMachines_myVM_name, (i + 1))
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
          id: resourceId('Microsoft.Network/networkInterfaces', concat(net_interface, (i + 1)))
        }
      ]
    }
  }
  dependsOn: [
    resourceId('Microsoft.Network/networkInterfaces', concat(net_interface, (i + 1)))
  ]
}]

resource virtualMachines_myVM_name_1_IIS 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, 2): {
  name: '${virtualMachines_myVM_name}${(i + 1)}/IIS'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.4'
    settings: {
      commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)'
    }
    protectedSettings: {}
  }
  dependsOn: [
    resourceId('Microsoft.Compute/virtualMachines', concat(virtualMachines_myVM_name, (i + 1)))
  ]
}]

resource applicationGateways_myAppGateway_name 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGateways_myAppGateway_name_var
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworks_myVNet_name_var, 'myAGSubnet')
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddress_var}0')
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'myBackendPool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'myHTTPSetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'myListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateways_myAppGateway_name_var, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateways_myAppGateway_name_var, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateways_myAppGateway_name_var, 'myListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateways_myAppGateway_name_var, 'myBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateways_myAppGateway_name_var, 'myHTTPSetting')
          }
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
  dependsOn: [
    virtualNetworks_myVNet_name
    resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddress_var}0')
  ]
}

resource net_interface_1 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, 2): {
  name: concat(net_interface, (i + 1))
  location: location
  properties: {
    ipConfigurations: [
      {
        name: concat(ipconfig_name, (i + 1))
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', concat(publicIPAddress_var, (i + 1)))
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworks_myVNet_name_var, 'myBackendSubnet')
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationGatewayBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateways_myAppGateway_name_var, 'myBackendPool')
            }
          ]
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', concat(nsg_name, (i + 1)))
    }
  }
  dependsOn: [
    resourceId('Microsoft.Network/publicIPAddresses', concat(publicIPAddress_var, (i + 1)))
    virtualNetworks_myVNet_name
    applicationGateways_myAppGateway_name
    resourceId('Microsoft.Network/networkSecurityGroups', concat(nsg_name, (i + 1)))
  ]
}]