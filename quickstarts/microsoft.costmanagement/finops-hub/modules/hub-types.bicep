// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Types
//==============================================================================

//------------------------------------------------------------------------------
// General
//------------------------------------------------------------------------------

@description('Resource ID and name.')
@metadata({
  id: 'Fully-qualified resource ID.'
  name: 'Resource name.'
})
type IdNameObject = { id: string, name: string }

//------------------------------------------------------------------------------
// Hub config
//------------------------------------------------------------------------------

@description('FinOps hub instance details.')
@metadata({
  id: 'FinOps hub resource ID.'
  name: 'FinOps hub instance name.'
  safeName: 'Safe name of the FinOps hub instance without underscores.'
  suffix: 'Unique suffix used for shared resources.'
  location: 'Azure resource location of the FinOps hub instance.'
  tags: 'Tags to apply to all FinOps hub resources.'
  version: 'FinOps hub version number.'
})
type HubInstanceConfig = {
  id: string
  name: string
  safeName: string
  suffix: string
  location: string
  tags: object
  version: string
}

@description('FinOps hub deployment settings.')
@metadata({
  tagsByResource: 'Tags to apply to resources based on their resource type.'
  storage: 'Name of the storage account used for deployment scripts.'
})
type HubDeploymentConfig = {
  tagsByResource: object
  storage: string
}

@description('FinOps hub storage settings to be used when creating storage accounts.')
@metadata({
  name: 'Name of the storage account for this publisher.'
  sku: 'Storage account SKU. Allowed values: "Premium_LRS", "Premium_ZRS".'
  isInfrastructureEncrypted: 'Indicates whether infrastructure encryption is enabled for the storage account.'
})
type HubStorageConfig = {
  sku: string
  isInfrastructureEncrypted: bool
}

@description('FinOps hub network settings.')
@metadata({
  id: 'Resource ID of the FinOps hub isolated virtual network, if private networking is enabled.'
  name: 'Name of the FinOps hub isolated virtual network, if private networking is enabled.'
  isPrivate: 'Indicates whether private networking is enabled.'
  addressPrefix: 'Address prefix for the FinOps hub isolated virtual network, if private networking is enabled.'
  dnsZones: {
    blob: 'Resource ID and name for the blob storage DNS zone.'
    dfs: 'Resource ID and name for the DFS storage DNS zone.'
    queue: 'Resource ID and name for the queue storage DNS zone.'
    table: 'Resource ID and name for the table storage DNS zone.'
  }
  subnets: {
    scripts: 'Resource ID of the subnet for deployment script storage.'
    storage: 'Resource ID of the subnet for storage accounts.'
  }
})
type HubNetworkConfig = {
  id: string
  name: string
  isPrivate: bool
  addressPrefix: string
  dnsZones: {
    blob: IdNameObject
    dfs: IdNameObject
    queue: IdNameObject
    table: IdNameObject
  }
  subnets: {
    scripts: string
    storage: string
  }
}

@export()
@description('FinOps hub configuration settings.')
@metadata({
  hub: 'FinOps hub instance details'
  deployment: 'FinOps hub deployment details'
  storage: 'FinOps hub storage details'
  network: 'FinOps hub network details'
})
type HubCoreConfig = {
  hub: HubInstanceConfig
  deployment: HubDeploymentConfig
  storage: HubStorageConfig
  network: HubNetworkConfig
}

//------------------------------------------------------------------------------
// App config
//------------------------------------------------------------------------------

