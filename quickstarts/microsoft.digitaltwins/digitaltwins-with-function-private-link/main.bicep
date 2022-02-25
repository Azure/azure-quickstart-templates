@description('The location into which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

@description('Azure Digital Twins instance name')
param digitalTwinsInstanceName string = 'digitaltwins-${uniqueString(resourceGroup().name)}'

@description('Azure Function name')
@maxLength(16)
param functionName string

@description('Virtual Network name')
param virtualNetworkName string

@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.0.0.0/22'

@description('Function Subnet Address Prefix')
param functionAddressPrefix string = '10.0.0.0/24'

@description('Private Link Subnet Address Prefix')
param privateLinkAddressPrefix string = '10.0.1.0/24'

var privateLinkSubnetName = 'PrivateLinkSubnet'
var functionSubnetName = 'FunctionSubnet'
var roleId = 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'

module digitaltwins 'modules/digitaltwins.bicep' = {
  name: 'digitaltwins'
  params: {
    digitalTwinsInstanceName: digitalTwinsInstanceName
    digitalTwinsInstanceLocation: location
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkLocation: location
    virtualNetworkAddressPrefix: vnetAddressPrefix
    functionSubnetName: functionSubnetName
    functionSubnetPrefix: functionAddressPrefix
    privateLinkSubnetName: privateLinkSubnetName
    privateLinkSubnetPrefix: privateLinkAddressPrefix
  }
}

module privatelink 'modules/privatelink.bicep' = {
  name: 'privatelink'
  params: {
    privateLinkName: 'PrivateLinkToDigitalTwins'
    location: location
    privateLinkServiceResourceId: digitaltwins.outputs.id
    groupId: 'API'
    privateLinkSubnetName: privateLinkSubnetName
    privateDnsZoneName: 'privatelink.digitaltwins.azure.net'
    virtualNetworkResourceName: virtualNetworkName
  }
}

module function 'modules/function.bicep' = {
  name: 'function'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    storageAccoutName: '${toLower(functionName)}stg'
    functionAppName: '${functionName}func'
    serverFarmName: functionName
    functionsSubnetName: functionSubnetName
    applicationInsightsName: '${functionName}ai'
    digitalTwinsEndpoint: digitaltwins.outputs.endpoint
  }
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: '${guid(uniqueString('roleAssignment-', digitalTwinsInstanceName, '-', function.name, '-', roleId))}'
  properties: {
    principalId: function.outputs.functionIdentityPrincipalId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleId}'
  }
}
