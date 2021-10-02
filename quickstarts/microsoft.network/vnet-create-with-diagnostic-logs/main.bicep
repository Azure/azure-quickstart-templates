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

@description('Array containing subnets to create within the Virtual Network')
@metadata({
  name: 'Subnet name'
  addressPrefix: 'Subnet address prefix'
  delegation: 'The name of the service to whom the subnet should be delegated (e.g. Microsoft.Web/serverFarms)'
  natGatewayId: 'Resource id of the NAT gateway to associate to subnet'
  nsgId: 'Resource id of the Network Security Group to associate to subnet'
  udrId: 'Resource id of the Route Table to associate to subnet'
  privateEndpointNetworkPolicies: 'Enable or disable Private Endpoint network policies on subnet'
  privateLinkServiceNetworkPolicies: 'Enable or disable PrivateLink service network policies on subnet'
  serviceEndpoints: [
    {
      service: 'The type of the endpoint service'
    }
  ]
})
param subnets array = [
  {
    name: 'subnet1'
    addressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'disabled'
    privateLinkServiceNetworkPolicies: 'disabled'
    delegation: 'Microsoft.Web/serverFarms'
    natgatewayId: null
    nsgId: null
    udrId: null
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
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
        delegations: empty(subnet.delegation) ? [] : [
          {
            name: '${subnet.name}-delegation'
            properties: {
              serviceName: subnet.delegation
            }
          }
        ]
        natGateway: empty(subnet.natGatewayId) ? null : {
          id: subnet.natGatewayId
        }
        networkSecurityGroup: empty(subnet.nsgId) ? null : {
          id: subnet.nsgId
        }
        routeTable: empty(subnet.udrId) ? null : {
          id: subnet.udrId
        }
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        serviceEndpoints: empty(subnet.serviceEndpoints) ? null : subnet.serviceEndpoints
      }
    }]
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (enableDiagnostics) {
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

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: vnet
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output name string = vnet.name
output id string = vnet.id