@export()
@description('FinOps hub app configuration settings.')
@metadata({
  hub: 'FinOps hub instance details'
  deployment: 'FinOps hub deployment details'
  storage: 'FinOps hub storage details'
  network: 'FinOps hub network details'
  publisher: {
    uniqueId: 'Unique suffix used for publisher resources.'
    // id: 'Resource ID of the FinOps hub app publisher for this hub instance.'
    name: 'Fully-qualified namespace of the FinOps hub app publisher.'
    displayName: 'Display name of the FinOps hub app publisher.'
    tags: 'Tags to apply to all FinOps hub resources for this FinOps hub app publisher.'
    storage: 'Name of the storage account for this publisher.'
    subnetId: 'Resource ID of the private endpoint subnet for the storage account.'
  }
  app: {
    // uniqueId: 'Unique suffix used for app resources.'
    // id: 'Resource ID of the FinOps hub app for this hub instance.'
    name: 'Short name of the FinOps hub app (not including the publisher namespace).'
    fullName: 'Fully-qualified namespace of the FinOps hub app.'
    displayName: 'Display name of the FinOps hub app.'
    tags: 'Tags to apply to all FinOps hub resources for this FinOps hub app.'
  }
})
type HubAppConfig = {
  hub: HubInstanceConfig
  deployment: HubDeploymentConfig
  storage: HubStorageConfig
  network: HubNetworkConfig
  publisher: {
    // id: string
    name: string
    displayName: string
    suffix: string
    tags: object
    storage: string
  }
  app: {
    // id: string
    name: string
    fullName: string
    displayName: string
    // suffix: string
    tags: object
  }
}

@export()
@description('FinOps hub app features.')
type HubAppFeature = 'Storage'


//==============================================================================
// Variables
//==============================================================================

// TODO: Remove this variable when we add support for publisher-specific resources
var usePublisherSpecificResources = false

@description('Version of the FinOps toolkit.')
var finOpsToolkitVersion = loadTextContent('ftkver.txt')  // cSpell:ignore ftkver

//==============================================================================
// Functions
//==============================================================================

//------------------------------------------------------------------------------
// Shared
//------------------------------------------------------------------------------

func safeName(name string) string => replace(replace(toLower(name), '-', ''), '_', '')

func idName(name string, resourceType string) IdNameObject => {
  id: resourceId(resourceType, name)
  name: name
}

// cSpell:ignore privatelink
func dnsZoneIdName(type string) IdNameObject => idName('privatelink.${type}.${environment().suffixes.storage}', 'Microsoft.Network/privateDnsZones')

//------------------------------------------------------------------------------
// Hub config
//------------------------------------------------------------------------------

// Internal function to create a new FinOps hub configuration object that includes extra parameters that are reused within the function.
func newHubCoreConfigInternal(
  id string,
  name string,
  safeName string,
  suffix string,
  location string,
  tags object,
  tagsByResource object,
  storageSku string,
  enableInfrastructureEncryption bool,
  enablePublicAccess bool,
  networkName string,
  networkAddressPrefix string,
) HubCoreConfig => {
  hub: {
    id: id
    name: name
    safeName: safeName
    suffix: suffix
    location: location ?? resourceGroup().location
    tags: union(tags, {
      'cm-resource-parent': id  // cm-resource-parent tag groups resources in Cost Management
      'ftk-tool': 'FinOps hubs'
      'ftk-version': finOpsToolkitVersion
    })
    version: finOpsToolkitVersion
  }
  deployment: union(
    { tagsByResource: tagsByResource },
    enablePublicAccess ? {
      storage: ''
    } : {
      storage: '${take(safeName, 16 - length(suffix))}script${suffix}'
    }
  )
  storage: {
    // name: ''
    sku: storageSku
    isInfrastructureEncrypted: enableInfrastructureEncryption
  }
  network: enablePublicAccess ? {
    isPrivate: false
    id: ''
    name: ''
    addressPrefix: ''
    dnsZones: {
      blob: { id: '', name: '' }
      dfs: { id: '', name: '' }
      queue: { id: '', name: '' }
      table: { id: '', name: '' }
    }
    subnets: {
      scripts: ''
      storage: ''
    }
  } : {
    isPrivate: true
    id: resourceId('Microsoft.Network/virtualNetworks', networkName)
    name: networkName
    addressPrefix: networkAddressPrefix
    dnsZones: {
      blob: dnsZoneIdName('blob')
      dfs: dnsZoneIdName('dfs')
      queue: dnsZoneIdName('queue')
      table: dnsZoneIdName('table')
    }
    subnets: {
      scripts: resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'script-subnet')
      storage: resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'private-endpoint-subnet')
    }
  }
}

