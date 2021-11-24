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

@description('Sku of the Disk Pool')
@allowed([
  'Basic_B1'
  'Standard_S1'
  'Premium_P1'
])
param diskPoolSku string = 'Standard_S1'

@description('Name of the Disk Pool')
@minLength(7)
@maxLength(30)
param diskPoolName string = 'diskpool-01'

@description('Availability zone to deploy the Disk Pool')
param diskPoolAvailabilityZone string

@description('Name of the managed disk (512 sector size) to create and export as an iSCSI LUN in the Disk Pool')
param existingManagedDiskName string = 'disk-1'

@description('Name of the iSCSI Target')
@minLength(5)
@maxLength(40)
param targetName string = 'iscsi-target-01'

@description('Name of the resourceGroup for the existing virtual network and disk to deploy the Disk Pool.')
param existingResourceGroupName string

@description('Name of the existing virtual network to deploy the Disk Pool into.')
param existingVnetName string

@description('Name of the existing subnet to deploy the Disk Pool into.')
param existingSubnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  scope: resourceGroup(existingResourceGroupName)
  name: existingVnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' existing = {
  name: existingSubnetName
  parent: vnet
}
var subnetId = subnet.id

resource disk 'Microsoft.Compute/disks@2021-04-01' existing =  {
  scope: resourceGroup(existingResourceGroupName)
  name: existingManagedDiskName
}
var diskId = disk.id

resource diskPool 'Microsoft.StoragePool/diskPools@2021-08-01' = {
  name: diskPoolName
  sku: {
    name: diskPoolSku
  }
  location: diskPoolLocation
  properties: {
    availabilityZones: [
      diskPoolAvailabilityZone
    ]
    subnetId: subnetId
    disks: [
      {
        id: diskId
      }
    ]
  }
}

resource target 'Microsoft.StoragePool/diskPools/iscsiTargets@2021-08-01' = {
  parent: diskPool
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
