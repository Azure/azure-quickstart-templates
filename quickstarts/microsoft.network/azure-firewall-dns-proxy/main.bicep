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

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  'Ubuntu-1804'
  'Ubuntu-2004'
  'Ubuntu-2204'
])
param imageSku string = 'Ubuntu-2004'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_D4s_v3'

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

var imageReference = {
  'Ubuntu-1804': {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2004': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2204': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }
}
var bastionPublicIpAddressName = '${bastionHostName}PublicIp'
var bastionPublicIpAddressId = bastionPublicIpAddress.id
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, bastionSubnetName)
var gatewayPublicIpName = '${gatewayName}PublicIp'
var hubVnetGatewaySubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubVnetGatewaySubnetName)
var hubVnetCommonSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubVnetCommonSubnetName)
var hubVnetFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubVnetFirewallSubnetName)
var devVnetDefaultSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', devVnetName, devVnetDefaultSubnetName)
var prodVnetDefaultSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', prodVnetName, prodVnetDefaultSubnetName)
var hubVnetId = hubVnet.id
var devVnetId = devVnet.id
var prodVnetId = prodVnet.id
var gatewayId = gateway.id
var dnsVmNicName = '${dnsVmName}Nic'
var devVmNicName = '${devVmName}Nic'
var prodVmNicName = '${prodVmName}Nic'
var dnsVmNicId = dnsVmNic.id
var devVmNicId = devVmNic.id
var prodVmNicId = prodVmNic.id
var dnsVmId = dnsVm.id
var devVmId = devVm.id
var prodVmId = prodVm.id
var gatewayPublicIpId = gatewayPublicIp.id
var hubVnetCommonSubnetNsgName = '${hubVnetName}${hubVnetCommonSubnetName}Nsg'
var hubVnetBastionSubnetNsgName = '${hubVnetName}${bastionSubnetName}Nsg'
var devVnetDefaultSubnetNsgName = '${devVnetName}${devVnetDefaultSubnetName}Nsg'
var prodVnetDefaultSubnetNsgName = '${prodVnetName}${prodVnetDefaultSubnetName}Nsg'
var hubVnetCommonSubnetNsgId = hubVnetCommonSubnetNsg.id
var hubVnetBastionSubnetNsgId = hubVnetBastionSubnetNsg.id
var devVnetDefaultSubnetNsgId = devVnetDefaultSubnetNsg.id
var prodVnetDefaultSubnetNsgId = prodVnetDefaultSubnetNsg.id
var devVnetDefaultSubnetRouteTableName = '${devVnetName}${devVnetDefaultSubnetName}RouteTable'
var prodVnetDefaultSubnetRouteTableName = '${prodVnetName}${prodVnetDefaultSubnetName}RouteTable'
var devVnetDefaultSubnetRouteTableId = devVnetDefaultSubnetRouteTable.id
var prodVnetDefaultSubnetRouteTableId = prodVnetDefaultSubnetRouteTable.id
var firewallPublicIPNamePrefix = '${firewallName}PublicIP'
var azureFirewallPublicIpId = resourceId('Microsoft.Network/publicIPAddresses', firewallPublicIPNamePrefix)
var azureFirewallSubnetJSON = json('{"id": "${hubVnetFirewallSubnetId}"}')
var firewallId = firewall.id
var privateDnsZoneId = privateDnsZone.id
var workspaceId = workspace.id
var firewallPolicyId = firewallPolicy.id
var firewallPolicyDefaultNetworkRuleCollectionGroupName = '${firewallPolicyName}/DefaultNetworkRuleCollectionGroup'
var firewallPolicyDefaultDnatRuleCollectionGroupName = '${firewallPolicyName}/DefaultDnatRuleCollectionGroup'
var firewallPolicyDefaultNetworkRuleCollectionGroupId = resourceId('Microsoft.Network/firewallPolicies/ruleCollectionGroups', firewallPolicyName, 'DefaultNetworkRuleCollectionGroup')
var devContributorRoleAssignmentGuid_var = guid('devcontributor${resourceGroup().id}${devVmName}')
var prodContributorRoleAssignmentGuid_var = guid('prodcontributor${resourceGroup().id}${prodVmName}')
var devContributorRoleAssignmentId = devContributorRoleAssignmentGuid.id
var prodContributorRoleAssignmentId = prodContributorRoleAssignmentGuid.id
var devStorageBlobDataContributorRoleAssignmentGuid_var = guid('devStorageBlobDataContributor${resourceGroup().id}${devVmName}')
var prodStorageBlobDataContributorRoleAssignmentGuid_var = guid('prodStorageBlobDataContributor${resourceGroup().id}${prodVmName}')
var devStorageBlobDataContributorRoleAssignmentId = devStorageBlobDataContributorRoleAssignmentGuid.id
var prodStorageBlobDataContributorRoleAssignmentId = prodStorageBlobDataContributorRoleAssignmentGuid.id
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var dnsCustomScriptId = dnsVmName_CustomScript.id
var devCustomScriptId = devVmName_CustomScript.id
var prodCustomScriptId = prodVmName_CustomScript.id
var dnsOmsAgentForLinuxId = dnsVmName_LogAnalytics.id
var devOmsAgentForLinuxId = devVmName_LogAnalytics.id
var prodOmsAgentForLinuxId = prodVmName_LogAnalytics.id
var dnsAvailabilitySetId = dnsAvailabilitySet.id
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
}
var adlsStorageAccountId = adlsStorageAccount.id
var blobStorageAccountId = blobStorageAccount.id
var adlsPublicDNSZoneForwarder = '.dfs.${environment().suffixes.storage}'
var blobPublicDNSZoneForwarder = '.blob.${environment().suffixes.storage}'
var adlsPrivateDnsZoneName = 'privatelink${adlsPublicDNSZoneForwarder}'
var blobPrivateDnsZoneName = 'privatelink${blobPublicDNSZoneForwarder}'
var adlsPrivateDnsZoneId = adlsPrivateDnsZone.id
var blobPrivateDnsZoneId = blobPrivateDnsZone.id
var adlsServicePrimaryEndpoint = concat(adlsStorageAccountName, adlsPublicDNSZoneForwarder)
var blobServicePrimaryEndpoint = concat(blobStorageAccountName, blobPublicDNSZoneForwarder)
var adlsStorageAccountAdlsPrivateEndpointId = adlsStorageAccountAdlsPrivateEndpoint.id
var adlsStorageAccountBlobPrivateEndpointId = adlsStorageAccountBlobPrivateEndpoint.id
var blobStorageAccountBlobPrivateEndpointId = blobStorageAccountBlobPrivateEndpoint.id
var adlsGroupName = 'dfs'
var blobGroupName = 'blob'
var dnsVmScriptFileName = 'configure-custom-dns-forwarder.sh'
var testVmScriptFileName = 'test-dns-and-private-endpoints.sh'
var dnsVmScriptFileUri = uri(_artifactsLocation, 'scripts/${dnsVmScriptFileName}${_artifactsLocationSasToken}')
var testVmScriptFileUri = uri(_artifactsLocation, 'scripts/${testVmScriptFileName}${_artifactsLocationSasToken}')
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
var maaEndpoint = substring('emptystring', 0, 0)


