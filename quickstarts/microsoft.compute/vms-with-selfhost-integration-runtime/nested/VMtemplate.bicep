param virtualMachineName string
param vmSize string
param adminUserName string

@secure()
param adminPassword string
param existingVnetLocation string
param subnetId string
param nsgId string

var nicName = '${virtualMachineName}Nic'
var publicIPAddressName = '${virtualMachineName}-ip'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIPAddressName
  location: existingVnetLocation
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: existingVnetLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: virtualMachineName
  location: existingVnetLocation
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${virtualMachineName}_OSDisk'
        caching: 'ReadWrite'
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
