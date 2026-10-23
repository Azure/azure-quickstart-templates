targetScope = 'subscription'

#disable-next-line no-unused-params
param isMsisrTenant bool = false
#disable-next-line no-unused-params
param isPlxTenant bool = false

@allowed([
  'ActiveDirectoryDomainServices'
  'MicrosoftEntraDomainServices'
  'MicrosoftEntraId'
  'MicrosoftEntraIdIntuneEnrollment'
])
@description('The service providing domain services for Azure Virtual Desktop.  This is needed to properly configure the firewall rules for connectivity.')
param activeDirectorySolution string

@description('Determines whether public network access is allowed for Azure Virtual Desktop resources.')
param avdPublicNetworkAccess bool = false

@description('The resource ID of the existing AE Community.')
param communityResourceId string

@description('The suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param deploymentNameSuffix string = utcNow()

@description('Enable anonymous usage telemetry for this template.')
param enableTelemetry bool = true

@description('Determine whether to enable access to Windows Update services through the firewall.')
param enableWindowsUpdateFwRules bool = false

@allowed([
  'dev' // Development
  'prod' // Production
  'test' // Test
])
@description('The abbreviation for the target environment.')
param environmentAbbreviation string = 'dev'

@maxLength(3)
@description('The unique identifier to distinguish the unique business unit or project in your tenant.')
param identifier string

@description('The location for the resources deployed in this template.')
param location string = deployment().location

@description('The metadata to apply to the resources deployed in this template.')
param tags object = {}

var agentTrafficUniqueString = substring(cloud, 2, 1) == 'n'
  ? 'wvd${first(cloudSuffix)}xportalcontainer'
  : 'wvdportalstorageblob'
var agentUpdatesUniqueString = cloud == 'AzureCloud'
  ? 'eus2prod'
  : cloud == 'AzureUSGovernment'
      ? 'ugviffx'
      : '${first(cloud)}${take(skip(cloud, 2), 1)}${first(location)}${substring(cloud, 2, 1) == 'n' ? first(cloudSuffix) : substring(cloudSuffix, 3, 1)}x'
var cloud = environment().name
var cloudSuffix = replace(replace(environment().resourceManager, 'https://management.', ''), '/', '')
var privateDnsZoneSuffixes_AzureVirtualDesktop = {
  AzureCloud: 'microsoft.com'
  AzureUSGovernment: 'azure.us'
}

module naming './modules/naming.bicep' = {
  name: 'naming-convention-${deploymentNameSuffix}'
  params: {
    environmentAbbreviation: environmentAbbreviation
    identifier: identifier
    location: location
    workloadShortName: 'avd'
  }
}

module communityEndpoint './modules/community-endpoint.bicep' = {
  scope: resourceGroup(split(communityResourceId, '/')[2], split(communityResourceId, '/')[4])
  name: 'community-endpoint-${deploymentNameSuffix}'
  params: {
    communityEndpointName: naming.outputs.convention.communityEndpoint
    communityName: split(communityResourceId, '/')[8]
    location: location
    ruleCollection: union([
      {
        endpointRuleName: 'allow-entra-id'
        destination: 'AzureActiveDirectory'
        destinationType: 'ServiceTag'
        ports: '443'
        protocols: [
          'TCP'
        ]
      }
      {
        endpointRuleName: 'allow-azure-monitor'
        destination: 'AzureMonitor'
        destinationType: 'ServiceTag'
        ports: '443'
        protocols: [
          'TCP'
        ]
      }
      {
        endpointRuleName: 'avd-deployment-endpoints'
        destination: '${split(environment().resourceManager, '/')[2]}, mrsglobalst${agentUpdatesUniqueString}.blob.${environment().suffixes.storage}, ${agentTrafficUniqueString}.blob.${environment().suffixes.storage}, gcs${cloud == 'AzureCloud' ? '.prod' : ''}.monitoring.${environment().suffixes.storage}, *.prod.warm.ingest.monitor.${environment().suffixes.storage}, *.guestconfiguration.${privateDnsZoneSuffixes_AzureVirtualDesktop[?environment().name] ?? cloudSuffix},*.wvd.${privateDnsZoneSuffixes_AzureVirtualDesktop[?environment().name] ?? cloudSuffix}'
        destinationType: 'FQDN'
        protocols: [
          'HTTPS'
        ]
        ports: '443'
      }
    ],
    avdPublicNetworkAccess ? [
      {
        endpointRuleName: 'azure-virtual-desktop'
        destination: 'WindowsVirtualDesktop'
        destinationType: 'FQDNTag'
        protocols: [
          'HTTPS'
        ]
        ports: '443'
      }
    ] : [],
    startsWith(activeDirectorySolution, 'MicrosoftEntraId') ? [
      {
        endpointRuleName: 'avd-auth-endpoints'
        destination: '${split(environment().authentication.loginEndpoint, '/')[2]}, ${split(environment().graph, '/')[2]}, enterpriseregistration.windows.net'
        destinationType: 'FQDN'
        protocols: [
          'HTTPS'
        ]
        ports: '443'
      } 
    ] : [],
    enableWindowsUpdateFwRules ? [
      {
        endpointRuleName: 'windows-update'
        destination: 'WindowsUpdate'
        destinationType: 'FQDNTag'
        protocols: [
          'HTTPS'
        ]
        ports: '443'
      }
    ] : [])
    tags: tags
  }
}

module telemetry './telemetry.bicep' = if (enableTelemetry && !isMsisrTenant) {
  name: 'telemetry-${deploymentNameSuffix}'
  scope: resourceGroup(split(communityResourceId, '/')[2], split(communityResourceId, '/')[4])
  params: {
    enableTelemetry: enableTelemetry
    name: 've.sc2.avdcommunityendpoint.fce90515-0f7d-433d-b756-d32b39058d4d.ver${deployment().properties.template.contentVersion}'
  }
}

output communityResourceId string = communityEndpoint.outputs.communityResourceId
output communityEndpointResourceId string = communityEndpoint.outputs.communityEndpointResourceId