resource adlsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
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

resource blobStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
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

resource hubVnetCommonSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: hubVnetCommonSubnetNsgName
  location: location
}

resource hubVnetCommonSubnetNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${hubVnetCommonSubnetNsgName}/Microsoft.Insights/default'
  location: location
  properties: {
    workspaceId: workspaceId
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
  dependsOn: [
    hubVnetCommonSubnetNsgId
    workspaceId
  ]
}

resource devVnetDefaultSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: devVnetDefaultSubnetNsgName
  location: location
}

resource devVnetDefaultSubnetNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${devVnetDefaultSubnetNsgName}/Microsoft.Insights/default'
  location: location
  properties: {
    workspaceId: workspaceId
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
  dependsOn: [
    devVnetDefaultSubnetNsgId
    workspaceId
  ]
}

resource prodVnetDefaultSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: prodVnetDefaultSubnetNsgName
  location: location
}

resource prodVnetDefaultSubnetNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${prodVnetDefaultSubnetNsgName}/Microsoft.Insights/default'
  location: location
  properties: {
    workspaceId: workspaceId
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
  dependsOn: [
    prodVnetDefaultSubnetNsgId
    workspaceId
  ]
}

resource hubVnetBastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
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

resource hubVnetBastionSubnetNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${hubVnetBastionSubnetNsgName}/Microsoft.Insights/default'
  location: location
  properties: {
    workspaceId: workspaceId
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
  dependsOn: [
    hubVnetBastionSubnetNsgId
    workspaceId
  ]
}

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: bastionPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConfiguration'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIpAddressId
          }
        }
      }
    ]
  }
  dependsOn: [
    bastionPublicIpAddressId
    hubVnetId
  ]
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-04-01' = {
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
            id: hubVnetCommonSubnetNsgId
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
            id: hubVnetBastionSubnetNsgId
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
  dependsOn: [
    hubVnetCommonSubnetNsgId
    hubVnetBastionSubnetNsgId
  ]
}

