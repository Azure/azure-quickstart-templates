@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation. If your artifacts are stored on a public repo or public storage account you can leave this blank.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('name of the VNet where is deployed the Gateway Load Balancer')
param vnet1Name string = 'vnetgtw'

@description('name of the VNet where are deployed the Public Load Balancer and the application VMs')
param vnet2Name string = 'vnetapp'

@description('size of the Virtual Machine')
param vmSize string = 'Standard_DS1_v2'

@description('name of the nva1 in the backend pool of the Gateway Load Balancer')
param nva1Name string = 'nva1'

@description('name of the nva2 in the backend pool of the Gateway Load Balancer')
param nva2Name string = 'nva2'

@description('name of the of the application VM1 in the backend pool of the Public Load Balancer')
param vmapp1Name string = 'vmapp1'

@description('name of the of the application VM2 in the backend pool of the Public Load Balancer')
param vmapp2Name string = 'vmapp2'

@description('name of the of VM client in the vnet2')
param vmclient1Name string = 'vmclient1'

@description('VMs admin username')
param adminUsername string

@description('VMs admin password')
@secure()
param adminPassword string

@description('The storage account type for the disks of the VM')
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('name of the azure bastion')
param bastionName string = 'bastion'

var scriptFolder = 'scripts'
var elbName = 'elb'
var elbSkuName = 'Standard'
var elbPublicIpAddressName = '${elbName}-pubIP'
var elbFrontEndName = 'elbFrontEnd'
var elbBackEndPoolName = 'elbBackEndPool'
var elbProbeName = 'elbHealthProbe'
var elbRule1frontendPort = 8081
var elbRule1backendPort = 8081
var elbRule2frontendPort = 8082
var elbRule2backendPort = 8082
var elbRule3frontendPort = 8083
var elbRule3backendPort = 8083
var elbRule4frontendPort = 8084
var elbRule4backendPort = 8084
var elbprobePort = 8080
var gwlbName = 'gwlb'
var gwlbFrontEndIP = '10.0.1.100'
var gwlbFrontEndName = 'lbFrontEndConf'
var gwlbBackEndPoolName = 'gwlbBackEndPool'
var gwlbProbeName = 'gwlbprobe'
var gwlbprobePort = 8080
var vxlanTunnelInternalPort = 10800
var vxlanTunnelInternalIdentifier = 800
var vxlanTunnelExternalPort = 10801
var vxlanTunnelExternalIdentifier = 801
var vnet1Config = {
  location: location
  name: vnet1Name
  addressSpacePrefix1: '10.0.1.0/24'
  subnet1Name: 'nvasubnet'
  subnet2Name: 'fesubnet'
  subnet1Prefix: '10.0.1.0/28'
  subnet2Prefix: '10.0.1.96/28'
  peeringName: '${vnet1Name}To${vnet2Name}'
}
var vnet2Config = {
  location: location
  name: vnet2Name
  addressSpacePrefix1: '10.0.2.0/24'
  subnet1Name: 'appsubnet'
  subnet2Name: 'clientsubnet'
  subnet3Name: 'AzureBastionSubnet'
  subnet1Prefix: '10.0.2.0/28'
  subnet2Prefix: '10.0.2.32/28'
  subnet3Prefix: '10.0.2.192/26'
  peeringName: '${vnet2Name}To${vnet1Name}'
}
var nginxScriptFileName = 'nginx-serverblocks.sh'
var nginxScriptURL = uri(_artifactsLocation, '${scriptFolder}/${nginxScriptFileName}${_artifactsLocationSasToken}')
var nginxCommand = 'bash ${nginxScriptFileName} ${elbRule1backendPort} ${elbRule2backendPort} ${elbRule3backendPort} ${elbRule4backendPort}'
var nvaScriptFileName = 'nva.sh'
var nvaScriptURL = uri(_artifactsLocation, '${scriptFolder}/${nvaScriptFileName}${_artifactsLocationSasToken}')
var nvaCommand = 'bash ${nvaScriptFileName} -p ${vxlanTunnelInternalPort} -v ${vxlanTunnelInternalIdentifier} -P ${vxlanTunnelExternalPort} -V ${vxlanTunnelExternalIdentifier} -n ${gwlbFrontEndIP}'
var nva1IpAddresses = '10.0.1.10'
var nva2IpAddresses = '10.0.1.11'
var vmapp1IpAddress = '10.0.2.5'
var vmapp2IpAddress = '10.0.2.6'
var nvaArray = [
  {
    location: location
    vmName: nva1Name
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
    vnetName: vnet1Config.name
    subnetName: vnet1Config.subnet1Name
    privateIP: nva1IpAddresses
    enableIPForwarding: true
    acceleratedNetworking: false
    scriptURL: nvaScriptURL
    scriptCommand: nvaCommand
    nsgName: '${nva1Name}-nsg'
  }
  {
    location: location
    vmName: nva2Name
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
    vnetName: vnet1Config.name
    subnetName: vnet1Config.subnet1Name
    privateIP: nva2IpAddresses
    enableIPForwarding: true
    acceleratedNetworking: false
    scriptURL: nvaScriptURL
    scriptCommand: nvaCommand
    nsgName: '${nva2Name}-nsg'
  }
]
var vmarray = [
  {
    location: location
    vmName: vmapp1Name
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
    vnetName: vnet2Config.name
    subnetName: vnet2Config.subnet1Name
    privateIP: vmapp1IpAddress
    enableIPForwarding: false
    acceleratedNetworking: false
    scriptURL: nginxScriptURL
    scriptCommand: nginxCommand
    nsgName: '${vmapp1Name}-nsg'
  }
  {
    location: location
    vmName: vmapp2Name
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
    vNetName: vnet2Config.name
    subnetName: vnet2Config.subnet1Name
    privateIP: vmapp2IpAddress
    enableIPForwarding: false
    acceleratedNetworking: false
    scriptURL: nginxScriptURL
    scriptCommand: nginxCommand
    nsgName: '${vmapp2Name}-nsg'
  }
  {
    location: location
    vmName: vmclient1Name
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
    vNetName: vnet2Config.name
    subnetName: vnet2Config.subnet2Name
    privateIP: '10.0.2.40'
    enableIPForwarding: false
    acceleratedNetworking: false
    scriptURL: 'SKIP_CustomScript'
    scriptCommand: 'SKIP_CustomScript'
    nsgName: '${vmclient1Name}-nsg'
  }
]
var nvaCount = length(nvaArray)
var vmCount = length(vmarray)
var vmStorageAccountType = storageAccountType
var bastionSubnetName = vnet2Config.subnet3Name
var bastionPublicIPAddressName = '${bastionName}-pubIP'
var bastionSkuName = 'Standard'
var deploymentBastion = true

