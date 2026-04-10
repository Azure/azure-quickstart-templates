@description('The name of you virtual machine.')
param vmName string = 'myTVM'

@description('The OS for the virtual machine. This will pick the latest fully patched image of the given OS.')
@allowed([
  'Ubuntu-2204'
  'RHEL-83'
  'SUSE-15-SP2'
])
param sku string = 'Ubuntu-2204'

@description('The size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

@description('Username for the virtual machine.')
param adminUsername string

@description('Type of authentication to use on the virtual machine. SSH Public key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH Public Key or password for the virtual machine. SSH Public key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique DNS Name for the Public IP used to access the virtual machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

@description('Name for the Public IP used to access the virtual machine.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the virtual machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the virtual machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('Name of the network interface')
param nicName string = 'nic'

@description('Name of the virtual network')
param virtualNetworkName string = 'vnet'

@description('Name of the network security group')
param networkSecurityGroupName string = 'nsg'

@description('Custom Attestation Endpoint to attest to. By default, MAA and ASC endpoints are empty and Azure values are populated based on the location of the VM.')
param maaEndpoint string = ''

var imageReference = {
  'Ubuntu-2204': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }
  'RHEL-83': {
    publisher: 'RedHat'
    offer: 'RHEL'
    sku: '83-gen2'
    version: 'latest'
  }
  'SUSE-15-SP2': {
    publisher: 'SUSE'
    offer: 'SLES-15-SP2'
    sku: 'gen2'
    version: 'latest'
  }
}
var addressPrefix = '10.0.0.0/16'
var disableAlerts = 'false'
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var useAlternateToken = 'false'
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

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
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
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
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

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
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
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: imageReference[sku]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
      securityType: 'TrustedLaunch'
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (vTPM && secureBoot) {
  parent: vm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: substring(maaEndpoint, 0, 0)
          ascReportingFrequency: substring(maaEndpoint, 0, 0)
        }
        useCustomToken: useAlternateToken
        disableAlerts: disableAlerts
      }
    }
  }
}

output hostname string = publicIp.properties.dnsSettings.fqdn
