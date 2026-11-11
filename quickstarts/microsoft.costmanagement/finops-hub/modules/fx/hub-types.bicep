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

@description('FinOps hub private network routing properties.')
@metadata({
  networkId: 'Resource ID of the FinOps hub isolated virtual network, if private network routing is enabled.'
  networkName: 'Name of the FinOps hub isolated virtual network, if private network routing is enabled.'
  scriptStorage: 'Name of the storage account used for deployment scripts.'
  dnsZones: {
    blob: 'Resource ID and name for the blob storage DNS zone.'
    dfs: 'Resource ID and name for the DFS storage DNS zone.'
    file: 'Resource ID and name for the file storage DNS zone.'
    queue: 'Resource ID and name for the queue storage DNS zone.'
    table: 'Resource ID and name for the table storage DNS zone.'
  }
  subnets: {
    dataExplorer: 'Resource ID of the subnet for the Data Explorer instance.'
    dataFactory: 'Resource ID of the subnet for Data Factory instances.'
    keyVault: 'Resource ID of the subnet for Key Vault instances.'
    scripts: 'Resource ID of the subnet for deployment script storage.'
    storage: 'Resource ID of the subnet for storage accounts.'
  }
})
type HubRoutingProperties = {
  networkId: string
  networkName: string
  scriptStorage: string
  dnsZones: {
    blob: IdNameObject
    dfs: IdNameObject
    file: IdNameObject
    queue: IdNameObject
    table: IdNameObject
  }
  subnets: {
    dataExplorer: string
    dataFactory: string
    keyVault: string
    scripts: string
    storage: string
  }
}

@export()
@description('FinOps hub instance properties.')
@metadata({
  id: 'FinOps hub resource ID.'
  name: 'FinOps hub instance name.'
  location: 'Azure resource location of the FinOps hub instance.'
  tags: 'Tags to apply to all FinOps hub resources.'
  tagsByResource: 'Tags to apply to resources based on their resource type.'
  version: 'FinOps hub version number.'
  options: {
    enableTelemetry: 'Indicates whether telemetry should be enabled for deployments.'
    keyVaultSku: 'KeyVault SKU. Allowed values: "standard", "premium".'
    keyVaultEnablePurgeProtection: 'Indicates whether purge protection is enabled for the Key Vault. When enabled, deleted Key Vault and its secrets cannot be permanently deleted until the retention period expires, which is required for compliance in some environments.'
    networkAddressPrefix: 'Address prefix for the FinOps hub isolated virtual network, if private network routing is enabled.'
    natGateway: 'Indicates whether a NAT Gateway should be deployed for controlled outbound internet access. When enabled, the script and Data Explorer subnets route outbound traffic through the NAT Gateway.'
    privateRouting: 'Indicates whether private network routing is enabled.'
    publisherIsolation: 'Indicates whether FinOps hub resources should be separated by publisher for advanced security.'
    storageInfrastructureEncryption: 'Indicates whether infrastructure encryption is enabled for the storage account.'
    storageSku: 'Storage account SKU. Allowed values: "Premium_LRS", "Premium_ZRS".'
  }
  routing: 'FinOps hub private network routing properties, if enabled.'
  core: {
    suffix: 'Unique suffix used for shared resources.'
  }
  apps: {
  }
})
type HubProperties = {
  id: string
  name: string
  location: string
  tags: object
  tagsByResource: object
  version: string
  options: {
    enableTelemetry: bool
    keyVaultSku: string
    keyVaultEnablePurgeProtection: bool
    networkAddressPrefix: string
    natGateway: bool
    privateRouting: bool
    publisherIsolation: bool
    storageInfrastructureEncryption: bool
    storageSku: string
  }
  routing: HubRoutingProperties
  core: {
    suffix: string
  }
}

//------------------------------------------------------------------------------
// App config
//------------------------------------------------------------------------------

