targetScope = 'resourceGroup'

@description('Azure region for the managed instance and its network resources.')
param location string = resourceGroup().location

@description('Name of the free Azure SQL Managed Instance.')
@minLength(1)
@maxLength(63)
param managedInstanceName string = 'sqlmi-free-${uniqueString(resourceGroup().id)}'

@description('Name of the virtual network dedicated to this managed instance.')
param virtualNetworkName string = 'vnet-sqlmi-free-${uniqueString(resourceGroup().id)}'

@description('Address space for the dedicated virtual network.')
param virtualNetworkAddressPrefix string = '10.0.0.0/16'

@description('Subnet range for the managed instance. SQL Managed Instance requires at least a /27 subnet.')
param managedInstanceSubnetPrefix string = '10.0.0.0/27'

@description('Create the dedicated virtual network, NSG, route table, and delegated subnet. Set to false only when reusing the matching network created by an earlier deployment in this resource group.')
param deployNetwork bool = true

@description('Public IPv4 address of the client that may connect to the public endpoint. The NSG rule restricts it to a /32.')
@minLength(7)
@maxLength(15)
param clientIPv4Address string

@description('SQL administrator login required by the managed instance create API. SQL authentication is disabled after provisioning.')
@minLength(1)
@maxLength(128)
param sqlAdministratorLogin string

@description('Strong SQL administrator password required by the managed instance create API. It is not usable after Entra-only authentication is enabled.')
@secure()
@minLength(8)
@maxLength(128)
param sqlAdministratorPassword string

@description('Login name (typically the user principal name) of the Microsoft Entra administrator.')
@minLength(1)
@maxLength(128)
param entraAdministratorLogin string

@description('Object ID (GUID) of the Microsoft Entra user who will administer the instance.')
@minLength(36)
@maxLength(36)
param entraAdministratorObjectId string

var managedInstanceSubnetName = 'ManagedInstance'
var networkSecurityGroupName = '${managedInstanceName}-nsg'
var routeTableName = '${managedInstanceName}-rt'
var weekdays = [
  'Monday'
  'Tuesday'
  'Wednesday'
  'Thursday'
  'Friday'
]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-07-01' = if (deployNetwork) {
  name: networkSecurityGroupName
  location: location
  properties: {}
}

resource clientPublicEndpointRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = if (deployNetwork) {
  parent: networkSecurityGroup
  name: 'AllowClientToPublicEndpoint'
  properties: {
    description: 'Allow only the supplied client IPv4 /32 to the SQL Managed Instance public endpoint.'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3342'
    sourceAddressPrefix: '${clientIPv4Address}/32'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
  }
}

resource virtualNetworkSqlRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = if (deployNetwork) {
  parent: networkSecurityGroup
  name: 'AllowVirtualNetworkSql'
  properties: {
    description: 'Allow SQL traffic from the virtual network to the VNet-local endpoint.'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 110
    direction: 'Inbound'
  }
}

resource virtualNetworkRedirectRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = if (deployNetwork) {
  parent: networkSecurityGroup
  name: 'AllowVirtualNetworkRedirect'
  properties: {
    description: 'Allow redirect traffic between clients and the instance inside the virtual network.'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '11000-11999'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 120
    direction: 'Inbound'
  }
}

resource routeTable 'Microsoft.Network/routeTables@2024-07-01' = if (deployNetwork) {
  name: routeTableName
  location: location
  properties: {}
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = if (deployNetwork) {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
  }
}

resource managedInstanceSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = if (deployNetwork) {
  parent: virtualNetwork
  name: managedInstanceSubnetName
  properties: {
    addressPrefix: managedInstanceSubnetPrefix
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
    }
    routeTable: {
      id: resourceId('Microsoft.Network/routeTables', routeTableName)
    }
    delegations: [
      {
        name: 'ManagedInstanceDelegation'
        properties: {
          serviceName: 'Microsoft.Sql/managedInstances'
        }
      }
    ]
  }
  dependsOn: [
    clientPublicEndpointRule
    virtualNetworkSqlRule
    virtualNetworkRedirectRule
  ]
}

resource managedInstance 'Microsoft.Sql/managedInstances@2025-01-01' = {
  name: managedInstanceName
  location: location
  sku: {
    name: 'GP_Gen5'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      login: entraAdministratorLogin
      principalType: 'User'
      sid: entraAdministratorObjectId
      tenantId: tenant().tenantId
    }
    isGeneralPurposeV2: true
    licenseType: 'LicenseIncluded'
    pricingModel: 'Freemium'
    publicDataEndpointEnabled: true
    storageSizeInGB: 64
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, managedInstanceSubnetName)
    vCores: 4
  }
  dependsOn: [
    managedInstanceSubnet
  ]
}

resource azureADOnlyAuthentication 'Microsoft.Sql/managedInstances/azureADOnlyAuthentications@2025-01-01' = {
  parent: managedInstance
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
}

resource startStopSchedule 'Microsoft.Sql/managedInstances/startStopSchedules@2023-08-01' = {
  parent: managedInstance
  name: 'default'
  properties: {
    description: 'Free-offer workday schedule: start at 09:00 and stop at 17:00 UTC, Monday through Friday.'
    timeZoneId: 'UTC'
    scheduleList: [for day in weekdays: {
      startDay: day
      startTime: '09:00'
      stopDay: day
      stopTime: '17:00'
    }]
  }
}

output managedInstanceId string = managedInstance.id
output managedInstanceSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, managedInstanceSubnetName)