resource devVnet 'Microsoft.Network/virtualNetworks@2020-04-01' = {
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
        reference(firewallId).ipConfigurations[0].properties.privateIPAddress
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
            id: devVnetDefaultSubnetNsgId
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  dependsOn: [
    firewallId
    devVnetDefaultSubnetNsgId
    devVnetDefaultSubnetRouteTableId
  ]
}

resource prodVnet 'Microsoft.Network/virtualNetworks@2020-04-01' = {
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
        reference(firewallId).ipConfigurations[0].properties.privateIPAddress
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
            id: prodVnetDefaultSubnetNsgId
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  dependsOn: [
    firewallId
    prodVnetDefaultSubnetNsgId
    prodVnetDefaultSubnetRouteTableId
  ]
}

resource hubVnetName_hubVnetName_To_devVnetName_Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: hubVnet
  name: '${hubVnetName}To${devVnetName}Peering'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: deployVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: devVnetId
    }
  }
  dependsOn: [
    hubVnetId
    devVnetId
    gatewayId
  ]
}

resource hubVnetName_hubVnetName_To_prodVnetName_Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: hubVnet
  name: '${hubVnetName}To${prodVnetName}Peering'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: deployVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: prodVnetId
    }
  }
  dependsOn: [
    hubVnetId
    prodVnetId
    gatewayId
  ]
}

resource devVnetName_devVnetName_To_hubVnetName_Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: devVnet
  name: '${devVnetName}To${hubVnetName}Peering'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: deployVpnGateway
    remoteVirtualNetwork: {
      id: hubVnetId
    }
  }
  dependsOn: [
    hubVnetId
    devVnetId
    gatewayId
  ]
}

resource prodVnetName_prodVnetName_To_hubVnetName_Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: prodVnet
  name: '${prodVnetName}To${hubVnetName}Peering'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: deployVpnGateway
    remoteVirtualNetwork: {
      id: hubVnetId
    }
  }
  dependsOn: [
    hubVnetId
    prodVnetId
    gatewayId
  ]
}

resource gatewayPublicIp 'Microsoft.Network/publicIPAddresses@2020-04-01' = if (deployVpnGateway) {
  name: gatewayPublicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource gateway 'Microsoft.Network/virtualNetworkGateways@2020-04-01' = if (deployVpnGateway) {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hubVnetGatewaySubnetId
          }
          publicIPAddress: {
            id: gatewayPublicIpId
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
    gatewayPublicIpId
    hubVnetId
  ]
}

resource dnsAvailabilitySet 'Microsoft.Compute/availabilitySets@2019-12-01' = if (deployCustomDnsForwarder) {
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

resource dnsVmNic 'Microsoft.Network/networkInterfaces@2020-07-01' = if (deployCustomDnsForwarder) {
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
    hubVnetId
  ]
}

resource dnsVm 'Microsoft.Compute/virtualMachines@2020-06-01' = if (deployCustomDnsForwarder) {
  name: dnsVmName
  location: location
  properties: {
    availabilitySet: {
      id: dnsAvailabilitySetId
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: dnsVmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: imageReference[imageSku]
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
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : json('null'))
  }
  dependsOn: [
    dnsAvailabilitySetId
    blobStorageAccountBlobPrivateEndpointId
    dnsVmNicId
  ]
}

