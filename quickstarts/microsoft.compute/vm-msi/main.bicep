@description('Username for the Virtual Machine.')
param adminUsername string

@description('Authentication type')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'sshPublicKey'

@description('OS Admin password or SSH Key depending on value of authentication type')
@secure()
param adminPasswordOrKey string

@description('The Location For the resources')
param location string = resourceGroup().location

@description('The size of the VM to create')
param vmSize string = 'Standard_D2s_v3'

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Operating system to use for the virtual machine')
@allowed([
  'UbuntuServer_23_04-gen2'
  'UbuntuServer_23_04-daily-gen2'
  'WindowsServer_2022-datacenter-azure-edition'
  'WindowsServer_2022-datacenter-smalldisk-g2'
])
param operatingSystem string = 'UbuntuServer_23_04-daily-gen2'

var azureCLI2DockerImage = 'mcr.microsoft.com/azure-cli'
var storageAccountName = 'vm${uniqueString(resourceGroup().id)}'
var networkSecurityGroupName = 'nsg'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var vmName = 'vm${uniqueString(resourceGroup().id)}'
var virtualNetworkName = 'vnet'
var containerName = 'msi'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {}
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-remote-access'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: (contains(toLower(operatingSystem), 'windows') ? '3389' : '22')
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

module creatingVM './nestedtemplates/createVM.bicep' = {
  name: 'creatingVM'
  params: {
    securityType: securityType
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    adminPasswordOrKey: adminPasswordOrKey
    adminUsername: adminUsername
    authenticationType: authenticationType
    azureCLI2DockerImage: azureCLI2DockerImage
    containerName: containerName
    operatingSystem: operatingSystem
    location: location
    nsgId: networkSecurityGroup.id
    provisionExtensions: false
    storageAccountId: storageAccount.id
    storageAccountName: storageAccountName
    subnetRef: subnet.id
    vmSize: vmSize
    vmName: vmName
  }
}

module creatingRBAC './nestedtemplates/setuprbac.bicep' = {
  name: 'creatingRBAC'
  params: {
    principalId: creatingVM.outputs.principalId
    storageAccountName: storageAccountName
  }
}

module updatingVM './nestedtemplates/createVM.bicep' = {
  name: 'updatingVM'
  params: {
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    adminPasswordOrKey: adminPasswordOrKey
    adminUsername: adminUsername
    authenticationType: authenticationType
    azureCLI2DockerImage: azureCLI2DockerImage
    containerName: containerName
    operatingSystem: operatingSystem
    location: location
    nsgId: networkSecurityGroup.id
    provisionExtensions: true
    storageAccountId: storageAccount.id
    storageAccountName: storageAccountName
    subnetRef: subnet.id
    vmSize: vmSize
    vmName: vmName
  }
  dependsOn: [
    creatingRBAC
  ]
}
