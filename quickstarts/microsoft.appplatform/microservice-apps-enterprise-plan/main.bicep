@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specifies the base URI where artifacts required by this template are located including a trailing \'/\'. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation. When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var _fxv_0 = {
  analysisServicesServers: 'as'
  apiManagementService: 'apim-'
  appConfigurationConfigurationStores: 'appcs-'
  appManagedEnvironments: 'cae-'
  appContainerApps: 'ca-'
  authorizationPolicyDefinitions: 'policy-'
  automationAutomationAccounts: 'aa-'
  blueprintBlueprints: 'bp-'
  blueprintBlueprintsArtifacts: 'bpa-'
  cacheRedis: 'redis-'
  cdnProfiles: 'cdnp-'
  cdnProfilesEndpoints: 'cdne-'
  cognitiveServicesAccounts: 'cog-'
  cognitiveServicesFormRecognizer: 'cog-fr-'
  cognitiveServicesTextAnalytics: 'cog-ta-'
  computeAvailabilitySets: 'avail-'
  computeCloudServices: 'cld-'
  computeDiskEncryptionSets: 'des'
  computeDisks: 'disk'
  computeDisksOs: 'osdisk'
  computeGalleries: 'gal'
  computeSnapshots: 'snap-'
  computeVirtualMachines: 'vm'
  computeVirtualMachineScaleSets: 'vmss-'
  containerInstanceContainerGroups: 'ci'
  containerRegistryRegistries: 'cr'
  containerServiceManagedClusters: 'aks-'
  databricksWorkspaces: 'dbw-'
  dataFactoryFactories: 'adf-'
  dataLakeAnalyticsAccounts: 'dla'
  dataLakeStoreAccounts: 'dls'
  dataMigrationServices: 'dms-'
  dBforMySQLServers: 'mysql-'
  dBforPostgreSQLServers: 'psql-'
  devicesIotHubs: 'iot-'
  devicesProvisioningServices: 'provs-'
  devicesProvisioningServicesCertificates: 'pcert-'
  documentDBDatabaseAccounts: 'cosmos-'
  eventGridDomains: 'evgd-'
  eventGridDomainsTopics: 'evgt-'
  eventGridEventSubscriptions: 'evgs-'
  eventHubNamespaces: 'evhns-'
  eventHubNamespacesEventHubs: 'evh-'
  hdInsightClustersHadoop: 'hadoop-'
  hdInsightClustersHbase: 'hbase-'
  hdInsightClustersKafka: 'kafka-'
  hdInsightClustersMl: 'mls-'
  hdInsightClustersSpark: 'spark-'
  hdInsightClustersStorm: 'storm-'
  hybridComputeMachines: 'arcs-'
  insightsActionGroups: 'ag-'
  insightsComponents: 'appi-'
  keyVaultVaults: 'kv-'
  kubernetesConnectedClusters: 'arck'
  kustoClusters: 'dec'
  kustoClustersDatabases: 'dedb'
  logicIntegrationAccounts: 'ia-'
  logicWorkflows: 'logic-'
  machineLearningServicesWorkspaces: 'mlw-'
  managedIdentityUserAssignedIdentities: 'id-'
  managementManagementGroups: 'mg-'
  migrateAssessmentProjects: 'migr-'
  networkApplicationGateways: 'agw-'
  networkApplicationSecurityGroups: 'asg-'
  networkAzureFirewalls: 'afw-'
  networkBastionHosts: 'bas-'
  networkConnections: 'con-'
  networkDnsZones: 'dnsz-'
  networkExpressRouteCircuits: 'erc-'
  networkFirewallPolicies: 'afwp-'
  networkFirewallPoliciesWebApplication: 'waf'
  networkFirewallPoliciesRuleGroups: 'wafrg'
  networkFrontDoors: 'fd-'
  networkFrontdoorWebApplicationFirewallPolicies: 'fdfp-'
  networkLoadBalancersExternal: 'lbe-'
  networkLoadBalancersInternal: 'lbi-'
  networkLoadBalancersInboundNatRules: 'rule-'
  networkLocalNetworkGateways: 'lgw-'
  networkNatGateways: 'ng-'
  networkNetworkInterfaces: 'nic-'
  networkNetworkSecurityGroups: 'nsg-'
  networkNetworkSecurityGroupsSecurityRules: 'nsgsr-'
  networkNetworkWatchers: 'nw-'
  networkPrivateDnsZones: 'pdnsz-'
  networkPrivateLinkServices: 'pl-'
  networkPublicIPAddresses: 'pip-'
  networkPublicIPPrefixes: 'ippre-'
  networkRouteFilters: 'rf-'
  networkRouteTables: 'rt-'
  networkRouteTablesRoutes: 'udr-'
  networkTrafficManagerProfiles: 'traf-'
  networkVirtualNetworkGateways: 'vgw-'
  networkVirtualNetworks: 'vnet-'
  networkVirtualNetworksSubnets: 'snet-'
  networkVirtualNetworksVirtualNetworkPeerings: 'peer-'
  networkVirtualWans: 'vwan-'
  networkVpnGateways: 'vpng-'
  networkVpnGatewaysVpnConnections: 'vcn-'
  networkVpnGatewaysVpnSites: 'vst-'
  notificationHubsNamespaces: 'ntfns-'
  notificationHubsNamespacesNotificationHubs: 'ntf-'
  operationalInsightsWorkspaces: 'log-'
  portalDashboards: 'dash-'
  powerBIDedicatedCapacities: 'pbi-'
  purviewAccounts: 'pview-'
  postgresServer: 'pg-'
  recoveryServicesVaults: 'rsv-'
  resourcesResourceGroups: 'rg-'
  searchSearchServices: 'srch-'
  serviceBusNamespaces: 'sb-'
  serviceBusNamespacesQueues: 'sbq-'
  serviceBusNamespacesTopics: 'sbt-'
  serviceEndPointPolicies: 'se-'
  serviceFabricClusters: 'sf-'
  signalRServiceSignalR: 'sigr'
  springApps: 'asa-'
  sqlManagedInstances: 'sqlmi-'
  sqlServers: 'sql-'
  sqlServersDataWarehouse: 'sqldw-'
  sqlServersDatabases: 'sqldb-'
  sqlServersDatabasesStretch: 'sqlstrdb-'
  storageStorageAccounts: 'st'
  storageStorageAccountsVm: 'stvm'
  storSimpleManagers: 'ssimp'
  streamAnalyticsCluster: 'asa-'
  synapseWorkspaces: 'syn'
  synapseWorkspacesAnalyticsWorkspaces: 'synw'
  synapseWorkspacesSqlPoolsDedicated: 'syndp'
  synapseWorkspacesSqlPoolsSpark: 'synsp'
  timeSeriesInsightsEnvironments: 'tsi-'
  webServerFarms: 'plan-'
  webSitesAppService: 'app-'
  webSitesAppServiceEnvironment: 'ase-'
  webSitesFunctions: 'func-'
  webStaticSites: 'stapp-'
}
var abbrs = _fxv_0
var resourceToken = toLower(uniqueString(subscription().id, resourceGroup().name, location))
var asaInstanceName = '${abbrs.springApps}${resourceToken}'
var adminServerAppName = 'admin-server'
var customersServiceAppName = 'customers-service'
var vetsServiceAppName = 'vets-service'
var visitsServiceAppName = 'visits-service'
var apiGatewayAppName = 'api-gateway'
var logAnalyticsName = '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
var applicationInsightsName = '${abbrs.insightsComponents}${resourceToken}'
var applicationInsightsDashboardName = '${abbrs.portalDashboards}${resourceToken}'
var userAssignedManagedIdentityName = '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
var const_ownerRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var const_uploadScriptName = 'deploy-jar-to-asa.sh'
var const_checkScriptName = 'check-provision-state.ps1'
var const_checkingBuilderStateDeploymentName = 'checking-build-service-builder-state'
var ref_identityId = userAssignedManagedIdentity.id
var name_deploymentScriptName = 'asa-enterprise-deployment-script'
var name_roleAssignmentName = guid('${resourceGroup().name}${ref_identityId}Role assignment in group${resourceGroup().name}')
var tags = {
  'spring-cloud-azure': 'true'
  'deploy-to-azure-button': 'true'
}

