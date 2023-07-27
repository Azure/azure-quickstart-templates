@description('Specifies a project name that is used for generating resource names.')
param projectName string

@description('Specifies the location for the cross-region load balancer.  Available in limited regions.')
@allowed([
  'eastus2'
  'westus'
  'centralus'
  'westeurope'
  'southeastasia'
  'centralus'
  'northeurope'
  'eastasia'
  'UKsouth'
  'USgovvirginia'
])
param location_cr string = 'eastus2'

@description('Specifies the location for the regional load balancer.')
@allowed([
  'eastus'
  'eastus2'
  'southcentralus'
  'westus2'
  'westus3'
  'australiaeast'
  'southeastasia'
  'northeurope'
  'swedencentral'
  'uksouth'
  'westeurope'
  'centralus'
  'southafricanorth'
  'centralindia'
  'eastasia'
  'japaneast'
  'koreacentral'
  'canadacentral'
  'francecentral'
  'germanywestcentral'
  'norwayeast'
  'switzerlandnorth'
  'uaenorth'
  'brazilsouth'
  'eastus2euap'
  'qatarcentral'
  'centralusstage'
  'eastus2stage'
  'northcentralusstage'
  'southcentralusstage'
  'westusstage'
  'westus2stage'
  'asia'
  'asiapacific'
  'australia'
  'brazil'
  'canada'
  'europe'
  'france'
  'germany'
  'global'
  'india'
  'japan'
  'korea'
  'norway'
  'singapore'
  'southafrica'
  'switzerland'
  'unitedstates'
  'eastasiastage'
  'eastusstg'
  'northcentralus'
  'westus'
  'jioindiawest'
  'centraluseuap'
  'westcentralus'
  'southafricawest'
  'australiacentral'
  'australiacentral2'
  'australiasoutheast'
  'japanwest'
  'jioindiacentral'
  'koreasouth'
  'southindia'
  'westindia'
  'francesouth'
  'germanynorth'
  'norwaywest'
  'switzerlandwest'
  'ukwest'
  'uaecentral'
  'brazilsoutheast'
])
param location_r1 string = 'eastus'

@description('Specifies the location for the regional load balancer.')
@allowed([
  'eastus'
  'eastus2'
  'southcentralus'
  'westus2'
  'westus3'
  'australiaeast'
  'southeastasia'
  'northeurope'
  'swedencentral'
  'uksouth'
  'westeurope'
  'centralus'
  'southafricanorth'
  'centralindia'
  'eastasia'
  'japaneast'
  'koreacentral'
  'canadacentral'
  'francecentral'
  'germanywestcentral'
  'norwayeast'
  'switzerlandnorth'
  'uaenorth'
  'brazilsouth'
  'eastus2euap'
  'qatarcentral'
  'centralusstage'
  'eastus2stage'
  'northcentralusstage'
  'southcentralusstage'
  'westusstage'
  'westus2stage'
  'asia'
  'asiapacific'
  'australia'
  'brazil'
  'canada'
  'europe'
  'france'
  'germany'
  'global'
  'india'
  'japan'
  'korea'
  'norway'
  'singapore'
  'southafrica'
  'switzerland'
  'unitedstates'
  'eastasiastage'
  'eastusstg'
  'northcentralus'
  'westus'
  'jioindiawest'
  'centraluseuap'
  'westcentralus'
  'southafricawest'
  'australiacentral'
  'australiacentral2'
  'australiasoutheast'
  'japanwest'
  'jioindiacentral'
  'koreasouth'
  'southindia'
  'westindia'
  'francesouth'
  'germanynorth'
  'norwaywest'
  'switzerlandwest'
  'ukwest'
  'uaecentral'
  'brazilsoutheast'
])
param location_r2 string = 'westus2'

@description('Specifies the virtual machine administrator username.')
param adminUsername string

@description('Specifies the virtual machine administrator password.')
@secure()
param adminPassword string

@description('Size of the virtual machine')
param vmSize string = 'Standard_DS1_v2'

