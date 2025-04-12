@description('The name of the Azure Analysis Services server to create. Server name must begin with a letter, be lowercase alphanumeric, and between 3 and 63 characters in length. Server name must be unique per region.')
param serverName string

@description('Location of the Azure Analysis Services server. For supported regions, see https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-overview#availability-by-region')
param location string = resourceGroup().location

@description('The sku name of the Azure Analysis Services server to create. Choose from: B1, B2, D1, S0, S1, S2, S3, S4, S8, S9. Some skus are region specific. See https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-overview#availability-by-region')
param skuName string = 'S0'

@description('The total number of query replica scale-out instances. Scale-out of more than one instance is supported on selected regions only. See https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-overview#availability-by-region')
param capacity int = 1

@description('The inbound firewall rules to define on the server. If not specified, firewall is disabled.')
param firewallSettings object = {
  firewallRules: [
    {
      firewallRuleName: 'AllowFromAll'
      rangeStart: '0.0.0.0'
      rangeEnd: '255.255.255.255'
    }
  ]
  enablePowerBIService: true
}

@description('The SAS URI to a private Azure Blob Storage container with read, write and list permissions. Required only if you intend to use the backup/restore functionality. See https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-backup')
param backupBlobContainerUri string = ''

resource server 'Microsoft.AnalysisServices/servers@2017-08-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    ipV4FirewallSettings: firewallSettings
    backupBlobContainerUri: backupBlobContainerUri
  }
}
