param location string

param subnetId string
param virtualMachine object
@secure()
param adminUsername string
@secure()
param adminPassword string

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  location: location
  name: '${virtualMachine.name}-nic'
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vms 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  location: location
  name: virtualMachine.name
  properties: {
    hardwareProfile: {
      vmSize: virtualMachine.vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: virtualMachine.osDisk.createOption
        managedDisk: {
          storageAccountType: virtualMachine.osDisk.storageAccountType
        }
        deleteOption: virtualMachine.osDisk.deleteOption
      }
      imageReference: {
        publisher: virtualMachine.imageReference.publisher
        offer: virtualMachine.imageReference.offer
        sku: virtualMachine.imageReference.sku
        version: virtualMachine.imageReference.version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachine.name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output virtualMachineId string = vms.id
output virtualMachineName string = vms.name
output virtualMachineDiskId string = vms.properties.storageProfile.osDisk.managedDisk.id
output virtualMachineDiskSku string = vms.properties.storageProfile.osDisk.managedDisk.storageAccountType
