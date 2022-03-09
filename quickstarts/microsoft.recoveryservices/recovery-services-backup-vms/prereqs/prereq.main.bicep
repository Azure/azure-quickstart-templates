param numberOfInstances int
param recoveryServicesName string
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

param vmSize string = 'Standard_DS1'

resource RecoveryServicesVault 'Microsoft.RecoveryServices/vaults@2021-03-01' = {
  name: recoveryServicesName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, numberOfInstances): {
  name: '${virtualMachineName}${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${virtualMachineName}${i}'
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
          id: resourceId('Microsoft.Network/networkInterfaces', '${networkInterfaceName}${i}')
        }
      ]
    }
  }
  dependsOn: [
    networkInterface
  ]
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = [for i in range(0, numberOfInstances): {
  name: '${virtualNetworkName}${i}'
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

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, numberOfInstances): {
  name: '${networkInterfaceName}${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', '${virtualNetworkName}${i}', subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIpAddresses', '${publicIpAddressName}${i}')
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', '${networkSecurityGroupName}${i}')
    }
  }
  dependsOn: [
    virtualNetwork
    publicIpAddress
    networkSecurityGroup
  ]
}]

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = [for i in range(0, numberOfInstances): {
  sku: {
    name: publicIpAddressSku
  }
  name: '${publicIpAddressName}${i}'
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = [for i in range(0, numberOfInstances): {
  name: '${networkSecurityGroupName}${i}'
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
