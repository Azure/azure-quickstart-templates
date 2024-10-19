targetScope = 'subscription'
@description('Location for all resources.')
param location string = 'westus'
@description('Location of the recovery service Vault for disaster recovery')
param replicationLocation string = 'East US'

@description('Virtual network resource name.')
param virtualNetworkName string
@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace string = '10.100.0.0/16'
@description('Virtual network resource Subnet 1 name.')
param subnetName1 string
@description('Virtual network resource Subnet 2 name.')
param subnetName2 string
@description('Virtual network resource Subnet 1 Address Prefix.')
param subnetAddressPrefix1 string = '10.100.0.0/24'
@description('Virtual network resource Subnet 2 Address Prefix.')
param subnetAddressPrefix2 string = '10.100.1.0/24'
@secure()
@description('Virtual machine resource admin username')
param vmAdminUsername string
@secure()
@description('Virtual machine resource admin password')
param vmAdminPassword string
@description('Virtual machine size')
param vmSize string = 'Standard_D2s_v3'
@description('Storage account name')
param storageAccountName string = 'storage${uniqueString(subscription().id)}'
@description('Azure recovery service vault name')
param recoveryServiceVaultName string = 'rsv-${uniqueString(subscription().id)}'



@description('Set to true is disaster recovery vm replication should be enabled on the VM')
param disasterRecoveryEnabled bool = true
@description('Virtual machine resource object')
var virtualMachineObject = {
  name: 'azurevm'
  vmSize: vmSize
  osDisk: {
    createOption: 'FromImage'
    storageAccountType: 'Premium_LRS'
    deleteOption: 'Delete'
  }
  imageReference: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-datacenter-gensecond'
    version: 'latest'
  }
}


resource vmRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  location: location
  name: 'compute-resourcegroup'
}

resource rsvRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  location: replicationLocation
  name: 'rsv-resourcegroup'
}

resource replicationRG 'Microsoft.Resources/resourceGroups@2024-03-01' = if(disasterRecoveryEnabled) {
  location: replicationLocation
  name: '${vmRG.name}-asr'
}

module network1 'modules/virtualnetwork/main.bicep' = {
  scope: az.resourceGroup(vmRG.name)
  name: 'network1Component'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    subnetName1: subnetName1
    subnetAddressPrefix1: subnetAddressPrefix1
    subnetName2: subnetName2
    subnetAddressPrefix2: subnetAddressPrefix2
  }
}

module network2 'modules/virtualnetwork/main.bicep' = if(disasterRecoveryEnabled) {
  scope: az.resourceGroup(replicationRG.name)
  name: 'network2Component'
  params: {
    location: replicationLocation
    virtualNetworkName: '${virtualNetworkName}-asr'
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    subnetName1: subnetName1
    subnetAddressPrefix1: subnetAddressPrefix1
    subnetName2: subnetName2
    subnetAddressPrefix2: subnetAddressPrefix2
  }
}

module virtualMachine 'modules/virtualmachine/main.bicep' = {
  scope: az.resourceGroup(vmRG.name)
  name: 'virtualMachineComponent'
  params: {
    location: location
    subnetId: network1.outputs.computeSubnet
    virtualMachine: virtualMachineObject
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
  }
}

module storageAccount 'modules/storage/main.bicep' = {
  scope: az.resourceGroup(rsvRG.name)
  name: 'storageAccountComponent'
  params: {
    location: location
    storageAccountName: storageAccountName
    virtualNetworkId: network1.outputs.virtualNetworkId
    subnetId: network1.outputs.privateEndpointSubnet
  }
}

module disasterRecovery 'modules/recoveryservicevault/main.bicep' = {
  scope: az.resourceGroup(rsvRG.name)
  name: 'disasterRecoveryComponent'
  params: {
    location: location
    replicationLocation: replicationLocation
    recoveryServiceVaultName: recoveryServiceVaultName
    disasterRecoveryEnabled: disasterRecoveryEnabled
    virtualNetworkId: network1.outputs.virtualNetworkId
    recoveryNetworkId: disasterRecoveryEnabled ? network2.outputs.virtualNetworkId : 'none'
    recoverySubnetName: disasterRecoveryEnabled ? network2.outputs.computeSubnet : 'none'
    subnetId: network1.outputs.privateEndpointSubnet
    storageAccountId: storageAccount.outputs.storageAccountId
    recoveryResourceGroupId: replicationRG.id
    virtualMachineId: virtualMachine.outputs.virtualMachineId
    virtualMachineName: virtualMachine.outputs.virtualMachineName
    virtualMachineDiskId: virtualMachine.outputs.virtualMachineDiskId
    virtualMachineDiskSku: virtualMachine.outputs.virtualMachineDiskSku
  }
}