resource asaInstance 'Microsoft.AppPlatform/Spring@2023-05-01-preview' = {
  name: asaInstanceName
  location: location
  tags: tags
  sku: {
    name: 'E0'
    tier: 'Enterprise'
  }
}

resource asaInstanceName_default 'Microsoft.AppPlatform/Spring/buildServices@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
  properties: {
    resourceRequests: {
      cpu: '1000m'
      memory: '2000Mi'
    }
  }
}

resource asaInstanceName_adminServerApp 'Microsoft.AppPlatform/Spring/apps@2023-05-01-preview' = {
  parent: asaInstance
  name: adminServerAppName
  location: location
  properties: {
    public: true
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
    ingressSettings: {
      readTimeoutInSeconds: 300
      sendTimeoutInSeconds: 60
      sessionCookieMaxAge: 0
      sessionAffinity: 'None'
      backendProtocol: 'Default'
    }
  }
}

resource asaInstanceName_customersServiceApp 'Microsoft.AppPlatform/Spring/apps@2023-05-01-preview' = {
  parent: asaInstance
  name: customersServiceAppName
  location: location
  properties: {
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
    ingressSettings: {
      readTimeoutInSeconds: 300
      sendTimeoutInSeconds: 60
      sessionCookieMaxAge: 0
      sessionAffinity: 'None'
      backendProtocol: 'Default'
    }
  }
}

