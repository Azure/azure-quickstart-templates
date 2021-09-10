param location string = 'eastus'
param networkInterfaceName string = 'kemp-vlm-nic01'
param networkSecurityGroupName string = 'kemp-vlm-nsg'
param subnetName string = 'default'
param virtualNetworkName string = 'kemp-vnet'
param publicIpAddressName string = 'kemp-vlm-pip'
param publicIpAddressType string = 'Static'
param publicIpAddressSku string = 'Standard'
param virtualMachineName string = 'kemp-vlm'
param virtualMachineComputerName string = 'kemp-vlm'
param osDiskType string = 'Standard_LRS'
param virtualMachineSize string = 'Standard_B2s'
param adminUsername string = 'bal'

@secure()
param adminPassword string 

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2018-10-01' = {
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
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroupName_resource
    virtualNetworkName_resource
    publicIpAddressName_resource
  ]
}

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
          name: 'Management'
          properties: {
              priority: 1010
              protocol: 'Tcp'
              access: 'Allow'
              direction: 'Inbound'
              sourceApplicationSecurityGroups: []
              destinationApplicationSecurityGroups: []
              sourceAddressPrefix: '*'
              sourcePortRange: '*'
              destinationAddressPrefix: '*'
              destinationPortRange: '8443'
          }
      }
      {
          name: 'SSH'
          properties: {
              priority: 1020
              protocol: 'Tcp'
              access: 'Allow'
              direction: 'Inbound'
              sourceApplicationSecurityGroups: []
              destinationApplicationSecurityGroups: []
              sourceAddressPrefix: '*'
              sourcePortRange: '*'
              destinationAddressPrefix: '*'
              destinationPortRange: '22'
          }
      }
  ]
  }
}

resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.5.0.0/16'
    ]
    }
    subnets:[
      {
      name: 'default'
      properties: {
          addressPrefix: '10.5.0.0/24'
         }
    }
  ]
  }
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'kemptech'
        offer: 'vlm-azure'
        sku: 'basic-byol'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  plan: {
    name: 'basic-byol'
    publisher: 'kemptech'
    product: 'vlm-azure'
  }
}

output adminUsername string = adminUsername
