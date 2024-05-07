param numberOfInstances int
param virtualMachineName string
param adminUsername string
param virtualNetworkName string
param networkInterfaceName string
param networkSecurityGroupName string
param location string = resourceGroup().location

@secure()
param adminPassword string
param addressPrefix string
param subnetName string
param subnetPrefix string
param publicIpAddressName string
param publicIpAddressType string
param publicIpAddressSku string
param virtualMachineSize string = 'Standard_B1s'

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, numberOfInstances): {
  name: '${virtualMachineName}${range(0, numberOfInstances)[i]}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    osProfile: {
      computerName: '${virtualMachineName}${range(0, numberOfInstances)[i]}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          createOption: 'Empty'
          lun: 0
          diskSizeGB: 1023
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
        }
      ]
    }
  }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = [for i in range(0, length(range(0, numberOfInstances))): {
  name: '${virtualNetworkName}${range(0, numberOfInstances)[i]}'
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
    ]
  }
}]

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, length(range(0, numberOfInstances))): {
  name: '${networkInterfaceName}${range(0, numberOfInstances)[i]}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: virtualNetwork[i].properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress[i].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup[i].id
    }
  }
}]

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = [for i in range(0, length(range(0, numberOfInstances))): {
  name: '${publicIpAddressName}${range(0, numberOfInstances)[i]}'
  sku: {
    name: publicIpAddressSku
  }
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = [for i in range(0, length(range(0, numberOfInstances))): {
  name: '${networkSecurityGroupName}${range(0, numberOfInstances)[i]}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          priority: 300
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
      {
        name: 'default-allow-sql'
        properties: {
          priority: 1500
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '1433'
        }
      }
    ]
  }
}]

output adminUsername string = adminUsername
output resourceGroupName string = resourceGroup().name
