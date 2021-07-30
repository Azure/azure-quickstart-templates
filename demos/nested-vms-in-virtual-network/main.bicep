@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Resource Name for Public IP address attached to Hyper-V Host')
param HostPublicIPAddressName string = 'HVHOSTPIP'

@description('Hyper-V Host and Guest VMs Virtual Network')
param virtualNetworkName string = 'VirtualNetwork'

@description('Virtual Network Address Space')
param virtualNetworkAddressPrefix string = '10.0.0.0/22'

@description('NAT Subnet Name')
param NATSubnetName string = 'NAT'

@description('NAT Subnet Address Space')
param NATSubnetPrefix string = '10.0.0.0/24'

@description('Hyper-V Host Subnet Name')
param hyperVSubnetName string = 'Hyper-V-LAN'

@description('Hyper-V Host Subnet Address Space')
param hyperVSubnetPrefix string = '10.0.1.0/24'

@description('Ghosted Subnet Name')
param ghostedSubnetName string = 'Ghosted'

@description('Ghosted Subnet Address Space')
param ghostedSubnetPrefix string = '10.0.2.0/24'

@description('Azure VMs Subnet Name')
param azureVMsSubnetName string = 'Azure-VMs'

@description('Azure VMs Address Space')
param azureVMsSubnetPrefix string = '10.0.3.0/24'

@description('Hyper-V Host Network Interface 1 Name, attached to NAT Subnet')
param HostNetworkInterface1Name string = 'HVHOSTNIC1'

@description('Hyper-V Host Network Interface 2 Name, attached to Hyper-V LAN Subnet')
param HostNetworkInterface2Name string = 'HVHOSTNIC2'

@description('Name of Hyper-V Host Virtual Machine, Maximum of 15 characters, use letters and numbers only.')
@maxLength(15)
param HostVirtualMachineName string = 'HVHOST'

@description('Size of the Host Virtual Machine')
@allowed([
  'Standard_D2_v3'
  'Standard_D4_v3'
  'Standard_D8_v3'
  'Standard_D16_v3'
  'Standard_D32_v3'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_D16s_v3'
  'Standard_D32s_v3'
  'Standard_D64_v3'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E32_v3'
  'Standard_E64_v3'
  'Standard_D64s_v3'
  'Standard_E2s_v3'
  'Standard_E4s_v3'
  'Standard_E8s_v3'
  'Standard_E16s_v3'
  'Standard_E32s_v3'
  'Standard_E64s_v3'
])
param HostVirtualMachineSize string = 'Standard_D4s_v3'

@description('Admin Username for the Host Virtual Machine')
param HostAdminUsername string

@description('Admin User Password for the Host Virtual Machine')
@secure()
param HostAdminPassword string

var NATSubnetNSGName = '${NATSubnetName}NSG'
var hyperVSubnetNSGName = '${hyperVSubnetName}NSG'
var ghostedSubnetNSGName = '${ghostedSubnetName}NSG'
var azureVMsSubnetNSGName = '${azureVMsSubnetName}NSG'
var azureVMsSubnetUDRName = '${azureVMsSubnetName}UDR'
var DSCInstallWindowsFeaturesUri = uri(_artifactsLocation, 'dsc/dscinstallwindowsfeatures.zip${_artifactsLocationSasToken}')
var HVHostSetupScriptUri = uri(_artifactsLocation, 'hvhostsetup.ps1${_artifactsLocationSasToken}')

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: HostPublicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('${HostVirtualMachineName}-${uniqueString(resourceGroup().id)}')
    }
  }
}

resource natNsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: NATSubnetNSGName
  location: location
  properties: {}
}

resource hyperVNsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: hyperVSubnetNSGName
  location: location
  properties: {}
}

resource ghostedNsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: ghostedSubnetNSGName
  location: location
  properties: {}
}

