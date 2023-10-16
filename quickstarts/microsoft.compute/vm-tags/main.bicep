@description('Username for the Virtual Machine.')
@minLength(1)
@maxLength(20)
param adminUsername string

@description('Password for the Virtual Machine.')
@secure()
param adminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = 'vm-${uniqueString(resourceGroup().id)}'

@description('The Windows version for the VM.')
@allowed([
  '2016-Datacenter'
  '2016-Datacenter-Server-Core'
  '2016-Datacenter-Server-Core-smalldisk'
  '2016-Datacenter-smalldisk'
  '2016-Datacenter-with-Containers'
  '2016-Datacenter-with-RDSH'
  '2016-Datacenter-zhcn'
  '2019-Datacenter'
  '2019-Datacenter-Core'
  '2019-Datacenter-Core-smalldisk'
  '2019-Datacenter-Core-with-Containers'
  '2019-Datacenter-Core-with-Containers-smalldisk'
  '2019-datacenter-gensecond'
  '2019-Datacenter-smalldisk'
  '2019-Datacenter-with-Containers'
  '2019-Datacenter-with-Containers-smalldisk'
  '2019-Datacenter-zhcn'
  'Datacenter-Core-1803-with-Containers-smalldisk'
  'Datacenter-Core-1809-with-Containers-smalldisk'
  'Datacenter-Core-1903-with-Containers-smalldisk'
])
param windowSOSVersion string = '2019-Datacenter'

@description('Department Tag.')
param departmentName string = 'MyDepartment'

@description('Application Tag.')
param applicationName string = 'MyApp'

@description('CreatedBy Tag')
param createdBy string = 'MyName'

@description('Size for the Virtual Machine')
param vmSize string = 'Standard_D2_v3'

@description('Location for all resources')
param location string = resourceGroup().location

var storageAccountName = concat(uniqueString(resourceGroup().id, 'diagsa'))
var storageAccountType = 'Standard_LRS'
var publicIPAddressName = 'MyPublicIP'
var publicIPAddressType = 'Dynamic'
var networkSecurityGroupName = 'default-NSG'
var virtualNetworkName = 'MyVNET'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var vmName = 'MyVM'
var nicName = '${vmName}Nic'
var diskName = '${vmName}Disk'
var resourceTags = {
  Department: departmentName
  Application: applicationName
  CreatedBy: createdBy
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
  tags: resourceTags
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIPAddressName
  location: location
  tags: resourceTags
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: networkSecurityGroupName
  location: location
  tags: resourceTags
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: virtualNetworkName
  location: location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetPrefix
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: nicName
  location: location
  tags: resourceTags
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
            id: subnet.id
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  tags: resourceTags
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
        sku: windowSOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: diskName
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
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
