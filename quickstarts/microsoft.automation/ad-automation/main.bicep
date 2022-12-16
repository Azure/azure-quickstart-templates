@description('The name of the administrator account of the new VM and domain.')
param adminUsername string

@description('The password for the administrator account of the new VM and domain.')
@minLength(12)
@secure()
param adminPassword string

@description('The FQDN of the Active Directory Domain to be created.')
param domainName string = 'ad.contoso.local'

@description('The name of the DSC Compilation Job')
param compileConfigurationJobName string = 'Compile-${take(guid(deployment().name),5)}'

@description('Specifies the Azure location where the resources will be created.')
param location string = resourceGroup().location

@description('Specifies the name of the network security group')
param networkSecurityGroupName string = 'AD-NSG'

@description('The name of the automation account.')
param automationAccountName string = 'Automation-${take(guid(resourceGroup().id),5)}'

@description('The SKU for the automation account')
param automationAccountSku string = 'Basic'

@description('The name of the virtualNetwork.')
param virtualNetworkName string = 'AD-VNET'

@description('Virtual network address range.')
param virtualNetworkAddressPrefix string = '10.0.0.0/16'

@description('The name of the subnet.')
param subnetName string = 'AD-VNET-SUBNET'

@description('Subnet IP range.')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('The name of the Automation Account Credentials')
param credentialsName string = 'DomainCredentials'

@description('Computer Name of Domain Controller VM')
param dcComputername string = 'DC'

@description('Private IP Address of the Domain Controller.')
param dcPrivateIPAddress string = '10.0.0.4'

@description('Size of the VM')
@allowed([
  'Standard_B1ms'
  'Standard_D2s_v3'
])
param vmSize string = 'Standard_B1ms'

@description('Computer Name of the Member Server VM')
param msComputerName string = 'MS1'

var azurePlatformDnsIPAddress = '168.63.129.16' // Azure Platform DNS https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16

var dscConfigurationName = 'DscConfiguration'

var dscConfiguration = loadTextContent('dsc/configuration.ps1')

var dscResourceModules = [
  {
    name: 'ActiveDirectoryDsc'
    version: '6.2.0'
  }
  {
    name: 'ComputerManagementDsc'
    version: '8.5.0'
  }
  {
    name: 'PSDscResources'
    version: '2.12.0.0'
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: [
        dcPrivateIPAddress
        azurePlatformDnsIPAddress // needed for the Automation Account DSC to work
      ]
    }
  }
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow_RDP_to_AD_Servers'
        properties: {
          description: 'Allow RDP to AD Servers'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: securityGroup.id
    }
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: automationAccountSku
    }
  }
}

resource modules 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = [for item in dscResourceModules: {
  parent: automationAccount
  name: item.name
  location: location
  properties: {
    contentLink: {
      uri: uri('https://www.powershellgallery.com/api/v2/package/', '${item.name}/${item.version}')
      version: item.version
    }
  }
}]

resource domainCredential 'Microsoft.Automation/automationAccounts/credentials@2022-08-08' = {
  parent: automationAccount
  name: credentialsName
  properties: {
    userName: '${domainName}\\${adminUsername}'
    password: adminPassword
  }
}

resource configuration 'Microsoft.Automation/automationAccounts/configurations@2022-08-08' = {
  parent: automationAccount
  name: dscConfigurationName
  location: location
  properties: {
    source: {
      type: 'embeddedContent'
      value: dscConfiguration
    }
  }
}

resource compileConfiguration 'Microsoft.Automation/automationAccounts/compilationjobs@2022-08-08' = {
  parent: automationAccount
  name: compileConfigurationJobName
  location: location
  dependsOn: [
    modules
  ]
  properties: {
    configuration: {
      name: configuration.name
    }
    parameters: {
      domainName: domainName
      domainCredentialName: domainCredential.name
      dcComputerName: dcComputername
      msComputerName: msComputerName
    }
  }
}