resource asaInstanceName_vetsServiceApp 'Microsoft.AppPlatform/Spring/apps@2023-05-01-preview' = {
  parent: asaInstance
  name: vetsServiceAppName
  location: location
  properties: {
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
    ingressSettings: {
      readTimeoutInSeconds: 300
      sendTimeoutInSeconds: 60
      sessionCookieMaxAge: 0
      sessionAffinity: 'None'
      backendProtocol: 'Default'
    }
  }
}

resource asaInstanceName_visitsServiceApp 'Microsoft.AppPlatform/Spring/apps@2023-05-01-preview' = {
  parent: asaInstance
  name: visitsServiceAppName
  location: location
  properties: {
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
    ingressSettings: {
      readTimeoutInSeconds: 300
      sendTimeoutInSeconds: 60
      sessionCookieMaxAge: 0
      sessionAffinity: 'None'
      backendProtocol: 'Default'
    }
  }
}

resource asaInstanceName_apiGatewayApp 'Microsoft.AppPlatform/Spring/apps@2023-05-01-preview' = {
  parent: asaInstance
  name: apiGatewayAppName
  location: location
  properties: {
    public: true
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
    ingressSettings: {
      readTimeoutInSeconds: 300
      sendTimeoutInSeconds: 60
      sessionCookieMaxAge: 0
      sessionAffinity: 'None'
      backendProtocol: 'Default'
    }
  }
}

resource asaInstanceName_adminServerAppName_default 'Microsoft.AppPlatform/Spring/apps/deployments@2023-05-01-preview' = {
  parent: asaInstanceName_adminServerApp
  name: 'default'
  properties: {
    active: true
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    source: {
      type: 'BuildResult'
      buildResultId: '<default>'
    }
  }
}

resource asaInstanceName_customersServiceAppName_default 'Microsoft.AppPlatform/Spring/apps/deployments@2023-05-01-preview' = {
  parent: asaInstanceName_customersServiceApp
  name: 'default'
  properties: {
    active: true
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    source: {
      type: 'BuildResult'
      buildResultId: '<default>'
    }
  }
}

