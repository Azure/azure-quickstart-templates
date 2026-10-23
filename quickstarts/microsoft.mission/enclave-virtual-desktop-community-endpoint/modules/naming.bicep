targetScope = 'subscription'

@allowed([
  '' // none
  '-' // hyphen
])
param delimiter string = '-'
param environmentAbbreviation string
param identifier string
param location string
param stampIndex string = '' // Enables multiple deployments of the same workload within a namespace
param workloadShortName string

var genericLocations = {
  central: {
      abbreviation: 'usc'
      timeDifference: '-6:00'
      timeZone: 'Central Standard Time'
  }
  east: {
    abbreviation: 'use'
    timeDifference: '-5:00'
    timeZone: 'Eastern Standard Time'
  }
  eastcentral: {
    abbreviation: 'usec'
    timeDifference: '-6:00'
    timeZone: 'Central Standard Time'
  }
  north: {
    abbreviation: 'usn'
    timeDifference: '-7:00'
    timeZone: 'Mountain Standard Time'
  }
  northcentral: {
    abbreviation: 'usnc'
    timeDifference: '-6:00'
    timeZone: 'Central Standard Time'
  }
  south: {
    abbreviation: 'uss'
    timeDifference: '-7:00'
    timeZone: 'Mountain Standard Time'
  }
  southcentral: {
    abbreviation: 'ussc'
    timeDifference: '-6:00'
    timeZone: 'Central Standard Time'
  }
  west: {
    abbreviation: 'usw'
    timeDifference: '-8:00'
    timeZone: 'Pacific Standard Time'
  }
  westcentral: {
    abbreviation: 'uswc'
    timeDifference: '-7:00'
    timeZone: 'Mountain Standard Time'
  }
}
var locationAbbreviation = locations[location].abbreviation
var locations = loadJsonContent('./locations.json')[?environment().name] ?? {
  '${location}': {
    abbreviation: genericLocations[skip(location, 5)].abbreviation
    timeDifference: genericLocations[skip(location, 5)].timeDifference
    timeZone: genericLocations[skip(location, 5)].timeZone
  }
}
var resourceAbbreviations = loadJsonContent('./resourceAbbreviations.json')
var tokens = {
  resource: 'resource_token'
  service: 'service_token'
}

/*

  NAMING COMPONENTS

  The two variables below define the component order for all the resource names deployed in the service catalog. The concepts below
  adhere to the best practices in the Cloud Adoption Framework. Resource names are defined using a different naming 
  components that are separated by a delimiter. The components are:

  - identifier: A unique identifier for the resource. This is typically a short name or abbreviation that represents an organization, department, or business unit.
  - environmentAbbreviation: A short abbreviation that represents the environment in which the resource is deployed. Common values include "prod" for production, "dev" for development, and "test" for testing.
  - locationAbbreviation: A short abbreviation that represents the geographical location of the resource. This is a two to four letter code that corresponds to the Azure region in which the resource is deployed.
  - networkName: A name that represents the network tier in which the resource is deployed.
  - tokens.service: This is a placeholder value for the service type, typically representing a parent child relationship, that is replaced in the "namingConvention" var.
  - tokens.resource: This is a placeholder value for the resource type that is replaced in the "namingConvention" var.
  - stampIndex: A unique integer value that is used to identify the specific instance of a workload.

*/

var namingComponents = '${toLower(identifier)}${delimiter}${environmentAbbreviation}${delimiter}${locationAbbreviation}${delimiter}${workloadShortName}${delimiter}${tokens.resource}${empty(stampIndex) ? '' : '${delimiter}${stampIndex}'}'
var namingComponents_Service = '${toLower(identifier)}${delimiter}${environmentAbbreviation}${delimiter}${locationAbbreviation}${delimiter}${workloadShortName}${delimiter}${tokens.service}${delimiter}${tokens.resource}${empty(stampIndex) ? '' : '${delimiter}${stampIndex}'}'


