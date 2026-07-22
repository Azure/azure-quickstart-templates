// Parameters
@description('Specifies the name prefix for all the Azure resources.')
@minLength(4)
@maxLength(13)
param prefix string = substring(uniqueString(resourceGroup().id), 0, 4)

@description('Specifies the name suffix or all the Azure resources.')
@minLength(4)
@maxLength(13)
param suffix string = substring(uniqueString(resourceGroup().id), 0, 4)

@description('Specifies the location for all the Azure resources.')
param location string = resourceGroup().location

@description('Specifies the name Azure AI Hub workspace.')
param hubName string = ''

@description('Specifies the friendly name of the Azure AI Hub workspace.')
param hubFriendlyName string = 'Demo AI Hub'

@description('Specifies the description for the Azure AI Hub workspace dispayed in Azure AI Foundry.')
param hubDescription string = 'This is a demo hub for use in Azure AI Foundry.'

@description('Specifies the Isolation mode for the managed network of the Azure AI Hub workspace.')
@allowed([
  'AllowInternetOutbound'
  'AllowOnlyApprovedOutbound'
  'Disabled'
])
param hubIsolationMode string = 'AllowInternetOutbound'

@description('Specifies the public network access for the Azure AI Hub workspace.')
@allowed([
  'Disabled'
  'Enabled'
])
param hubPublicNetworkAccess string = 'Disabled'

@description('Specifies the authentication method for the OpenAI Service connection.')
@allowed([
  'ApiKey'
  'AAD'
  'ManagedIdentity'
  'None'
])
param connectionAuthType string = 'AAD'

@description('Determines whether or not to use credentials for the system datastores of the workspace workspaceblobstore and workspacefilestore. The default value is accessKey, in which case, the workspace will create the system datastores with credentials. If set to identity, the workspace will create the system datastores with no credentials.')
@allowed([
  'identity'
  'accessKey'
])
param systemDatastoresAuthMode string = 'identity'

@description('Specifies the name for the Azure AI Foundry Hub Project workspace.')
param projectName string = ''

@description('Specifies the friendly name for the Azure AI Foundry Hub Project workspace.')
param projectFriendlyName string = 'AI Foundry Hub Project'

@description('Specifies the public network access for the Azure AI Project workspace.')
@allowed([
  'Disabled'
  'Enabled'
])
param projectPublicNetworkAccess string = 'Disabled'

@description('Specifies the name of the Azure Log Analytics resource.')
param logAnalyticsName string = ''

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies the name of the Azure Application Insights resource.')
param applicationInsightsName string = ''

@description('Specifies the name of the Azure AI Services resource.')
param aiServicesName string = ''

@description('Specifies the resource model definition representing SKU.')
param aiServicesSku object = {
  name: 'S0'
}

@description('Specifies the identity of the Azure AI Services resource.')
param aiServicesIdentity object = {
  type: 'SystemAssigned'
}

@description('Specifies an optional subdomain name used for token-based authentication.')
param aiServicesCustomSubDomainName string = ''

@description('Specifies whether disable the local authentication via API key.')
param aiServicesDisableLocalAuth bool = false

@description('Specifies whether or not public endpoint access is allowed for this account..')
@allowed([
  'Enabled'
  'Disabled'
])
param aiServicesPublicNetworkAccess string = 'Enabled'

@description('Specifies the OpenAI deployments to create.')
param openAiDeployments array = [
  {
    model: {
      name: 'text-embedding-ada-002'
      version: '2'
    }
    sku: {
      name: 'Standard'
      capacity: 10
    }
  }
  {
    model: {
      name: 'gpt-4o'
      version: '2024-05-13'
    }
    sku: {
      name: 'Standard'
      capacity: 10
    }
  }
]

@description('Specifies the name of the Azure Key Vault resource.')
param keyVaultName string = ''

@description('Specifies whether to allow public network access for Key Vault.')
@allowed([
  'Disabled'
  'Enabled'
])
param keyVaultPublicNetworkAccess string = 'Disabled'

