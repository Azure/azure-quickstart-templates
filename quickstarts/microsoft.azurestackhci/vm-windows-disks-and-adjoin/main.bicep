@maxLength(15)
param name string
param location string
param vCPUCount int = 2
param memoryMB int = 8192
param adminUsername string
@description('The name of a Marketplace Gallery Image already downloaded to the Azure Stack HCI cluster. For example: winServer2022-01')
param imageName string
@description('The name of an existing Logical Network in your HCI cluster - for example: lnet-compute-vlan240-dhcp')
param hciLogicalNetworkName string
@description('The name of the custom location to use for the deployment. This name is specified during the deployment of the Azure Stack HCI cluster and can be found on the Azure Stack HCI cluster resource Overview in the Azure portal.')
param customLocationName string
@secure()
param adminPassword string

// below parameters are used to join the VM to a domain
@description('Optional Domain name to join - specify to join the VM to domain. example: contoso.com - If left empty, ou, username and password parameters will not be evaluated in the deployment.')
param domainToJoin string = ''
@description('Optional domain organizational unit to join. example: ou=computers,dc=contoso,dc=com - Required if \'domainToJoin\' is secified.')
param domainTargetOu string = ''
@description('Optional User Name with permissions to join the domain. example: domain-joiner - Required if \'domainToJoin\' is secified.')
param domainJoinUserName string = ''
@description('Optional Password of User with permissions to join the domain. - Required if \'domainToJoin\' is secified.')
@secure()
param domainJoinPassword string = ''

//define a custom type for the dataDiskParams parameter and array of disks
type dataDiskType = {
  diskSizeGB: int
  dynamic: bool?
  //containerId: string
}
type dataDiskArrayType = dataDiskType[]

@description('The bicep array description of the dataDisks to attached to the vm. Provide an empty array for no addtional disks, or an array following the example below.')
// param dataDiskParams array = [{'diskSizeGB': 1024,'dynamic': true},{'diskSizeGB': 2048,'dynamic': false}]
param dataDiskParams dataDiskArrayType = []

var nicName = 'nic-${name}' // name of the NIC to be created
var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName) // full custom location ID
var marketplaceGalleryImageId = resourceId('microsoft.azurestackhci/marketplaceGalleryImages', imageName) // full marketplace gallery image ID
var logicalNetworkId = resourceId('microsoft.azurestackhci/logicalnetworks', hciLogicalNetworkName) // full logical network ID

// precreate an Arc Connected Machine with an identity--used for zero-touch onboarding of the Arc VM during deployment
resource hybridComputeMachine 'Microsoft.HybridCompute/machines@2023-10-03-preview' = {
  name: name
  location: location
  kind: 'HCI'
  identity: {
    type: 'SystemAssigned'
  }
}

resource nic 'Microsoft.AzureStackHCI/networkInterfaces@2024-01-01' = {
  name: nicName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          // uncomment to specify an IP, otherwise an IP address is dynamically allocated from the Logical Network's address pool or DHCP
          // privateIPAddress: 'x.x.x.x'
          subnet: {
            id: logicalNetworkId
          }
        }
      }
    ]
  }
}

resource dataDisks 'Microsoft.AzureStackHCI/virtualHardDisks@2024-01-01' = [for (disk, i) in dataDiskParams: {
  name: '${name}dataDisk${padLeft(i + 1, 2, '0')}'
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    diskSizeGB: disk.diskSizeGB
    dynamic: disk.?dynamic // dynamic is optional
    // containerId: uncomment if you want to target a specific CSV/storage path in your HCI cluster
  }
}]

resource virtualMachine 'Microsoft.AzureStackHCI/virtualMachineInstances@2024-01-01' = {
  name: 'default' // value must be 'default' per 2023-09-01-preview
  properties: {
    hardwareProfile: {
      vmSize: 'Custom'
      processors: vCPUCount
      memoryMB: memoryMB
      // ### uncomment to use dymamic memory ###
      // dynamicMemoryConfig: {
      //   maximumMemoryMB: memoryMB
      //   minimumMemoryMB: 512
      //   targetMemoryBuffer: 20
      // }
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: name
      windowsConfiguration: {
        provisionVMAgent: true // mocguestagent
        provisionVMConfigAgent: true // azure arc connected machine agent
      }
    }
    storageProfile: {
      // vmConfigStoragePathId: specify a storage path ID to target a specific CSV/storage path in your HCI cluster
      imageReference: {
        id: marketplaceGalleryImageId
      }
      dataDisks: [for (disk, i) in dataDiskParams: {
        id: resourceId('Microsoft.AzureStackHCI/virtualHardDisks', '${name}dataDisk${padLeft(i + 1, 2, '0')}')

      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  scope: hybridComputeMachine

}

resource domainJoin 'Microsoft.HybridCompute/machines/extensions@2023-10-03-preview' = if (!empty(domainToJoin)) {
  parent: hybridComputeMachine
  location: location
  name: 'domainJoinExtension'
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      OUPath: domainTargetOu
      User: '${domainToJoin}\\${domainJoinUserName}'
      Restart: true
      Options: 3
    }
    protectedSettings: {
      Password: domainJoinPassword
    }
  }
}
