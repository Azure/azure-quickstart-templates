@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the AKS cluster.')
param aksClusterName string = 'aks-${uniqueString(resourceGroup().id)}'

@description('Specifies the DNS prefix specified when creating the managed cluster.')
param aksClusterDnsPrefix string = aksClusterName

@description('Specifies the tags of the AKS cluster.')
param aksClusterTags object = {
  resourceType: 'AKS Cluster'
  createdBy: 'ARM Template'
}

@description('Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
@allowed([
  'azure'
  'kubenet'
])
param aksClusterNetworkPlugin string = 'azure'

@description('Specifies the network policy used for building Kubernetes network. - calico or azure')
@allowed([
  'azure'
  'calico'
])
param aksClusterNetworkPolicy string = 'azure'

@description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param aksClusterPodCidr string = '10.244.0.0/16'

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param aksClusterServiceCidr string = '10.3.0.0/16'

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = '10.3.0.10'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
])
param aksClusterOutboundType string = 'loadBalancer'

@description('Specifies the tier of a managed cluster SKU: Automatic or Base')
@allowed([
  'Automatic'
  'Base'
])
param aksClusterSkuName string = 'Base'

@description('Specifies the tier of a managed cluster SKU: Free, Premium or Standard')
@allowed([
  'Free'
  'Premium'
  'Standard'
])
param aksClusterSkuTier string = 'Standard'

