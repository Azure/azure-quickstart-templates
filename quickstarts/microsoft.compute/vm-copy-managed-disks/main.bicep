@description('Administrator Username for the local admin account')
param virtualMachineAdminUserName string

@description('Administrator password for the local admin account')
@secure()
param virtualMachineAdminPassword string

@description('Name of the virtual machine to be created')
@maxLength(15)
param virtualMachineNamePrefix string = 'MyVM0'

@description('Number of  virtual machines to be created')
param virtualMachineCount int = 3

@description('Virtual Machine Size')
param virtualMachineSize string = 'Standard_DS2_v2'

@description('Operating System of the Server')
@allowed([
  'Server2012R2'
  'Server2016'
  'Server2019'
])
param operatingSystem string = 'Server2019'

@description('Availability Set Name where the VM will be placed')
param availabilitySetName string = 'MyAvailabilitySet'

@description('Globally unique DNS prefix for the Public IPs used to access the Virtual Machines')
@minLength(2)
@maxLength(14)
param dnsPrefixForPublicIP string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

var myVNETName = 'myVNET'
var myVNETPrefix = '10.0.0.0/16'
var myVNETSubnet1Name = 'Subnet1'
var myVNETSubnet1Prefix = '10.0.0.0/24'
var diagnosticStorageAccountName = 'diagst${uniqueString(resourceGroup().id)}'
var operatingSystemValues = {
  Server2012R2: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2012-R2-Datacenter'
  }
  Server2016: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2016-Datacenter'
  }
  Server2019: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2019-Datacenter'
  }
}
var availabilitySetPlatformFaultDomainCount = 2
var availabilitySetPlatformUpdateDomainCount = 5
var networkSecurityGroupName = 'default-NSG'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName
  location: location
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: myVNETName
  location: location
  tags: {
    displayName: myVNETName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        myVNETPrefix
      ]
    }
    subnets: [
      {
        name: myVNETSubnet1Name
        properties: {
          addressPrefix: myVNETSubnet1Prefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: diagnosticStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  tags: {
    displayName: 'diagnosticStorageAccount'
  }
  kind: 'StorageV2'
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-06-01' = {
  name: availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: availabilitySetPlatformFaultDomainCount
    platformUpdateDomainCount: availabilitySetPlatformUpdateDomainCount
  }
  sku: {
    name: 'Aligned'
  }
}

resource virtualMachines 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, virtualMachineCount): {
  name: '${virtualMachineNamePrefix}${i + 1}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      imageReference: {
        publisher: operatingSystemValues[operatingSystem].PublisherValue
        offer: operatingSystemValues[operatingSystem].OfferValue
        sku: operatingSystemValues[operatingSystem].SkuValue
        version: 'latest'
      }
      osDisk: {
        name: '${virtualMachineNamePrefix}${i + 1}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: '${virtualMachineNamePrefix}${i + 1}'
      adminUsername: virtualMachineAdminUserName
      windowsConfiguration: {
        provisionVMAgent: true
      }
      adminPassword: virtualMachineAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
        }
      ]
    }
    availabilitySet: {
      id: availabilitySet.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}]

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, virtualMachineCount): {
  name: '${virtualMachineNamePrefix}${i + 1}-NIC1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses[i].id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, myVNETSubnet1Name)
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}]

resource publicIPAddresses 'Microsoft.Network/publicIPAddresses@2020-05-01' = [for i in range(0, virtualMachineCount): {
  name: '${virtualMachineNamePrefix}${i + 1}-PIP1'
  location: location
  tags: {
    displayName: '${virtualMachineNamePrefix}${i + 1}-PIP1'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: '${dnsPrefixForPublicIP}${i + 1}'
    }
  }
}]
