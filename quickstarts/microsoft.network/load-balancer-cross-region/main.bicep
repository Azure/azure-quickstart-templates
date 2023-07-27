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
param locationCr string = 'eastus2'

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
param locationR1 string = 'eastus'

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
param locationR2 string = 'westus2'

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
var lbR1Name = '${projectName}-lb-r1'
var lbPIPR1Name = '${projectName}-lbPublicIP-r1'
var lbPIPOutboundR1Name = '${projectName}-lbPublicIPOutbound-r1'
var lbFrontEndR1Name = 'LoadBalancerFrontEnd-r1'
var lbFrontEndNameOutboundR1 = 'LoadBalancerFrontEndOutbound-r1'
var lbBackendPoolR1Name = 'LoadBalancerBackEndPool-r1'
var lbBackendPoolNameOutboundR1 = 'LoadBalancerBackEndPoolOutbound-r1'
var lbProbeR1Name = 'loadBalancerHealthProbe-r1'
var nsgR1Name = '${projectName}-nsg-r1'
var vnetR1Name = '${projectName}-vnet-r1'
var vnetAddressPrefixR1 = '10.0.0.0/16'
var vnetSubnetR1Name = 'BackendSubnet-r1'
var vnetSubnetAddressPrefixR1 = '10.0.0.0/24'
var bastionHostR1Name = '${projectName}-bastion-r1'
var bastionSubnetR1Name = 'AzureBastionSubnet'
var vnetBastionSubnetAddressPrefixR1 = '10.0.1.0/24'
var bastionPIPR1Name = '${projectName}-bastionPublicIP-r1'
var lbR2Name = '${projectName}-lb-r2'
var lbPIPR2Name = '${projectName}-lbPublicIP-r2'
var lbPIPOutboundR2Name = '${projectName}-lbPublicIPOutbound-r2'
var lbFrontEndR2Name = 'LoadBalancerFrontEnd-r2'
var lbFrontEndNameOutboundR2 = 'LoadBalancerFrontEndOutbound-r2'
var lbBackendPoolR2Name = 'LoadBalancerBackEndPool-r2'
var lbBackendPoolNameOutboundR2 = 'LoadBalancerBackEndPoolOutbound-r2'
var lbProbeR2Name = 'loadBalancerHealthProbe-r2'
var nsgR2Name = '${projectName}-nsg-r2'
var vnetR2Name = '${projectName}-vnet-r2'
var vnetAddressPrefixR2 = '11.0.0.0/16'
var vnetSubnetR2Name = 'BackendSubnet-r2'
var vnetSubnetAddressPrefixR2 = '11.0.0.0/24'
var bastionHostR2Name = '${projectName}-bastion-r2'
var bastionSubnetR2Name = 'AzureBastionSubnet'
var vnetBastionSubnetAddressPrefixR2 = '11.0.1.0/24'
var bastionPIPR2Name = '${projectName}-bastionPublicIP-r2'
var lbCrName = '${projectName}-lb-cr'
var lbBackendPoolCrName = 'LoadBalancerBackEndPool-cr'
var lbPIPCrName = '${projectName}-lbPublicIP-cr'
var lbFrontEndCrName = 'LoadBalancerFrontEnd-cr'

resource nicVmR1 'Microsoft.Network/networkInterfaces@2023-02-01' = [for i in range(0, 3): {
  name: 'vm-r1-${(i + 1)}-networkInterface'
  location: locationR1
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
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR1Name, lbBackendPoolR1Name)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR1Name, lbBackendPoolNameOutboundR1)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgR1.id
    }
  }
  dependsOn: [
    vnetR1
    lbR1
  ]
}]

resource installWebServerVmR1 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r1-${(i + 1)}/InstallWebServer'
  location: locationR1
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
    vmR2
  ]
}]

resource vmR1 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r1-${(i + 1)}'
  location: locationR1
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
    nicVmR2
  ]
}]

resource vnetSubnetR1Bastion 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vnetR1
  name: bastionSubnetR1Name
  properties: {
    addressPrefix: vnetBastionSubnetAddressPrefixR1
  }
}

resource vnetSubnetR1 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vnetR1
  name: vnetSubnetR1Name
  properties: {
    addressPrefix: vnetSubnetAddressPrefixR1
  }
  dependsOn: [

    vnetSubnetR1Bastion
  ]
}

resource bastionHostR1 'Microsoft.Network/bastionHosts@2023-02-01' = {
  name: bastionHostR1Name
  location: locationR1
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPIPR1.id
          }
          subnet: {
            id: vnetSubnetR1Bastion.id
          }
        }
      }
    ]
  }
  dependsOn: [

    vnetR1

  ]
}