resource dcPublicIPAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${dcComputername}-PIP'
  location: location
  dependsOn: [
    virtualNetwork
  ]
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource dcNic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${dcComputername}-NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'privateipconfig'
        properties: {
          privateIPAddress: dcPrivateIPAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: dcPublicIPAddress.id
          }
        }
      }
    ]
  }
}

resource dcVirtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${dcComputername}-VM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: dcComputername
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: dcNic.id
        }
      ]
    }
  }

  resource dscExtension 'extensions' = {
    name: '${dcComputername}-OnboardToDSC'
    location: location
    dependsOn: [
      compileConfiguration
    ]
    properties: {
      publisher: 'Microsoft.Powershell'
      type: 'DSC'
      typeHandlerVersion: '2.75'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        Items: {
          registrationPrivateKey: automationAccount.listKeys().keys[0].Value
        }
      }
      settings: {
        Properties: [
          {
            Name: 'RegistrationKey'
            Value: {
              UserName: 'PLACEHOLDER_DONOTUSE'
              Password: 'PrivateSettingsRef:registrationPrivateKey'
            }
            TypeName: 'System.Management.Automation.PSCredential'
          }
          {
            Name: 'RegistrationUrl'
            Value: reference(automationAccount.id, '2021-06-22').registrationUrl
            TypeName: 'System.String'
          }
          {
            Name: 'NodeConfigurationName'
            Value: '${dscConfigurationName}.${dcComputername}'
            TypeName: 'System.String'
          }
          {
            Name: 'ConfigurationMode'
            Value: 'ApplyAndAutoCorrect'
            TypeName: 'System.String'
          }
          {
            Name: 'RebootNodeIfNeeded'
            Value: true
            TypeName: 'System.Boolean'
          }
          {
            Name: 'ActionAfterReboot'
            Value: 'ContinueConfiguration'
            TypeName: 'System.String'
          }
        ]
      }
    }
  }
}

resource msPublicIPAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${msComputerName}-PIP'
  location: location
  dependsOn: [
    virtualNetwork
  ]
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource msNic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${msComputerName}-NIC'
  location: location
  dependsOn: [
    dcNic // wait on static IP address allocation. Otherwise we could have a conflict.
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'privateipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: msPublicIPAddress.id
          }
        }
      }
    ]
  }
}

resource msVirtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${msComputerName}-VM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: msComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: msNic.id
        }
      ]
    }
  }

  resource dscExtension 'extensions' = {
    name: '${msComputerName}-OnboardToDSC'
    location: location
    dependsOn: [
      compileConfiguration
    ]
    properties: {
      publisher: 'Microsoft.Powershell'
      type: 'DSC'
      typeHandlerVersion: '2.75'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        Items: {
          registrationPrivateKey: automationAccount.listKeys().keys[0].Value
        }
      }
      settings: {
        Properties: [
          {
            Name: 'RegistrationKey'
            Value: {
              UserName: 'PLACEHOLDER_DONOTUSE'
              Password: 'PrivateSettingsRef:registrationPrivateKey'
            }
            TypeName: 'System.Management.Automation.PSCredential'
          }
          {
            Name: 'RegistrationUrl'
            Value: reference(automationAccount.id, '2021-06-22').registrationUrl
            TypeName: 'System.String'
          }
          {
            Name: 'NodeConfigurationName'
            Value: '${dscConfigurationName}.${msComputerName}'
            TypeName: 'System.String'
          }
          {
            Name: 'ConfigurationMode'
            Value: 'ApplyAndAutoCorrect'
            TypeName: 'System.String'
          }
          {
            Name: 'RebootNodeIfNeeded'
            Value: true
            TypeName: 'System.Boolean'
          }
          {
            Name: 'ActionAfterReboot'
            Value: 'ContinueConfiguration'
            TypeName: 'System.String'
          }
        ]
      }
    }
  }
}