resource dnsVmName_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (deployCustomDnsForwarder) {
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
  dependsOn: [
    dnsVmId
  ]
}

resource dnsVmName_LogAnalytics 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (deployCustomDnsForwarder) {
  parent: dnsVm
  name: 'LogAnalytics'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.12'
    settings: {
      workspaceId: reference(workspaceId, '2020-03-01-preview').customerId
      stopOnMultipleConnections: false
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, '2020-03-01-preview').primarySharedKey
    }
  }
  dependsOn: [
    dnsVmId
    workspaceId
    dnsCustomScriptId
  ]
}

resource dnsVmName_DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (deployCustomDnsForwarder) {
  parent: dnsVm
  name: 'DependencyAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    dnsVmId
    workspaceId
    dnsCustomScriptId
    dnsOmsAgentForLinuxId
  ]
}

resource vmExtensiondnsVm 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: dnsVm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
      }
    }
  }
}

resource devVmNic 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: devVmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: devVnetDefaultSubnetId
          }
        }
      }
    ]
  }
  dependsOn: [
    devVnetId
  ]
}

resource devContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: devContributorRoleAssignmentGuid_var
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: reference(devVmId, '2020-06-01', 'Full').identity.principalId
    scope: resourceGroup().id
  }
  dependsOn: [
    devVmId
  ]
}

resource devStorageBlobDataContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: devStorageBlobDataContributorRoleAssignmentGuid_var
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: reference(devVmId, '2020-06-01', 'Full').identity.principalId
    scope: resourceGroup().id
  }
  dependsOn: [
    devVmId
  ]
}

resource devVm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: devVmName
  location: location
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
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: imageReference[imageSku]
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
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : json('null'))
  }
  dependsOn: [
    adlsStorageAccountAdlsPrivateEndpointId
    adlsStorageAccountBlobPrivateEndpointId
    blobStorageAccountBlobPrivateEndpointId
    devVmNicId
  ]
}

resource devVmName_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
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
    devVmId
    devContributorRoleAssignmentId
    devStorageBlobDataContributorRoleAssignmentId
    firewallPolicyDefaultNetworkRuleCollectionGroupId
  ]
}

resource devVmName_LogAnalytics 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: devVm
  name: 'LogAnalytics'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.12'
    settings: {
      workspaceId: reference(workspaceId, '2020-03-01-preview').customerId
      stopOnMultipleConnections: false
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, '2020-03-01-preview').primarySharedKey
    }
  }
  dependsOn: [
    devVmId
    workspaceId
    devCustomScriptId
  ]
}

resource devVmName_DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: devVm
  name: 'DependencyAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    devVmId
    workspaceId
    devCustomScriptId
    devOmsAgentForLinuxId
  ]
}

resource vmExtensiondevVm 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: devVm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
      }
    }
  }
}

resource prodVmNic 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: prodVmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: prodVnetDefaultSubnetId
          }
        }
      }
    ]
  }
  dependsOn: [
    prodVnetId
  ]
}

resource prodContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: prodContributorRoleAssignmentGuid_var
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: reference(prodVmId, '2020-06-01', 'Full').identity.principalId
    scope: resourceGroup().id
  }
  dependsOn: [
    prodVmId
  ]
}

resource prodStorageBlobDataContributorRoleAssignmentGuid 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: prodStorageBlobDataContributorRoleAssignmentGuid_var
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: reference(prodVmId, '2020-06-01', 'Full').identity.principalId
    scope: resourceGroup().id
  }
  dependsOn: [
    prodVmId
  ]
}

resource prodVm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: prodVmName
  location: location
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
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: imageReference[imageSku]
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
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : json('null'))
  }
  dependsOn: [
    adlsStorageAccountAdlsPrivateEndpointId
    adlsStorageAccountBlobPrivateEndpointId
    blobStorageAccountBlobPrivateEndpointId
    prodVmNicId
  ]
}

resource prodVmName_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
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
    prodVmId
    prodContributorRoleAssignmentId
    prodStorageBlobDataContributorRoleAssignmentId
    firewallPolicyDefaultNetworkRuleCollectionGroupId
  ]
}

