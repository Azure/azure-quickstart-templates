@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('VM name prefix')
param vmNamePrefix string = 'vm-'

@description('Load Balancer name')
param lbName string = 'load-balancer'

@description('Network Interface Name Prefix')
param nicNamePrefix string = 'nic-'

@description('Public IP Address Name')
param publicIPAddressName string = 'public-ip'

@description('VNET name')
param vnetName string = 'vnet-1'

@description('Image Publisher')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('Image Offer')
param imageOffer string = 'WindowsServer'

@description('Image SKU')
param imageSKU string = '2019-Datacenter'

@description('VM Size')
param vmSize string = 'Standard_D2s_v3'

@description('Resource location')
param location string = resourceGroup().location

@description('NAT Gateway Name')
param natGatewayName string = 'nat-gateway'

@description('NAT Gateway Public IP Name')
param natGatewayPublicIPName string = 'public-ip-nat-gateway'

var availabilitySetName = 'availability-set'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'subnet-1'
var subnetPrefix = '10.0.0.0/24'
var numberOfInstances = 2
var networkSecurityGroupName = '${subnetName}-nsg'


resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-11-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource natPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: natGatewayPublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource natGateway 'Microsoft.Network/natGateways@2022-07-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: natPublicIP.id
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {}
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
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
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          natGateway: {
            id: natGateway.id
          }
        }
      }
    ]
  }
}

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2022-07-01' = [
  for i in range(0, numberOfInstances): {
    name: '${nicNamePrefix}${i}'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
            }
            loadBalancerBackendAddressPools: [
              {
                id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackend')
              }
            ]
            loadBalancerInboundNatRules: [
              {
                id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', lbName, 'RDP-VM${i}')
              }
            ]
          }
        }
      ]
    }
    dependsOn: [
      vnet
      lb
      lbName_RDP_VM[i]
    ]
  }
]

resource lb 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
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
  }
}

resource lbName_RDP_VM 'Microsoft.Network/loadBalancers/inboundNatRules@2022-07-01' = [
  for i in range(0, numberOfInstances): {
    parent: lb
    name: 'RDP-VM${i}'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
      }
      protocol: 'Tcp'
      frontendPort: (i + 5000)
      backendPort: 3389
      enableFloatingIP: false
    }
  }
]

resource virtualMachines 'Microsoft.Compute/virtualMachines@2022-11-01' = [
  for i in range(0, numberOfInstances): {
    name: '${vmNamePrefix}${i}'
    location: location
    properties: {
      availabilitySet: {
        id: availabilitySet.id
      }
      hardwareProfile: {
        vmSize: vmSize
      }
      osProfile: {
        computerName: '${vmNamePrefix}${i}'
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      storageProfile: {
        imageReference: {
          publisher: imagePublisher
          offer: imageOffer
          sku: imageSKU
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
        }
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: resourceId('Microsoft.Network/networkInterfaces', '${nicNamePrefix}${i}')
          }
        ]
      }
    }
    dependsOn: [
      networkInterfaces[i]
    ]
  }
]
