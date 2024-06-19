// Define the parameters for the deployment
@description('Name of the vm.')
param vmName string = 'windows-bastion'

@description('Name of the adminUsername')
param adminUsername string = 'azureuser'

@description('Name of the admin login password.')
@secure()
param adminPassword string

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

// Create the virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'CoreVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
      }
    ]
  }
}

// Get the subnet reference
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: 'default'
}

// Create a public IP address
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'windows-bastion-ip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Create a network interface
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: 'windows-bastion-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

// Create the virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
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
          id: nic.id
        }
      ]
    }
  }
}

// Outputs
output vnetName string = vnet.name
output subnetName string = subnet.name
output vnetResourceGroupName string = resourceGroup().name
