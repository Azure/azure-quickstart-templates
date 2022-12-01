param sqlServerName string
param location string
param administratorLogin string

@secure()
param administratorLoginPassword string
param tags object

resource sqlServerName_resource 'Microsoft.Sql/servers@2020-02-02-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

resource sqlServerName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = {
  parent: sqlServerName_resource
  name: 'AllowAllWindowsAzureIps'
  location: location
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output name string = sqlServerName
output fqdn string = reference(sqlServerName_resource.id, '2020-02-02-preview').fullyQualifiedDomainName