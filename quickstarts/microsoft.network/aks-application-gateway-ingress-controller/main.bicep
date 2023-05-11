@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the AKS cluster.')
param aksClusterName string = 'aks${uniqueString(resourceGroup().id)}'

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

@description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param aksClusterDockerBridgeCidr string = '172.17.0.1/16'

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

@description('Specifies the tier of a managed cluster SKU: Paid or Free')
@allowed([
  'Paid'
  'Free'
])
param aksClusterSkuTier string = 'Paid'

@description('Specifies the version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = '1.26.3'

@description('Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string

@description('Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string

@description('Specifies whether enabling AAD integration.')
param aadEnabled bool = false

@description('Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
param aadProfileTenantId string = subscription().tenantId

@description('Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@description('Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = false

@description('Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = false

@description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = false

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

@description('Specifies the Agent pool node labels to be persisted across all nodes in the system node pool.')
param systemNodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param systemNodePoolNodeTaints array = []

@description('Specifies the type for the system node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param systemNodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the system node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param systemNodePoolAvailabilityZones array = []

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

@description('Specifies the Agent pool node labels to be persisted across all nodes in the user node pool.')
param userNodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param userNodePoolNodeTaints array = []

@description('Specifies the type for the user node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param userNodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the user node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param userNodePoolAvailabilityZones array = []

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
param virtualNetworkName string = 'myVnet'

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

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'Canonical'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = 'UbuntuServer'

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  '18_04-daily-lts-gen2'
  '18_04-lts-gen2'
])
param imageSku string = '18_04-lts-gen2'

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

@description('Specifies the availability zones of the Application Gateway.')
param applicationGatewayZones array = []

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

var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var readerRoleDefinitionName = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var contributorRoleDefinitionName = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var acrPullRoleDefinitionName = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var aksClusterUserDefinedManagedIdentityName = '${aksClusterName}ManagedIdentity'
var aksClusterUserDefinedManagedIdentityId = aksClusterUserDefinedManagedIdentity.id
var applicationGatewayUserDefinedManagedIdentityName = '${applicationGatewayName}ManagedIdentity'
var applicationGatewayUserDefinedManagedIdentityId = applicationGatewayUserDefinedManagedIdentity.id
var aadPodIdentityUserDefinedManagedIdentityName = '${aksClusterName}AadPodManagedIdentity'
var aadPodIdentityUserDefinedManagedIdentityId = aadPodIdentityUserDefinedManagedIdentity.id
var vmSubnetNsgName = '${vmSubnetName}Nsg'
var vmSubnetNsgId = vmSubnetNsg.id
var virtualNetworkId = virtualNetwork.id
var bastionSubnetNsgName = '${bastionHostName}Nsg'
var bastionSubnetNsgId = bastionSubnetNsg.id
var aksSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, aksSubnetName)
var vmSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, vmSubnetName)
var applicationGatewaySubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, applicationGatewaySubnetName)
var vmNicName = '${vmName}Nic'
var blobStorageAccountId = blobStorageAccount.id
var blobPublicDNSZoneForwarder = 'blob.${environment().suffixes.storage}'
var blobPrivateDnsZoneName = 'privatelink.${blobPublicDNSZoneForwarder}'
var blobPrivateDnsZoneId = blobPrivateDnsZone.id
var blobStorageAccountPrivateEndpointGroupName = 'blob'
var blobPrivateDnsZoneGroupName = '${blobStorageAccountPrivateEndpointGroupName}PrivateDnsZoneGroup'
var omsAgentForLinuxName = 'LogAnalytics'
var omsDependencyAgentForLinuxName = 'DependencyAgent'
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
var bastionPublicIpAddressName = '${bastionHostName}PublicIp'
var bastionPublicIpAddressId = bastionPublicIpAddress.id
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, bastionSubnetName)
var workspaceId = logAnalyticsWorkspace.id
var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleDefinitionName)
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionName)
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionName)
var aksContributorRoleAssignmentName = guid('${resourceGroup().id}${aksClusterUserDefinedManagedIdentityName}${aksClusterName}')

