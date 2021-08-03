param createNetworkSecurityGroup bool
param newNsgName string
param location string
param networkSecurityGroupTags object
param networkSecurityGroupRules array

resource newNsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = if (createNetworkSecurityGroup) {
  name: newNsgName
  location: location
  tags: networkSecurityGroupTags
  properties: {
    securityRules: networkSecurityGroupRules
  }
}
