@description('Data factory name')
param dataFactoryName string = uniqueString(resourceGroup().id)

@description('Managed Virtual Network name')
param enableManagedVirtualNetwork bool = false

@description('Enable the integration runtime inside the managed virtual network. Only required if enableManagedVirtualNetwork is true')
param enableManagedVnetIntegrationRuntime bool = false

@description('Data factory location')
param location string = resourceGroup().location

@description('Object containing resource tags')
param tags object = {}

@description('Enable or disable public network access')
param publicNetworkAccess bool = true

@description('Configure git during deployment')
param configureGit bool = false

@allowed([
  'FactoryVSTSConfiguration'
  'FactoryGitHubConfiguration'
])
@description('Git repository type. Azure DevOps = FactoryVSTSConfiguration and GitHub = FactoryGitHubConfiguration')
param gitRepoType string = 'FactoryGitHubConfiguration'

@description('Git account name. Azure DevOps = Organisation name and GitHub = Username')
param gitAccountName string = ''

@description('Git project name. Only relevant for Azure DevOps')
param gitProjectName string = ''

@description('Git repository name')
param gitRepositoryName string = ''

@description('The collaboration branch name. Default is main')
param gitCollaborationBranch string = 'main'

@description('The root folder path name. Default is /')
param gitRootFolder string = '/'

@description('Enables system assigned managed identity on the resource')
param systemAssignedIdentity bool = true

@description('The user assigned ID(s) to assign to the resource')
param userAssignedIdentities object = {}

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account resource id. Only required if enableDiagnostics is set to true')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Event hub authorization rule for the Event Hub namespace. Only required if enableDiagnostics is set to true')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Event hub name. Only required if enableDiagnostics is set to true')
param diagnosticEventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Specify the type of resource lock.')
param resourcelock string = 'NotSpecified'

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')
var managedVnetName = 'default'
var managedVnetRuntimeName = 'AutoResolveIntegrationRuntime'
var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null
var repoConfiguration = gitRepoType == 'FactoryVSTSConfiguration' ? {
  accountName: gitAccountName
  collaborationBranch: gitCollaborationBranch
  repositoryName: gitRepositoryName
  rootFolder: gitRootFolder
  type: 'FactoryVSTSConfiguration'
  projectName: gitProjectName
} : {
  accountName: gitAccountName
  collaborationBranch: gitCollaborationBranch
  repositoryName: gitRepositoryName
  rootFolder: gitRootFolder
  type: 'FactoryGitHubConfiguration'
}
var lockName = toLower('${dataFactory.name}-${resourcelock}-lck')
var diagnosticsName = '${dataFactory.name}-dgs'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: tags
  identity: identity
  properties: {
    repoConfiguration: configureGit ? repoConfiguration : null
    publicNetworkAccess: bool(publicNetworkAccess) ? 'Enabled' : 'Disabled'
  }
}

resource managedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if (enableManagedVirtualNetwork) {
  name: managedVnetName
  parent: dataFactory
  properties: {}
}

resource managedIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (enableManagedVnetIntegrationRuntime) {
  name: managedVnetRuntimeName
  parent: dataFactory
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: managedVnetName
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
  dependsOn: [
    managedVirtualNetwork
  ]
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: dataFactory
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: dataFactory
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: [
      {
        category: 'ActivityRuns'
        enabled: true
      }
      {
        category: 'PipelineRuns'
        enabled: true
      }
      {
        category: 'TriggerRuns'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessages'
        enabled: true
      }
      {
        category: 'SSISPackageExecutableStatistics'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessageContext'
        enabled: true
      }
      {
        category: 'SSISPackageExecutionComponentPhases'
        enabled: true
      }
      {
        category: 'SSISPackageExecutionDataStatistics'
        enabled: true
      }
      {
        category: 'SSISIntegrationRuntimeLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output name string = dataFactory.name
output id string = dataFactory.id
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(dataFactory.identity, 'principalId') ? dataFactory.identity.principalId : ''
