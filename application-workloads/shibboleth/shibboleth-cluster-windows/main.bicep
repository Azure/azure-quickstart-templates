@description('User name for the Virtual Machine administrator. Do not use simple names such as \'admin\'')
param adminUsername string

@description('Password for the Virtual Machine administrator.')
@secure()
param adminPassword string

@description('Unique name that will be used to generate various other names including the name of the Public IP used to access the Virtual Machine.')
@maxLength(12)
param uniqueNamePrefix string = take('shc${uniqueString(resourceGroup().id)}', 8)

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter.')
@allowed([
  '2008-R2-SP1'
  '2012-Datacenter'
  '2012-R2-Datacenter'
  '2016-Datacenter'
  '2019-Datacenter'
  '2022-Datacenter'
])
param windowsOSVersion string = '2022-Datacenter'

@description('Password for the MySQL \'root\' admin user.')
@secure()
param mySqlPasswordForRootUser string

@description('User name that will be used to create user in MySQL database which has all privileges.')
param mySqlIdpUser string

@description('Password for the MySQL Idp user.')
@secure()
param mySqlPasswordForIdpUser string

@description('Number of web front end VMs to create.')
@allowed([
  1
  2
  3
  4
  5
])
param vmCountFrontend int = 2

@description('The size of the VM.')
param vmSizeFrontend string = 'Standard_D4s_v4'

@description('The size of the database backend VM.')
param vmSizeDB string = 'Standard_D2s_v4'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var OSVersion = windowsOSVersion
var nicName = '${uniqueNamePrefix}Nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var subnetNameDB = 'SubnetDB'
var subnetPrefixDB = '10.0.1.0/24'
var publicIPAddressName = '${uniqueNamePrefix}IP'
var publicDBIPAddressName = '${uniqueNamePrefix}DBIP'
var publicIPAddressType = 'Dynamic'
var vmName = '${uniqueNamePrefix}VM'
var virtualNetworkName = '${uniqueNamePrefix}VNet'
var availabilitySetName = '${uniqueNamePrefix}AvSet'
var lbName = '${uniqueNamePrefix}LB'
var installScriptName = 'install_shibboleth_idp.ps1'
var installCommand = 'powershell.exe -File ${installScriptName} ${uniqueNamePrefix} ${location} ${uniqueNamePrefix}db ${mySqlIdpUser} "${mySqlPasswordForIdpUser}"'
var installBackendScriptName = 'install_backend.ps1'
var installBackendCommand = 'powershell.exe -File ${installBackendScriptName} "${mySqlPasswordForRootUser}" ${mySqlIdpUser} "${mySqlPasswordForIdpUser}"'

resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-08-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: uniqueNamePrefix
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
      {
        name: subnetNameDB
        properties: {
          addressPrefix: subnetPrefixDB
          networkSecurityGroup: {
            id: virtualNetworkSg.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = [for i in range(0, vmCountFrontend): {
  name: '${nicName}${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          loadBalancerBackendAddressPools: [
            {
              id: lb.properties.backendAddressPools[0].id
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: lb.properties.inboundNatRules[i].id
            }
          ]
        }
      }
    ]
  }
}]

resource lb 'Microsoft.Network/loadBalancers@2022-05-01' = {
  name: lbName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontend'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBackend'
      }
    ]
    inboundNatRules: [
      {
        name: 'SSH-VM0'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
          }
          protocol: 'Tcp'
          frontendPort: 2200
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: 'SSH-VM1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
          }
          protocol: 'Tcp'
          frontendPort: 2201
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: 'SSH-VM2'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
          }
          protocol: 'Tcp'
          frontendPort: 2202
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: 'SSH-VM3'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
          }
          protocol: 'Tcp'
          frontendPort: 2203
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: 'SSH-VM4'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
          }
          protocol: 'Tcp'
          frontendPort: 2204
          backendPort: 22
          enableFloatingIP: false
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackend')
          }
          protocol: 'Tcp'
          frontendPort: 8443
          backendPort: 8443
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          loadDistribution: 'SourceIP'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'tcpProbe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'tcpProbe'
        properties: {
          protocol: 'Tcp'
          port: 8443
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, vmCountFrontend): {
  name: '${vmName}${i}'
  location: location
  properties: {
    availabilitySet: {
      id: availabilitySet.id
    }
    hardwareProfile: {
      vmSize: vmSizeFrontend
    }
    osProfile: {
      computerName: '${vmName}${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}${i}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
        }
      ]
    }
  }
  dependsOn: [
    nic[i]
  ]
}]

resource availabilitySetDb 'Microsoft.Compute/availabilitySets@2022-08-01' = {
  name: '${availabilitySetName}db'
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
}

resource publicDBIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicDBIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: '${uniqueNamePrefix}db'
    }
  }
}

resource nicDb 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: '${nicName}db'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfigdb'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicDBIPAddress.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: virtualNetworkSg.id
    }
  }
}

resource virtualNetworkSg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: '${virtualNetworkName}-sg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'MySQL'
        properties: {
          description: 'Allows MySQL traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1101
          direction: 'Inbound'
        }
      }
      {
        name: 'RDPTCP'
        properties: {
          description: 'Allows RDP traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1301
          direction: 'Inbound'
        }
      }
      {
        name: 'RDPUDP'
        properties: {
          description: 'Allows RDP traffic'
          protocol: 'UDP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1401
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH'
        properties: {
          description: 'Allows SSH traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1201
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vmDb 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: '${vmName}db'
  location: location
  properties: {
    availabilitySet: {
      id: availabilitySetDb.id
    }
    hardwareProfile: {
      vmSize: vmSizeDB
    }
    osProfile: {
      computerName: '${vmName}db'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}db_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicDb.id
        }
      ]
    }
  }
}

resource vmDbCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vmDb
  name: 'CustomScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, format('{0}{1}',installScriptName, _artifactsLocationSasToken))
      ]
    }
    protectedSettings: {
      commandToExecute: installCommand
    }
  }
}

resource vmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, vmCountFrontend): {
  parent: vm[i]
  name: 'customScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, format('{0}{1}', installBackendScriptName, _artifactsLocationSasToken))
      ]
    }
    protectedSettings: {
      commandToExecute: installBackendCommand
    }
  }
  dependsOn: [
    vm[i]
  ]
}]
