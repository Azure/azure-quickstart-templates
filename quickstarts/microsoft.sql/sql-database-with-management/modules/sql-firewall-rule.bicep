@description('Firewall rule')
param sqlFirewallRule object

@description('The name of the SQL Logical server.')
param sqlServerName string

resource firewallRule 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  name: '${sqlServerName}/${sqlFirewallRule.name}'
  properties: {
    startIpAddress: sqlFirewallRule.startIpAddress
    endIpAddress: sqlFirewallRule.endIpAddress
  }
}