var publicIPAddressType = 'Static'
var lbSkuName = 'Standard'
var vmStorageAccountType = 'Premium_LRS'
var lbName_r1_var = '${projectName}-lb-r1'
var lbPublicIpAddressName_r1_var = '${projectName}-lbPublicIP-r1'
var lbPublicIPAddressNameOutbound_r1_var = '${projectName}-lbPublicIPOutbound-r1'
var lbFrontEndName_r1 = 'LoadBalancerFrontEnd-r1'
var lbFrontEndNameOutbound_r1 = 'LoadBalancerFrontEndOutbound-r1'
var lbBackendPoolName_r1 = 'LoadBalancerBackEndPool-r1'
var lbBackendPoolNameOutbound_r1 = 'LoadBalancerBackEndPoolOutbound-r1'
var lbProbeName_r1 = 'loadBalancerHealthProbe-r1'
var nsgName_r1_var = '${projectName}-nsg-r1'
var vNetName_r1_var = '${projectName}-vnet-r1'
var vNetAddressPrefix_r1 = '10.0.0.0/16'
var vNetSubnetName_r1 = 'BackendSubnet-r1'
var vNetSubnetAddressPrefix_r1 = '10.0.0.0/24'
var bastionName_r1_var = '${projectName}-bastion-r1'
var bastionSubnetName_r1 = 'AzureBastionSubnet'
var vNetBastionSubnetAddressPrefix_r1 = '10.0.1.0/24'
var bastionPublicIPAddressName_r1_var = '${projectName}-bastionPublicIP-r1'
var lbName_r2_var = '${projectName}-lb-r2'
var lbPublicIpAddressName_r2_var = '${projectName}-lbPublicIP-r2'
var lbPublicIPAddressNameOutbound_r2_var = '${projectName}-lbPublicIPOutbound-r2'
var lbFrontEndName_r2 = 'LoadBalancerFrontEnd-r2'
var lbFrontEndNameOutbound_r2 = 'LoadBalancerFrontEndOutbound-r2'
var lbBackendPoolName_r2 = 'LoadBalancerBackEndPool-r2'
var lbBackendPoolNameOutbound_r2 = 'LoadBalancerBackEndPoolOutbound-r2'
var lbProbeName_r2 = 'loadBalancerHealthProbe-r2'
var nsgName_r2_var = '${projectName}-nsg-r2'
var vNetName_r2_var = '${projectName}-vnet-r2'
var vNetAddressPrefix_r2 = '11.0.0.0/16'
var vNetSubnetName_r2 = 'BackendSubnet-r2'
var vNetSubnetAddressPrefix_r2 = '11.0.0.0/24'
var bastionName_r2_var = '${projectName}-bastion-r2'
var bastionSubnetName_r2 = 'AzureBastionSubnet'
var vNetBastionSubnetAddressPrefix_r2 = '11.0.1.0/24'
var bastionPublicIPAddressName_r2_var = '${projectName}-bastionPublicIP-r2'
var lbName_cr_var = '${projectName}-lb-cr'
var lbBackendPoolName_cr = 'LoadBalancerBackEndPool-cr'
var lbPublicIpAddressName_cr_var = '${projectName}-lbPublicIP-cr'
var lbFrontEndName_cr = 'LoadBalancerFrontEnd-cr'

resource nicVmR1 'Microsoft.Network/networkInterfaces@2023-02-01' = [for i in range(0, 3): {
  name: 'vm-r1-${(i + 1)}-networkInterface'
  location: location_r1
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetSubnetR1.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r1_var, lbBackendPoolName_r1)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r1_var, lbBackendPoolNameOutbound_r1)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgName_r1.id
    }
  }
  dependsOn: [
    vNetName_r1
    vnetSubnetR1
    lbName_r1
    nsgName_r1
  ]
}]

resource installWebServerVmR1 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r1-${(i + 1)}/InstallWebServer'
  location: location_r1
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
    vm_r2_1
  ]
}]

resource vmR1 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r1-${(i + 1)}'
  location: location_r1
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
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'vm-r1-${(i + 1)}-networkInterface')
        }
      ]
    }
    osProfile: {
      computerName: 'vm-r1-${(i + 1)}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
  dependsOn: [
    vm_r2_1_networkInterface
  ]
}]

resource vnetSubnetR1Bastion 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vNetName_r1
  location: location_r1
  name: '${bastionSubnetName_r1}'
  properties: {
    addressPrefix: vNetBastionSubnetAddressPrefix_r1
  }
}

resource vnetSubnetR1 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vNetName_r1
  location: location_r1
  name: '${vNetSubnetName_r1}'
  properties: {
    addressPrefix: vNetSubnetAddressPrefix_r1
  }
  dependsOn: [

    vnetSubnetR1Bastion
  ]
}

resource bastionName_r1 'Microsoft.Network/bastionHosts@2023-02-01' = {
  name: bastionName_r1_var
  location: location_r1
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIPAddressName_r1.id
          }
          subnet: {
            id: vnetSubnetR1Bastion.id
          }
        }
      }
    ]
  }
  dependsOn: [

    vNetName_r1

  ]
}

resource bastionPublicIPAddressName_r1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: bastionPublicIPAddressName_r1_var
  location: location_r1
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbName_r1 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbName_r1_var
  location: location_r1
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndName_r1
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddressName_r1.id
          }
        }
      }
      {
        name: lbFrontEndNameOutbound_r1
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddressNameOutbound_r1.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolName_r1
      }
      {
        name: lbBackendPoolNameOutbound_r1
      }
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_r1_var, lbFrontEndName_r1)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r1_var, lbBackendPoolName_r1)
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
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName_r1_var, lbProbeName_r1)
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeName_r1
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
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
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r1_var, lbBackendPoolNameOutbound_r1)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_r1_var, lbFrontEndNameOutbound_r1)
            }
          ]
        }
      }
    ]
  }
}

