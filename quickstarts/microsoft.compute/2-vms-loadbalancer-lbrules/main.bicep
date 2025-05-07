@description('Name of storage account')
param storageAccountName string

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('DNS for Load Balancer IP')
param dnsNameforLBIP string

@description('Prefix to use for VM names')
param vmNamePrefix string = 'myVM'

@description('Image Publisher')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('Image Offer')
param imageOffer string = 'WindowsServer'

@description('Image SKU')
param imageSKU string = '2019-Datacenter'

@description('Load Balancer name')
param lbName string = 'myLB'

@description('Network Interface name prefix')
param nicNamePrefix string = 'nic'

@description('Public IP Name')
param publicIPAddressName string = 'myPublicIP'

@description('VNET name')
param vnetName string = 'myVNET'

@description('Size of the VM')
param vmSize string = 'Standard_D2s_v3'

@description('Location for all resources')
param location string = resourceGroup().location

@description('NAT Gateway name')
param natGatewayName string = 'myNatGateway'

@description('NAT Gateway Public IP name')
param natGatewayPublicIPName string = 'myNatGatewayPublicIP'

@description('Azure Bastion name')
param bastionName string = 'myBastion'

@description('Azure Bastion Public IP name')
param bastionPublicIPName string = 'myBastionPublicIP'

var storageAccountType = 'Standard_LRS'
var availabilitySetName = 'myAvSet'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet-1'
var subnetPrefix = '10.0.0.0/24'
var publicIPAddressType = 'Dynamic'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
var publicIPAddressID = publicIPAddress.id
var numberOfInstances = 2

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-03-01' = {
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

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameforLBIP
    }
  }
}

// Add a NAT Gateway Public IP resource
resource natGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
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
resource natGateway 'Microsoft.Network/natGateways@2023-02-01' = {
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
resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
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

// Add an Azure Bastion resource
resource bastionHost 'Microsoft.Network/bastionHosts@2023-02-01' = {
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
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
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

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2023-02-01' = [
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
    ]
  }
]

resource lb 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lbName
  location: location
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
    inboundNatRules: [
      {
        name: 'RDP-VM0'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPort: 50001
          backendPort: 3389
          enableFloatingIP: false
        }
      }
      {
        name: 'RDP-VM1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPort: 50002
          backendPort: 3389
          enableFloatingIP: false
        }
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

resource virtualMachines 'Microsoft.Compute/virtualMachines@2022-08-01' = [
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
          storageUri: reference(storageAccountName, '2019-06-01').primaryEndpoints.blob
        }
      }
    }
    dependsOn: [
      storageAccount
      networkInterfaces[i]
    ]
  }
]