resource prodVmName_LogAnalytics 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: prodVm
  name: 'LogAnalytics'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.12'
    settings: {
      workspaceId: reference(workspaceId, '2020-03-01-preview').customerId
      stopOnMultipleConnections: false
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, '2020-03-01-preview').primarySharedKey
    }
  }
  dependsOn: [
    prodVmId
    workspaceId
    prodCustomScriptId
  ]
}

resource prodVmName_DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: prodVm
  name: 'DependencyAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    prodVmId
    workspaceId
    prodCustomScriptId
    prodOmsAgentForLinuxId
  ]
}

resource vmExtensionprodVm 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: prodVm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
      }
    }
  }
}

resource numberOfFirewallPublicIPAddresses_1_firewallPublicIPNamePrefix_firewallPublicIPNamePrefix_1 'Microsoft.Network/publicIPAddresses@2020-04-01' = [for i in range(0, numberOfFirewallPublicIPAddresses): {
  name: ((numberOfFirewallPublicIPAddresses == 1) ? firewallPublicIPNamePrefix : concat(firewallPublicIPNamePrefix, (i + 1)))
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}]

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2020-07-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    dnsSettings: {
      enableProxy: true
      servers: (deployCustomDnsForwarder ? [
        reference(dnsVmNicId).ipConfigurations[0].properties.privateIPAddress
      ] : [])
    }
    threatIntelMode: 'Alert'
  }
  dependsOn: [
    dnsVmNicId
  ]
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-07-01' = {
  name: firewallName
  location: location
  zones: ((length(firewallAvailabilityZones) == 0) ? json('null') : firewallAvailabilityZones)
  properties: {
    ipConfigurations: [for j in range(0, numberOfFirewallPublicIPAddresses): {
      name: ((numberOfFirewallPublicIPAddresses == 1) ? 'IpConfiguration' : 'IpConfiguration${j}')
      properties: {
        subnet: ((j == 0) ? azureFirewallSubnetJSON : json('null'))
        publicIPAddress: {
          id: ((numberOfFirewallPublicIPAddresses == 1) ? azureFirewallPublicIpId : concat(azureFirewallPublicIpId, (j + 1)))
        }
      }
    }]
    firewallPolicy: {
      id: firewallPolicyId
    }
  }
  dependsOn: [
    firewallPolicyId
    hubVnetId
    numberOfFirewallPublicIPAddresses_1_firewallPublicIPNamePrefix_firewallPublicIPNamePrefix_1
  ]
}

resource firewallPolicyDefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-07-01' = {
  name: firewallPolicyDefaultNetworkRuleCollectionGroupName
  properties: {
    priority: '200'
    ruleCollections: [
      {
        name: 'VnetToVnetNetworkRules'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: '100'
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
        priority: '200'
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
    firewallPolicyId
    firewallId
    hubVnetId
    devVnetId
    prodVnetId
  ]
}

resource firewallPolicyDefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-07-01' = if (createDnatRuleCollection) {
  name: firewallPolicyDefaultDnatRuleCollectionGroupName
  properties: {
    priority: '100'
    ruleCollections: [
      {
        name: 'VirtualMachineNatRules'
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        priority: '300'
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
              numberOfFirewallPublicIPAddresses_1_firewallPublicIPNamePrefix_firewallPublicIPNamePrefix_1.properties.ipAddress
            ]
            destinationPorts: [
              '4001'
            ]
            ipProtocols: [
              'TCP'
            ]
            translatedAddress: reference(devVmNicId).ipConfigurations[0].properties.privateIPAddress
            translatedPort: '22'
          }
          {
            name: '${prodVmName}-Rdp-Nat-Rule'
            ruleType: 'NatRule'
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              numberOfFirewallPublicIPAddresses_1_firewallPublicIPNamePrefix_firewallPublicIPNamePrefix_1.properties.ipAddress
            ]
            destinationPorts: [
              '4002'
            ]
            ipProtocols: [
              'TCP'
            ]
            translatedAddress: reference(prodVmNicId).ipConfigurations[0].properties.privateIPAddress
            translatedPort: '22'
          }
        ]
      }
    ]
  }
  dependsOn: [
    firewallPolicyId
    firewallId
    firewallPolicyDefaultNetworkRuleCollectionGroupId
    devVmNicId
    prodVmNicId
  ]
}