@description('Specifies the default action of allow or deny when no other rules match for the Azure Key Vault resource. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param keyVaultNetworkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Key Vault resource is enabled for deployments.')
param keyVaultEnabledForDeployment bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param keyVaultEnabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param keyVaultEnabledForTemplateDeployment bool = true

@description('Specifies whether the soft delete is enabled for this Azure Key Vault resource.')
param keyVaultEnableSoftDelete bool = true

@description('Specifies whether purge protection is enabled for this Azure Key Vault resource.')
param keyVaultEnablePurgeProtection bool = true

@description('Specifies whether enable the RBAC authorization for the Azure Key Vault resource.')
param keyVaultEnableRbacAuthorization bool = true

@description('Specifies the soft delete retention in days.')
param keyVaultSoftDeleteRetentionInDays int = 7

@description('Specifies the name of the Azure Container Registry resource.')
param acrName string = ''

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Whether to allow public network access. Defaults to Enabled.')
@allowed([
  'Disabled'
  'Enabled'
])
param acrPublicNetworkAccess string = 'Disabled'

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Specifies whether or not registry-wide pull is enabled from unauthenticated clients.')
param acrAnonymousPullEnabled bool = false

@description('Specifies whether or not a single data endpoint is enabled per region for serving data.')
param acrDataEndpointEnabled bool = false

@description('Specifies the network rule set for the container registry.')
param acrNetworkRuleSet object = {
  defaultAction: 'Deny'
}

@description('Specifies whether to allow trusted Azure services to access a network restricted registry.')
@allowed([
  'AzureServices'
  'None'
])
param acrNetworkRuleBypassOptions string = 'AzureServices'

@description('Specifies whether or not zone redundancy is enabled for this container registry.')
@allowed([
  'Disabled'
  'Enabled'
])
param acrZoneRedundancy string = 'Disabled'

@description('Specifies the name of the Azure Azure Storage Account resource resource.')
param storageAccountName string = ''

@description('Specifies whether to allow public network access for the storage account.')
@allowed([
  'Disabled'
  'Enabled'
])
param storageAccountPublicNetworkAccess string = 'Disabled'

@description('Specifies the access tier of the Azure Storage Account resource. The default value is Hot.')
param storageAccountAccessTier string = 'Hot'

@description('Specifies whether the Azure Storage Account resource allows public access to blobs. The default value is false.')
param storageAccountAllowBlobPublicAccess bool = false

@description('Specifies whether the Azure Storage Account resource allows shared key access. The default value is true.')
param storageAccountAllowSharedKeyAccess bool = false

@description('Specifies whether the Azure Storage Account resource allows cross-tenant replication. The default value is false.')
param storageAccountAllowCrossTenantReplication bool = false

@description('Specifies the minimum TLS version to be permitted on requests to the Azure Storage Account resource. The default value is TLS1_2.')
param storageAccountMinimumTlsVersion string = 'TLS1_2'

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param storageAccountANetworkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Storage Account resource should only support HTTPS traffic.')
param storageAccountSupportsHttpsTrafficOnly bool = true

@description('Specifies the name of the resource group hosting the virtual network and private endpoints.')
param virtualNetworkResourceGroupName string = resourceGroup().name

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = ''

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string = 'VmSubnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string = '10.3.1.0/24'

@description('Specifies the name of the network security group associated to the subnet hosting the virtual machine.')
param vmSubnetNsgName string = ''

