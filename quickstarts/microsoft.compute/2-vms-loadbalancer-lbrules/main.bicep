@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('DNS for Load Balancer IP')
param dnsNameforLBIP string

@description('Prefix to use for VM names')
param vmNamePrefix string = 'vm-'

@description('Image Publisher')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('Image Offer')
param imageOffer string = 'WindowsServer'

@description('Image SKU')
param imageSKU string = '2019-Datacenter'

@description('Load Balancer name')
param lbName string = 'load-balancer'

@description('Network Interface name prefix')
param nicNamePrefix string = 'nic-'

@description('Public IP Name')
param publicIPAddressName string = 'public-ip-lb'

@description('Virtual network name')
param vnetName string = 'vnet-1'

@description('Size of the VM')
param vmSize string = 'Standard_D2s_v3'

@description('Location for all resources')
param location string = resourceGroup().location

@description('NAT Gateway name')
param natGatewayName string = 'nat-gateway'

@description('NAT Gateway Public IP name')
param natGatewayPublicIPName string = 'public-ip-nat-gateway'

@description('Azure Bastion name')
param bastionName string = 'bastion'

@description('Azure Bastion Public IP name')
param bastionPublicIPName string = 'public-ip-bastion'

var availabilitySetName = 'availability-set'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'subnet-1'
var subnetPrefix = '10.0.0.0/24'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
var publicIPAddressID = publicIPAddress.id
var numberOfInstances = 2

resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-11-01' = {
  name: availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
  sku: {
    name: 'Aligned'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsNameforLBIP
    }
  }
}

// Add a NAT Gateway Public IP resource
resource natGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
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

// Add a NAT Gateway resource
resource natGateway 'Microsoft.Network/natGateways@2022-07-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: natGatewayPublicIP.id
      }
    ]
    idleTimeoutInMinutes: 4
  }
}

// Add a public IP address for Azure Bastion
resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: bastionPublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
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
          natGateway: {
            id: natGateway.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
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
              id: subnetRef
            }
            loadBalancerBackendAddressPools: [
              {
                id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'BackendPool1')
              }
            ]
          }
        }
      ]
    }
    dependsOn: [
      vnet
      lb
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
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIPAddressID
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'BackendPool1')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
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
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

// Add an Azure Bastion resource
resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIPConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

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
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
    dependsOn: [
      networkInterfaces[i]
    ]
  }
]