@export()
@description('FinOps hub app configuration settings.')
@metadata({
  id: 'Fully-qualified name of the publisher and app, separated by a dot.'
  name: 'Short name of the FinOps hub app. Last segment of the app ID.'
  publisher: 'Fully-qualified namespace of the FinOps hub app publisher.'
  suffix: 'Unique suffix used for publisher resources.'
  tags: 'Tags to apply to all FinOps hub resources for this FinOps hub app publisher. Tags are not specific to the app since resources are shared.'
  dataFactory: 'Name of the Data Factory instance for this publisher.'
  keyVault: 'Name of the KeyVault instance for this publisher.'
  storage: 'Name of the storage account for this publisher.'
  hub: 'FinOps hub instance the app is deployed to.'
})
type HubAppProperties = {
  id: string
  name: string
  publisher: string
  suffix: string
  tags: object
  dataFactory: string
  keyVault: string
  storage: string
  hub: HubProperties
}

@export()
@description('FinOps hub app features.')
type HubAppFeature = 'DataFactory' | 'KeyVault' | 'Storage'


//==============================================================================
// Variables
//==============================================================================

@export()
@description('Version of the FinOps toolkit.')
var finOpsToolkitVersion = loadTextContent('ftkver.txt')  // cSpell:ignore ftkver


//==============================================================================
// Functions
//==============================================================================

//------------------------------------------------------------------------------
// Shared
//------------------------------------------------------------------------------

func safeStorageName(name string) string => replace(replace(toLower(name), '-', ''), '_', '')

@description('Converts a version string (e.g., "13.0", "13.1", "14.0-dev") to a comparable integer using major * 1000 + minor. Prerelease suffixes (e.g., "-dev") and patch versions are ignored.')
func versionToNumber(version string) int => int(split(split(version, '-')[0], '.')[0]) * 1000 + (length(split(split(version, '-')[0], '.')) > 1 ? int(split(split(version, '-')[0], '.')[1]) : 0)

@export()
@description('Checks if a version string falls within the specified range. Use empty string to skip a bound. Example: isSupportedVersion(\'13.1\', \'13.0\', \'\') checks >= 13.0 with no upper limit.')
func isSupportedVersion(version string, minVersion string, maxVersion string) bool => (empty(minVersion) || versionToNumber(version) >= versionToNumber(minVersion)) && (empty(maxVersion) || versionToNumber(version) <= versionToNumber(maxVersion))

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
func newHubInternal(
  id string,
  name string,
  suffix string,
  location string,
  tags object,
  tagsByResource object,
  storageSku string,
  keyVaultSku string,
  keyVaultEnablePurgeProtection bool,
  enableInfrastructureEncryption bool,
  enablePublicAccess bool,
  enableNatGateway bool,
  networkName string,
  networkAddressPrefix string,
  isTelemetryEnabled bool,
) HubProperties => {
  id: id
  name: name
  location: location ?? resourceGroup().location
  tags: union(tags, {
    'cm-resource-parent': id  // cm-resource-parent tag groups resources in Cost Management
    'ftk-tool': 'FinOps hubs'
    'ftk-version': finOpsToolkitVersion
  })
  tagsByResource: tagsByResource
  version: finOpsToolkitVersion
  options: {
    enableTelemetry: isTelemetryEnabled ?? true
    keyVaultSku: keyVaultSku
    keyVaultEnablePurgeProtection: keyVaultEnablePurgeProtection
    networkAddressPrefix: networkAddressPrefix
    natGateway: !enablePublicAccess && enableNatGateway
    privateRouting: !enablePublicAccess
    publisherIsolation: false  // TODO: Expose publisher isolation option
    storageInfrastructureEncryption: enableInfrastructureEncryption
    storageSku: storageSku
  }
  routing: {
    networkId: enablePublicAccess ? '' : resourceId('Microsoft.Network/virtualNetworks', networkName)
    networkName: enablePublicAccess ? '' : networkName
    scriptStorage: enablePublicAccess ? '' : '${take(safeStorageName(name), 16 - length(suffix))}script${suffix}'
    dnsZones: {
      blob:  enablePublicAccess ? { id:'', name:'' } : dnsZoneIdName('blob')
      dfs:   enablePublicAccess ? { id:'', name:'' } : dnsZoneIdName('dfs')
      file:  enablePublicAccess ? { id:'', name:'' } : dnsZoneIdName('file')
      queue: enablePublicAccess ? { id:'', name:'' } : dnsZoneIdName('queue')
      table: enablePublicAccess ? { id:'', name:'' } : dnsZoneIdName('table')
    }
    subnets: {
      dataExplorer: enablePublicAccess ? '' : resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'dataExplorer-subnet')!
      dataFactory:  enablePublicAccess ? '' : resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'private-endpoint-subnet')!
      keyVault:     enablePublicAccess ? '' : resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'private-endpoint-subnet')!
      scripts:      enablePublicAccess ? '' : resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'script-subnet')!
      storage:      enablePublicAccess ? '' : resourceId('Microsoft.Network/virtualNetworks/subnets', networkName, 'private-endpoint-subnet')!
    }
  }
  core: {
    suffix: suffix
  }
}

