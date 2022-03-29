@description('Specifies a project name that is used for generating resource names.')
param projectName string

@description('Specifies the location for all of the resources created by this template.')
param location string = resourceGroup().location

@description('Specifies the virtual machine administrator username.')
param adminUsername string

@description('Specifies the virtual machine administrator password.')
@secure()
param adminPassword string

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

var lbName_var = '${projectName}-lb'
var lbSkuName = 'Standard'
var lbPublicIpAddressName_var = '${projectName}-lbPublicIP'
var lbPublicIPAddressNameOutbound_var = '${projectName}-lbPublicIPOutbound'
var lbFrontEndName = 'LoadBalancerFrontEnd'
var lbFrontEndNameOutbound = 'LoadBalancerFrontEndOutbound'
var lbBackendPoolName = 'LoadBalancerBackEndPool'
var lbBackendPoolNameOutbound = 'LoadBalancerBackEndPoolOutbound'
var lbProbeName = 'loadBalancerHealthProbe'
var nsgName_var = '${projectName}-nsg'
var vNetName_var = '${projectName}-vnet'
var vNetAddressPrefix = '10.0.0.0/16'
var vNetSubnetName = 'BackendSubnet'
var vNetSubnetAddressPrefix = '10.0.0.0/24'
var bastionName_var = '${projectName}-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var vNetBastionSubnetAddressPrefix = '10.0.1.0/24'
var bastionPublicIPAddressName_var = '${projectName}-bastionPublicIP'
var vmStorageAccountType = 'Premium_LRS'

resource projectName_vm_1_networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = [for i in range(0, 3): {
  name: '${projectName}-vm${(i + 1)}-networkInterface'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vNetName_vNetSubnetName.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_var, lbBackendPoolName)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_var, lbBackendPoolNameOutbound)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgName.id
    }
  }
  dependsOn: [
    vNetName
    vNetName_vNetSubnetName
    lbName
    nsgName
  ]
}]

resource projectName_vm_1_InstallWebServer 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, 3): {
  name: '${projectName}-vm${(i + 1)}/InstallWebServer'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item \'C:\\inetpub\\wwwroot\\iisstart.htm\' && powershell.exe Add-Content -Path \'C:\\inetpub\\wwwroot\\iisstart.htm\' -Value $(\'Hello World from \' + $env:computername)'
    }
  }
  dependsOn: [
    projectName_vm_1
  ]
}]

resource projectName_vm_1 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0, 3): {
  name: '${projectName}-vm${(i + 1)}'
  location: location
  zones: [
    (i + 1)
  ]
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
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${projectName}-vm${(i + 1)}-networkInterface')
        }
      ]
    }
    osProfile: {
      computerName: '${projectName}-vm${(i + 1)}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
  dependsOn: [
    projectName_vm_1_networkInterface
  ]
}]

resource vNetName_bastionSubnetName 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vNetName
  location: location
  name: '${bastionSubnetName}'
  properties: {
    addressPrefix: vNetBastionSubnetAddressPrefix
  }
}

resource vNetName_vNetSubnetName 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vNetName
  location: location
  name: '${vNetSubnetName}'
  properties: {
    addressPrefix: vNetSubnetAddressPrefix
  }
}

resource bastionName 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastionName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIPAddressName.id
          }
          subnet: {
            id: vNetName_bastionSubnetName.id
          }
        }
      }
    ]
  }
  dependsOn: [
    vNetName
  ]
}

resource bastionPublicIPAddressName 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: bastionPublicIPAddressName_var
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbName 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: lbName_var
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndName
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddressName.id
          }
        }
      }
      {
        name: lbFrontEndNameOutbound
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddressNameOutbound.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolName
      }
      {
        name: lbBackendPoolNameOutbound
      }
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_var, lbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_var, lbBackendPoolName)
          }
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName_var, lbProbeName)
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    outboundRules: [
      {
        name: 'myOutboundRule'
        properties: {
          allocatedOutboundPorts: 10000
          protocol: 'All'
          enableTcpReset: false
          idleTimeoutInMinutes: 15
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_var, lbBackendPoolNameOutbound)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_var, lbFrontEndNameOutbound)
            }
          ]
        }
      }
    ]
  }
}

resource lbPublicIPAddressName 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: lbPublicIpAddressName_var
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbPublicIPAddressNameOutbound 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: lbPublicIPAddressNameOutbound_var
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsgName 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName_var
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vNetName 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNetName_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressPrefix
      ]
    }
  }
}