resource vnet1 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnet1Config.name
  location: vnet1Config.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1Config.addressSpacePrefix1
      ]
    }
    subnets: [
      {
        name: vnet1Config.subnet1Name
        properties: {
          addressPrefix: vnet1Config.subnet1Prefix
        }
      }
      {
        name: vnet1Config.subnet2Name
        properties: {
          addressPrefix: vnet1Config.subnet2Prefix
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnet2Config.name
  location: vnet2Config.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet2Config.addressSpacePrefix1
      ]
    }
    subnets: [
      {
        name: vnet2Config.subnet1Name
        properties: {
          addressPrefix: vnet2Config.subnet1Prefix
        }
      }
      {
        name: vnet2Config.subnet2Name
        properties: {
          addressPrefix: vnet2Config.subnet2Prefix
        }
      }
      {
        name: vnet2Config.subnet3Name
        properties: {
          addressPrefix: vnet2Config.subnet3Prefix
        }
      }
    ]
  }
}

resource vnet1Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  parent: vnet1
  name: vnet1Config.peeringName
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet2.id
    }
  }
}

resource vnet2Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  parent: vnet2
  name: vnet2Config.peeringName
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet1.id
    }
  }
}

resource gwlb 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: gwlbName
  location: location
  sku: {
    name: 'Gateway'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: gwlbFrontEndName
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet1Config.name, vnet1Config.subnet2Name)
          }
          privateIPAddress: gwlbFrontEndIP
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    backendAddressPools: [
      {
        name: gwlbBackEndPoolName
        properties: {
          tunnelInterfaces: [
            {
              port: vxlanTunnelInternalPort
              identifier: vxlanTunnelInternalIdentifier
              protocol: 'VXLAN'
              type: 'Internal'
            }
            {
              port: vxlanTunnelExternalPort
              identifier: vxlanTunnelExternalIdentifier
              protocol: 'VXLAN'
              type: 'External'
            }
          ]
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbAnyPortRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', gwlbName, gwlbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', gwlbName, gwlbBackEndPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', gwlbName, gwlbProbeName)
          }
          protocol: 'All'
          frontendPort: 0
          backendPort: 0
          loadDistribution: 'Default'
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          disableOutboundSnat: true
        }
      }
    ]
    probes: [
      {
        name: gwlbProbeName
        properties: {
          protocol: 'Http'
          port: gwlbprobePort
          requestPath: '/'
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
  }
  dependsOn: [
    vnet1
  ]
}

resource elbPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: elbPublicIpAddressName
  location: location
  sku: {
    name: elbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource elb 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: elbName
  location: location
  sku: {
    name: elbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: elbFrontEndName
        properties: {
          gatewayLoadBalancer: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', gwlbName, gwlbFrontEndName)
          }
          publicIPAddress: {
            id: elbPublicIpAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: elbBackEndPoolName
      }
    ]
    loadBalancingRules: [
      {
        name: 'http-${string(elbRule1backendPort)}'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', elbName, elbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/LoadBalancers/backendAddressPools', elbName, elbBackEndPoolName)
          }
          frontendPort: elbRule1frontendPort
          backendPort: elbRule1backendPort
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', elbName, elbProbeName)
          }
        }
      }
      {
        name: 'http-${string(elbRule2backendPort)}'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', elbName, elbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/LoadBalancers/backendAddressPools', elbName, elbBackEndPoolName)
          }
          frontendPort: elbRule2frontendPort
          backendPort: elbRule2backendPort
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', elbName, elbProbeName)
          }
        }
      }
      {
        name: 'http-${string(elbRule3backendPort)}'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', elbName, elbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/LoadBalancers/backendAddressPools', elbName, elbBackEndPoolName)
          }
          frontendPort: elbRule3frontendPort
          backendPort: elbRule3backendPort
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', elbName, elbProbeName)
          }
        }
      }
      {
        name: 'http-${string(elbRule4backendPort)}'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', elbName, elbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/LoadBalancers/backendAddressPools', elbName, elbBackEndPoolName)
          }
          frontendPort: elbRule4frontendPort
          backendPort: elbRule4backendPort
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', elbName, elbProbeName)
          }
        }
      }
    ]
    probes: [
      {
        name: elbProbeName
        properties: {
          protocol: 'Http'
          port: elbprobePort
          requestPath: '/'
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
  dependsOn: [
    gwlb
    vnet2
  ]
}

resource elbBackEndPool 'Microsoft.Network/loadBalancers/backendAddressPools@2022-07-01' = {
  parent: elb
  name: elbBackEndPoolName
  properties: {
    loadBalancerBackendAddresses: [
      {
        name: 'app1-address'
        properties: {
          virtualNetwork: {
            id: vnet2.id
          }
          ipAddress: vmapp1IpAddress
        }
      }
      {
        name: 'app2-address'
        properties: {
          virtualNetwork: {
            id: vnet2.id
          }
          ipAddress: vmapp2IpAddress
        }
      }
    ]
  }
}

resource nvaArray_nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = [for i in range(0, nvaCount): {
  name: nvaArray[i].nsgName
  location: nvaArray[i].location
  properties: {
    securityRules: [
      {
        name: 'SSH-rule'
        properties: {
          description: 'allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 500
          direction: 'Inbound'
        }
      }
    ]
  }
}]

resource nvaArray_pubIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for i in range(0, nvaCount): {
  name: '${nvaArray[i].vmName}-pubIP'
  location: nvaArray[i].location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}]

resource nvaArray_NIC 'Microsoft.Network/networkInterfaces@2022-07-01' = [for i in range(0, nvaCount): {
  name: '${nvaArray[i].vmName}-NIC'
  location: nvaArray[i].location
  properties: {
    enableIPForwarding: nvaArray[i].enableIPForwarding
    enableAcceleratedNetworking: nvaArray[i].acceleratedNetworking
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: nvaArray[i].privateIP
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${nvaArray[i].vmName}-pubIP')
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', nvaArray[i].vNetName, nvaArray[i].subnetName)
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', gwlbName, gwlbBackEndPoolName)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', nvaArray[i].nsgName)
    }
  }
  dependsOn: [
    vnet1
    nvaArray_pubIP[i]
    nvaArray_nsg[i]
    gwlb
  ]
}]

