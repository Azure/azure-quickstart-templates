@description('Prefix for the environment (2-5 characters)')
param envPrefixName string = 'cust1'

@description('SQL IaaS VM local administrator username')
param username string

@description('SQL IaaS VM local administrator password')
@secure()
param password string

@description('The size of the Web Server VMs Created')
@allowed([
  'Standard_D2s_v3'
])
param webSrvVMSize string = 'Standard_D2s_v3'

@description('Number of Web Servers')
@allowed([
  1
  2
])
param numberOfWebSrvs int = 2

@description('The size of the SQL VM Created')
@allowed([
  'Standard_D4s_v3'
])
param sqlVMSize string = 'Standard_D4s_v3'

@description('The type of the Storage Account created')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
])
param diskType string = 'Premium_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

var virtualNetworkName = '${envPrefixName}Vnet'
var addressPrefix = '10.0.0.0/16'
var feSubnetPrefix = '10.0.0.0/24'
var dbSubnetPrefix = '10.0.2.0/24'
var feNSGName = 'feNsg'
var dbNSGName = 'dbNsg'
var sqlSrvDBName = '${envPrefixName}sqlSrv14'
var sqlVmSize = sqlVMSize
var sqlSrvDBNicName = '${sqlSrvDBName}Nic'
var sqlPublicIPName = '${envPrefixName}SqlPip'
var sqlImagePublisher = 'MicrosoftSQLServer'
var sqlImageOffer = 'sql2022-ws2022'
var sqlImageSku = 'standard-gen2'
var webSrvName = '${envPrefixName}webSrv'
var webSrvNicName = '${webSrvName}Nic'
var webSrvPublicIPName = '${envPrefixName}websrvpip'
var webSrvAvailabilitySetName = '${envPrefixName}webSrvAS'
var webSrvNumbOfInstances = numberOfWebSrvs
var webSrvDnsNameforLBIP = '${toLower(webSrvName)}lb'
var webLbName = '${webSrvName}lb'
var vmExtensionName = 'AzurePolicyforWindows'

resource feNSG 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: feNSGName
  location: location
  tags: {
    displayName: 'FrontEndNSG'
  }
  properties: {
    securityRules: [
      {
        name: 'web_rule'
        properties: {
          description: 'Allow WEB'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource dbNSG 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: dbNSGName
  location: location
  tags: {
    displayName: 'BackEndNSG'
  }
  properties: {
    securityRules: [
      {
        name: 'Allow_FE'
        properties: {
          description: 'Allow FE Subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.0.0/24'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Block_FE'
        properties: {
          description: 'Block App Subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.0.0.0/24'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 121
          direction: 'Inbound'
        }
      }
      {
        name: 'Block_Internet'
        properties: {
          description: 'Block Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 200
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    displayName: 'VirtualNetwork'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'FESubnetName'
        properties: {
          addressPrefix: feSubnetPrefix
          networkSecurityGroup: {
            id: feNSG.id
          }
        }
      }
      {
        name: 'DBSubnetName'
        properties: {
          addressPrefix: dbSubnetPrefix
          networkSecurityGroup: {
            id: dbNSG.id
          }
        }
      }
    ]
  }
}

resource sqlPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: sqlPublicIPName
  location: location
  tags: {
    displayName: 'SqlPIP'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource sqlSrvDBNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: sqlSrvDBNicName
  location: location
  tags: {
    displayName: 'SQLSrvDBNic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'DBSubnetName')
          }
          publicIPAddress: {
            id: sqlPublicIP.id
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource sqlSrv14vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: '${envPrefixName}sqlSrv14'
  location: location
  tags: {
    displayName: 'SQL-Svr-DB'
  }
  properties: {
    hardwareProfile: {
      vmSize: sqlVmSize
    }
    osProfile: {
      computerName: sqlSrvDBName
      adminUsername: username
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: sqlImagePublisher
        offer: sqlImageOffer
        sku: sqlImageSku
        version: 'latest'
      }
      osDisk: {
        name: '${sqlSrvDBName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: diskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: sqlSrvDBNic.id
        }
      ]
    }
  }
  dependsOn: [
    sqlPublicIP
  ]
}

resource webSrvAvailabilitySet 'Microsoft.Compute/availabilitySets@2023-09-01' = {
  location: location
  name: webSrvAvailabilitySetName
  properties: {
    platformUpdateDomainCount: 20
    platformFaultDomainCount: 2
  }
  tags: {
    displayName: 'WebSrvAvailabilitySet'
  }
  sku: {
    name: 'Aligned'
  }
}

resource webSrvPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: webSrvPublicIPName
  location: location
  tags: {
    displayName: 'WebSrvPIP for LB'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: webSrvDnsNameforLBIP
    }
  }
}

resource webLb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: webLbName
  location: location
  tags: {
    displayName: 'Web LB'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: webSrvPublicIP.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', webLbName, 'LoadBalancerFrontEnd')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', webLbName, 'BackendPool1')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', webLbName, 'tcpProbe')
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

resource webSrvNic 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in range(0, webSrvNumbOfInstances): {
  name: '${webSrvNicName}${i}'
  location: location
  tags: {
    displayName: 'WebSrvNic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'FESubnetName')
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', webLbName, 'BackendPool1')
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    webLb
  ]
}]

resource webSrv 'Microsoft.Compute/virtualMachines@2023-09-01' = [for i in range(0, webSrvNumbOfInstances): {
  name: '${webSrvName}${i}'
  location: location
  tags: {
    displayName: 'WebSrv'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    availabilitySet: {
      id: webSrvAvailabilitySet.id
    }
    hardwareProfile: {
      vmSize: webSrvVMSize
    }
    osProfile: {
      computerName: '${webSrvName}${i}'   
      adminUsername: username
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-core'
        version: 'latest'
      }
      osDisk: {
        name: '${webSrvName}${i}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: diskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webSrvNic[i].id
        }
      ]
    }
  }
}]

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [for i in range(0, webSrvNumbOfInstances): {
  parent: webSrv[i]
  name: vmExtensionName
  location: location
  tags: {
    displayName: 'VM Extensions'
  }
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}]

resource configuration 'Microsoft.GuestConfiguration/guestConfigurationAssignments@2022-01-25' = [for i in range(0, webSrvNumbOfInstances): {
  name: 'webServerConfig'
  scope: webSrv[i]
  location: location
  properties: {
    guestConfiguration: {
      name: 'WebServerConfig'
      version: '1.0.0'
      contentUri: uri(_artifactsLocation, 'scripts/WebServerConfig.zip?${_artifactsLocationSasToken}')
      contentHash: '018652dab6e4506ea3eb1370237cde8c692a8b9358942284a9ede13130303212'
      assignmentType: 'ApplyAndMonitor'
    }
  }
}]