resource asaInstanceName_vetsServiceAppName_default 'Microsoft.AppPlatform/Spring/apps/deployments@2023-05-01-preview' = {
  parent: asaInstanceName_vetsServiceApp
  name: 'default'
  properties: {
    active: true
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    source: {
      type: 'BuildResult'
      buildResultId: '<default>'
    }
  }
}

resource asaInstanceName_visitsServiceAppName_default 'Microsoft.AppPlatform/Spring/apps/deployments@2023-05-01-preview' = {
  parent: asaInstanceName_visitsServiceApp
  name: 'default'
  properties: {
    active: true
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    source: {
      type: 'BuildResult'
      buildResultId: '<default>'
    }
  }
}

resource asaInstanceName_apiGatewayAppName_default 'Microsoft.AppPlatform/Spring/apps/deployments@2023-05-01-preview' = {
  parent: asaInstanceName_apiGatewayApp
  name: 'default'
  properties: {
    active: true
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    source: {
      type: 'BuildResult'
      buildResultId: '<default>'
    }
  }
}

resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedManagedIdentityName
  location: location
  tags: tags
}

resource name_roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: name_roleAssignmentName
  properties: {
    roleDefinitionId: const_ownerRole
    principalId: reference(ref_identityId).principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
  dependsOn: [

    asaInstance
  ]
}

resource const_checkingBuilderStateDeployment 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: const_checkingBuilderStateDeploymentName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '9.7'
    primaryScriptUri: uri(_artifactsLocation, 'scripts/${const_checkScriptName}${_artifactsLocationSasToken}')
    environmentVariables: [
      {
        name: 'SUBSCRIPTION_ID'
        value: subscription().subscriptionId
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'ASA_SERVICE_NAME'
        value: asaInstanceName
      }
    ]
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    name_roleAssignment
    asaInstanceName_adminServerAppName_default
    asaInstanceName_customersServiceAppName_default
    asaInstanceName_vetsServiceAppName_default
    asaInstanceName_visitsServiceAppName_default
    asaInstanceName_apiGatewayAppName_default
  ]
}