@export()
@description('Creates a new FinOps hub configuration object.')
func newHub(
  name string,
  location string,
  tags object,
  tagsByResource object,
  storageSku string,
  keyVaultSku string,
  keyVaultEnablePurgeProtection bool,
  enableInfrastructureEncryption bool,
  enablePublicAccess bool,
  enableNatGateway bool,
  networkAddressPrefix string,
  isTelemetryEnabled bool,
) HubProperties => newHubInternal(
  '${resourceGroup().id}/providers/Microsoft.Cloud/hubs/${name}',  // id
  name,
  uniqueString(name, resourceGroup().id),  // suffix
  location,
  tags,
  tagsByResource,
  storageSku,
  keyVaultSku,
  keyVaultEnablePurgeProtection,
  enableInfrastructureEncryption,
  enablePublicAccess,
  enableNatGateway,
  '${safeStorageName(name)}-vnet-${location}',    // networkName, cSpell:ignore vnet
  networkAddressPrefix,
  isTelemetryEnabled ?? true
)

//------------------------------------------------------------------------------
// App config
//------------------------------------------------------------------------------

// Internal function to create a new FinOps hub configuration object that includes extra parameters that are reused within the function.
func newAppInternal(
  hub HubProperties,
  id string,
  name string,
  publisher string,
  suffix string,
) HubAppProperties => {
  id: id
  name: name
  publisher: publisher
  suffix: suffix
  tags: union(
    hub.tags,
    { 'ftk-hubapp-publisher': publisher }  // publisherTags
    // TODO: How do we want to handle app-specific tags?
    // {
    //   'ftk-hubapp': appName  // cSpell:ignore hubapp
    //   'ftk-hubapp-version': version
    // }
  )
  hub: hub

  // Globally unique Data Factory name: 3-63 chars; letters, numbers, non-repeating dashes
  dataFactory: replace('${take('${replace(hub.name, '_', '-')}-engine', 63 - length(suffix) - 1)}-${suffix}', '--', '-')

  // Globally unique KeyVault name: 3-24 chars; letters, numbers, dashes
  keyVault: replace('${take('${replace(hub.name, '_', '-')}-vault', 24 - length(suffix) - 1)}-${suffix}', '--', '-')

  // Globally unique storage account name: 3-24 chars; lowercase letters/numbers only
  storage: '${take(safeStorageName(hub.name), 24 - length(suffix))}${suffix}'
}

@export()
@description('Creates a new FinOps hub app configuration object.')
func newApp(
  hub HubProperties,
  publisher string,
  app string,
) HubAppProperties => newAppInternal(
  hub,
  '${publisher}.${app}',  // id
  app,
  publisher,
  !hub.options.publisherIsolation || publisher == 'Microsoft.FinOpsHubs' ? hub.core.suffix : uniqueString(publisher)  // publisher suffix
)

@export()
@description('Returns a tags dictionary that includes tags for the FinOps hub instance.')
func getHubTags(hub HubProperties, resourceType string) object => union(
  hub.tags,
  hub.tagsByResource[?resourceType] ?? {}
)

@export()
@description('Returns a tags dictionary that includes tags for the FinOps hub app publisher.')
func getAppPublisherTags(app HubAppProperties, resourceType string) object => union(
  app.hub.options.publisherIsolation ? app.tags : app.hub.tags,
  app.hub.tagsByResource[?resourceType] ?? {}
)


//------------------------------------------------------------------------------
// Private routing
//------------------------------------------------------------------------------

@export()
@description('Returns an object that represents the properties needed to enable private routing for linked services. Use property expansion (`...value`) to apply to a linkedServices resource.')
func privateRoutingForLinkedServices(hub HubProperties) object => hub.options.privateRouting ? {
  connectVia: {
    referenceName: 'ManagedIntegrationRuntime'
    type: 'IntegrationRuntimeReference'
  }
} : {}
