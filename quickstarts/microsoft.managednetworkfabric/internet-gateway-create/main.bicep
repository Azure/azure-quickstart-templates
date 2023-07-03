@description('Name of Internet Gateway Name')
param internetGatewayName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('Gateway Type of the resource')
@allowed([
  'Infrastructure'
  'Workload'
])
param type string

@description('ARM Resource ID of the Network Fabric Controller')
param networkFabricControllerId string

@description('ARM Resource ID of the Internet Gateway Rule')
param internetGatewayRuleId string

@description('Create Internet Gateway Resource')
resource internetGateway 'Microsoft.ManagedNetworkFabric/internetGateways@2023-06-15' = {
  name: internetGatewayName
  location: location
  properties: {
    annotation: annotation
    type: type
    networkFabricControllerId: networkFabricControllerId
    internetGatewayRuleId: internetGatewayRuleId
  }
}

output resourceID string = internetGateway.id
