@description('Location for the VMs, only certain regions support zones.')
param location string = resourceGroup().location

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Unique DNS Name for the Public IP for the frontend load balancer.')
param dnsName string

@description('Operation System for the Virtual Machine.')
@allowed([
  'Windows'
  'Ubuntu'
])
param windowsOrUbuntu string = 'Ubuntu'

@description('Number of VMs to provision')
@minValue(1)
@maxValue(10)
param numberOfVms int = 3

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

var extensionName = 'GuestAttestation'
var extensionPublisherLin = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionPublisherWin = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var storageAccountName = 'diags${uniqueString(resourceGroup().id)}'
var nicName = 'myVMNic'
var subnetName = 'Subnet-1'
var publicIPAddressName = 'myPublicIP'
var virtualNetworkName = 'MyVNET'
var networkSecurityGroupName = 'allowRemoting'
var lbName = 'multiVMLB'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets/', virtualNetworkName, subnetName)
var frontEndIPConfigID = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'loadBalancerFrontend')
var inboundNatRuleName = 'remoting'
var windowsImage = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: OSVersion
  version: 'latest'
}
var linuxImage = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-lunar-daily'
  sku: '23_04-daily-gen2'
  version: 'latest'
}
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsName
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'RemoteConnection'
        properties: {
          description: 'Allow RDP/SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: ((windowsOrUbuntu == 'Windows') ? 3389 : 22)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = [for i in range(0, numberOfVms): {
  name: concat(nicName, i)
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackend')
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', lbName, concat(inboundNatRuleName, i))
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    lb
    lbName_inboundNatRule
  ]
}]

resource lb 'Microsoft.Network/loadBalancers@2020-05-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontend'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBackend'
      }
    ]
    loadBalancingRules: [
      {
        name: 'port80'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIPConfigID
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackend')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'tcpProbe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'tcpProbe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource lbName_inboundNatRule 'Microsoft.Network/loadBalancers/inboundNatRules@2020-05-01' = [for i in range(0, numberOfVms): {
  name: '${lbName}/${inboundNatRuleName}${i}'
  location: location
  properties: {
    frontendIPConfiguration: {
      id: frontEndIPConfigID
    }
    protocol: 'Tcp'
    frontendPort: (i + 50000)
    backendPort: ((windowsOrUbuntu == 'Windows') ? 3389 : 22)
    enableFloatingIP: false
  }
  dependsOn: [
    lb
  ]
}]

resource dns 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, numberOfVms): {
  name: concat(dnsName, i)
  location: location
  zones: split(string(((i % 3) + 1)), ',')
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: concat(dnsName, i)
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: ((windowsOrUbuntu == 'Windows') ? windowsImage : linuxImage)
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', concat(nicName, i))
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
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    nic
  ]
}]

resource dnsName_GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for i in range(0, numberOfVms): if (vTPM && secureBoot) {
  name: '${dnsName}${i}/GuestAttestation'
  location: location
  properties: {
    publisher: ((windowsOrUbuntu == 'Windows') ? extensionPublisherWin : extensionPublisherLin)
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}]

output hostname string = publicIPAddress.properties.dnsSettings.fqdn
