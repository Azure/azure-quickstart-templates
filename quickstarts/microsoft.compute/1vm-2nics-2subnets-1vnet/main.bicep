@description('Virtual machine size (has to be at least the size of Standard_A3 to support 2 NICs)')
param virtualMachineSize string = 'Standard_DS1_v2'

@description('Default Admin username')
param adminUsername string

@description('Default Admin password')
@secure()
param adminPassword string

@description('Storage Account type for the VM and VM diagnostic storage')
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

var virtualMachineName = 'VM-MultiNic'
var nic1Name = 'nic-1'
var nic2Name = 'nic-2'
var virtualNetworkName = 'virtualNetwork'
var subnet1Name = 'subnet-1'
var subnet2Name = 'subnet-2'
var publicIPAddressName = 'publicIp'
var diagStorageAccountName = 'diags${uniqueString(resourceGroup().id)}'
var networkSecurityGroupName = 'NSG'
var networkSecurityGroupName2 = '${subnet2Name}-nsg'

// This is the virtual machine that you're building.
resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
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
        storageUri: diagsAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource diagsAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: diagStorageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

// Simple Network Security Group for subnet2
resource nsg2 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName2
  location: location
}

// This will build a Virtual Network.
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
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
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg2.id
          }
        }
      }
    ]
  }
}

// This will be your Primary NIC
resource nic1 'Microsoft.Network/networkInterfaces@2020-06-01' = {
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
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// This will be your Secondary NIC
resource nic2 'Microsoft.Network/networkInterfaces@2020-06-01' = {
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

// Public IP for your Primary NIC
resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Network Security Group (NSG) for your Primary NIC
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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
