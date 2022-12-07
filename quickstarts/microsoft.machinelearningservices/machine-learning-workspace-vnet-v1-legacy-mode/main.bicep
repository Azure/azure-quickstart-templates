@description('Specifies the name of the Azure Machine Learning workspace.')
param workspaceName string

@description('Specifies the location for workspace.')
param location string

@description('Specifies the identity type of the Azure Machine Learning workspace.')
@allowed([
  'systemAssigned'
  'userAssigned'
  'systemAssigned,userAssigned'
])
param identityType string = 'systemAssigned'

@description('Specifies the resource group of user assigned identity that represents the Azure Machine Learing workspace.')
param primaryUserAssignedIdentityResourceGroup string = resourceGroup().name

@description('Specifies the name of user assigned identity that represents the Azure Machine Learing    workspace.')
param primaryUserAssignedIdentityName string = ''

@description('Specifies the resource group of user assigned identity that needs to be used to access the key for encryption.')
param cmkUserAssignedIdentityResourceGroup string = resourceGroup().name

@description('Specifies the name of user assigned identity that needs to be used to access the key for encryption.')
param cmkUserAssignedIdentityName string = ''

@description('Tags for workspace, will also be populated if provisioning new dependent resources.')
param tagValues object = {
}

@description('Determines whether or not a new storage should be provisioned.')
@allowed([
  'new'
  'existing'
])
param storageAccountOption string = 'new'

@description('Name of the storage account.')
param storageAccountName string = 'sa${uniqueString(resourceGroup().id, workspaceName)}'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Determines whether or not to put the storage account behind VNet')
@allowed([
  'true'
  'false'
])
param storageAccountBehindVNet string = 'true'

@description('Resource group name of the storage account if using existing one')
param storageAccountResourceGroupName string = resourceGroup().name

@description('Determines whether or not a new key vault should be provisioned.')
@allowed([
  'new'
  'existing'
])
param keyVaultOption string = 'new'

@description('Name of the key vault.')
param keyVaultName string = 'kv${uniqueString(resourceGroup().id, workspaceName)}'

@description('Determines whether or not to put the storage account behind VNet')
@allowed([
  'true'
  'false'
])
param keyVaultBehindVNet string = 'false'

@description('Resource group name of the key vault if using existing one')
param keyVaultResourceGroupName string = resourceGroup().name

@description('Determines whether or not new ApplicationInsights should be provisioned.')
@allowed([
  'new'
  'existing'
])
param applicationInsightsOption string = 'new'

@description('Name of ApplicationInsights.')
param applicationInsightsName string = 'ai${uniqueString(resourceGroup().id, workspaceName)}'

@description('Resource group name of the application insights if using existing one.')
param applicationInsightsResourceGroupName string = resourceGroup().name