resource azureVmsSubnet 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: azureVMsSubnetNSGName
  location: location
  properties: {}
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: NATSubnetName
        properties: {
          addressPrefix: NATSubnetPrefix
          networkSecurityGroup: {
            id: natNsg.id
          }
        }
      }
      {
        name: hyperVSubnetName
        properties: {
          addressPrefix: hyperVSubnetPrefix
          networkSecurityGroup: {
            id: hyperVNsg.id
          }
        }
      }
      {
        name: ghostedSubnetName
        properties: {
          addressPrefix: ghostedSubnetPrefix
          networkSecurityGroup: {
            id: ghostedNsg.id
          }
        }
      }
      {
        name: azureVMsSubnetName
        properties: {
          addressPrefix: azureVMsSubnetPrefix
          networkSecurityGroup: {
            id: azureVmsSubnet.id
          }
          routeTable: {
            id: createAzureVmUdr.outputs.udrId
          }
        }
      }
    ]
  }
}

module createNic1 './nic.bicep' = {
  name: 'createNic1'
  params: {
    location: location
    nicName: HostNetworkInterface1Name
    subnetId: '${vnet.id}/subnets/${NATSubnetName}'
    pipId: publicIp.id
  }
}

module createNic2 './nic.bicep' = {
  name: 'createNic2'
  params: {
    location: location
    nicName: HostNetworkInterface2Name
    enableIPForwarding: true
    subnetId: '${vnet.id}/subnets/${hyperVSubnetName}'
  }
}

// update nic to staticIp now that nic has been created
module updateNic1 './nic.bicep' = {
  name: 'updateNic1'
  params: {
    location: location
    ipAllocationMethod: 'Static'
    staticIpAddress: createNic1.outputs.assignedIp
    nicName: HostNetworkInterface1Name
    subnetId: '${vnet.id}/subnets/${NATSubnetName}'
    pipId: publicIp.id
  }
}

// update nic to staticIp now that nic has been created
module updateNic2 './nic.bicep' = {
  name: 'updateNic2'
  params: {
    location: location
    ipAllocationMethod: 'Static'
    staticIpAddress: createNic2.outputs.assignedIp
    nicName: HostNetworkInterface2Name
    enableIPForwarding: true
    subnetId: '${vnet.id}/subnets/${hyperVSubnetName}'
  }
}

module createAzureVmUdr './udr.bicep' = {
  name: 'udrDeploy'
  params: {
    location: location
    udrName: azureVMsSubnetUDRName
  }
}

module updateAzureVmUdr './udr.bicep' = {
  name: 'udrUpdate'
  params: {
    location: location
    udrName: azureVMsSubnetUDRName
    addressPrefix: ghostedSubnetPrefix
    nextHopAddress: createNic2.outputs.assignedIp
  }
}

resource hostVm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: HostVirtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: HostVirtualMachineSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${HostVirtualMachineName}OsDisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
      }
      dataDisks: [
        {
          lun: 0
          name: '${HostVirtualMachineName}DataDisk1'
          createOption: 'Empty'
          diskSizeGB: 1024
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    osProfile: {
      computerName: HostVirtualMachineName
      adminUsername: HostAdminUsername
      adminPassword: HostAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: createNic1.outputs.nicId
          properties: {
            primary: true
          }
        }
        {
          id: createNic2.outputs.nicId
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: hostVm
  name: 'InstallWindowsFeatures'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: DSCInstallWindowsFeaturesUri
        script: 'DSCInstallWindowsFeatures.ps1'
        function: 'InstallWindowsFeatures'
      }
    }
  }
}

resource hostVmSetupExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: hostVm
  name: 'HVHOSTSetup'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        HVHostSetupScriptUri
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File HVHostSetup.ps1 -NIC1IPAddress ${createNic1.outputs.assignedIp} -NIC2IPAddress ${createNic2.outputs.assignedIp} -GhostedSubnetPrefix ${ghostedSubnetPrefix} -VirtualNetworkPrefix ${virtualNetworkAddressPrefix}'
    }
  }
  dependsOn: [
    vmExtension
  ]
}
