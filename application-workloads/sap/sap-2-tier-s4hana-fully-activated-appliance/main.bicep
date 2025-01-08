// This Bicep file is used to deploy a virtual machine with S/4HANA Fully Activated Appliance. 
@description('User name for the Virtual Machine.')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('The resource group of the existing Virtual Network.')
param existingVirtualNetworkResourceGroupName string = resourceGroup().name

@description('The name of the existing Virtual Network.')
param existingVirtualNetworkName string

@description('The name of the existing subnet.')
param existingSubnetName string

@description('The VM size for the Virtual Machine.')
param vmSize string = 'Standard_E16-4ds_v5'

@description('The location where the Virtual Machine will be created.')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation. When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var imagePublisher = 'SUSE'
var imageOffer = 'sles-sap-15-sp3'
var imageSku = 'gen2'
var vmName = 'vhcals4hci'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var s4ScriptFileUri = uri(_artifactsLocation, 'scripts/s4install.sh${_artifactsLocationSasToken}')
var s4InifileUri = uri(_artifactsLocation, 'scripts/inifile.params${_artifactsLocationSasToken}')

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' existing = {
  name: '${existingVirtualNetworkName}/${existingSubnetName}'
  scope: resourceGroup(existingVirtualNetworkResourceGroupName)
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: {
    Database: 'HANA'
    Application: 'S4HANA Fully Activated Appliance'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OsDisk'
        osType: 'Linux'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          name: '${vmName}_hanaData'
          lun: 0
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 512
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
        {
          name: '${vmName}_hanaLog'
          lun: 1
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 128
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
        {
          name: '${vmName}_sapMedia'
          lun: 2
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 512
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
        {
          name: '${vmName}_sapMnt'
          lun: 3
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 64
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
      diskControllerType: 'SCSI'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: '${vmName}Nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource installscript 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: vm
  name: '${vmName}Installscript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/install.sh${_artifactsLocationSasToken}')
      ]
      commandToExecute: 'sh install.sh ${s4ScriptFileUri} ${s4InifileUri}'
    }
  }
}

