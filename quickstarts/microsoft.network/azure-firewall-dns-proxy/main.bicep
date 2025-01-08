@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('Specifies the globally unique DNS Name for the ADLS Gen 2 storage account.')
param adlsStorageAccountName string = 'adls${uniqueString(resourceGroup().id)}'

@description('Specifies the globally unique name for the storage account used to store the test file system and the boot diagnostics logs of the virtual machines.')
param blobStorageAccountName string = 'blob${uniqueString(resourceGroup().id)}'

@description('Specifies the default action of allow or deny when no other rules match for the ADLS storage account.')
@allowed([
  'Allow'
  'Deny'
])
param adlsStorageAccountNetworkAclsDefaultAction string = 'Deny'

@description('Allow or disallow public access to all blobs or containers in the Blob storage account. The default interpretation is true for this property.')
@allowed([
  'Allow'
  'Deny'
])
param blobStorageAccountNetworkAclsDefaultAction string = 'Deny'

@description('Allow or disallow public access to all blobs or containers in the ADLS storage account. The default interpretation is true for this property.')
param adlsStorageAccountAllowBlobPublicAccess bool = true

@description('Allow or disallow public access to all blobs or containers in the Blob storage account. The default interpretation is true for this property.')
param blobStorageAccountAllowBlobPublicAccess bool = true

@description('Specify whether deploy a custom DNS forwarder in the Hub Virtual Network. Default value is false.')
param deployCustomDnsForwarder bool = false

@description('Name of the Availability Set used by the DNS virtual machine.')
param dnsAvailabilitySetName string = 'availabilityset${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the DNS virtual machine.')
param dnsVmName string = 'DnsVm'

@description('Specifies the name of the virtual machine in the Development Virtual Network.')
param devVmName string = 'DevVm'

@description('Specifies the name of the virtual machine in the Production Virtual Network.')
param prodVmName string = 'ProdVm'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_D4s_v3'

@description('The publisher of the image from which to launch the virtual machine.')
param imagePublisher string = 'MicrosoftCBLMariner'

@description('The offer of the image from which to launch the virtual machine.')
param imageOffer string = 'cbl-mariner'

@description('The SKU of the image from which to launch the virtual machine.')
param imageSku string = 'cbl-mariner-2-gen2'

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
param adminUsername string

@description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Defines the storage account type for OS and data disk.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
])
param diskStorageAccounType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('The size in GB of the OS disk of the VM.')
param osDiskSize int = 100

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 10

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies the base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('Specifies the sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Specifies the name of the adls private endpoint to the adls storage account.')
param adlsStorageAccountAdlsPrivateEndpointName string = 'AdlsStorageAccountAdlsPrivateEndpoint'

@description('Specifies the name of the blob private endpoint to the adls storage account.')
param adlsStorageAccountBlobPrivateEndpointName string = 'AdlsStorageAccountBlobPrivateEndpoint'

@description('Specifies the name of the blob private endpoint to the boot diagnostics storage account.')
param blobStorageAccountBlobPrivateEndpointName string = 'BlobStorageAccountBlobPrivateEndpoint'

@description('Private DNS Zone name.')
param privateDnsZoneName string = 'contoso.corp'

@description('the name of the Log Analytics workspace.')
param workspaceName string = 'loganalytics${uniqueString(resourceGroup().id)}'

@description('The sku of the Log Analytics workspace.')
@allowed([
  'Free'
  'Standard'
  'Premium'
  'PerNode'
  'PerGB2018'
  'Standalone'
  'CapacityReservation'
])
param workspaceSku string = 'PerGB2018'

@description('The name of the Azure Firewall.')
param firewallName string = 'HubFirewall'

@description('Zone numbers e.g. 1,2,3.')
param firewallAvailabilityZones array = []

@description('Number of public IP addresses for the Azure Firewall')
@minValue(1)
@maxValue(100)
param numberOfFirewallPublicIPAddresses int = 1

