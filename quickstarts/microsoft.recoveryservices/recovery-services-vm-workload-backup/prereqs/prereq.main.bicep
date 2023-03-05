param virtualMachineName string
param virtualMachineSize string
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
param sqlConnectivityType string
param sqlPortNumber int
param sqlStorageDisksCount int
param sqlStorageWorkloadType string
param sqlStorageDisksConfigurationType string
param sqlStorageStartingDeviceId int
param sqlAutopatchingDayOfWeek string
param sqlAutopatchingStartHour string
param sqlAutopatchingWindowDuration string
param sqlAuthenticationLogin string

@secure()
param sqlAuthenticationPassword string
param rServicesEnabled string

var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
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
        publisher: 'MicrosoftSQLServer'
        offer: 'SQL2016SP1-WS2016'
        sku: 'Enterprise'
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
          id: networkInterface.id
        }
      ]
    }
  }
}

resource sqlVirtualMachine 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2017-03-01-preview' = {
  name: virtualMachineName
  location: location
  properties: {
    virtualMachineResourceId: virtualMachine.id
    autoPatchingSettings: {
      enable: true
      dayOfWeek: sqlAutopatchingDayOfWeek
      maintenanceWindowStartingHour: sqlAutopatchingStartHour
      maintenanceWindowDuration: sqlAutopatchingWindowDuration
    }
    keyVaultCredentialSettings: {
      enable: false
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: sqlConnectivityType
        port: sqlPortNumber
        sqlAuthUpdateUserName: sqlAuthenticationLogin
        sqlAuthUpdatePassword: sqlAuthenticationPassword
      }
      sqlWorkloadTypeUpdateSettings: {
        sqlWorkloadType: sqlStorageWorkloadType
      }
      sqlStorageUpdateSettings: {
        diskCount: sqlStorageDisksCount
        diskConfigurationType: sqlStorageDisksConfigurationType
        startingDeviceId: sqlStorageStartingDeviceId
      }
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: rServicesEnabled
      }
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
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
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  sku: {
    name: publicIpAddressSku
  }
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroupName
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
}

output adminUsername string = adminUsername
output virtualMachineName string = virtualMachineName
output resourceGroupName string = resourceGroup().name