@description('Determines whether or not a new container registry should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param containerRegistryOption string = 'none'

@description('The container registry bind to the workspace.')
param containerRegistryName string = 'cr${uniqueString(resourceGroup().id, workspaceName)}'

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param containerRegistrySku string = 'Standard'

@description('Resource group name of the container registry if using existing one.')
param containerRegistryResourceGroupName string = resourceGroup().name

@description('Determines whether or not to put container registry behind VNet.')
@allowed([
  'true'
  'false'
])
param containerRegistryBehindVNet string = 'false'

@description('Determines whether or not a new VNet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param vnetOption string = ((privateEndpointType == 'none') ? 'none' : 'new')

@description('Name of the VNet')
param vnetName string = 'vn${uniqueString(resourceGroup().id, workspaceName)}'

@description('Resource group name of the VNET if using existing one.')
param vnetResourceGroupName string = resourceGroup().name

@description('Required if existing VNET location differs from workspace location')
param vnetLocation string = location

@description('Address prefix of the virtual network')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Determines whether or not a new subnet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param subnetOption string = (((privateEndpointType != 'none') || (vnetOption == 'new')) ? 'new' : 'none')

@description('Name of the subnet')
param subnetName string = 'sn${uniqueString(resourceGroup().id, workspaceName)}'

@description('Subnet prefix of the virtual network')
param subnetPrefix string = '10.0.0.0/24'

@description('Specifies that the Azure Machine Learning workspace holds highly confidential data.')
@allowed([
  false
  true
])
param confidential_data bool = false

@description('Specifies if the Azure Machine Learning workspace should be encrypted with customer managed key.')
@allowed([
  'Enabled'
  'Disabled'
])
param encryption_status string = 'Disabled'

@description('Specifies the customer managed keyVault arm id. Required when encryption is enabled')
param cmk_keyvault string = ''

@description('Specifies if the customer managed keyvault key uri. Required when encryption is enabled')
param resource_cmk_uri string = ''

@allowed([
  'AutoApproval'
  'ManualApproval'
  'none'
])
param privateEndpointType string = 'none'

var tenantId = subscription().tenantId
var storageAccountId = resourceId(storageAccountResourceGroupName, 'Microsoft.Storage/storageAccounts', storageAccountName)
var keyVaultId = resourceId(keyVaultResourceGroupName, 'Microsoft.KeyVault/vaults', keyVaultName)
var containerRegistryId = resourceId(containerRegistryResourceGroupName, 'Microsoft.ContainerRegistry/registries', containerRegistryName)
var applicationInsightsId = resourceId(applicationInsightsResourceGroupName, 'Microsoft.Insights/components', applicationInsightsName)
var vnetId = resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks', vnetName)
var subnetId = resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
var privateDnsZoneName = {
  azureusgovernment: 'privatelink.api.ml.azure.us'
  azurechinacloud: 'privatelink.api.ml.azure.cn'
  azurecloud: 'privatelink.api.azureml.ms'
}
var privateAznbDnsZoneName = {
  azureusgovernment: 'privatelink.notebooks.usgovcloudapi.net'
  azurecloud: 'privatelink.notebooks.azure.net'
  azurechinacloud: 'privatelink.notebooks.chinacloudapi.cn'
}
var enablePE = (privateEndpointType != 'none')
var networkRuleSetBehindVNet = {
  defaultAction: 'deny'
  virtualNetworkRules: [
    {
      action: 'Allow'
      id: subnetId
    }
  ]
}
var serviceEndpointsAll = [
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.KeyVault'
  }
  {
    service: 'Microsoft.ContainerRegistry'
  }
]
var serviceEndpointsAzureChinaCloud = [
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.KeyVault'
  }
]
var privateEndpointSettings = {
  name: '${workspaceName}-PrivateEndpoint'
  properties: {
    privateLinkServiceId: workspace.id
    groupIds: [
      'amlworkspace'
    ]
  }
}
var defaultPEConnections = array(privateEndpointSettings)
var userAssignedIdentities = union(userAssignedIdentitiesPrimary, userAssignedIdentitiesCmk)
var userAssignedIdentityPrimary = {
  '${primaryUserAssignedIdentity}': {
  }
}
var userAssignedIdentitiesPrimary = ((primaryUserAssignedIdentityName != '') ? userAssignedIdentityPrimary : json('{}'))
var primaryUserAssignedIdentity = resourceId(primaryUserAssignedIdentityResourceGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', primaryUserAssignedIdentityName)
var userAssignedIdentityCmk = {
  '${cmkUserAssignedIdentity}': {
  }
}
var userAssignedIdentitiesCmk = ((cmkUserAssignedIdentityName != '') ? userAssignedIdentityCmk : json('{}'))
var cmkUserAssignedIdentity = resourceId(cmkUserAssignedIdentityResourceGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', cmkUserAssignedIdentityName)
var encryptionUserAssignedIdentity = {
  userAssignedIdentity: cmkUserAssignedIdentity
}
var encryptionIdentity = ((cmkUserAssignedIdentityName != '') ? encryptionUserAssignedIdentity : json('{}'))
var appInsightsLocation = (((location == 'westcentralus') || (location == 'eastus2euap') || (location == 'centraluseuap') || (location == 'westus3')) ? 'southcentralus' : ((location == 'canadaeast') ? 'canadacentral' : location))

resource vNet 'Microsoft.Network/virtualNetworks@2022-05-01' = if (vnetOption == 'new') {
  name: vnetName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource vNetSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = if (subnetOption == 'new') {
  parent: vNet
  name: subnetName
  properties: {
    addressPrefix: subnetPrefix
    serviceEndpoints: ((toLower(environment().name) == 'azurechinacloud') ? serviceEndpointsAzureChinaCloud : serviceEndpointsAll)
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = if (storageAccountOption == 'new') {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  tags: tagValues
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: ((storageAccountBehindVNet == 'true') ? networkRuleSetBehindVNet : json('null'))
  }
  dependsOn: [
    vNetSubnet
  ]
}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = if (keyVaultOption == 'new') {
  name: keyVaultName
  location: location
  tags: tagValues
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    networkAcls: ((keyVaultBehindVNet == 'true') ? networkRuleSetBehindVNet : json('null'))
  }
  dependsOn: [
    vNetSubnet
  ]
}

resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = if (containerRegistryOption == 'new') {
  name: containerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  tags: tagValues
  properties: {
    adminUserEnabled: false
    networkRuleSet: ((containerRegistryBehindVNet == 'true') ? networkRuleSetBehindVNet : json('null'))
  }
  dependsOn: [
    vNetSubnet
  ]
}

resource insight 'Microsoft.Insights/components@2020-02-02' = if (applicationInsightsOption == 'new') {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  tags: tagValues
  properties: {
    Application_Type: 'web'
  }
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  identity: {
    type: identityType
    userAssignedIdentities: (((identityType == 'userAssigned') || (identityType == 'systemAssigned,userAssigned')) ? userAssignedIdentities : json('null'))
  }
  tags: tagValues
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightsId
    containerRegistry: ((containerRegistryOption != 'none') ? containerRegistryId : json('null'))
    primaryUserAssignedIdentity: ((identityType == 'userAssigned') ? primaryUserAssignedIdentity : json('null'))
    encryption: {
      status: encryption_status
      identity: encryptionIdentity
      keyVaultProperties: {
        keyVaultArmId: cmk_keyvault
        keyIdentifier: resource_cmk_uri
      }
    }
    hbiWorkspace: confidential_data
    publicNetworkAccess: 'Disabled'
    v1LegacyMode: true
  }
  dependsOn: [
    storageAccount
    vault
    insight
    registry
  ]
}

module DeployPrivateEndpoints './nested_DeployPrivateEndpoints.bicep' = {
  name: 'DeployPrivateEndpoints'
  scope: resourceGroup(vnetResourceGroupName)
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateAznbDnsZoneName: privateAznbDnsZoneName
    enablePE: enablePE
    defaultPEConnections: defaultPEConnections
    subnetId: subnetId
    vnetId: vnetId
    workspaceName: workspaceName
    vnetLocation: vnetLocation
    tagValues: tagValues
    privateEndpointType: privateEndpointType
  }
  dependsOn: [
    vNetSubnet
  ]
}