@description('Specifies whether create DNAT rule collection in the Azure Firewall policy or not.')
param createDnatRuleCollection bool = true

@description('Specifies whether deploy a VPN Gateway in the Hub or not.')
param deployVpnGateway bool = false

@description('The SKU of the Gateway, if deployed')
@allowed([
  'Basic'
  'HighPerformance'
  'Standard'
  'UltraPerformance'
  'VpnGw1'
  'VpnGw2'
  'VpnGw3'
  'VpnGw4'
  'VpnGw5'
  'VpnGw1AZ'
  'VpnGw2AZ'
  'VpnGw3AZ'
  'VpnGw4AZ'
  'VpnGw5AZ'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
])
param gatewaySku string = 'Standard'

@description('The type of this virtual network gateway. - Vpn or ExpressRoute')
@allowed([
  'Vpn'
  'ExpressRoute'
])
param gatewayType string = 'Vpn'

@description('The type of this virtual network gateway. - PolicyBased or RouteBased')
@allowed([
  'PolicyBased'
  'RouteBased'
])
param vpnType string = 'RouteBased'

@description('Whether BGP is enabled for this virtual network gateway or not.')
param enableBgp bool = false

@description('Location for all resources.')
param location string = resourceGroup().location
param hubVnetName string = 'HubVnet'
param hubVnetAddressPrefix string = '192.168.0.0/16'

@description('The name of the Firewall subnet.')
param hubVnetFirewallSubnetName string = 'AzureFirewallSubnet'

@description('The address prefix of the Firewall subnet.')
param hubVnetFirewallSubnetPrefix string = '192.168.0.0/26'

@description('The name of the Management subnet.')
param hubVnetCommonSubnetName string = 'CommonSubnet'

@description('The address prefix of the Management subnet.')
param hubVnetCommonSubnetPrefix string = '192.168.1.0/24'

@description('The name of the Development Virtual Network.')
param hubVnetGatewaySubnetName string = 'GatewaySubnet'

@description('The address prefix of the Gateway subnet.')
param hubVnetGatewaySubnetPrefix string = '192.168.15.224/27'

@description('The name of gateway.')
param gatewayName string = 'HubVpnGateway'

@description('The name of the Development Virtual Network.')
param devVnetName string = 'DevelopmentVNet'

@description('The address prefix of the Development Virtual Network.')
param devVnetAddressPrefix string = '10.0.0.0/16'

@description('The name of the Production Virtual Network.')
param prodVnetName string = 'ProductionVNet'

@description('The address prefix of the Production Virtual Network.')
param prodVnetAddressPrefix string = '10.1.0.0/16'

@description('The name of the Workload subnet.')
param devVnetDefaultSubnetName string = 'DefaultSubnet'

@description('The address prefix of the Workload subnet in the Development Virtual Network.')
param devVNetDefaultSubnetPrefix string = '10.0.0.0/24'

@description('The name of the Workload subnet.')
param prodVnetDefaultSubnetName string = 'DefaultSubnet'

@description('The address prefix of the Workload subnet in the Production Virtual Network.')
param prodVNetDefaultSubnetPrefix string = '10.1.0.0/24'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param hubVnetBastionSubnetPrefix string = '192.168.4.0/24'

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string = 'bastion${uniqueString(resourceGroup().id)}'

@description('The name of the Firewall Policy uased by the Azure Firewall')
param firewallPolicyName string = '${firewallName}Policy'

