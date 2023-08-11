@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Azure OpenAI account')
param openAiAccountName string = 'oai-private-demo'

@description('Custom subdomain name for the Azure OpenAI account')
param customSubDomainName string

@description('SKU for the Azure OpenAI account')
param sku string = 'S0'

@description('Tokens per Minute Rate Limit (thousands)')
param embeddingsDeploymentCapacity int

@description('Name of the Embeddings Model to deploy')
param embeddingsModelName string

@description('Tokens per Minute Rate Limit (thousands)')
param gptDeploymentCapacity int

@description('Name of the GPT Model to deploy')
param chatGptModelName string

@description('Name of the Azure Virtual Network')
param virtualNetworkName string = 'vnet-oai-demo'

@description('Name of the Azure OpenaAI Private DNS Zone')
param oaiPrivateDnsZoneName string = 'privatelink.openai.azure.com'

@description('Name of the Azure OpenaAI Private Endpoint')
param oaiPrivateEndpointName string = 'oaiDemoPrivateEndpoint'

@description('The name of the Azure Bastion host')
param bastionHostName string = 'bastion-oai-demo'

@description('Admin Username for the Virtual Machine.')
param adminUsername string

@description('Admin Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  'win11-22h2-pro'
  'win11-22h2-pron'
  'win11-22h2-pro-zh-cn'
  'win11-22h2-ent'
])
param OSVersion string = 'win11-22h2-ent'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Name of the virtual machine.')
param vmName string = 'vm-oai-demo'

var embeddingsDeployment = empty(embeddingsModelName) ? 'ada' : embeddingsModelName
var chatGptDeployment = empty(chatGptModelName) ? 'chat' : chatGptModelName
var deployments = [
  {
    name: embeddingsDeployment
    model: {
      format: 'OpenAI'
      name: embeddingsModelName
    }
    sku: {
      name: 'Standard'
      capacity: embeddingsDeploymentCapacity
    }
  }
  {
    name: chatGptDeployment
    model: {
      format: 'OpenAI'
      name: chatGptModelName
    }
    sku: {
      name: 'Standard'
      capacity: gptDeploymentCapacity
    }
  }
]

resource peNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'nsg-pe-oai-demo'
  location: location
  properties: {
    securityRules: []
  }
}

resource vmNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'nsg-vm-oai-demo'
  location: location
  properties: {
    securityRules: []
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'OpenAI'
        properties: {
          addressPrefix: '10.0.0.0/27'
          networkSecurityGroup: {
            id: peNSG.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'VMs'
        properties: {
          addressPrefix: '10.0.0.32/28'
          networkSecurityGroup: {
            id: vmNSG.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.192/26'
          networkSecurityGroup: {
            id: bastionNSG.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
  }
}

resource oaiAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiAccountName
  location: location
  kind: 'OpenAI'
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: 'Disabled'
  }
  sku: {
    name: sku
  }
  dependsOn: [
    virtualNetwork
  ]
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: oaiAccount
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: contains(deployment, 'raiPolicyName') ? deployment.raiPolicyName : null
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

resource oaiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.openai.azure.com'
  location: 'global'
  properties: {}
  dependsOn: [
    virtualNetwork
  ]
}

resource oaiPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: oaiPrivateDnsZone
  name: '${oaiPrivateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource oaiPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: oaiPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${oaiPrivateEndpointName}-connection'
        properties: {
          privateLinkServiceId: oaiAccount.id
          groupIds: [
            'account'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    customNetworkInterfaceName: '${oaiPrivateEndpointName}-nic'
    subnet: {
      id: '${virtualNetwork.id}/subnets/OpenAI'
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: oaiPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: oaiPrivateDnsZone.id
        }
      }
    ]
  }
}

resource vmNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetwork.id}/subnets/VMs'
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
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
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm
  name: 'GuestAttestation'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.WindowsAttestation'
    type: 'GuestAttestation'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: substring('emptyString', 0, 0)
          maaTenantName: 'GuestAttestation'
        }
      }
    }
  }
}

resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-${bastionHostName}'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
        name: 'ipconfig1'
      }
    ]
  }
}

resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'nsg-${bastionHostName}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}
