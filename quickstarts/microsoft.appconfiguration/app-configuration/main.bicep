@description('Specify the locations for all resources.')
param location string = resourceGroup().location

@description('Specify the virtual machine admin user name.')
param adminUsername string

@description('Specify the virtual machine admin password.')
@secure()
param adminPassword string

@description('Specify the DNS label for the virtual machine public IP address. It must be lowercase. It should match the following regular expression, or it will raise an error: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.')
param domainNameLabel string

@description('Specify the size of the VM.')
param vmSize string = 'Standard_D2_v3'

@description('Specify the storage account name.')
param storageAccountName string

@description('App configuration store name.')
param appConfigStoreName string

@description('Specify the name of the key in the app config store for the VM windows sku.')
param vmSkuKey string

@description('Specify the name of the key in the app config store for the VM disk size')
param diskSizeKey string

var nicName = 'myVMNic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var publicIPAddressName = 'myPublicIP'
var vmName = 'SimpleWinVM'
var virtualNetworkName = 'MyVNET'
var windowsOSVersionParameters = {
  key: vmSkuKey
  label: 'template'
}
var diskSizeGBParameters = {
  key: diskSizeKey
  label: 'template'
}

resource appConfigStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing = {
  name: appConfigStoreName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {}
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
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
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
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
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
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
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: listKeyValue(appConfigStore.id, '2019-10-01', windowsOSVersionParameters).value
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: listKeyValue(appConfigStore.id, '2019-10-01', diskSizeGBParameters).value
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

output hostname string = publicIPAddress.properties.dnsSettings.fqdn