var appGwContributorRoleAssignmentName = guid('${resourceGroup().id}${applicationGatewayUserDefinedManagedIdentityName}${applicationGatewayName}')
var acrPullRoleAssignmentName = 'Microsoft.Authorization/${guid('${resourceGroup().id}acrPullRoleAssignment')}'
var containerInsightsSolutionName = 'ContainerInsights(${logAnalyticsWorkspaceName})'
var acrPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? 'azurecr.us' : 'azurecr.io')
var acrPrivateDnsZoneName = 'privatelink.${acrPublicDNSZoneForwarder}'
var acrPrivateDnsZoneId = acrPrivateDnsZone.id
var acrPrivateEndpointGroupName = 'registry'
var acrPrivateDnsZoneGroupName = '${acrPrivateEndpointGroupName}PrivateDnsZoneGroup'
var aksClusterId = aksCluster.id
var keyVaultPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.vaultcore.usgovcloudapi.net' : '.vaultcore.azure.net')
var keyVaultPrivateDnsZoneName = 'privatelink${keyVaultPublicDNSZoneForwarder}'
var keyVaultPrivateDnsZoneId = keyVaultPrivateDnsZone.id
var keyVaultPrivateEndpointGroupName = 'vault'
var keyVaultPrivateDnsZoneGroupName = '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup'
var applicationGatewayId = applicationGateway.id
var applicationGatewayPublicIPAddressName = '${applicationGatewayName}PublicIp'
var applicationGatewayPublicIPAddressId = applicationGatewayPublicIPAddress.id
var applicationGatewayIPConfigurationName = 'applicationGatewayIPConfiguration'
var applicationGatewayFrontendIPConfigurationName = 'applicationGatewayFrontendIPConfiguration'
var applicationGatewayFrontendIPConfigurationId = resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
var applicationGatewayFrontendPortName = 'applicationGatewayFrontendPort'
var applicationGatewayFrontendPortId = resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortName)
var applicationGatewayHttpListenerName = 'applicationGatewayHttpListener'
var applicationGatewayHttpListenerId = resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, applicationGatewayHttpListenerName)
var applicationGatewayBackendAddressPoolName = 'applicationGatewayBackendPool'
var applicationGatewayBackendAddressPoolId = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayBackendAddressPoolName)
var applicationGatewayBackendHttpSettingsName = 'applicationGatewayBackendHttpSettings'
var applicationGatewayBackendHttpSettingsId = resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, applicationGatewayBackendHttpSettingsName)
var applicationGatewayRequestRoutingRuleName = 'default'
var aadProfileConfiguration = {
  managed: aadProfileManaged
  enableAzureRBAC: aadProfileEnableAzureRBAC
  adminGroupObjectIDs: aadProfileAdminGroupObjectIDs
  tenantID: aadProfileTenantId
}

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: bastionPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: bastionSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource bastionSubnetNsgDiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: bastionSubnetNsg.name
  scope: bastionSubnetNsg
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIpAddressId
          }
        }
      }
    ]
  }
}

resource bastionHostDiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: bastionHost.name
  scope: bastionHost
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'BastionAuditLogs'
        enabled: true
      }
    ]
  }
}

resource blobStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: blobStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource vmNic 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: vmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: osDiskSize
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }
      dataDisks: [for j in range(0, numDataDisks): {
        caching: dataDiskCaching
        diskSizeGB: dataDiskSize
        lun: j
        name: '${vmName}-DataDisk${j}'
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(blobStorageAccountId).primaryEndpoints.blob
      }
    }
  }
}

resource vmName_GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (vTPM && secureBoot) {
  parent: vm
  name: 'GuestAttestation'
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

resource vmName_omsAgentForLinux 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: vm
  name: omsAgentForLinuxName
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.12'
    settings: {
      workspaceId: reference(workspaceId, '2020-03-01-preview').customerId
      stopOnMultipleConnections: false
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, '2020-03-01-preview').primarySharedKey
    }
  }
}

