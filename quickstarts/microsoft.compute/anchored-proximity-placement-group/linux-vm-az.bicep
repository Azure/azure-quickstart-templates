param location string = resourceGroup().location
param adminSshKey string
param proximityPlacementGroupId string
param subnetId string
param vmName string

@allowed([
  1
  2
  3
])
param zone int

resource pip 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: '${vmName}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  zones: [
    '${zone}'
  ]
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4ms'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'vmadmin'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/vmadmin/.ssh/authorized_keys'
              keyData: adminSshKey
            }
          ]
        }
      }
    }
    proximityPlacementGroup: {
      id: proximityPlacementGroupId
    }
    storageProfile: {
      imageReference: {
        publisher: 'OpenLogic'
        offer: 'CentOS'
        sku: '7.7'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-os'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
  }
  zones: [
    '${zone}'
  ]
}
