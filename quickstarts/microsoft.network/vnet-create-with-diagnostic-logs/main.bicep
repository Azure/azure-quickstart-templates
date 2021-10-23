@description('Virtual network name')
param vnetName string = uniqueString(resourceGroup().id)

@description('Virtual network location')
param location string = resourceGroup().location

@description('Array containing virtual network address space(s)')
param vnetAddressSpace array = [
  '10.0.0.0/16'
]

@description('Array containing DNS Servers')
param dnsServers array = []

@description('Array containing subnets to create within the Virtual Network. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat')
param subnets array = [
  {
    name: 'subnet1'
    addressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'disabled'
    privateLinkServiceNetworkPolicies: 'disabled'
  }
]

@description('Enable delete lock')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceId string = ''

var lockName = '${vnet.name}-lck'
var diagnosticsName = '${vnet.name}-dgs'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
    dhcpOptions: empty(dnsServers) ? null : {
      dnsServers: dnsServers
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        delegations: contains(subnet, 'delegation') ? [
          {
            name: '${subnet.name}-delegation'
            properties: {
              serviceName: subnet.delegation
            }
          }
        ] : []
        natGateway: contains(subnet, 'natGatewayId') ? {
          id: subnet.natGatewayId
        } : null
        networkSecurityGroup: contains(subnet, 'nsgId') ? {
          id: subnet.nsgId
        } : null
        routeTable: contains(subnet, 'udrId') ? {
          id: subnet.udrId
        } : null
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : null
      }
    }]
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: vnet
  name: diagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: vnet
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output name string = vnet.name
output id string = vnet.id