resource vmName_omsDependencyAgentForLinux 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: vm
  name: omsDependencyAgentForLinuxName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
  }
}

resource vmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: vmSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: vmSubnetNsg.name
  scope: vmSubnetNsg
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          networkSecurityGroup: {
            id: vmSubnetNsgId
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionSubnetNsgId
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource aksClusterUserDefinedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: aksClusterUserDefinedManagedIdentityName
  location: location
}

resource applicationGatewayUserDefinedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: applicationGatewayUserDefinedManagedIdentityName
  location: location
}

resource aadPodIdentityUserDefinedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: aadPodIdentityUserDefinedManagedIdentityName
  location: location
}

resource aksContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: aksContributorRoleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleId
    description: 'Assign the cluster user-defined managed identity contributor role on the resource group.'
    principalId: aksClusterUserDefinedManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies: [
      {
        tenantId: reference(applicationGatewayUserDefinedManagedIdentityId).tenantId
        objectId: reference(applicationGatewayUserDefinedManagedIdentityId).principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
          ]
        }
      }
      {
        tenantId: reference(aadPodIdentityUserDefinedManagedIdentityId).tenantId
        objectId: reference(aadPodIdentityUserDefinedManagedIdentityId).principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
          ]
        }
      }
    ]
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: keyVaultNetworkRuleSetDefaultAction
    }
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: false
  }
}

resource keyVaultdiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: keyVault.name
  scope: keyVault
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
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

resource keyVaultName_Microsoft_Authorization_id_readerRoleId 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(concat(resourceGroup().id), readerRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: readerRoleId
    principalId: reference(aadPodIdentityUserDefinedManagedIdentityId).principalId
    principalType: 'ServicePrincipal'
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    networkRuleSet: {
      defaultAction: acrNetworkRuleSetDefaultAction
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 15
        status: 'enabled'
      }
    }
    publicNetworkAccess: acrPublicNetworkAccess
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: true
    networkRuleBypassOptions: 'AzureServices'
  }
}