// Names are generated using the "replace()" function to insert unique values into the token components.
var namingConvention = {
  actionGroup: replace(namingComponents, tokens.resource, resourceAbbreviations.actionGroups)
  applicationGroup: replace(namingComponents, tokens.resource, resourceAbbreviations.applicationGroups)
  applicationInsights: replace(namingComponents, tokens.resource, resourceAbbreviations.applicationInsights)
  appServicePlan: replace(namingComponents, tokens.resource, resourceAbbreviations.appServicePlans)
  automationAccount: replace(namingComponents, tokens.resource, resourceAbbreviations.automationAccounts)
  automationAccountDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.automationAccounts)
  automationAccountNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.automationAccounts)
  automationAccountPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.automationAccounts)
  availabilitySet: replace(namingComponents, tokens.resource, resourceAbbreviations.availabilitySets)
  azureFirewall: replace(namingComponents, tokens.resource, resourceAbbreviations.azureFirewalls)
  azureFirewallPublicIPAddress: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.publicIPAddresses), tokens.service, resourceAbbreviations.azureFirewalls)
  azureFirewallPublicIPAddressDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.publicIPAddresses}${delimiter}${resourceAbbreviations.azureFirewalls}')
  azureFirewallDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.azureFirewalls)
  azureFirewallPolicy: replace(namingComponents, tokens.resource, resourceAbbreviations.firewallPolicies)
  bastionHost: replace(namingComponents, tokens.resource, resourceAbbreviations.bastionHosts)
  bastionHostDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.bastionHosts)
  bastionHostNetworkSecurityGroup: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkSecurityGroups), tokens.service, resourceAbbreviations.bastionHosts)
  bastionHostNetworkSecurityGroupDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.networkSecurityGroups}${delimiter}${resourceAbbreviations.bastionHosts}')
  bastionHostPublicIPAddress: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.publicIPAddresses), tokens.service, resourceAbbreviations.bastionHosts)
  bastionHostPublicIPAddressDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.publicIPAddresses}${delimiter}${resourceAbbreviations.bastionHosts}')
  community: replace(namingComponents, tokens.resource, resourceAbbreviations.communities)
  communityEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.communitiesCommunityEndpoints), tokens.service, resourceAbbreviations.communities)
  communityTransitHub: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.communitiesTransitHubs), tokens.service, resourceAbbreviations.communities)
  computeGallery: replace(replace(namingComponents, tokens.resource, resourceAbbreviations.computeGallieries), delimiter, empty(delimiter) ? '' : '_') // Compute Galleries do not support hyphens
  dataCollectionEndpoint: replace(namingComponents, tokens.resource, resourceAbbreviations.dataCollectionEndpoints)
  dataCollectionRuleAssociation: replace(namingComponents, tokens.resource, resourceAbbreviations.dataCollectionRuleAssociations)
  dataCollectionRule: replace(namingComponents, tokens.resource, resourceAbbreviations.dataCollectionRules)
  diskAccess: replace(namingComponents, tokens.resource, resourceAbbreviations.diskAccesses)
  diskAccessNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.diskAccesses)
  diskAccessPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.diskAccesses)
  diskEncryptionSet: replace(namingComponents, tokens.resource, resourceAbbreviations.diskEncryptionSets)
  enclaveConnection: replace(namingComponents, tokens.resource, resourceAbbreviations.enclaveConnections)
  functionApp: replace(namingComponents, tokens.resource, resourceAbbreviations.functionApps)
  functionAppNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.functionApps)
  functionAppPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.functionApps)
  hostPool: replace(namingComponents, tokens.resource, resourceAbbreviations.hostPools)
  hostPoolDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.hostPools)
  hostPoolNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.hostPools)
  hostPoolPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.hostPools)
  keyVault: replace(namingComponents, tokens.resource, resourceAbbreviations.keyVaults)
  keyVaultDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.keyVaults)
  keyVaultNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.keyVaults)
  keyVaultPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.keyVaults)
  localNetworkGateway: replace(namingComponents, tokens.resource, resourceAbbreviations.localNetworkGateways)
  logAnalyticsWorkspace: replace(namingComponents, tokens.resource, resourceAbbreviations.logAnalyticsWorkspaces)
  logAnalyticsWorkspaceDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.logAnalyticsWorkspaces)
  natGateway: replace(namingComponents, tokens.resource, resourceAbbreviations.natGateways)
  natGatewayPublicIPPrefix: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.publicIPPrefixes), tokens.service, resourceAbbreviations.natGateways)
  netAppAccount: replace(namingComponents, tokens.resource, resourceAbbreviations.netAppAccounts)
  netAppAccountCapacityPool: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.netAppAccountsCapacityPools), tokens.service, resourceAbbreviations.netAppAccounts)
  netAppAccountSmbServer: replace(replace(replace(replace(namingComponents, tokens.resource, ''), environmentAbbreviation, first(environmentAbbreviation)), workloadShortName, ''), delimiter, '')
  networkSecurityGroup: replace(namingComponents, tokens.resource, resourceAbbreviations.networkSecurityGroups)
  networkSecurityGroupDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.networkSecurityGroups)
  networkWatcherFlowLogsNetworkSecurityGroup: replace(namingComponents, tokens.resource, '${resourceAbbreviations.networkWatchers}${delimiter}${resourceAbbreviations.networkWatchersFlowLogs}${delimiter}${resourceAbbreviations.networkSecurityGroups}')
  networkWatcherFlowLogsVirtualNetwork: replace(namingComponents, tokens.resource, '${resourceAbbreviations.networkWatchers}${delimiter}${resourceAbbreviations.networkWatchersFlowLogs}${delimiter}${resourceAbbreviations.virtualNetworks}')
  privateLinkScope: replace(namingComponents, tokens.resource, resourceAbbreviations.privateLinkScopes)
  privateLinkScopeNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.privateLinkScopes)
  privateLinkScopePrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.privateLinkScopes)
  recoveryServicesVault: replace(namingComponents, tokens.resource, resourceAbbreviations.recoveryServicesVaults)
  recoveryServicesVaultNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.recoveryServicesVaults)
  recoveryServicesVaultPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.recoveryServicesVaults)
  resourceGroup: replace(namingComponents, tokens.resource, resourceAbbreviations.resourceGroups)
  routeTable: replace(namingComponents, tokens.resource, resourceAbbreviations.routeTables)
  scalingPlan: replace(namingComponents, tokens.resource, resourceAbbreviations.scalingPlans)
  scalingPlanDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.scalingPlans)
  storageAccount: replace(namingComponents, tokens.resource, resourceAbbreviations.storageAccounts)
  storageAccountBlobDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}blob')
  storageAccountBlobNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}blob')
  storageAccountBlobPrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}blob')
  storageAccountFileDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}file')
  storageAccountFileNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}file')
  storageAccountFilePrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}file')
  storageAccountQueueDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}queue')
  storageAccountQueueNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}queue')
  storageAccountQueuePrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}queue')
  storageAccountTableDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}table')
  storageAccountTableNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}table')
  storageAccountTablePrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, '${resourceAbbreviations.storageAccounts}${delimiter}table')
  subnet: replace(namingComponents, tokens.resource, resourceAbbreviations.subnets)
  userAssignedIdentity: replace(namingComponents, tokens.resource, resourceAbbreviations.userAssignedIdentities)
  virtualEnclave: replace(namingComponents, tokens.resource, resourceAbbreviations.virtualEnclaves)
  virtualEnclaveEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.virtualEnclavesEnclaveEndpoints), tokens.service, resourceAbbreviations.virtualEnclaves)
  virtualEnclaveWorkload: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.virtualEnclavesWorkloads), tokens.service, resourceAbbreviations.virtualEnclaves)
  virtualMachine: replace(replace(replace(replace(namingComponents, tokens.resource, resourceAbbreviations.virtualMachines), environmentAbbreviation, first(environmentAbbreviation)), workloadShortName, ''), delimiter, '')
  virtualMachineDisk: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.disks), tokens.service, '${resourceAbbreviations.virtualMachines}')
  virtualMachineNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.virtualMachines)
  virtualMachineNetworkInterfaceDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, '${resourceAbbreviations.networkInterfaces}${delimiter}${resourceAbbreviations.virtualMachines}')
  virtualNetwork: replace(namingComponents, tokens.resource, resourceAbbreviations.virtualNetworks)
  virtualNetworkDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.virtualNetworks)
  virtualNetworkGateway: replace(namingComponents, tokens.resource, resourceAbbreviations.virtualNetworkGateways)
  virtualNetworkGatewayPublicIpAddress: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.publicIPAddresses), tokens.service, resourceAbbreviations.virtualNetworkGateways)
  workload: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.virtualEnclavesWorkloads), tokens.service, resourceAbbreviations.virtualEnclaves)
  workspace: replace(namingComponents, tokens.resource, resourceAbbreviations.workspaces)
  workspaceDiagnosticSetting: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.diagnosticSettings), tokens.service, resourceAbbreviations.workspaces)
  workspaceNetworkInterface: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.networkInterfaces), tokens.service, resourceAbbreviations.workspaces)
  workspacePrivateEndpoint: replace(replace(namingComponents_Service, tokens.resource, resourceAbbreviations.privateEndpoints), tokens.service, resourceAbbreviations.workspaces)
}

output delimiter string = delimiter
output locationProperties object = locations[location]
output convention object = namingConvention
output resourceAbbreviations object = resourceAbbreviations