resource devVnetDefaultSubnetRouteTable 'Microsoft.Network/routeTables@2020-06-01' = {
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
          nextHopIpAddress: reference(firewallId).ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
  dependsOn: [
    firewallId
  ]
}

resource prodVnetDefaultSubnetRouteTable 'Microsoft.Network/routeTables@2020-06-01' = {
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
          nextHopIpAddress: reference(firewallId).ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
  dependsOn: [
    firewallId
  ]
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
  }
}

resource privateDnsZoneName_LinkTo_prodVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'LinkTo${prodVnetName}'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: prodVnetId
    }
  }
  dependsOn: [
    privateDnsZoneId
    prodVnetId
  ]
}

resource privateDnsZoneName_LinkTo_hubVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'LinkTo${hubVnetName}'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: hubVnetId
    }
  }
  dependsOn: [
    privateDnsZoneId
    hubVnetId
  ]
}

resource privateDnsZoneName_LinkTo_devVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'LinkTo${devVnetName}'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: devVnetId
    }
  }
  dependsOn: [
    privateDnsZoneId
    devVnetId
  ]
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: workspaceSku
    }
  }
}

resource workspaceName_AgentHealthAssessment_workspace 'Microsoft.OperationalInsights/workspaces/Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  location: location
  name: '${workspaceName}/AgentHealthAssessment(${workspaceName})'
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'AgentHealthAssessment(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/AgentHealthAssessment'
    promotionCode: ''
  }
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_InfrastructureInsights_workspace 'Microsoft.OperationalInsights/workspaces/Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  location: location
  name: '${workspaceName}/InfrastructureInsights(${workspaceName})'
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'InfrastructureInsights(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/InfrastructureInsights'
    promotionCode: ''
  }
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_Kern 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_Syslog 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_User 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_SampleSyslogCollection1 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'SampleSyslogCollection1'
  kind: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_DiskPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_ProcessorPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_ProcessPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_SystemPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_NetworkPerfCounters 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_MemorydataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
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
  dependsOn: [
    workspaceId
  ]
}

resource workspaceName_SampleLinuxPerfCollection1 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace
  name: 'SampleLinuxPerfCollection1'
  kind: 'LinuxPerformanceCollection'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    workspaceId
  ]
}

resource adlsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: adlsPrivateDnsZoneName
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
  }
}

resource adlsPrivateDnsZoneName_link_to_HubVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: adlsPrivateDnsZone
  name: 'link_to_${toLower(hubVnetName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
  dependsOn: [
    adlsPrivateDnsZoneId
    hubVnetId
  ]
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
  }
}

resource blobPrivateDnsZoneName_link_to_HubVnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(hubVnetName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
  dependsOn: [
    blobPrivateDnsZoneId
    hubVnetId
  ]
}

resource adlsStorageAccountAdlsPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
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
    hubVnetId
    adlsStorageAccountId
  ]
}

resource adlsStorageAccountAdlsPrivateEndpointName_PrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: adlsStorageAccountAdlsPrivateEndpoint
  name: 'PrivateDnsZoneGroup'
  location: location
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
  dependsOn: [
    adlsPrivateDnsZoneId
    adlsStorageAccountAdlsPrivateEndpointId
  ]
}

resource adlsStorageAccountBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
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
    hubVnetId
    adlsStorageAccountId
  ]
}

resource adlsStorageAccountBlobPrivateEndpointName_PrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: adlsStorageAccountBlobPrivateEndpoint
  name: 'PrivateDnsZoneGroup'
  location: location
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
  dependsOn: [
    blobPrivateDnsZoneId
    adlsStorageAccountBlobPrivateEndpointId
  ]
}

resource blobStorageAccountBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
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
    hubVnetId
    blobStorageAccountId
  ]
}

resource blobStorageAccountBlobPrivateEndpointName_PrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: blobStorageAccountBlobPrivateEndpoint
  name: 'PrivateDnsZoneGroup'
  location: location
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
  dependsOn: [
    blobPrivateDnsZoneId
    blobStorageAccountBlobPrivateEndpointId
  ]
}