resource nvaArray_vm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, nvaCount): {
  name: nvaArray[i].vmName
  location: nvaArray[i].location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: nvaArray[i].vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: nvaArray[i].publisher
        offer: nvaArray[i].offer
        sku: nvaArray[i].sku
        version: nvaArray[i].version
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${nvaArray[i].vmName}-OS'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${nvaArray[i].vmName}-NIC')
        }
      ]
    }
  }
  dependsOn: [
    nvaArray_NIC[i]
  ]
}]

resource nvaArray_customScript 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, nvaCount): if (!empty(nvaArray[i].scriptCommand)) {
  name: '${nvaArray[i].vmName}/vmCustomScript'
  location: nvaArray[i].location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        nvaArray[i].scriptURL
      ]
      commandToExecute: nvaArray[i].scriptCommand
    }
  }
  dependsOn: [
    nvaArray_vm[i]
  ]
}]

resource vmArray_nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = [for i in range(0, vmCount): {
  name: vmarray[i].nsgName
  location: vmarray[i].location
  properties: {
    securityRules: [
      {
        name: 'SSH-rule'
        properties: {
          description: 'allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 500
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-${elbRule1backendPort}'
        properties: {
          description: 'allow web'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: string(elbRule1backendPort)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-${elbRule2backendPort}'
        properties: {
          description: 'allow web'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: string(elbRule2backendPort)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 250
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-${elbRule3backendPort}'
        properties: {
          description: 'allow web'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: string(elbRule3backendPort)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-${elbRule4backendPort}'
        properties: {
          description: 'allow web'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: string(elbRule4backendPort)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 350
          direction: 'Inbound'
        }
      }
    ]
  }
}]

resource vmArray_pubIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for i in range(0, vmCount): {
  name: '${vmarray[i].vmName}-pubIP'
  location: vmarray[i].location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}]

resource vmArray_NIC 'Microsoft.Network/networkInterfaces@2022-07-01' = [for i in range(0, vmCount): {
  name: '${vmarray[i].vmName}-NIC'
  location: vmarray[i].location
  properties: {
    enableIPForwarding: vmarray[i].enableIPForwarding
    enableAcceleratedNetworking: vmarray[i].acceleratedNetworking
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vmarray[i].privateIP
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${vmarray[i].vmName}-pubIP')
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vmarray[i].vNetName, vmarray[i].subnetName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', vmarray[i].nsgName)
    }
  }
  dependsOn: [
    vnet1
    vmArray_pubIP[i]
    vmArray_nsg[i]
  ]
}]

resource vmArray_vm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, vmCount): {
  name: vmarray[i].vmName
  location: vmarray[i].location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmarray[i].vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: vmarray[i].publisher
        offer: vmarray[i].offer
        sku: vmarray[i].sku
        version: vmarray[i].version
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${vmarray[i].vmName}-OS'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmarray[i].vmName}-NIC')
        }
      ]
    }
  }
  dependsOn: [
    vmArray_NIC[i]
  ]
}]

resource vmArray_customScript 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, vmCount): if (vmarray[i].scriptCommand != 'SKIP_CustomScript') {
  name: '${vmarray[i].vmName}/vmCustomScript'
  location: vmarray[i].location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        vmarray[i].scriptURL
      ]
      commandToExecute: vmarray[i].scriptCommand
    }
  }
  dependsOn: [
    vmArray_vm[i]
  ]
}]

resource bastionPublicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = if (deploymentBastion) {
  name: bastionPublicIPAddressName
  location: vnet2Config.location
  sku: {
    name: bastionSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = if (deploymentBastion) {
  name: bastionName
  location: vnet2Config.location
  sku: {
    name: 'Standard'
  }
  properties: {
    disableCopyPaste: false
    enableFileCopy: true
    enableIpConnect: true
    enableShareableLink: true
    enableTunneling: true
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIPAddress.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet2Config.name, bastionSubnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet2
  ]
}

output nginxScriptFileName string = nginxScriptFileName
output nginxScriptURL string = nginxScriptURL
output nginxCommand string = nginxCommand
output nvaScriptFileName string = nvaScriptFileName
output nvaScriptURL string = nvaScriptURL
output nvaCommand string = nvaCommand