var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var bastionPublicIpAddressName = '${bastionHostName}PublicIp'
var bastionSubnetName = 'AzureBastionSubnet'
var gatewayPublicIpName = '${gatewayName}PublicIp'
var hubVnetCommonSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubVnetCommonSubnetName)
var dnsVmNicName = '${dnsVmName}Nic'
var devVmNicName = '${devVmName}Nic'
var prodVmNicName = '${prodVmName}Nic'
var hubVnetCommonSubnetNsgName = '${hubVnetName}${hubVnetCommonSubnetName}Nsg'
var hubVnetBastionSubnetNsgName = '${hubVnetName}${bastionSubnetName}Nsg'
var devVnetDefaultSubnetNsgName = '${devVnetName}${devVnetDefaultSubnetName}Nsg'
var prodVnetDefaultSubnetNsgName = '${prodVnetName}${prodVnetDefaultSubnetName}Nsg'
var devVnetDefaultSubnetRouteTableName = '${devVnetName}${devVnetDefaultSubnetName}RouteTable'
var prodVnetDefaultSubnetRouteTableName = '${prodVnetName}${prodVnetDefaultSubnetName}RouteTable'
var devVnetDefaultSubnetRouteTableId = devVnetDefaultSubnetRouteTable.id
var prodVnetDefaultSubnetRouteTableId = prodVnetDefaultSubnetRouteTable.id
var firewallPublicIPNamePrefix = '${firewallName}PublicIP'
var azureFirewallPublicIpId = resourceId('Microsoft.Network/publicIPAddresses', firewallPublicIPNamePrefix)
var azureFirewallSubnetJSON = json('{"id": "${resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubVnetFirewallSubnetName)}"}')
var firewallPolicyDefaultNetworkRuleCollectionGroupName = '${firewallPolicyName}/DefaultNetworkRuleCollectionGroup'
var firewallPolicyDefaultDnatRuleCollectionGroupName = '${firewallPolicyName}/DefaultDnatRuleCollectionGroup'
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
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
  provisionVMAgent: true
  patchSettings: {
      patchMode: 'AutomaticByPlatform'
  }
}
var adlsStorageAccountId = adlsStorageAccount.id
var blobStorageAccountId = blobStorageAccount.id
var adlsPublicDNSZoneForwarder = '.dfs.${environment().suffixes.storage}'
var blobPublicDNSZoneForwarder = '.blob.${environment().suffixes.storage}'
var adlsPrivateDnsZoneName = 'privatelink${adlsPublicDNSZoneForwarder}'
var blobPrivateDnsZoneName = 'privatelink${blobPublicDNSZoneForwarder}'
var adlsPrivateDnsZoneId = adlsPrivateDnsZone.id
var blobPrivateDnsZoneId = blobPrivateDnsZone.id
var adlsServicePrimaryEndpoint = '${adlsStorageAccountName}${adlsPublicDNSZoneForwarder}'
var blobServicePrimaryEndpoint = '${blobStorageAccountName}${blobPublicDNSZoneForwarder}'
var adlsGroupName = 'dfs'
var blobGroupName = 'blob'
var dnsVmScriptFileName = 'configure-custom-dns-forwarder.sh'
var testVmScriptFileName = 'test-dns-and-private-endpoints.sh'
var dnsVmScriptFileUri = uri(_artifactsLocation, 'scripts/${dnsVmScriptFileName}${_artifactsLocationSasToken}')
var testVmScriptFileUri = uri(_artifactsLocation, 'scripts/${testVmScriptFileName}${_artifactsLocationSasToken}')

var devContributorRoleAssignmentName = guid('devcontributor${resourceGroup().id}${devVmName}')
var prodContributorRoleAssignmentName = guid('prodcontributor${resourceGroup().id}${prodVmName}')
var devStorageBlobDataContributorRoleAssignmentName = guid('devStorageBlobDataContributor${resourceGroup().id}${devVmName}')
var prodStorageBlobDataContributorRoleAssignmentName = guid('prodStorageBlobDataContributor${resourceGroup().id}${prodVmName}')

resource adlsStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: adlsStorageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      defaultAction: adlsStorageAccountNetworkAclsDefaultAction
      bypass: 'AzureServices'
    }
    allowBlobPublicAccess: adlsStorageAccountAllowBlobPublicAccess
  }
}

