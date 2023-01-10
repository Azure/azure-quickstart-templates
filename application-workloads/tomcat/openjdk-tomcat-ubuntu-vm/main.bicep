@description('java Package Name')
@allowed([
  'openjdk-11-jdk'
  'openjdk-12-jdk'
  'openjdk-13-jdk'
])
param javaPackageName string = 'openjdk-13-jdk'

@description('tomcat Package Name')
@allowed([
  'tomcat7'
  'tomcat8'
  'tomcat9'
])
param tomcatPackageName string = 'tomcat9'

@description('User name for the Virtual Machine.')
param adminUsername string

@description('The size of the virtual machines used when provisioning')
param vmSize string = 'Standard_D2s_v3'

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  '18.04-LTS'
  '16.04-LTS'
  '14.04.5-LTS'
])
param ubuntuOSVersion string = '18.04-LTS'

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

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var imagePublisher = 'Canonical'
var imageOffer = 'UbuntuServer'
var nicName = 'myVMNic'
var nsgName = 'myNSG'
var vmName = 'Tomcat'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var publicIPAddressName = 'myPublicIP'
var virtualNetworkName = 'MyVNET'
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
var networkSecurityGroupName = 'default-NSG'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vnNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-22'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vn 'Microsoft.Network/virtualNetworks@2022-07-01' = {
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
          networkSecurityGroup: {
            id: vnNsg.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
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
    networkSecurityGroup: {
      id: nicNsg.id
    }
  }
  dependsOn: [

    vn

  ]
}

resource nicNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          description: 'Allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Web'
        properties: {
          description: 'Allow Web'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 112
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: ubuntuOSVersion
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
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

resource installscript 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vm
  name: 'installscript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'java-tomcat-install.sh${_artifactsLocationSasToken}')
      ]
      commandToExecute: 'sh java-tomcat-install.sh ${javaPackageName} ${tomcatPackageName}'
    }
  }
}