@description('Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string

@description('Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string

@description('Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = false

@description('Specifies the unique name of of the system node pool profile in the context of the subscription and resource group.')
param systemNodePoolName string = 'system'

@description('Specifies the vm size of nodes in the system node pool.')
param systemNodePoolVmSize string = 'Standard_D16s_v3'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param systemNodePoolOsDiskSizeGB int = 100

@description('Specifies the number of agents (VMs) to host docker containers in the system node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param systemNodePoolAgentCount int = 3

@description('Specifies the OS type for the vms in the system node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param systemNodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node in the system node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param systemNodePoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the system node pool.')
param systemNodePoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the system node pool.')
param systemNodePoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the system node pool.')
param systemNodePoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the system node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param systemNodePoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param systemNodePoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the type for the system node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param systemNodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the unique name of of the user node pool profile in the context of the subscription and resource group.')
param userNodePoolName string = 'user'

@description('Specifies the vm size of nodes in the user node pool.')
param userNodePoolVmSize string = 'Standard_D16s_v3'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param userNodePoolOsDiskSizeGB int = 100

@description('Specifies the number of agents (VMs) to host docker containers in the user node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param userNodePoolAgentCount int = 3

@description('Specifies the OS type for the vms in the user node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param userNodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node in the user node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param userNodePoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the user node pool.')
param userNodePoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the user node pool.')
param userNodePoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the user node pool.')
param userNodePoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the user node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param userNodePoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param userNodePoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the type for the user node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param userNodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies whether the httpApplicationRouting add-on is enabled or not.')
param httpApplicationRoutingEnabled bool = false

@description('Specifies whether the aciConnectorLinux add-on is enabled or not.')
param aciConnectorLinuxEnabled bool = false

@description('Specifies whether the azurepolicy add-on is enabled or not.')
param azurePolicyEnabled bool = true

@description('Specifies whether the kubeDashboard add-on is enabled or not.')
param kubeDashboardEnabled bool = false

@description('Specifies whether the pod identity addon is enabled..')
param podIdentityProfileEnabled bool = false

@description('Specifies the scan interval of the auto-scaler of the AKS cluster.')
param autoScalerProfileScanInterval string = '10s'

@description('Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

@description('Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

@description('Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

@description('Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnneededTime string = '10m'

@description('Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnreadyTime string = '20m'

@description('Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
param autoScalerProfileUtilizationThreshold string = '0.5'

@description('Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
param autoScalerProfileMaxGracefulTerminationSec string = '600'

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = '${aksClusterName}Vnet'

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet hosting the system node pool of the AKS cluster.')
param aksSubnetName string = 'AksSubnet'

@description('Specifies the address prefix of the subnet hosting the system node pool of the AKS cluster.')
param aksSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string = '${aksClusterName}Workspace'

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerGB2018'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string = 'VmSubnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string = '10.1.0.0/16'

@description('Specifies the name of the subnet which contains the the Application Gateway.')
param applicationGatewaySubnetName string = 'AppGatewaySubnet'

@description('Specifies the address prefix of the subnet which contains the Application Gateway.')
param applicationGatewaySubnetAddressPrefix string = '10.2.0.0/24'

@description('Specifies the name of the virtual machine.')
param vmName string = 'TestVm'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_D4s_v3'

@description('The publisher of the image from which to launch the virtual machine.')
param imagePublisher string = 'Canonical'

@description('The offer of the image from which to launch the virtual machine.')
param imageOffer string = '0001-com-ubuntu-server-jammy'

@description('The SKU of the image from which to launch the virtual machine.')
param imageSku string = '22_04-lts-gen2'

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
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
])
param diskStorageAccounType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('Specifies the size in GB of the OS disk of the VM.')
param osDiskSize int = 50

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 50

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies the globally unique name for the storage account used to store the boot diagnostics logs of the virtual machine.')
param blobStorageAccountName string = 'boot${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param blobStorageAccountPrivateEndpointName string = 'BlobStorageAccountPrivateEndpoint'

@description('Specifies the name of the private link to the Azure Container Registry.')
param acrPrivateEndpointName string = 'AcrPrivateEndpoint'

@description('Name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param acrNetworkRuleSetDefaultAction string = 'Deny'

@description('Whether or not public network access is allowed for the container registry. Allowed values: Enabled or Disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param acrPublicNetworkAccess string = 'Enabled'

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.2.1.0/24'

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string = '${aksClusterName}Bastion'

@description('Specifies the name of the private link to the Key Vault.')
param keyVaultPrivateEndpointName string = 'KeyVaultPrivateEndpoint'

@description('Specifies the name of the Key Vault resource.')
param keyVaultName string = 'keyvault-${uniqueString(resourceGroup().id)}'

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param keyVaultNetworkRuleSetDefaultAction string = 'Deny'

@description('Specifies the name of the Application Gateway.')
param applicationGatewayName string = 'appgw-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the WAF policy')
param wafPolicyName string = '${applicationGatewayName}WafPolicy'

@description('Specifies the mode of the WAF policy.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string = 'Prevention'

@description('Specifies the state of the WAF policy.')
@allowed([
  'Enabled'
  'Disabled '
])
param wafPolicyState string = 'Enabled'

@description('Specifies the maximum file upload size in Mb for the WAF policy.')
param wafPolicyFileUploadLimitInMb int = 100

@description('Specifies the maximum request body size in Kb for the WAF policy.')
param wafPolicyMaxRequestBodySizeInKb int = 128

@description('Specifies the whether to allow WAF to check request Body.')
param wafPolicyRequestBodyCheck bool = true

@description('Specifies the rule set type.')
param wafPolicyRuleSetType string = 'OWASP'

@description('Specifies the rule set version.')
param wafPolicyRuleSetVersion string = '3.1'


@description('Unique name (within the Resource Group) for the Action group.')
param actionGroupName string = 'actiongroup${uniqueString(resourceGroup().id)}'

@description('Short name (maximum 12 characters) for the Action group.')
param actionGroupShortName string = 'actiongroup'

@description('The list of email receivers that are part of this action group.')
param emailReceivers array = [
  {
    name: 'contosoEmail'
    emailAddress: 'devops@contoso.com'
  }
]

@description('The list of SMS receivers that are part of this action group.')
param smsReceivers array = [
  {
    name: 'smsReceiver'
    countryCode: '1'
    phoneNumber: '2134567891'
  }
]

@description('The list of voice receivers that are part of this action group.')
param voiceReceivers array = [
  {
    name: 'voiceReceiver'
    countryCode: '1'
    phoneNumber: '2134567891'
  }
]


var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var readerRoleDefinitionName = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var contributorRoleDefinitionName = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var acrPullRoleDefinitionName = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var aksClusterUserDefinedManagedIdentityName = '${aksClusterName}ManagedIdentity'
var aadPodIdentityUserDefinedManagedIdentityName = '${aksClusterName}AadPodManagedIdentity'
var vmNicName = '${vmName}Nic'
var blobPublicDNSZoneForwarder = 'blob.${environment().suffixes.storage}'
var blobPrivateDnsZoneName = 'privatelink.${blobPublicDNSZoneForwarder}'
var blobStorageAccountPrivateEndpointGroupName = 'blob'
var blobPrivateDnsZoneGroupName = '${blobStorageAccountPrivateEndpointGroupName}PrivateDnsZoneGroup'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${vmAdminUsername}/.ssh/authorized_keys'
        keyData: vmAdminPasswordOrKey
      }
    ]
  }
  provisionVMAgent: true
}

var workspaceId = monitoring.outputs.logAnalyticsWorkspaceId
var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleDefinitionName)
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionName)
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionName)

var containerInsightsSolutionName = 'ContainerInsights(${logAnalyticsWorkspaceName})'
var acrPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? 'azurecr.us' : 'azurecr.io')
var acrPrivateDnsZoneName = 'privatelink.${acrPublicDNSZoneForwarder}'
var acrPrivateEndpointGroupName = 'registry'
var acrPrivateDnsZoneGroupName = '${acrPrivateEndpointGroupName}PrivateDnsZoneGroup'

var keyVaultPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment')
  ? '.vaultcore.usgovcloudapi.net'
  : '.vaultcore.azure.net')
var keyVaultPrivateDnsZoneName = 'privatelink${keyVaultPublicDNSZoneForwarder}'
var keyVaultPrivateEndpointGroupName = 'vault'
var keyVaultPrivateDnsZoneGroupName = '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup'

module monitoring 'modules/monitoring/monitoring.bicep' = {
  name: 'monitoringComponent'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsSku: logAnalyticsSku
    logAnalyticsRetentionInDays: logAnalyticsRetentionInDays
    containerInsightsSolutionName: containerInsightsSolutionName
    actionGroupName: actionGroupName
    actionGroupShortName: actionGroupShortName
    emailReceivers: emailReceivers
    smsReceivers: smsReceivers
    voiceReceivers: voiceReceivers
  }
}

module identity 'modules/identity/identity.bicep' = {
  name: 'identityComponent'
  params: {
    location: location
    applicationGatewayName: applicationGatewayName
    aksClusterUserDefinedManagedIdentityName: aksClusterUserDefinedManagedIdentityName
    aadPodIdentityUserDefinedManagedIdentityName: aadPodIdentityUserDefinedManagedIdentityName
  }
}

module network 'modules/networks/main.bicep' = {
  name: 'networkComponent'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    aksSubnetName: aksSubnetName
    aksSubnetAddressPrefix: aksSubnetAddressPrefix
    vmSubnetName: vmSubnetName
    vmSubnetAddressPrefix: vmSubnetAddressPrefix
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetAddressPrefix: applicationGatewaySubnetAddressPrefix
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
    bastionHostName: bastionHostName
    workspaceId: workspaceId
  }
}

module keyvault 'modules/security/keyvault.bicep' = {
  name: 'keyVaultComponent'
  params: {
    location: location
    keyVaultName: keyVaultName
    aadPodIdentityUserDefinedManagedIdentityTenantId: identity.outputs.aadPodIdentityUserDefinedManagedIdentityTenantId
    aadPodIdentityUserDefinedManagedIdentityPrincipalId: identity.outputs.aadPodIdentityUserDefinedManagedIdentityPrincipalId
    applicationGatewayUserDefinedManagedIdentityTenantId: identity.outputs.applicationGatewayUserDefinedManagedIdentityTenantId
    applicationGatewayUserDefinedManagedIdentityPrincipalId: identity.outputs.applicationGatewayUserDefinedManagedIdentityPrincipalId
    keyVaultNetworkRuleSetDefaultAction: keyVaultNetworkRuleSetDefaultAction
    workspaceId: workspaceId
    readerRoleId: readerRoleId
    keyVaultPrivateDnsZoneName: keyVaultPrivateDnsZoneName
    virtualNetworkName: virtualNetworkName
    virtualNetworkId: network.outputs.virtualNetworkId
    privateEndpointSubnetId: network.outputs.vmSubnetId
    keyVaultPrivateEndpointName: keyVaultPrivateEndpointName
    keyVaultPrivateEndpointGroupName: keyVaultPrivateEndpointGroupName
    keyVaultPrivateDnsZoneGroupName: keyVaultPrivateDnsZoneGroupName
  }
}

module compute 'modules/computes/virtualmachine.bicep' = {
  name: 'virtualMachineComponent'
  params: {
    location: location
    virtualNetworkId: network.outputs.virtualNetworkId
    blobStorageAccountName: blobStorageAccountName
    blobPrivateDnsZoneName: blobPrivateDnsZoneName
    blobStorageAccountPrivateEndpointName: blobStorageAccountPrivateEndpointName
    blobStorageAccountPrivateEndpointGroupName: blobStorageAccountPrivateEndpointGroupName
    blobPrivateDnsZoneGroupName: blobPrivateDnsZoneGroupName
    vmNicName: vmNicName
    vmSubnetId: network.outputs.vmSubnetId
    vmName: vmName
    vmSize: vmSize
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey
    authenticationType: authenticationType
    linuxConfiguration: linuxConfiguration
    securityType: securityType
    securityProfileJson: securityProfileJson
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    osDiskSize: osDiskSize
    diskStorageAccounType: diskStorageAccounType
    numDataDisks: numDataDisks
    dataDiskCaching: dataDiskCaching
    dataDiskSize: dataDiskSize
    extensionPublisher: extensionPublisher
    extensionName: extensionName
    extensionVersion: extensionVersion
    maaTenantName: maaTenantName
  }
}

module applicateGateway 'modules/networks/applicationgateway.bicep' = {
  name: 'applicationGatewayComponent'
  params: {
    location: location
    workspaceId: workspaceId
    applicationGatewayName: applicationGatewayName
    applicationGatewaySubnetId: network.outputs.applicationGatewaySubnetId
    wafPolicyName: wafPolicyName
    wafPolicyMode: wafPolicyMode
    wafPolicyState: wafPolicyState
    wafPolicyFileUploadLimitInMb: wafPolicyFileUploadLimitInMb
    wafPolicyMaxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
    wafPolicyRequestBodyCheck: wafPolicyRequestBodyCheck
    wafPolicyRuleSetType: wafPolicyRuleSetType
    wafPolicyRuleSetVersion: wafPolicyRuleSetVersion
    applicationGatewayUserDefinedManagedIdentityId: identity.outputs.applicationGatewayUserDefinedManagedIdentityId
  }
}

module kubernetes 'modules/containerservices/kubernetes.bicep' = {
  name: 'kubernetesComponent'
  params: {
    location: location
    aksClusterUserDefinedManagedIdentityPrincipalId: identity.outputs.aksClusterUserDefinedManagedIdentityPrincipalId
    aksClusterUserDefinedManagedIdentityId: identity.outputs.aksClusterUserDefinedManagedIdentityId
    contributorRoleId: contributorRoleId
    workspaceId: workspaceId
    aksClusterName: aksClusterName
    aksClusterTags: aksClusterTags
    aksClusterDnsPrefix: aksClusterDnsPrefix
    aksClusterSkuName: aksClusterSkuName
    aksClusterSkuTier: aksClusterSkuTier
    systemNodePoolName: systemNodePoolName
    systemNodePoolAgentCount: systemNodePoolAgentCount
    systemNodePoolVmSize: systemNodePoolVmSize
    systemNodePoolOsDiskSizeGB: systemNodePoolOsDiskSizeGB
    aksSubnetId: network.outputs.aksSubnetId
    systemNodePoolMaxPods: systemNodePoolMaxPods
    systemNodePoolOsType: systemNodePoolOsType
    systemNodePoolMaxCount: systemNodePoolMaxCount
    systemNodePoolMinCount: systemNodePoolMinCount
    systemNodePoolScaleSetPriority: systemNodePoolScaleSetPriority
    systemNodePoolScaleSetEvictionPolicy: systemNodePoolScaleSetEvictionPolicy
    systemNodePoolEnableAutoScaling: systemNodePoolEnableAutoScaling
    systemNodePoolType: systemNodePoolType
    userNodePoolName: userNodePoolName
    userNodePoolAgentCount: userNodePoolAgentCount
    userNodePoolVmSize: userNodePoolVmSize
    userNodePoolOsDiskSizeGB: userNodePoolOsDiskSizeGB
    userNodePoolMaxPods: userNodePoolMaxPods
    userNodePoolOsType: userNodePoolOsType
    userNodePoolMaxCount: userNodePoolMaxCount
    userNodePoolMinCount: userNodePoolMinCount
    userNodePoolScaleSetPriority: userNodePoolScaleSetPriority
    userNodePoolScaleSetEvictionPolicy: userNodePoolScaleSetEvictionPolicy
    userNodePoolEnableAutoScaling: userNodePoolEnableAutoScaling
    userNodePoolType: userNodePoolType
    aksClusterAdminUsername: aksClusterAdminUsername
    aksClusterSshPublicKey: aksClusterSshPublicKey
    httpApplicationRoutingEnabled: httpApplicationRoutingEnabled
    aciConnectorLinuxEnabled: aciConnectorLinuxEnabled
    azurePolicyEnabled: azurePolicyEnabled
    kubeDashboardEnabled: kubeDashboardEnabled
    applicationGatewayId: applicateGateway.outputs.applicationGatewayId
    podIdentityProfileEnabled: podIdentityProfileEnabled
    aksClusterNetworkPlugin: aksClusterNetworkPlugin
    aksClusterNetworkPolicy: aksClusterNetworkPolicy
    aksClusterPodCidr: aksClusterPodCidr
    aksClusterServiceCidr: aksClusterServiceCidr
    aksClusterDnsServiceIP: aksClusterDnsServiceIP
    aksClusterOutboundType: aksClusterOutboundType
    aksClusterLoadBalancerSku: aksClusterLoadBalancerSku
    autoScalerProfileScanInterval: autoScalerProfileScanInterval
    autoScalerProfileScaleDownDelayAfterAdd: autoScalerProfileScaleDownDelayAfterAdd
    autoScalerProfileScaleDownDelayAfterDelete: autoScalerProfileScaleDownDelayAfterDelete
    autoScalerProfileScaleDownDelayAfterFailure: autoScalerProfileScaleDownDelayAfterFailure
    autoScalerProfileScaleDownUnneededTime: autoScalerProfileScaleDownUnneededTime
    autoScalerProfileScaleDownUnreadyTime: autoScalerProfileScaleDownUnreadyTime
    autoScalerProfileUtilizationThreshold: autoScalerProfileUtilizationThreshold
    autoScalerProfileMaxGracefulTerminationSec: autoScalerProfileMaxGracefulTerminationSec
    aksClusterEnablePrivateCluster: aksClusterEnablePrivateCluster
  }
}

module containerRegistry 'modules/containerservices/containerregistry.bicep' = {
  name: 'containerRegistryComponent'
  params: {
    location: location
    acrName: acrName
    acrSku: acrSku
    acrAdminUserEnabled: acrAdminUserEnabled
    acrNetworkRuleSetDefaultAction: acrNetworkRuleSetDefaultAction
    acrPublicNetworkAccess: acrPublicNetworkAccess
    acrPullRoleId: acrPullRoleId
    aksClusterKubeletidentityObjectId: kubernetes.outputs.aksClusterKubeletidentityObjectId
    workspaceId: workspaceId
    acrPrivateDnsZoneName: acrPrivateDnsZoneName
    virtualNetworkId: network.outputs.virtualNetworkId
    acrPrivateEndpointName: acrPrivateEndpointName
    acrPrivateEndpointGroupName: acrPrivateEndpointGroupName
    privateEndpointSubnetId: network.outputs.vmSubnetId
    acrPrivateDnsZoneGroupName: acrPrivateDnsZoneGroupName
  }
}

module roleAssignment 'modules/roleassignment/roleassignment.bicep' = {
  name: 'roleAssignmentComponent'
  params: {
    applicationGatewayUserDefinedManagedIdentityId: identity.outputs.applicationGatewayUserDefinedManagedIdentityId
    applicationGatewayId: applicateGateway.outputs.applicationGatewayId
    aksClusterIngressApplicationGatewayObjectId: kubernetes.outputs.aksClusteringressApplicationGatewayIdentity
  }
}