resource blobStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: blobStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      defaultAction: blobStorageAccountNetworkAclsDefaultAction
      bypass: 'AzureServices'
    }
    allowBlobPublicAccess: blobStorageAccountAllowBlobPublicAccess
  }
}

resource hubVnetCommonSubnetNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: hubVnetCommonSubnetNsgName
  location: location
}

resource hubVnetCommonSubnetNsgDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: hubVnetCommonSubnetNsg
  name: 'default'
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource devVnetDefaultSubnetNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: devVnetDefaultSubnetNsgName
  location: location
}

resource devVnetDefaultSubnetNsgDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: devVnetDefaultSubnetNsg
  name: 'default'
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource prodVnetDefaultSubnetNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: prodVnetDefaultSubnetNsgName
  location: location
}

resource prodVnetDefaultSubnetNsgDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: prodVnetDefaultSubnetNsg
  name: 'default'
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource hubVnetBastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: hubVnetBastionSubnetNsgName
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

resource hubVnetBastionSubnetNsgDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: hubVnetBastionSubnetNsg
  name: 'default'
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: bastionPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConfiguration'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, bastionSubnetName)
          }
          publicIPAddress: {
            id: bastionPublicIpAddress.id
          }
        }
      }
    ]
  }
  dependsOn: [
    hubVnet
  ]
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: hubVnetCommonSubnetName
        properties: {
          addressPrefix: hubVnetCommonSubnetPrefix
          networkSecurityGroup: {
            id: hubVnetCommonSubnetNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: hubVnetBastionSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: hubVnetBastionSubnetNsg.id
          }
        }
      }
      {
        name: hubVnetGatewaySubnetName
        properties: {
          addressPrefix: hubVnetGatewaySubnetPrefix
        }
      }
      {
        name: hubVnetFirewallSubnetName
        properties: {
          addressPrefix: hubVnetFirewallSubnetPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource devVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: devVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        devVnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: [
        firewall.properties.ipConfigurations[0].properties.privateIPAddress
      ]
    }
    subnets: [
      {
        name: devVnetDefaultSubnetName
        properties: {
          addressPrefix: devVNetDefaultSubnetPrefix
          routeTable: {
            id: devVnetDefaultSubnetRouteTableId
          }
          networkSecurityGroup: {
            id: devVnetDefaultSubnetNsg.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource prodVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: prodVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        prodVnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: [
        firewall.properties.ipConfigurations[0].properties.privateIPAddress
      ]
    }
    subnets: [
      {
        name: prodVnetDefaultSubnetName
        properties: {
          addressPrefix: prodVNetDefaultSubnetPrefix
          routeTable: {
            id: prodVnetDefaultSubnetRouteTableId
          }
          networkSecurityGroup: {
            id: prodVnetDefaultSubnetNsg.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource hubVnetToDevVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: '${hubVnetName}To${devVnetName}Peering'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: deployVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: devVnet.id
    }
  }
  dependsOn: [
    gateway
  ]
}

resource hubVnetToProdVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: '${hubVnetName}To${prodVnetName}Peering'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: deployVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: prodVnet.id
    }
  }
  dependsOn: [
    gateway
  ]
}

resource devVnetToHubVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: devVnet
  name: '${devVnetName}To${hubVnetName}Peering'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: deployVpnGateway
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    gateway
  ]
}

resource prodVnetToHubVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: prodVnet
  name: '${prodVnetName}To${hubVnetName}Peering'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: deployVpnGateway
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    gateway
  ]
}

resource gatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (deployVpnGateway) {
  name: gatewayPublicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource gateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = if (deployVpnGateway) {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubVnetGatewaySubnetName)
          }
          publicIPAddress: {
            id: gatewayPublicIp.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: gatewayType
    vpnType: vpnType
    enableBgp: enableBgp
  }
  dependsOn: [
    hubVnet
  ]
}

