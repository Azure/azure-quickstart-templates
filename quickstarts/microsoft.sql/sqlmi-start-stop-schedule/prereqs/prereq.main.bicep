targetScope = 'resourceGroup'

@description('Azure region for the managed instance and its network resources.')
param location string = resourceGroup().location

@description('Deploy the dedicated network on first provisioning. Set false when reusing the matching existing network after SQL Managed Instance has added service-managed rules and routes.')
param deployNetwork bool = true

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
var managedInstanceSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, managedInstanceSubnetName)

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
  properties: {
    disableBgpRoutePropagation: false
  }
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
  dependsOn: [
    clientPublicEndpointRule
    virtualNetworkSqlRule
    virtualNetworkRedirectRule
  ]
  properties: {
    addressPrefix: managedInstanceSubnetPrefix
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    routeTable: {
      id: routeTable.id
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
}

resource managedInstance 'Microsoft.Sql/managedInstances@2025-01-01' = {
  name: managedInstanceName
  location: location
  dependsOn: [
    managedInstanceSubnet
  ]
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
    subnetId: managedInstanceSubnetId
    vCores: 4
  }
}

resource azureADOnlyAuthentication 'Microsoft.Sql/managedInstances/azureADOnlyAuthentications@2025-01-01' = {
  parent: managedInstance
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
}

output managedInstanceId string = managedInstance.id
output managedInstanceSubnetId string = managedInstanceSubnetId
