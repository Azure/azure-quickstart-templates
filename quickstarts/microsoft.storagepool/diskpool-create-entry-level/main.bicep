@description('Tier of the Disk Pool')
@allowed([
  'Standard'
])
param diskPoolTier string = 'Standard'

@description('Location of the Disk Pool')
@allowed([
  'AustraliaEast'
  'CanadaCentral'
  'CentralUS'
  'EastUS'
  'JapanEast'
  'NorthEurope'
  'SouthCentralUS'
  'SoutheastAsia'
  'UKSouth'
  'WestEurope'
  'WestUS2'
])
param diskPoolLocation string

@description('Name of the managed disk (512 sector size) to create and export as an iSCSI LUN in the Disk Pool')
param managedDiskName string = 'disk-10'

@description('Availability zone to deploy the managed disk and Disk Pool')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZone string = '1'

@description('Name of the Disk Pool')
param diskPoolName string = 'diskpool-09'

@description('Name of the iSCSI Target')
param targetName string = 'iscsi-target-01'

@description('Name of the resourceGroup for the existing virtual network to deploy the Disk Pool into.')
param existingVnetResourceGroupName string

@description('Name of the existing virtual network to deploy the Disk Pool into.')
param existingVnetName string

@description('Name of the existing subnet to deploy the Disk Pool into.')
param existingSubnetName string

var diskId = '${resourceGroup().id}/providers/Microsoft.Compute/disks/${managedDiskName}'

resource managedDiskNamePrefix 'Microsoft.Compute/disks@2020-09-30' = {
  name: managedDiskName
  location: diskPoolLocation
  sku: {
    name: 'Premium_LRS'
  }
  zones: [
    availabilityZone
  ]
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 1023
  }
}

resource diskPoolNamePrefix 'Microsoft.StoragePool/diskPools@2021-04-01-preview' = {
  name: diskPoolName
  sku: {
    name: diskPoolTier
    tier: diskPoolTier
  }
  location: diskPoolLocation
  properties: {
    availabilityZones: reference(diskId, '2017-03-30', 'Full').zones
    subnetId: resourceId(existingVnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', existingVnetName, existingSubnetName)
    disks: [
      {
        id: diskId
      }
    ]
  }
  dependsOn: [
    managedDiskNamePrefix
  ]
}

resource targetNamePrefix 'Microsoft.StoragePool/diskPools/iscsiTargets@2021-04-01-preview' = {
  parent: diskPoolNamePrefix
  name: targetName
  properties: {
    targetIqn: 'iqn.2021-04.org.microsoft.com:target'
    aclMode: 'Dynamic'
    luns: [
      {
        managedDiskAzureResourceId: diskId
        name: 'lun0'
      }
    ]
  }
}