resource dnsAvailabilitySet 'Microsoft.Compute/availabilitySets@2023-09-01' = if (deployCustomDnsForwarder) {
  name: dnsAvailabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
}

resource dnsVmNic 'Microsoft.Network/networkInterfaces@2023-09-01' = if (deployCustomDnsForwarder) {
  name: dnsVmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vmIpConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hubVnetCommonSubnetId
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
  }
  dependsOn: [
    hubVnet
  ]
}

resource dnsVm 'Microsoft.Compute/virtualMachines@2023-09-01' = if (deployCustomDnsForwarder) {
  name: dnsVmName
  location: location
  tags: {
      AzSecPackAutoConfigReady: true
  }
  properties: {
    availabilitySet: {
      id: dnsAvailabilitySet.id
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: dnsVmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${dnsVmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: osDiskSize
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }
      dataDisks: [for j in range(0, numDataDisks): {
        caching: dataDiskCaching
        diskSizeGB: dataDiskSize
        lun: j
        name: '${dnsVmName}-DataDisk${j}'
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }]
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
    networkProfile: {
      networkInterfaces: [
        {
          id: dnsVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(blobStorageAccountId).primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    blobStorageAccountBlobPrivateEndpoint
  ]
}

resource dnsVmGuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (deployCustomDnsForwarder && ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true)))) {
  parent: dnsVm
  name: 'GuestAttestation'
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
}

resource dnsVmCustomScript 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (deployCustomDnsForwarder) {
  parent: dnsVm
  name: 'CustomScript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        dnsVmScriptFileUri
      ]
      commandToExecute: './${dnsVmScriptFileName}'
    }
  }
}

resource dnsVmAzureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (deployCustomDnsForwarder) {
  parent: dnsVm
  name: '${dnsVmName}-AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource devVmNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: devVmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', devVnetName, devVnetDefaultSubnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    devVnet
  ]
}

resource devContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: devContributorRoleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: devVm.identity.principalId
  }
}

resource devStorageBlobDataContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: devStorageBlobDataContributorRoleAssignmentName
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: devVm.identity.principalId
  }
}

resource devVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: devVmName
  location: location
  tags: {
      AzSecPackAutoConfigReady: true
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: devVmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${devVmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: osDiskSize
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }
      dataDisks: [for j in range(0, numDataDisks): {
        caching: dataDiskCaching
        diskSizeGB: dataDiskSize
        lun: j
        name: '${devVmName}-DataDisk${j}'
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }]
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
    networkProfile: {
      networkInterfaces: [
        {
          id: devVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(blobStorageAccountId).primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    adlsStorageAccountAdlsPrivateEndpoint
    adlsStorageAccountBlobPrivateEndpoint
    blobStorageAccountBlobPrivateEndpoint
  ]
}

resource devVmGuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: devVm
  name: 'GuestAttestation'
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
}

resource devVmCustomScript 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: devVm
  name: 'CustomScript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
      timestamp: 123456789
      fileUris: [
        testVmScriptFileUri
      ]
    }
    protectedSettings: {
      commandToExecute: 'bash ${testVmScriptFileName} ${privateDnsZoneName} ${devVmName} ${prodVmName} ${adlsServicePrimaryEndpoint} ${blobServicePrimaryEndpoint}'
    }
  }
  dependsOn: [
    devContributorRoleAssignmentGuid
    devStorageBlobDataContributorRoleAssignmentGuid
    firewallPolicyDefaultNetworkRuleCollectionGroup
  ]
}

resource devVmAzureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: devVm
  name: '${devVmName}-AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource prodVmNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: prodVmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', prodVnetName, prodVnetDefaultSubnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    prodVnet
  ]
}

resource prodContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: prodContributorRoleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: prodVm.identity.principalId
  }
}

resource prodStorageBlobDataContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: prodStorageBlobDataContributorRoleAssignmentName
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: prodVm.identity.principalId
  }
}

