@description('Name for the virtual machine scale set')
param vmssName string = 'vmss-quickstart'

@description('User name for virtual machine instances')
param vmssAdminUserName string

@description('Password or SSH Key for the VM instances. Be sure to also update whether using Password or SSH Key authentication on the VMSS Flex')
@secure()
param vmssAdminPasswordOrSSHKey string

@description('Number of virtual machine instances in the scale set')
@minValue(0)
@maxValue(1000)
param instanceCount int = 3

@description('The platform fault domain count for your scale set. Set to 1 to allow Azure to maximally spread instances across many racks in the datacenter.')
@allowed([
  1
  2
  3
  4
  5
])
param platformFaultDomainCount int = 1

@description('Instances will be spread evenly between the zones you selected')
param zones array = [
]

@description('Specifies the virtual machine SKU to be used')
param sku string = 'Standard_B1s'

@description('Virtual network prefix')
param vnetPrefix string = vmssName

@description('Name for the load balancer')
param lbName string = '${vmssName}-LB'

@description('Choose the operating system for the VMs in the Virtual Machine Scale Set')
@allowed([
  'ubuntulinux'
  'windowsserver'
])
param os string = 'ubuntulinux'

@description('Region where the scale set will be deployed')
param location string = resourceGroup().location

var vnetName= '${vnetPrefix}${uniqueString(resourceGroup().name)}'

module basenetwork './modules/network/basenetwork.bicep' = {
  name: 'basenetwork'
  params: {
    virtualNetworkName: vnetName
    location:location
  }
}

module slb './modules/network/slb.bicep' = {
  name: 'slb'
  params: {
    slbName: lbName
    location:location
  }
}

module vmss './modules/compute/vmssflex.bicep' = {
  name: 'vmss-bicep'
  params: {
    location:location
    vmssname: vmssName
    vmCount: instanceCount
    vmSize: sku
    adminUsername: vmssAdminUserName
    adminPasswordOrKey: vmssAdminPasswordOrSSHKey
    os: os
    platformFaultDomainCount: platformFaultDomainCount
    zones: zones
    subnetId: basenetwork.outputs.vnetSubnetArray[0].id
    lbBackendPoolArray: [
      slb.outputs.slbBackendPoolArray[0]
    ]
  }
}
