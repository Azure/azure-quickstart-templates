@description('Username for the Virtual Machine.')
@minLength(1)
param adminUsername string

@description('Password for the Virtual Machine.')
@secure()
param adminPassword string

@description('Size of the virtual machine')
param vmSize string = 'Standard_A4_v2'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('An array of fileUris to download via the custom script extension')
param fileUris array

@description('name for the managedIdenity to use for custom script download, the principal must have at least storage blob reader permission on the storage account, roleDef: 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
param identityName string

@description('resourceGroup for the managedIdenity to use for custom script download')
param identityResourceGroup string

@description('For the sample, use this to ensure the extension will always execute.')
param alwaysRun string = newGuid()

var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var windowsOSVersion = '2019-Datacenter'
var nicName = 'myVMNic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var publicIPAddressName = 'myPublicIP'
var publicIPAddressType = 'Dynamic'
var vmName = 'MyWindowsVM'
var virtualNetworkName = 'MyVNET'

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroup)
  name: identityName
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
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
        name:subnetName
        properties:{
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource cse 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  parent: vm
  name: 'cse'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    forceUpdateTag: alwaysRun
    settings: {
      fileUris: fileUris
      commandToExecute: 'powershell -Command "ls"'
    }
    protectedSettings: {
      managedIdentity: {
        object: msi.properties.principalId
      }
    }
  }
}

output msiObjectId string = msi.properties.principalId
output instanceView object = cse.properties.instanceView
