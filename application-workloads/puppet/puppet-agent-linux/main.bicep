@description('Size of vm, e.g: Standard_D2')
param vmSize string

@description('Username for the Virtual Machine, e.g: joetheadmin.')
param username string

@description('Unique DNS prefix for the Storage Account where the Virtual Machine\'s disks will be placed.')
param newStorageAccountName string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsNameForPublicIP string

@description('FQDN of your PE box, e.g: pupmstr.cloudapp.net')
param pupmstrFQDN string = 'pupmstr.cloudapp.net'

@description('IP of your PE box, e.g: 192.168.1.1')
param pupmstrIP string = '192.168.1.1'

@description('Internal FQDN of your PE box, e.g: pupmstr.pupmstr.d6.internal.cloudapp.net.  Get it from node requests page in PE Console.')
param pupmstrInternalFQDN string = 'pupmstr.pupmstr.d6.internal.cloudapp.net'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

var scenarioPrefix = 'puppetAgentLinux'
var imagePublisher = 'Canonical'
var imageOffer = 'UbuntuServer'
var ubuntuOSVersion = '18.04-LTS'
var nicName = '${scenarioPrefix}Nic'
var vnetAddressPrefix = '10.0.0.0/16'
var subnetName = '${scenarioPrefix}Subnet'
var subnetPrefix = '10.0.0.0/24'
var storageAccountType = 'Standard_LRS'
var publicIPAddressName = '${scenarioPrefix}PublicIp'
var publicIPAddressType = 'Dynamic'
var vmName = '${scenarioPrefix}VM'
var virtualNetworkName = '${scenarioPrefix}Vnet'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var fileUris = uri(_artifactsLocation, 'scripts/install_puppet_agent.sh${_artifactsLocationSasToken}')
var commandToExecute = 'sh install_puppet_agent.sh ${pupmstrIP} ${pupmstrFQDN} ${pupmstrInternalFQDN}'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${username}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource newStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: newStorageAccountName
  kind: 'StorageV2'
  location: location
  sku: {
    name: storageAccountType
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameForPublicIP
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
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

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
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
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [

    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: username
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: ubuntuOSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
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
  dependsOn: [
    newStorageAccount

  ]
}

resource installcustomscriptvm 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: vm
  name: 'installcustomscript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        fileUris
      ]
      commandToExecute: commandToExecute
    }
  }
}