resource acrName_acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: acrPullRoleAssignmentName
  scope:  keyVault
  properties: {
    roleDefinitionId: acrPullRoleId
    principalId: reference(aksClusterId, '2020-12-01', 'Full').properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

resource acrDiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: acr.name
  scope: acr
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        timeGrain: 'PT1M'
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-03-02-Preview' = {
  name: aksClusterName
  location: location  
  sku: {
    name: 'Basic'
    tier: aksClusterSkuTier
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksClusterUserDefinedManagedIdentityId}': {}
    }
  }
  tags: aksClusterTags
  properties: {
    kubernetesVersion: aksClusterKubernetesVersion
    dnsPrefix: aksClusterDnsPrefix
    agentPoolProfiles: [
      {
        name: toLower(systemNodePoolName)
        count: systemNodePoolAgentCount
        vmSize: systemNodePoolVmSize
        osDiskSizeGB: systemNodePoolOsDiskSizeGB
        vnetSubnetID: aksSubnetId
        maxPods: systemNodePoolMaxPods
        osType: systemNodePoolOsType
        maxCount: systemNodePoolMaxCount
        minCount: systemNodePoolMinCount
        scaleSetPriority: systemNodePoolScaleSetPriority
        scaleSetEvictionPolicy: systemNodePoolScaleSetEvictionPolicy
        enableAutoScaling: systemNodePoolEnableAutoScaling
        mode: 'System'
        type: systemNodePoolType
        availabilityZones: systemNodePoolAvailabilityZones
        nodeLabels: systemNodePoolNodeLabels
        nodeTaints: systemNodePoolNodeTaints
      }
      {
        name: toLower(userNodePoolName)
        count: userNodePoolAgentCount
        vmSize: userNodePoolVmSize
        osDiskSizeGB: userNodePoolOsDiskSizeGB
        vnetSubnetID: aksSubnetId
        maxPods: userNodePoolMaxPods
        osType: userNodePoolOsType
        maxCount: userNodePoolMaxCount
        minCount: userNodePoolMinCount
        scaleSetPriority: userNodePoolScaleSetPriority
        scaleSetEvictionPolicy: userNodePoolScaleSetEvictionPolicy
        enableAutoScaling: userNodePoolEnableAutoScaling
        mode: 'User'
        type: userNodePoolType
        availabilityZones: userNodePoolAvailabilityZones
        nodeLabels: userNodePoolNodeLabels
        nodeTaints: userNodePoolNodeTaints
      }
    ]
    linuxProfile: {
      adminUsername: aksClusterAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: aksClusterSshPublicKey
          }
        ]
      }
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: httpApplicationRoutingEnabled
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
      aciConnectorLinux: {
        enabled: aciConnectorLinuxEnabled
      }
      azurepolicy: {
        enabled: azurePolicyEnabled
        config: {
          version: 'v2'
        }
      }
      kubeDashboard: {
        enabled: kubeDashboardEnabled
      }
      ingressApplicationGateway: {
        config: {
          applicationGatewayId: applicationGatewayId
        }
        enabled: true
      }
    }
    podIdentityProfile: {
      enabled: podIdentityProfileEnabled
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: aksClusterNetworkPlugin
      networkPolicy: aksClusterNetworkPolicy
      podCidr: aksClusterPodCidr
      serviceCidr: aksClusterServiceCidr
      dnsServiceIP: aksClusterDnsServiceIP
      dockerBridgeCidr: aksClusterDockerBridgeCidr
      outboundType: aksClusterOutboundType
      loadBalancerSku: aksClusterLoadBalancerSku
      loadBalancerProfile: null
    }
    aadProfile: (aadEnabled ? aadProfileConfiguration : null)
    autoScalerProfile: {
      'scan-interval': autoScalerProfileScanInterval
      'scale-down-delay-after-add': autoScalerProfileScaleDownDelayAfterAdd
      'scale-down-delay-after-delete': autoScalerProfileScaleDownDelayAfterDelete
      'scale-down-delay-after-failure': autoScalerProfileScaleDownDelayAfterFailure
      'scale-down-unneeded-time': autoScalerProfileScaleDownUnneededTime
      'scale-down-unready-time': autoScalerProfileScaleDownUnreadyTime
      'scale-down-utilization-threshold': autoScalerProfileUtilizationThreshold
      'max-graceful-termination-sec': autoScalerProfileMaxGracefulTerminationSec
    }
    apiServerAccessProfile: {
      enablePrivateCluster: aksClusterEnablePrivateCluster
    }
  }
}
resource aksClusterDiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: aksCluster.name
  scope: aksCluster
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'kube-apiserver'
        enabled: true
      }
      {
        category: 'kube-audit'
        enabled: true
      }
      {
        category: 'kube-audit-admin'
        enabled: true
      }
      {
        category: 'kube-controller-manager'
        enabled: true
      }
      {
        category: 'kube-scheduler'
        enabled: true
      }
      {
        category: 'cluster-autoscaler'
        enabled: true
      }
      {
        category: 'guard'
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

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsSku
    }
    retentionInDays: logAnalyticsRetentionInDays
  }
}

resource containerInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: containerInsightsSolutionName
  location: location
  plan: {
    name: containerInsightsSolutionName
    promotionCode: ''
    product: 'OMSGallery/ContainerInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: keyVaultPrivateDnsZoneName
  location: 'global'
}

resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (acrSku == 'Premium') {
  name: acrPrivateDnsZoneName
  location: 'global'
}

