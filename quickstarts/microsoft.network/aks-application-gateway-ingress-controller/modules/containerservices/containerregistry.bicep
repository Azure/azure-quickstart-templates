param location string
param acrName string
param acrSku string
param acrAdminUserEnabled bool
param acrNetworkRuleSetDefaultAction string
param acrPublicNetworkAccess string
param acrPullRoleId string
param aksClusterKubeletidentityObjectId string
param workspaceId string
param acrPrivateDnsZoneName string
param virtualNetworkId string
param acrPrivateEndpointName string
param acrPrivateEndpointGroupName string
param privateEndpointSubnetId string
param acrPrivateDnsZoneGroupName string

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    networkRuleSet: {
      defaultAction: acrNetworkRuleSetDefaultAction
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 15
        status: 'enabled'
      }
    }
    publicNetworkAccess: acrPublicNetworkAccess
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: true
    networkRuleBypassOptions: 'AzureServices'
  }
}

resource acrName_acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, acr.id, 'acrPull')
  properties: {
    roleDefinitionId: acrPullRoleId
    principalId: aksClusterKubeletidentityObjectId
    principalType: 'ServicePrincipal'
  }
}

resource acrDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: acr
  name: '${acrName}-Diag'
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        timeGrain: 'PT1M'
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
    ]
  }
}

resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: acrPrivateDnsZoneName
  location: 'global'
  properties: {}
}

resource acrPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: acrPrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetworkId, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: acrPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: acrPrivateEndpointName
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            acrPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource acrPrivateEndpointPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: acrPrivateEndpoint
  name: acrPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: acrPrivateDnsZone.id
        }
      }
    ]
  }
}