@export()
@description('Creates a new FinOps hub configuration object.')
func newHubCoreConfig(
  name string,
  location string,
  tags object,
  tagsByResource object,
  storageSku string,
  enableInfrastructureEncryption bool,
  enablePublicAccess bool,
  networkAddressPrefix string,
) HubCoreConfig => newHubCoreConfigInternal(
  '${resourceGroup().id}/providers/Microsoft.Cloud/hubs/${name}',  // id
  name,
  safeName(name),                          // safeName
  uniqueString(name, resourceGroup().id),  // suffix
  location,
  tags,
  tagsByResource,
  storageSku,
  enableInfrastructureEncryption,
  enablePublicAccess,
  '${safeName(name)}-vnet-${location}',    // networkName
  networkAddressPrefix
)

//------------------------------------------------------------------------------
// App config
//------------------------------------------------------------------------------

// Internal function to create a new FinOps hub configuration object that includes extra parameters that are reused within the function.
func newAppInternalConfig(
  coreConfig HubCoreConfig,
  publisher string,
  namespace string,
  publisherSuffix string,
  publisherTags object,
  appName string,
  appNamespace string,
  displayName string,
  version string,
) HubAppConfig => {
  ...coreConfig
  publisher: {
    // id: '${hubResourceId}/publishers/${namespace}'
    name: namespace
    displayName: publisher
    suffix: publisherSuffix
    tags: union(coreConfig.hub.tags, publisherTags)
    storage: '${take(coreConfig.hub.safeName, 24 - length(publisherSuffix))}${publisherSuffix}'
  }
  app: {
    // id: '${hubResourceId}/publishers/${namespace}/apps/${appName}'
    name: appName
    fullName: appNamespace
    displayName: displayName
    // suffix: ''
    tags: union(coreConfig.hub.tags, publisherTags, {
      'ftk-hubapp': appNamespace  // cSpell:ignore hubapp
      'ftk-hubapp-version': version
    })
  }
}

@export()
@description('Creates a new FinOps hub app configuration object.')
func newAppConfig(
  config HubCoreConfig,
  publisher string,
  namespace string,
  appName string,
  displayName string,
  version string,
) HubAppConfig => newAppInternalConfig(
  config,
  publisher,
  namespace,
  !usePublisherSpecificResources || namespace == 'Microsoft.FinOpsToolkit.Hubs' ? config.hub.suffix : uniqueString(namespace),  // publisherSuffix
  { 'ftk-hubapp-publisher': namespace },  // publisherTags
  appName,
  '${namespace}.${appName}',  // appNamespace
  displayName,
  version
)

@export()
@description('Returns a tags dictionary that includes tags for the FinOps hub instance.')
func getHubTags(config HubCoreConfig, resourceType string) object => union(
  config.hub.tags,
  config.deployment.tagsByResource[?resourceType] ?? {}
)

@export()
@description('Returns a tags dictionary that includes tags for the FinOps hub app publisher.')
func getPublisherTags(config HubAppConfig, resourceType string) object => union(
  usePublisherSpecificResources ? config.publisher.tags : config.hub.tags,
  config.deployment.tagsByResource[?resourceType] ?? {}
)

@export()
@description('Returns a tags dictionary that includes tags for the FinOps hub app.')
func getAppTags(config HubAppConfig, resourceType string, forceAppTags bool?) object => union(
  usePublisherSpecificResources || (forceAppTags ?? false) ? config.app.tags : config.hub.tags,
  config.deployment.tagsByResource[?resourceType] ?? {}
)