resource blobPrivateDnsZoneName_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource keyVaultPrivateDnsZoneName_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: keyVaultPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource acrPrivateDnsZoneName_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (acrSku == 'Premium') {
  parent: acrPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource blobStorageAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: blobStorageAccountPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobStorageAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: blobStorageAccountId
          groupIds: [
            blobStorageAccountPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: vmSubnetId
    }
  }
}

resource blobStorageAccountPrivateEndpointName_blobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  parent: blobStorageAccountPrivateEndpoint
  name: blobPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZoneId
        }
      }
    ]
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            keyVaultPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: vmSubnetId
    }
  }
}

resource keyVaultPrivateEndpointName_keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: keyVaultPrivateEndpoint
  name: keyVaultPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZoneId
        }
      }
    ]
  }
}

resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = if (acrSku == 'Premium') {
  name: acrPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: acrPrivateEndpointName
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            acrPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: vmSubnetId
    }
  }
}

resource acrPrivateEndpointName_acrPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = if (acrSku == 'Premium') {
  parent: acrPrivateEndpoint
  name: acrPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: acrPrivateDnsZoneId
        }
      }
    ]
  }
}

resource AllAzureAdvisorAlert 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: 'AllAzureAdvisorAlert'
  location: 'Global'
  properties: {
    actions: {
      actionGroups: [
        {
          actionGroupId: ''
          webhookProperties: {}
        }
      ]
    }    
    scopes: [
      resourceGroup().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Recommendation'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Advisor/recommendations/available/action'
        }
      ]
    }
    enabled: true
    description: 'All azure advisor alerts'
  }
}

resource applicationGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: applicationGatewayPublicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-06-01' = {
  name: wafPolicyName
  location: location
  properties: {
    customRules: [
      {
        name: 'BlockMe'
        priority: 1
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'QueryString'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'blockme'
            ]
          }
        ]
      }
      {
        name: 'BlockEvilBot'
        priority: 2
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'evilbot'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: wafPolicyRequestBodyCheck
      maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
      mode: wafPolicyMode
      state: wafPolicyState
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: wafPolicyRuleSetType
          ruleSetVersion: wafPolicyRuleSetVersion
        }
      ]
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-05-01' = {
  name: applicationGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayUserDefinedManagedIdentityId}': {}
    }
  }
  zones: applicationGatewayZones
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: applicationGatewayIPConfigurationName
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: applicationGatewayFrontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIPAddressId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: applicationGatewayFrontendPortName
        properties: {
          port: 80
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
    enableHttp2: false
    probes: [
      {
        name: 'defaultHttpProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
        }
      }
      {
        name: 'defaultHttpsProbe'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
        }
      }
    ]
    backendAddressPools: [
      {
        name: applicationGatewayBackendAddressPoolName
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: applicationGatewayBackendHttpSettingsName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: applicationGatewayHttpListenerName
        properties: {
          firewallPolicy: {
            id: wafPolicy.id
          }
          frontendIPConfiguration: {
            id: applicationGatewayFrontendIPConfigurationId
          }
          frontendPort: {
            id: applicationGatewayFrontendPortId
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: applicationGatewayRequestRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: applicationGatewayHttpListenerId
          }
          backendAddressPool: {
            id: applicationGatewayBackendAddressPoolId
          }
          backendHttpSettings: {
            id: applicationGatewayBackendHttpSettingsId
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: wafPolicyMode
      ruleSetType: wafPolicyRuleSetType
      ruleSetVersion: wafPolicyRuleSetVersion
      requestBodyCheck: wafPolicyRequestBodyCheck
      maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
    }
    firewallPolicy: {
      id: wafPolicy.id
    }
  }
}

resource applicationGatewayName_Microsoft_Insights_default 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: applicationGateway.name
  scope: applicationGateway
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
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

resource appGwContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: appGwContributorRoleAssignmentName
  scope: resourceGroup()
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: reference(aksClusterId, '2020-12-01', 'Full').properties.addonProfiles.ingressApplicationGateway.identity.objectId
    principalType: 'ServicePrincipal'
  }
}
