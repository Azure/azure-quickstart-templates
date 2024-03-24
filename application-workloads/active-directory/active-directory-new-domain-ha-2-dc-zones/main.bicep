@description('The name of the Administrator of the new VM and Domain')
param adminUsername string

@description('Location for the VM, the location selected must support availability zones. See: https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support')
param location string

@description('The password for the Administrator account of the new VM and Domain')
@secure()
param adminPassword string

@description('The FQDN of the AD Domain created ')
param domainName string = 'contoso.local'

@description('The DNS prefix for the public IP address used by the Load Balancer')
param dnsPrefix string

@description('Size of the VM for the controller')
param vmSize string = 'Standard_D2s_v3'

@description('The location of resources such as templates and DSC modules that the script is dependent')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('Auto-generated token to access _artifactsLocation')
@secure()
param _artifactsLocationSasToken string = ''

var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSKU = '2019-Datacenter'
var virtualNetworkName = 'adVNET'
var virtualNetworkAddressRange = '10.0.0.0/16'
var adSubnetName = 'adSubnet'
var adSubnet = '10.0.0.0/24'
var adSubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, adSubnetName)
var publicIPSKU = 'Standard'
var publicIPAddressName = 'adPublicIp'
var publicIPAddressType = 'Static'
var publicIpAddressId = {
  id: publicIPAddress.id
}
var vmName = [
  'adPDC'
  'adBDC'
]
var nicName = [
  'adPDCNic'
  'adBDCNic'
]
var ipAddress = [
  '10.0.0.4'
  '10.0.0.5'
]

var modulePath = 'DSC'
var adBDCPrepareFunctionName = 'PrepareADBDC'
var adPDCCreateFunctionName = 'CreateADPDC'
var adBDCConfigFunctionName = 'ConfigureADBDC'

var adBDCConfigurationScript = 'DSC/ConfigureADBDC.ps1'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: publicIPSKU
  }
  zones: [
    '1'
  ]
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsPrefix
    }
  }
}

module CreateVNet 'nestedtemplates/vnet.bicep' = {
  name: 'CreateVNet'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: adSubnetName
    subnetRange: adSubnet
    location: location
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = [for i in range(0, 2): {
  name: nicName[i]
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: ipAddress[i]
          publicIPAddress: ((i == 0) ? publicIpAddressId : json('null'))
          subnet: {
            id: adSubnetRef
          }
        }
      }
    ]
  }
  dependsOn: [
    CreateVNet
  ]
}]

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, 2): {
  name: vmName[i]
  location: location
  zones: [
    string(i + 1)
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName[i]
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSKU
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadOnly'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 64
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', nicName[i])
        }
      ]
    }
  }
  dependsOn: [
    nic
  ]
}]

resource createAdForest 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${vmName[0]}/CreateAdForest'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.24'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: uri(_artifactsLocation, '${modulePath}/${adPDCCreateFunctionName}.ps1.zip')
        script: '${adPDCCreateFunctionName}.ps1'
        function: adPDCCreateFunctionName
      }
      configurationArguments: {
        domainName: domainName
      }
    }
    protectedSettings: {
      configurationUrlSasToken: _artifactsLocationSasToken
      configurationArguments: {
        adminCreds: {
          userName: adminUsername
          password: adminPassword
        }
      }
    }
  }
  dependsOn: [
    vm
  ]
}

resource prepareBDC 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${vmName[1]}/PrepareBDC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.24'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: uri(_artifactsLocation, '${modulePath}/${adBDCPrepareFunctionName}.ps1.zip')
        script: 'PrepareADBDC.ps1'
        function: 'PrepareADBDC'
      }
      configurationArguments: {
        DNSServer: ipAddress[0]
      }
    }
    protectedSettings: {
      configurationUrlSasToken: _artifactsLocationSasToken
    }
  }
  dependsOn: [
    vm
  ]
}

module updateVNetDNS1 'nestedtemplates/vnet.bicep' = {
  name: 'UpdateVNetDNS1'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: adSubnetName
    subnetRange: adSubnet
    DNSServerAddress: [
      ipAddress[0]
    ]
    location: location
  }
  dependsOn: [
    createAdForest
    prepareBDC
  ]
}

module updateBDCNIC 'nestedtemplates/nic.bicep' = {
  name: 'UpdateBDCNIC'
  params: {
    nicName: nicName[1]
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: ipAddress[1]
          subnet: {
            id: adSubnetRef
          }
        }
      }
    ]
    dnsServers: [
      ipAddress[0]
    ]
    location: location
  }
  dependsOn: [
    updateVNetDNS1
  ]
}

module configuringBackupADDomainController  'nestedtemplates/configureADBDC.bicep' = {
  name: 'ConfiguringBackupADDomainController'
  params: {
    extName: '${vmName[1]}/PrepareBDC'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    domainName: domainName
    adBDCConfigurationScript: adBDCConfigurationScript
    adBDCConfigurationFunction: adBDCConfigFunctionName
    adBDCConfigurationModulesPath: '${modulePath}/${adBDCConfigFunctionName}.ps1.zip'
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
  }
  dependsOn: [
    updateBDCNIC
  ]
}

module updateVNetDNS2  'nestedtemplates/vnet.bicep' = {
  name: 'UpdateVNetDNS2'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: adSubnetName
    subnetRange: adSubnet
    DNSServerAddress: ipAddress
    location: location
  }
  dependsOn: [
    configuringBackupADDomainController
  ]
}