@description('Specifies the Bastion subnet IP prefix. This prefix must be within virtual network IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.3.2.0/24'

@description('Specifies the name of the network security group associated to the subnet hosting Azure Bastion.')
param bastionSubnetNsgName string = ''

@description('Specifies whether Azure Bastion should be created.')
param bastionHostEnabled bool = true

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string = ''

@description('Enable/Disable Copy/Paste feature of the Bastion Host resource.')
param bastionHostDisableCopyPaste bool = true

@description('Enable/Disable File Copy feature of the Bastion Host resource.')
param bastionHostEnableFileCopy bool = true

@description('Enable/Disable IP Connect feature of the Bastion Host resource.')
param bastionHostEnableIpConnect bool = true

@description('Enable/Disable Shareable Link of the Bastion Host resource.')
param bastionHostEnableShareableLink bool = true

@description('Enable/Disable Tunneling feature of the Bastion Host resource.')
param bastionHostEnableTunneling bool = true

@description('Specifies the name of the Azure Public IP Address used by the Azure Bastion Host.')
param bastionPublicIpAddressName string = ''

@description('Specifies the name of the Azure Bastion Host SKU.')
param bastionHostSkuName string = 'Standard'

@description('Specifies the name of the Azure NAT Gateway.')
param natGatewayName string = ''

@description('Specifies a list of availability zones denoting the zone in which Nat Gateway should be deployed.')
param natGatewayZones array = []

@description('Specifies the number of Public IPs to create for the Azure NAT Gateway.')
param natGatewayPublicIps int = 1

@description('Specifies the idle timeout in minutes for the Azure NAT Gateway.')
param natGatewayIdleTimeoutMins int = 30

@description('Specifies the name of the private endpoint to the blob storage account.')
param blobStorageAccountPrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the file storage account.')
param fileStorageAccountPrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the Key Vault.')
param keyVaultPrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the Azure Container Registry.')
param acrPrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the Azure Hub Workspace.')
param hubWorkspacePrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the Azure AI Services.')
param aiServicesPrivateEndpointName string = ''

@description('Specifies the name of the virtual machine.')
param vmName string = ''

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_D2ds_v4'

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'MicrosoftWindowsDesktop'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = 'Windows-11'

@description('Specifies the image version for the virtual machine.')
param imageSku string = 'win11-23h2-ent'

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
param vmAdminUsername string

@description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
@secure()
param vmAdminPasswordOrKey string

@description('Specifies the storage account type for OS and data disk.')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param diskStorageAccountType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('Specifies the size in GB of the OS disk of the VM.')
param osDiskSize int = 128

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 50

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies whether enabling Microsoft Entra ID authentication on the virtual machine.')
param enableMicrosoftEntraIdAuth bool = true

@description('Specifies whether enabling accelerated networking on the virtual machine.')
param enableAcceleratedNetworking bool = true

@description('Specifies the resource tags for all the resoources.')
param tags object = {}

@description('Specifies the object id of a Microsoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

// Resources
module workspace 'modules/logAnalytics.bicep' = {
  name: 'workspace'
  params: {
    // properties
    name: empty(logAnalyticsName) ? toLower('${prefix}-log-analytics-${suffix}') : logAnalyticsName
    location: location
    tags: tags
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    // properties
    name: empty(applicationInsightsName) ? toLower('${prefix}-app-insights-${suffix}') : applicationInsightsName
    location: location
    tags: tags
    workspaceId: workspace.outputs.id
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    // properties
    name: empty(keyVaultName) ? ('${prefix}-key-vault-${suffix}') : keyVaultName
    location: location
    tags: tags
    publicNetworkAccess: keyVaultPublicNetworkAccess
    networkAclsDefaultAction: keyVaultNetworkAclsDefaultAction
    enabledForDeployment: keyVaultEnabledForDeployment
    enabledForDiskEncryption: keyVaultEnabledForDiskEncryption
    enabledForTemplateDeployment: keyVaultEnabledForTemplateDeployment
    enablePurgeProtection: keyVaultEnablePurgeProtection
    enableRbacAuthorization: keyVaultEnableRbacAuthorization
    enableSoftDelete: keyVaultEnableSoftDelete
    softDeleteRetentionInDays: keyVaultSoftDeleteRetentionInDays
    workspaceId: workspace.outputs.id

    // role assignments
    userObjectId: userObjectId
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    // properties
    name: empty(acrName) ? toLower('${prefix}acr${suffix}') : acrName
    location: location
    tags: tags
    sku: acrSku
    adminUserEnabled: acrAdminUserEnabled
    anonymousPullEnabled: acrAnonymousPullEnabled
    dataEndpointEnabled: acrDataEndpointEnabled
    networkRuleBypassOptions: acrNetworkRuleBypassOptions
    networkRuleSet: acrNetworkRuleSet
    publicNetworkAccess: acrPublicNetworkAccess
    zoneRedundancy: acrZoneRedundancy
    workspaceId: workspace.outputs.id
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    // properties
    name: empty(storageAccountName) ? toLower('${prefix}datastore${suffix}') : storageAccountName
    location: location
    tags: tags
    publicNetworkAccess: storageAccountPublicNetworkAccess
    accessTier: storageAccountAccessTier
    allowBlobPublicAccess: storageAccountAllowBlobPublicAccess
    allowSharedKeyAccess: storageAccountAllowSharedKeyAccess
    allowCrossTenantReplication: storageAccountAllowCrossTenantReplication
    minimumTlsVersion: storageAccountMinimumTlsVersion
    networkAclsDefaultAction: storageAccountANetworkAclsDefaultAction
    supportsHttpsTrafficOnly: storageAccountSupportsHttpsTrafficOnly
    workspaceId: workspace.outputs.id

    // role assignments
    userObjectId: userObjectId
    aiServicesPrincipalId: aiServices.outputs.principalId
  }
}

module aiServices 'modules/aiServices.bicep' = {
  name: 'aiServices'
  params: {
    // properties
    name: empty(aiServicesName) ? toLower('${prefix}-ai-services-${suffix}') : aiServicesName
    location: location
    tags: tags
    sku: aiServicesSku
    identity: aiServicesIdentity
    customSubDomainName: empty(aiServicesCustomSubDomainName)
      ? toLower('${prefix}-ai-services-${suffix}')
      : aiServicesCustomSubDomainName
    disableLocalAuth: aiServicesDisableLocalAuth
    publicNetworkAccess: aiServicesPublicNetworkAccess
    deployments: openAiDeployments
    workspaceId: workspace.outputs.id

    // role assignments
    userObjectId: userObjectId
  }
}

module network './modules/virtualNetwork.bicep' = {
  name: 'network'
  scope: resourceGroup(virtualNetworkResourceGroupName)
  params: {
    virtualNetworkName: empty(virtualNetworkName) ? toLower('${prefix}-vnet-${suffix}') : virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    vmSubnetName: vmSubnetName
    vmSubnetAddressPrefix: vmSubnetAddressPrefix
    vmSubnetNsgName: empty(vmSubnetNsgName) ? toLower('${prefix}-vm-subnet-nsg-${suffix}') : vmSubnetNsgName
    bastionHostEnabled: bastionHostEnabled
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
    bastionSubnetNsgName: empty(bastionSubnetNsgName) ? toLower('${prefix}-bastion-subnet-nsg-${suffix}') : bastionSubnetNsgName
    bastionHostName: empty(bastionHostName) ? toLower('${prefix}-bastion-host-${suffix}') : bastionHostName
    bastionHostDisableCopyPaste: bastionHostDisableCopyPaste
    bastionHostEnableFileCopy: bastionHostEnableFileCopy
    bastionHostEnableIpConnect: bastionHostEnableIpConnect
    bastionHostEnableShareableLink: bastionHostEnableShareableLink
    bastionHostEnableTunneling: bastionHostEnableTunneling
    bastionPublicIpAddressName: empty(bastionPublicIpAddressName) ? toLower('${prefix}-bastion-host-pip-${suffix}') : bastionPublicIpAddressName
    bastionHostSkuName: bastionHostSkuName
    natGatewayName: empty(natGatewayName) ? toLower('${prefix}-nat-gateway-${suffix}') : natGatewayName
    natGatewayZones: natGatewayZones
    natGatewayPublicIps: natGatewayPublicIps
    natGatewayIdleTimeoutMins: natGatewayIdleTimeoutMins
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module privateEndpoints './modules/privateEndpoints.bicep' = {
  name: 'privateEndpoints'
  scope: resourceGroup(virtualNetworkResourceGroupName)
  params: {
    subnetId: network.outputs.vmSubnetId
    blobStorageAccountPrivateEndpointName: empty(blobStorageAccountPrivateEndpointName) ? toLower('${prefix}-blob-storage-pe-${suffix}') : blobStorageAccountPrivateEndpointName
    fileStorageAccountPrivateEndpointName: empty(fileStorageAccountPrivateEndpointName) ? toLower('${prefix}-file-storage-pe-${suffix}') : fileStorageAccountPrivateEndpointName
    keyVaultPrivateEndpointName: empty(keyVaultPrivateEndpointName) ? toLower('${prefix}-key-vault-pe-${suffix}') : keyVaultPrivateEndpointName
    acrPrivateEndpointName: empty(acrPrivateEndpointName) ? toLower('${prefix}-container-registry-pe-${suffix}') : acrPrivateEndpointName
    storageAccountId: storageAccount.outputs.id
    keyVaultId: keyVault.outputs.id
    acrId: containerRegistry.outputs.id
    createAcrPrivateEndpoint: containerRegistry.outputs.sku == 'Premium'
    hubWorkspacePrivateEndpointName: empty(hubWorkspacePrivateEndpointName) ? toLower('${prefix}-hub-workspace-pe-${suffix}') : hubWorkspacePrivateEndpointName
    hubWorkspaceId: hub.outputs.id
    aiServicesPrivateEndpointName: empty(aiServicesPrivateEndpointName) ? toLower('${prefix}-ai-services-pe-${suffix}') : aiServicesPrivateEndpointName
    aiServicesId: aiServices.outputs.id
    location: location
    tags: tags
  }
  dependsOn: [
    network
  ]
}

module virtualMachine './modules/virtualMachine.bicep' = {
  name: 'virtualMachine'
  params: {
    vmName: empty(vmName) ? toLower('${prefix}-jb-vm-${suffix}') : vmName
    vmNicName: empty(vmName) ? toLower('${prefix}-jb-nic-${suffix}') : vmName
    vmSize: vmSize
    vmSubnetId: network.outputs.vmSubnetId
    storageAccountName: storageAccount.outputs.name
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    authenticationType: authenticationType
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey
    diskStorageAccountType: diskStorageAccountType
    numDataDisks: numDataDisks
    osDiskSize: osDiskSize
    dataDiskSize: dataDiskSize
    dataDiskCaching: dataDiskCaching
    enableAcceleratedNetworking: enableAcceleratedNetworking
    enableMicrosoftEntraIdAuth: enableMicrosoftEntraIdAuth
    userObjectId: userObjectId
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module hub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    // workspace organization
    name: empty(hubName) ? toLower('${prefix}-hub-${suffix}') : hubName
    friendlyName: hubFriendlyName
    description_: hubDescription
    location: location
    tags: tags

    // dependent resources
    aiServicesName: aiServices.outputs.name
    applicationInsightsId: applicationInsights.outputs.id
    containerRegistryId: containerRegistry.outputs.id
    keyVaultId: keyVault.outputs.id
    storageAccountId: storageAccount.outputs.id
    connectionAuthType: connectionAuthType
    systemDatastoresAuthMode: systemDatastoresAuthMode

    // workspace configuration
    publicNetworkAccess: hubPublicNetworkAccess
    isolationMode: hubIsolationMode
    workspaceId: workspace.outputs.id

    // role assignments
    userObjectId: userObjectId
  }
}

module project 'modules/project.bicep' = {
  name: 'project'
  params: {
    // workspace organization
    name: empty(projectName) ? toLower('${prefix}-project-${suffix}') : projectName
    friendlyName: projectFriendlyName
    location: location
    tags: tags

    // workspace configuration
    publicNetworkAccess: projectPublicNetworkAccess
    hubId: hub.outputs.id
    workspaceId: workspace.outputs.id

    // role assignments
    userObjectId: userObjectId
    aiServicesPrincipalId: aiServices.outputs.principalId
  }
}

output deploymentInfo object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: resourceGroup().name
  location: location
  storageAccountName: storageAccount.outputs.name
  aiServicesName: aiServices.outputs.name
  aiServicesEndpoint: aiServices.outputs.endpoint
  hubName: hub.outputs.name
  projectName: project.outputs.name
}