resource prodVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: prodVmName
  location: location
  tags: {
      AzSecPackAutoConfigReady: true
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: prodVmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${prodVmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: osDiskSize
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }
      dataDisks: [for j in range(0, numDataDisks): {
        caching: dataDiskCaching
        diskSizeGB: dataDiskSize
        lun: j
        name: '${prodVmName}-DataDisk${j}'
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }]
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
    networkProfile: {
      networkInterfaces: [
        {
          id: prodVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(blobStorageAccountId).primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    adlsStorageAccountAdlsPrivateEndpoint
    adlsStorageAccountBlobPrivateEndpoint
    blobStorageAccountBlobPrivateEndpoint
  ]
}

resource prodVmGuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: prodVm
  name: 'GuestAttestation'
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
}

resource prodVmCustomScript 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: prodVm
  name: 'CustomScript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
      timestamp: 123456789
      fileUris: [
        testVmScriptFileUri
      ]
    }
    protectedSettings: {
      commandToExecute: 'bash ${testVmScriptFileName} ${privateDnsZoneName} ${devVmName} ${prodVmName} ${adlsServicePrimaryEndpoint} ${blobServicePrimaryEndpoint}'
    }
  }
  dependsOn: [
    prodContributorRoleAssignmentGuid
    prodStorageBlobDataContributorRoleAssignmentGuid
    firewallPolicyDefaultNetworkRuleCollectionGroup
  ]
}

resource prodVmAzureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: prodVm
  name: '${prodVmName}-AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = [for i in range(0, numberOfFirewallPublicIPAddresses): {
  name: ((numberOfFirewallPublicIPAddresses == 1) ? firewallPublicIPNamePrefix : '${firewallPublicIPNamePrefix}${i + 1}')
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}]

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    dnsSettings: {
      enableProxy: true
      servers: (deployCustomDnsForwarder ? [
        dnsVmNic.properties.ipConfigurations[0].properties.privateIPAddress
      ] : [])
    }
    threatIntelMode: 'Alert'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: firewallName
  location: location
  zones: ((length(firewallAvailabilityZones) == 0) ? null : firewallAvailabilityZones)
  properties: {
    ipConfigurations: [for j in range(0, numberOfFirewallPublicIPAddresses): {
      name: ((numberOfFirewallPublicIPAddresses == 1) ? 'IpConfiguration' : 'IpConfiguration${j}')
      properties: {
        subnet: ((j == 0) ? azureFirewallSubnetJSON : null)
        publicIPAddress: {
          id: ((numberOfFirewallPublicIPAddresses == 1) ? azureFirewallPublicIpId : '${azureFirewallPublicIpId}${j + 1}')
        }
      }
    }]
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
  dependsOn: [
    hubVnet
    firewallPublicIp
  ]
}

resource firewallPolicyDefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  name: firewallPolicyDefaultNetworkRuleCollectionGroupName
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'VnetToVnetNetworkRules'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow-${devVnetName}-${devVnetDefaultSubnetName}-To-${prodVnetName}-${prodVnetDefaultSubnetName}-Traffic'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              prodVnetAddressPrefix
            ]
            destinationAddresses: [
              devVnetAddressPrefix
            ]
            destinationPorts: [
              '*'
            ]
          }
          {
            name: 'Allow-${prodVnetName}-${prodVnetDefaultSubnetName}-To-${devVnetName}-${devVnetDefaultSubnetName}-Traffic'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              devVnetAddressPrefix
            ]
            destinationAddresses: [
              prodVnetAddressPrefix
            ]
            destinationPorts: [
              '*'
            ]
          }
        ]
      }
      {
        name: 'VnetToInternet'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow-${hubVnetName}-${hubVnetCommonSubnetName}-Internet-Traffic'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              hubVnetCommonSubnetPrefix
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
          {
            name: 'Allow-${prodVnetName}-${prodVnetDefaultSubnetName}-Internet-Traffic'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              prodVNetDefaultSubnetPrefix
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
          {
            name: 'Allow-${devVnetName}-${devVnetDefaultSubnetName}-Internet-Traffic'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              devVNetDefaultSubnetPrefix
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
        ]
      }
    ]
  }
  dependsOn: [
    firewallPolicy
    firewall
    hubVnet
    devVnet
    prodVnet
  ]
}

