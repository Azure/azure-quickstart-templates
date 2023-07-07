@description('Name of Internet Gateway Rule Name')
param internetGatewayRuleName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string = ''

@description('Rules for the InternetGateways')
param ruleProperties object

@description('Create Internet Gateway Rule Resource')
resource internetGatewayRule 'Microsoft.ManagedNetworkFabric/internetGatewayRules@2023-06-15' = {
  name: internetGatewayRuleName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    ruleProperties: {
      action: ruleProperties.action
      addressList: ruleProperties.addressList
    }
  }
}

output resourceID string = internetGatewayRule.id
