@description('Virtual machine size (has to be at least the size of Standard_A3 to support 2 NICs)')
param virtualMachineSize string = 'Standard_DS1_v2'

@description('Default Admin username')
param adminUsername string

@description('Default Admin password')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

var virtualMachineName = 'VM-MultiNic'
var nic1Name = 'nic-1'
var nic2Name = 'nic-2'
var virtualNetworkName = 'virtualNetwork'
var subnet1Name = 'subnet-1'
var subnet2Name = 'subnet-2'
var networkSecurityGroupName = '${nic1Name}-nsg'
var networkSecurityGroupName2 = '${subnet2Name}-nsg'
var natGatewayName = 'natGateway'
var natGatewayPublicIPName = 'natGatewayPublicIP'
var bastionHostName = 'bastionHost'
var bastionPublicIPName = 'bastionPublicIP'

// This is the virtual machine that you're building.
resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: virtualMachineName
  location: location
  properties: {
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: virtualMachineSize
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
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: nic1.id
        }
        {
          properties: {
            primary: false
          }
          id: nic2.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// Simple Network Security Group for subnet2
resource nsg2 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupName2
  location: location
}

// NAT gateway resource
resource natGateway'Microsoft.Network/natGateways@2022-07-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGatewayPublicIP.id
      }
    ]
  }
}

// Add a public IP address for the NAT Gateway
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

// Add an Azure Bastion resource
resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIPConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
        }
      }
    ]
  }
}

// This will build a Virtual Network.
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: '10.0.0.0/24'
          natGateway: {
            id: natGateway.id
          }
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg2.id
          }
          natGateway: {
            id: natGateway.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.2.0/26'
        }
      }
    ]
  }
}

// This will be your Primary NIC
resource nic1 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: nic1Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnet1Name)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// This will be your Secondary NIC
resource nic2 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: nic2Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnet2Name)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// Network Security Group (NSG) for your Primary NIC
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