resource asaInstanceName_default_default_default 'Microsoft.AppPlatform/Spring/buildservices/builders/buildpackBindings@2023-05-01-preview' = {
  name: '${asaInstanceName}/default/default/default'
  properties: {
    bindingType: 'ApplicationInsights'
    launchProperties: {
      properties: {
        sampling_percentage: '10'
        connection_string: applicationInsights.properties.ConnectionString
      }
    }
  }
  dependsOn: [
    const_checkingBuilderStateDeployment
  ]
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'java'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'CustomDeployment'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'Disabled'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsightsDashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = {
  name: applicationInsightsDashboardName
  location: location
  tags: tags
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              colSpan: 2
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'id'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/AspNetOverviewPinnedPart'
              asset: {
                idInputName: 'id'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'overview'
            }
          }
          {
            position: {
              x: 2
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/ProactiveDetectionAsyncPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'ProactiveDetection'
            }
          }
          {
            position: {
              x: 3
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'ResourceId'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/QuickPulseButtonSmallPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 4
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    createdTime: '2018-05-04T01:20:33.345Z'
                    isInitialTime: true
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/AvailabilityNavButtonPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 5
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    createdTime: '2018-05-08T18:47:35.237Z'
                    isInitialTime: true
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
                {
                  name: 'ConfigurationId'
                  value: '78ce933e-e864-4b05-a27b-71fd55a6afad'
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/AppMapButtonPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 0
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Usage'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 3
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    createdTime: '2018-05-04T01:22:35.782Z'
                    isInitialTime: true
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/UsageUsersOverviewPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 4
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Reliability'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 7
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ResourceId'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                }
                {
                  name: 'DataModel'
                  value: {
                    version: '1.0.0'
                    timeContext: {
                      durationMs: 86400000
                      createdTime: '2018-05-04T23:42:40.072Z'
                      isInitialTime: false
                      grain: 1
                      useDashboardTimeRange: false
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'ConfigurationId'
                  value: '8a02f7bf-ac0f-40e1-afe9-f0e72cfee77f'
                  isOptional: true
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/CuratedBladeFailuresPinnedPart'
              isAdapter: true
              asset: {
                idInputName: 'ResourceId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'failures'
            }
          }
          {
            position: {
              x: 8
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Responsiveness\r\n'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 11
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ResourceId'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                }
                {
                  name: 'DataModel'
                  value: {
                    version: '1.0.0'
                    timeContext: {
                      durationMs: 86400000
                      createdTime: '2018-05-04T23:43:37.804Z'
                      isInitialTime: false
                      grain: 1
                      useDashboardTimeRange: false
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'ConfigurationId'
                  value: '2a8ede4f-2bee-4b9c-aed9-2db0e8a01865'
                  isOptional: true
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/CuratedBladePerformancePinnedPart'
              isAdapter: true
              asset: {
                idInputName: 'ResourceId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'performance'
            }
          }
          {
            position: {
              x: 12
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Browser'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 15
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'MetricsExplorerJsonDefinitionId'
                  value: 'BrowserPerformanceTimelineMetrics'
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    createdTime: '2018-05-08T12:16:27.534Z'
                    isInitialTime: false
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
                {
                  name: 'CurrentFilter'
                  value: {
                    eventTypes: [
                      4
                      1
                      3
                      5
                      2
                      6
                      13
                    ]
                    isPermissive: false
                  }
                }
                {
                  name: 'id'
                  value: {
                    Name: applicationInsightsDashboardName
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/MetricsExplorerBladePinnedPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'browser'
            }
          }
          {
            position: {
              x: 0
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'sessions/count'
                          aggregationType: 5
                          namespace: 'microsoft.insights/components/kusto'
                          metricVisualization: {
                            displayName: 'Sessions'
                            color: '#47BDF5'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'users/count'
                          aggregationType: 5
                          namespace: 'microsoft.insights/components/kusto'
                          metricVisualization: {
                            displayName: 'Users'
                            color: '#7E58FF'
                          }
                        }
                      ]
                      title: 'Unique sessions and users'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                            menuid: 'segmentationUsers'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 4
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'requests/failed'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Failed requests'
                            color: '#EC008C'
                          }
                        }
                      ]
                      title: 'Failed requests'
                      visualization: {
                        chartType: 3
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                            menuid: 'failures'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 8
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'requests/duration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Server response time'
                            color: '#00BCF2'
                          }
                        }
                      ]
                      title: 'Server response time'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                            menuid: 'performance'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 12
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'browserTimings/networkDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Page load network connect time'
                            color: '#7E58FF'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'browserTimings/processingDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Client processing time'
                            color: '#44F1C8'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'browserTimings/sendDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Send request time'
                            color: '#EB9371'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'browserTimings/receiveDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Receiving response time'
                            color: '#0672F1'
                          }
                        }
                      ]
                      title: 'Average page load time breakdown'
                      visualization: {
                        chartType: 3
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 0
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'availabilityResults/availabilityPercentage'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Availability'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Average availability'
                      visualization: {
                        chartType: 3
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                            menuid: 'availability'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 4
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'exceptions/server'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Server exceptions'
                            color: '#47BDF5'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'dependencies/failed'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Dependency failures'
                            color: '#7E58FF'
                          }
                        }
                      ]
                      title: 'Server exceptions and Dependency failures'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 8
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'performanceCounters/processorCpuPercentage'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Processor time'
                            color: '#47BDF5'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'performanceCounters/processCpuPercentage'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Process CPU'
                            color: '#7E58FF'
                          }
                        }
                      ]
                      title: 'Average processor and process CPU utilization'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 12
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'exceptions/browser'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Browser exceptions'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Browser exceptions'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 0
              y: 8
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'availabilityResults/count'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Availability test results count'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Availability test results count'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 4
              y: 8
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'performanceCounters/processIOBytesPerSecond'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Process IO rate'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Average process I/O rate'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 8
              y: 8
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${applicationInsightsDashboardName}'
                          }
                          name: 'performanceCounters/memoryAvailableBytes'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Available memory'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Average available memory'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
        ]
      }
    ]
  }
  dependsOn: [
    applicationInsights
  ]
}