resource firewallPolicyDefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = if (createDnatRuleCollection) {
  name: firewallPolicyDefaultDnatRuleCollectionGroupName
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'VirtualMachineNatRules'
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        priority: 300
        action: {
          type: 'Dnat'
        }
        rules: [
          {
            name: '${devVmName}-Rdp-Nat-Rule'
            ruleType: 'NatRule'
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              firewallPublicIp[0].properties.ipAddress
            ]
            destinationPorts: [
              '4001'
            ]
            ipProtocols: [
              'TCP'
            ]
            translatedAddress: devVmNic.properties.ipConfigurations[0].properties.privateIPAddress
            translatedPort: '22'
          }
          {
            name: '${prodVmName}-Rdp-Nat-Rule'
            ruleType: 'NatRule'
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              firewallPublicIp[0].properties.ipAddress
            ]
            destinationPorts: [
              '4002'
            ]
            ipProtocols: [
              'TCP'
            ]
            translatedAddress: prodVmNic.properties.ipConfigurations[0].properties.privateIPAddress
            translatedPort: '22'
          }
        ]
      }
    ]
  }
  dependsOn: [
    firewallPolicy
    firewall
    firewallPolicyDefaultNetworkRuleCollectionGroup
  ]
}

resource devVnetDefaultSubnetRouteTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: devVnetDefaultSubnetRouteTableName
  location: location
  properties: {
    disableBgpRoutePropagation: (!enableBgp)
    routes: [
      {
        name: 'RouteTrafficTo${firewallName}'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource prodVnetDefaultSubnetRouteTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: prodVnetDefaultSubnetRouteTableName
  location: location
  properties: {
    disableBgpRoutePropagation: (!enableBgp)
    routes: [
      {
        name: 'RouteTrafficTo${firewallName}'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource linkToProdVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'LinkTo${prodVnetName}'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: prodVnet.id
    }
  }
}

resource linkToHubVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'LinkTo${hubVnetName}'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource linkToDevVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'LinkTo${devVnetName}'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: devVnet.id
    }
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: workspaceSku
    }
  }
}

resource agentHealthAssessmentWorkspace 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  location: location
  name: 'AgentHealthAssessment(${workspaceName})'
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'AgentHealthAssessment(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/AgentHealthAssessment'
    promotionCode: ''
  }
}

resource infrastructureInsightsWorkspace 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  location: location
  name: 'InfrastructureInsights(${workspaceName})'
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'InfrastructureInsights(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/InfrastructureInsights'
    promotionCode: ''
  }
}

resource workspaceKern 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'Kern'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: 'kern'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
    ]
  }
}

resource workspaceSyslog 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'Syslog'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: 'syslog'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
    ]
  }
}

resource workspaceUser 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'User'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: 'user'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
    ]
  }
}

resource workspaceSampleSyslogCollection1 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'SampleSyslogCollection1'
  kind: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}

