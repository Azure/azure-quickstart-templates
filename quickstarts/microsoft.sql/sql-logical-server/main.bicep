@description('The name of the SQL logical server.')
param serverName string = uniqueString('sql', resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

@description('Enable Microsoft Defender for SQL, the user deploying the template must have an administrator or owner permissions.')
param enableSqlDefender bool = true

@description('Allow Azure services to access server.')
param allowAzureIPs bool = true

@description('SQL logical server connection type.')
@allowed([
  'Default'
  'Redirect'
  'Proxy'
])
param connectionType string = 'Default'

resource server 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = if (allowAzureIPs) {
  parent: server
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource protectionSetting 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-05-01-preview' = if (enableSqlDefender) {
  parent: server
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource assessment 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2022-05-01-preview' = if (enableSqlDefender) {
  parent: server
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource connectionPolicy 'Microsoft.Sql/servers/connectionPolicies@2022-05-01-preview' = {
  parent: server
  name: 'Default'
  properties: {
    connectionType: connectionType
  }
}