resource Microsoft_AppPlatform_Spring_monitoringSettings_asaInstanceName_default 'Microsoft.AppPlatform/Spring/monitoringSettings@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
  }
}

resource monitoring 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: asaInstance
  name: 'monitoring'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
      }
    ]
  }
}

resource Microsoft_AppPlatform_Spring_applicationAccelerators_asaInstanceName_default 'Microsoft.AppPlatform/Spring/applicationAccelerators@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
}

resource Microsoft_AppPlatform_Spring_applicationLiveViews_asaInstanceName_default 'Microsoft.AppPlatform/Spring/applicationLiveViews@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
}

resource Microsoft_AppPlatform_Spring_configurationServices_asaInstanceName_default 'Microsoft.AppPlatform/Spring/configurationServices@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
  properties: {
    settings: {
      gitProperty: {
        repositories: [
          {
            name: 'default'
            patterns: [
              'application'
              'api-gateway'
              'admin-server'
              'customers-service'
              'vets-service'
              'visits-service'
            ]
            label: 'master'
            uri: 'https://github.com/Azure-Samples/spring-petclinic-microservices-config.git'
          }
        ]
      }
    }
    generation: 'Gen1'
  }
}

resource Microsoft_AppPlatform_Spring_devToolPortals_asaInstanceName_default 'Microsoft.AppPlatform/Spring/devToolPortals@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
  properties: {
    public: false
    features: {
      applicationAccelerator: {
        state: 'Enabled'
      }
      applicationLiveView: {
        state: 'Enabled'
      }
    }
  }
}

resource Microsoft_AppPlatform_Spring_gateways_asaInstanceName_default 'Microsoft.AppPlatform/Spring/gateways@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
  sku: {
    name: 'E0'
    tier: 'Enterprise'
    capacity: 2
  }
  properties: {
    public: false
    httpsOnly: false
    resourceRequests: {
      cpu: '1'
      memory: '2Gi'
    }
    clientAuth: {
      certificateVerification: 'Disabled'
    }
  }
}

resource Microsoft_AppPlatform_Spring_serviceRegistries_asaInstanceName_default 'Microsoft.AppPlatform/Spring/serviceRegistries@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
}

resource Microsoft_AppPlatform_Spring_apiPortals_asaInstanceName_default 'Microsoft.AppPlatform/Spring/apiPortals@2023-05-01-preview' = {
  parent: asaInstance
  name: 'default'
  sku: {
    name: 'E0'
    tier: 'Enterprise'
    capacity: 1
  }
  properties: {
    public: false
    httpsOnly: false
    gatewayIds: [
      Microsoft_AppPlatform_Spring_gateways_asaInstanceName_default.id
    ]
  }
}

resource asaInstanceName_default_default 'Microsoft.AppPlatform/Spring/buildServices/agentPools@2023-05-01-preview' = {
  parent: asaInstanceName_default
  name: 'default'
  properties: {
    poolSize: {
      name: 'S1'
    }
  }
}

resource name_deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name_deploymentScriptName
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.41.0'
    primaryScriptUri: uri(_artifactsLocation, 'scripts/${const_uploadScriptName}${_artifactsLocationSasToken}')
    environmentVariables: [
      {
        name: 'SUBSCRIPTION_ID'
        value: subscription().subscriptionId
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'ASA_SERVICE_NAME'
        value: asaInstanceName
      }
    ]
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    asaInstanceName_default_default_default
    name_roleAssignment
  ]
}

output API_Gateway_URL string = asaInstanceName_apiGatewayApp.properties.url
output Admin_Server_URL string = asaInstanceName_adminServerApp.properties.url