resource lbPublicIPAddressName_r1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPublicIpAddressName_r1_var
  location: location_r1
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbPublicIPAddressNameOutbound_r1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPublicIPAddressNameOutbound_r1_var
  location: location_r1
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsgName_r1 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: nsgName_r1_var
  location: location_r1
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

resource vNetName_r1 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vNetName_r1_var
  location: location_r1
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressPrefix_r1
      ]
    }
  }
}

resource vm_r2_1_networkInterface 'Microsoft.Network/networkInterfaces@2023-02-01' = [for i in range(0, 3): {
  name: 'vm-r2-${(i + 1)}-networkInterface'
  location: location_r2
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vNetName_r2_vNetSubnetName_r2.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r2_var, lbBackendPoolName_r2)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r2_var, lbBackendPoolNameOutbound_r2)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgName_r2.id
    }
  }
  dependsOn: [
    vNetName_r2
    vNetName_r2_vNetSubnetName_r2
    lbName_r2
    nsgName_r2
  ]
}]

resource vm_r2_1_InstallWebServer 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r2-${(i + 1)}/InstallWebServer'
  location: location_r2
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
    vm_r2_1
  ]
}]

resource vm_r2_1 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r2-${(i + 1)}'
  location: location_r2
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
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'vm-r2-${(i + 1)}-networkInterface')
        }
      ]
    }
    osProfile: {
      computerName: 'vm-r2-${(i + 1)}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
  dependsOn: [
    vm_r2_1_networkInterface
  ]
}]

resource vNetName_r2_bastionSubnetName_r2 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vNetName_r2
  location: location_r2
  name: '${bastionSubnetName_r2}'
  properties: {
    addressPrefix: vNetBastionSubnetAddressPrefix_r2
  }
}

resource vNetName_r2_vNetSubnetName_r2 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vNetName_r2
  location: location_r2
  name: '${vNetSubnetName_r2}'
  properties: {
    addressPrefix: vNetSubnetAddressPrefix_r2
  }
  dependsOn: [

    vNetName_r2_bastionSubnetName_r2
  ]
}

resource bastionName_r2 'Microsoft.Network/bastionHosts@2023-02-01' = {
  name: bastionName_r2_var
  location: location_r2
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIPAddressName_r2.id
          }
          subnet: {
            id: vNetName_r2_bastionSubnetName_r2.id
          }
        }
      }
    ]
  }
  dependsOn: [

    vNetName_r2

  ]
}

resource bastionPublicIPAddressName_r2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: bastionPublicIPAddressName_r2_var
  location: location_r2
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbName_r2 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbName_r2_var
  location: location_r2
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndName_r2
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddressName_r2.id
          }
        }
      }
      {
        name: lbFrontEndNameOutbound_r2
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddressNameOutbound_r2.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolName_r2
      }
      {
        name: lbBackendPoolNameOutbound_r2
      }
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_r2_var, lbFrontEndName_r2)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r2_var, lbBackendPoolName_r2)
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
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName_r2_var, lbProbeName_r2)
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeName_r2
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
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
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName_r2_var, lbBackendPoolNameOutbound_r2)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_r2_var, lbFrontEndNameOutbound_r2)
            }
          ]
        }
      }
    ]
  }
}

resource lbPublicIPAddressName_r2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPublicIpAddressName_r2_var
  location: location_r2
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbPublicIPAddressNameOutbound_r2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPublicIPAddressNameOutbound_r2_var
  location: location_r2
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsgName_r2 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: nsgName_r2_var
  location: location_r2
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

resource vNetName_r2 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vNetName_r2_var
  location: location_r2
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressPrefix_r2
      ]
    }
  }
}

resource lbPublicIpAddressName_cr 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPublicIpAddressName_cr_var
  location: location_cr
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}

resource lbName_cr 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbName_cr_var
  location: location_cr
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndName_cr
        properties: {
          publicIPAddress: {
            id: lbPublicIpAddressName_cr.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolName_cr
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_cr_var, lbFrontEndName_cr)
          }
          backendAddressPool: {
            id: lbName_cr_lbBackendPoolName_cr.id
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
        }
      }
    ]
  }
}

resource lbName_cr_lbBackendPoolName_cr 'Microsoft.Network/loadBalancers/backendAddressPools@2023-02-01' = {
  name: '${lbName_cr_var}/${lbBackendPoolName_cr}'
  location: location_cr
  properties: {
    loadBalancerBackendAddresses: [
      {
        name: 'address1'
        properties: {
          probeAdministrativeState: 'InService'
          loadBalancerFrontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_r1_var, lbFrontEndName_r1)
          }
        }
      }
      {
        name: 'address2'
        properties: {
          probeAdministrativeState: 'InService'
          loadBalancerFrontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName_r2_var, lbFrontEndName_r2)
          }
        }
      }
    ]
  }
  dependsOn: [
    lbName_cr
    lbName_r1
    lbName_r2
  ]
}
