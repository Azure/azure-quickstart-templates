@description('The location into which the Azure Storage resources should be deployed.')
@allowed([
  'westcentralus'
  'westus2'
  'northeurope'
  'australiaeast'
  'westeurope'
  'eastus'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'eastus2'
])
param location string

@description('Azure Digital Twins instance name')
param digitalTwinsInstanceName string = 'digitaltwins-${uniqueString(resourceGroup().id)}'

@description('Azure function name')
@maxLength(16)
param functionName string = uniqueString(resourceGroup().id)

@description('Virtual Network name')
param virtualNetworkName string = 'vnet-${uniqueString(resourceGroup().id)}'

@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.0.0.0/22'

@description('Function Subnet Address Prefix')
param functionAddressPrefix string = '10.0.0.0/24'

@description('Private Link Subnet Address Prefix')
param privateLinkAddressPrefix string = '10.0.1.0/24'

var privateLinkSubnetName = 'PrivateLinkSubnet'
var functionSubnetName = 'FunctionSubnet'

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
    storageAccountName: '${uniqueString(resourceGroup().id)}stg'
    functionAppName: functionName
    serverFarmName: functionName
    functionsSubnetName: functionSubnetName
    applicationInsightsName: '${functionName}ai'
    digitalTwinsEndpoint: digitaltwins.outputs.endpoint
  }
}

module roleassignment 'modules/roleassignment.bicep' = {
  name: 'roleassignment'
  params: {
    principalId: function.outputs.functionIdentityPrincipalId
    roleId: 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'
    digitalTwinsInstanceName: digitalTwinsInstanceName
  }
}
