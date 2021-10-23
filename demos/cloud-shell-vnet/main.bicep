@description('Name of the existing VNET to inject Cloud Shell into.')
param existingVNETName string

@description('Name of Azure Relay Namespace.')
param relayNamespaceName string

@description('Object Id of Azure Container Instance Service Principal. We have to grant this permission to create hybrid connections in the Azure Relay you specify. To get it: Get-AzADServicePrincipal -DisplayNameBeginsWith \'Azure Container Instance\'')
param azureContainerInstanceOID string

@description('Name of the subnet to use for cloud shell containers.')
param containerSubnetName string = 'cloudshellsubnet'

@description('Address space of the subnet to add for cloud shell. e.g. 10.0.1.0/26')
param containerSubnetAddressPrefix string

@description('Name of the subnet to use for private link of relay namespace.')
param relaySubnetName string = 'relaysubnet'

@description('Address space of the subnet to add for relay. e.g. 10.0.2.0/26')
param relaySubnetAddressPrefix string

@description('Name of the subnet to use for storage account.')
param storageSubnetName string = 'storagesubnet'

@description('Address space of the subnet to add for storage. e.g. 10.0.3.0/26')
param storageSubnetAddressPrefix string

@description('Name of Private Endpoint for Azure Relay.')
param privateEndpointName string = 'cloudshellRelayEndpoint'

@description('Location for all resources.')
param location string = resourceGroup().location

var networkProfileName = 'aci-networkProfile-${location}'
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var networkRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var privateDnsZoneName = ((toLower(environment().name) == 'azureusgovernment') ? 'privatelink.servicebus.usgovcloudapi.net' : 'privatelink.servicebus.windows.net')
var vnetResourceId = resourceId('Microsoft.Network/virtualNetworks', existingVNETName)

resource existingVNET 'Microsoft.Network/virtualNetworks@2020-04-01' existing = {
  name: existingVNETName
}

resource containerSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = {
  parent: existingVNET
  name: containerSubnetName
  properties: {
    addressPrefix: containerSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          location
        ]
      }
    ]
    delegations: [
      {
        name: 'CloudShellDelegation'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}

resource networkProfile 'Microsoft.Network/networkProfiles@2019-11-01' = {
  name: networkProfileName
  location: location
  properties: {
    containerNetworkInterfaceConfigurations: [
      {
        name: 'eth-${containerSubnetName}'
        properties: {
          ipConfigurations: [
            {
              name: 'ipconfig-${containerSubnetName}'
              properties: {
                subnet: {
                  id: containerSubnet.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

resource networkProfile_roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: networkProfile
  name: guid(networkRoleDefinitionId, azureContainerInstanceOID, networkProfile.name)
  properties: {
    roleDefinitionId: networkRoleDefinitionId
    principalId: azureContainerInstanceOID
  }
}

resource relayNamespace 'Microsoft.Relay/namespaces@2018-01-01-preview' = {
  name: relayNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource relayNamespace_roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: relayNamespace
  name: guid(contributorRoleDefinitionId, azureContainerInstanceOID, relayNamespace.name)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: azureContainerInstanceOID
  }
}

resource relaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = {
  parent: existingVNET
  name: relaySubnetName
  properties: {
    addressPrefix: relaySubnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    containerSubnet
  ]
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: relayNamespace.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
    subnet: {
      id: relaySubnet.id
    }
  }
}

resource storageSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = {
  parent: existingVNET
  name: storageSubnetName
  properties: {
    addressPrefix: storageSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          location
        ]
      }
    ]
  }
  dependsOn: [
    relaySubnet
  ]
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-01-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneARecord 'Microsoft.Network/privateDnsZones/A@2020-01-01' = {
  parent: privateDnsZone
  name: relayNamespaceName
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: first(first(privateEndpoint.properties.customDnsConfigs).ipAddresses)
      }
    ]
  }
}

resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  parent: privateDnsZone
  name: relayNamespaceName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetResourceId
    }
  }
}

output vnetId string = vnetResourceId
output containerSubnetId string = containerSubnet.id
output storageSubnetId string = storageSubnet.id