resource bastionPIPR1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: bastionPIPR1Name
  location: locationR1
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbR1 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbR1Name
  location: locationR1
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndR1Name
        properties: {
          publicIPAddress: {
            id: lbPIPR1.id
          }
        }
      }
      {
        name: lbFrontEndNameOutboundR1
        properties: {
          publicIPAddress: {
            id: lbPIPOutboundR1.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolR1Name
      }
      {
        name: lbBackendPoolNameOutboundR1
      }
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbR1Name, lbFrontEndR1Name)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR1Name, lbBackendPoolR1Name)
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
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbR1Name, lbProbeR1Name)
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeR1Name
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
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR1Name, lbBackendPoolNameOutboundR1)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbR1Name, lbFrontEndNameOutboundR1)
            }
          ]
        }
      }
    ]
  }
}

resource lbPIPR1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPIPR1Name
  location: locationR1
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbPIPOutboundR1 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPIPOutboundR1Name
  location: locationR1
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsgR1 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: nsgR1Name
  location: locationR1
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

resource vnetR1 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vnetR1Name
  location: locationR1
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixR1
      ]
    }
  }
}

resource nicVmR2 'Microsoft.Network/networkInterfaces@2023-02-01' = [for i in range(0, 3): {
  name: 'vm-r2-${(i + 1)}-networkInterface'
  location: locationR2
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetSubnetR2.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR2Name, lbBackendPoolR2Name)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR2Name, lbBackendPoolNameOutboundR2)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgR2.id
    }
  }
  dependsOn: [
    vnetR2
    lbR2
  ]
}]

resource installWebServerVmR2 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r2-${(i + 1)}/InstallWebServer'
  location: locationR2
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
    vmR2
  ]
}]

resource vmR2 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, 3): {
  name: 'vm-r2-${(i + 1)}'
  location: locationR2
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
    nicVmR2
  ]
}]

resource vnetSubnetR2Bastion 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vnetR2
  name: bastionSubnetR2Name
  properties: {
    addressPrefix: vnetBastionSubnetAddressPrefixR2
  }
}

resource vnetSubnetR2 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  parent: vnetR2
  name: vnetSubnetR2Name
  properties: {
    addressPrefix: vnetSubnetAddressPrefixR2
  }
  dependsOn: [

    vnetSubnetR2Bastion
  ]
}

resource bastionHostR2 'Microsoft.Network/bastionHosts@2023-02-01' = {
  name: bastionHostR2Name
  location: locationR2
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPIPR2.id
          }
          subnet: {
            id: vnetSubnetR2Bastion.id
          }
        }
      }
    ]
  }
  dependsOn: [

    vnetR2

  ]
}

resource bastionPIPR2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: bastionPIPR2Name
  location: locationR2
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbR2 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbR2Name
  location: locationR2
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndR2Name
        properties: {
          publicIPAddress: {
            id: lbPIPR2.id
          }
        }
      }
      {
        name: lbFrontEndNameOutboundR2
        properties: {
          publicIPAddress: {
            id: lbPIPOutboundR2.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolR2Name
      }
      {
        name: lbBackendPoolNameOutboundR2
      }
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbR2Name, lbFrontEndR2Name)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR2Name, lbBackendPoolR2Name)
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
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbR2Name, lbProbeR2Name)
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeR2Name
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
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbR2Name, lbBackendPoolNameOutboundR2)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbR2Name, lbFrontEndNameOutboundR2)
            }
          ]
        }
      }
    ]
  }
}

resource lbPIPR2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPIPR2Name
  location: locationR2
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lbPIPOutboundR2 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPIPOutboundR2Name
  location: locationR2
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsgR2 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: nsgR2Name
  location: locationR2
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

resource vnetR2 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vnetR2Name
  location: locationR2
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixR2
      ]
    }
  }
}

resource lbPIPCr 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: lbPIPCrName
  location: locationCr
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}

resource lbCr 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbCrName
  location: locationCr
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndCrName
        properties: {
          publicIPAddress: {
            id: lbPIPCr.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolCrName
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbCrName, lbFrontEndCrName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbCrName, lbBackendPoolCrName)
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

resource lbBackendPoolCr 'Microsoft.Network/loadBalancers/backendAddressPools@2023-02-01' = {
  parent: lbCr
  name: lbBackendPoolCrName
  properties: {
    loadBalancerBackendAddresses: [
      {
        name: 'address1'
        properties: {
          loadBalancerFrontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbR1Name, lbFrontEndR1Name)
          }
        }
      }
      {
        name: 'address2'
        properties: {
          loadBalancerFrontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbR2Name, lbFrontEndR2Name)
          }
        }
      }
    ]
  }
  dependsOn: [
    lbR1
    lbR2
  ]
}