resource workspaceDiskPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'DiskPerfCounters'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: '% Used Inodes'
      }
      {
        counterName: 'Free Megabytes'
      }
      {
        counterName: '% Used Space'
      }
      {
        counterName: 'Disk Transfers/sec'
      }
      {
        counterName: 'Disk Reads/sec'
      }
      {
        counterName: 'Disk Writes/sec'
      }
      {
        counterName: 'Disk Read Bytes/sec'
      }
      {
        counterName: 'Disk Write Bytes/sec'
      }
    ]
    objectName: 'Logical Disk'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource workspaceProcessorPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'ProcessorPerfCounters'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: '% Processor Time'
      }
      {
        counterName: '% User Time'
      }
      {
        counterName: '% Privileged Time'
      }
      {
        counterName: '% IO Wait Time'
      }
      {
        counterName: '% Idle Time'
      }
      {
        counterName: '% Interrupt Time'
      }
    ]
    objectName: 'Processor'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource workspaceProcessPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'ProcessPerfCounters'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: '% User Time'
      }
      {
        counterName: '% Privileged Time'
      }
      {
        counterName: 'Used Memory'
      }
      {
        counterName: 'Virtual Shared Memory'
      }
    ]
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource workspaceSystemPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'SystemPerfCounters'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: 'Processes'
      }
    ]
    objectName: 'System'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource workspaceNetworkPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'NetworkPerfCounters'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: 'Total Bytes Transmitted'
      }
      {
        counterName: 'Total Bytes Received'
      }
      {
        counterName: 'Total Bytes'
      }
      {
        counterName: 'Total Packets Transmitted'
      }
      {
        counterName: 'Total Packets Received'
      }
      {
        counterName: 'Total Rx Errors'
      }
      {
        counterName: 'Total Tx Errors'
      }
      {
        counterName: 'Total Collisions'
      }
    ]
    objectName: 'Network'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource workspaceMemorydataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'MemorydataSources'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: 'Available MBytes Memory'
      }
      {
        counterName: '% Available Memory'
      }
      {
        counterName: 'Used Memory MBytes'
      }
      {
        counterName: '% Used Memory'
      }
    ]
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource workspaceSampleLinuxPerfCollection1 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'SampleLinuxPerfCollection1'
  kind: 'LinuxPerformanceCollection'
  properties: {
    state: 'Enabled'
  }
}

resource adlsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: adlsPrivateDnsZoneName
  location: 'global'
}

resource adlsPrivateDnsZoneLinkToHubVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: adlsPrivateDnsZone
  name: 'link_to_${toLower(hubVnetName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource blobPrivateDnsZoneLinkToHubVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(hubVnetName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource adlsStorageAccountAdlsPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: adlsStorageAccountAdlsPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: adlsStorageAccountAdlsPrivateEndpointName
        properties: {
          privateLinkServiceId: adlsStorageAccountId
          groupIds: [
            adlsGroupName
          ]
        }
      }
    ]
    subnet: {
      id: hubVnetCommonSubnetId
    }
  }
  dependsOn: [
    hubVnet
  ]
}

resource adlsStorageAccountAdlsPrivateEndpointPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: adlsStorageAccountAdlsPrivateEndpoint
  name: 'PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: adlsPrivateDnsZoneId
        }
      }
    ]
  }
}

resource adlsStorageAccountBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: adlsStorageAccountBlobPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: adlsStorageAccountBlobPrivateEndpointName
        properties: {
          privateLinkServiceId: adlsStorageAccountId
          groupIds: [
            blobGroupName
          ]
        }
      }
    ]
    subnet: {
      id: hubVnetCommonSubnetId
    }
  }
  dependsOn: [
    hubVnet
  ]
}

resource adlsStorageAccountBlobPrivateEndpointPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: adlsStorageAccountBlobPrivateEndpoint
  name: 'PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZoneId
        }
      }
    ]
  }
}

resource blobStorageAccountBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: blobStorageAccountBlobPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobStorageAccountBlobPrivateEndpointName
        properties: {
          privateLinkServiceId: blobStorageAccountId
          groupIds: [
            blobGroupName
          ]
        }
      }
    ]
    subnet: {
      id: hubVnetCommonSubnetId
    }
  }
  dependsOn: [
    hubVnet
  ]
}

resource blobStorageAccountBlobPrivateEndpointPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: blobStorageAccountBlobPrivateEndpoint
  name: 'PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZoneId
        }
      }
    ]
  }
}
