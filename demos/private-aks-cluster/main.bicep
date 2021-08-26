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
param aksClusterServiceCidr string = '10.2.0.0/16'

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = '10.2.0.10'

@description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param aksClusterDockerBridgeCidr string = '172.17.0.1/16'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Specifies the tier of a managed cluster SKU: Paid or Free')
@allowed([
  'Paid'
  'Free'
])
param aksClusterSkuTier string = 'Paid'

@description('Specifies the version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = '1.21.1'

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
param aksClusterEnablePrivateCluster bool = true

@description('Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = false

@description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = false

@description('Specifies the unique name of the node pool profile in the context of the subscription and resource group.')
param nodePoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the node pool.')
param nodePoolVmSize string = 'Standard_D4s_v3'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in this master/agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param nodePoolOsDiskSizeGB int = 100

@description('Specifies the number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param nodePoolCount int = 5

@description('Specifies the OS type for the vms in the node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param nodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param nodePoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the node pool.')
param nodePoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the node pool.')
param nodePoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the node pool.')
param nodePoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param nodePoolScaleSetPriority string = 'Regular'

@description('Specifies the Agent pool node labels to be persisted across all nodes in agent pool.')
param nodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param nodePoolNodeTaints array = []

@description('Specifies the mode of an agent pool: System or User')
@allowed([
  'System'
  'User'
])
param nodePoolMode string = 'System'

@description('Specifies the type of a node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param nodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for nodes. Requirese the use of VirtualMachineScaleSets as node pool type.')
param nodePoolAvailabilityZones array = []

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = '${aksClusterName}Vnet'

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the default subnet hosting the AKS cluster.')
param aksSubnetName string = 'AksSubnet'

@description('Specifies the address prefix of the subnet hosting the AKS cluster.')
param aksSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

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
param vmSubnetAddressPrefix string = '10.1.0.0/24'

@description('Specifies the name of the virtual machine.')
param vmName string = 'TestVm'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_D4s_v3'

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'Canonical'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = 'UbuntuServer'

@description('Specifies the Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
param imageSku string = '18.04-LTS'

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
param blobStorageAccountName string = 'blob${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param blobStorageAccountPrivateEndpointName string = 'BlobStorageAccountPrivateEndpoint'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.1.1.0/26'

@description('Specifies the name of the Azure Bastion resource.')
param bastionName string = '${aksClusterName}Bastion'

module vnet 'vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    aksSubnetName: aksSubnetName
    aksSubnetAddressPrefix: aksSubnetAddressPrefix
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
    vmSubnetName: vmSubnetName
    vmSubnetAddressPrefix: vmSubnetAddressPrefix
  }
}

module bastion 'bastion.bicep' = {
  name: 'bastion'
  params: {
    bastionHostName: bastionName
    bastionSubnetId: vnet.outputs.bastionSubnetId
    location: location
  }
}

module logAnalytics 'log-analytics.bicep' = {
  name: 'log-analytics.bicep'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsSku: logAnalyticsSku
    logAnalyticsRetentionInDays: logAnalyticsRetentionInDays
  }
}

module jumpbox 'jumpbox.bicep' = {
  name: 'jumpbox'
  params: {
    location: location

    vmName: vmName
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey

    vmSize: vmSize
    authenticationType: authenticationType

    diskStorageAccounType: diskStorageAccounType
    osDiskSize: osDiskSize
    dataDiskCaching: dataDiskCaching
    dataDiskSize: dataDiskSize
    numDataDisks: numDataDisks

    imageOffer: imageOffer
    imagePublisher: imagePublisher
    imageSku: imageSku

    blobStorageAccountName: blobStorageAccountName
    blobStorageAccountPrivateEndpointName: blobStorageAccountPrivateEndpointName

    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    virtualNetworkId: vnet.outputs.virtualNetworkResourceId
    vmSubnetId: vnet.outputs.vmSubnetId
  }
}

module aks 'aks.bicep' = {
  name: 'aks'
  params: {
    location: location

    aadEnabled: aadEnabled
    aadProfileAdminGroupObjectIDs: aadProfileAdminGroupObjectIDs
    aadProfileEnableAzureRBAC: aadProfileEnableAzureRBAC
    aadProfileManaged: aadProfileManaged
    aadProfileTenantId: aadProfileTenantId
    aksClusterAdminUsername: aksClusterAdminUsername
    aksClusterDnsPrefix: aksClusterDnsPrefix
    aksClusterDnsServiceIP: aksClusterDnsServiceIP
    aksClusterDockerBridgeCidr: aksClusterDockerBridgeCidr
    aksClusterEnablePrivateCluster: aksClusterEnablePrivateCluster
    aksClusterKubernetesVersion: aksClusterKubernetesVersion
    aksClusterLoadBalancerSku: aksClusterLoadBalancerSku
    aksClusterName: aksClusterName
    aksClusterNetworkPlugin: aksClusterNetworkPlugin
    aksClusterNetworkPolicy: aksClusterNetworkPolicy
    aksClusterPodCidr: aksClusterPodCidr
    aksClusterServiceCidr: aksClusterServiceCidr
    aksClusterSkuTier: aksClusterSkuTier
    aksClusterSshPublicKey: aksClusterSshPublicKey
    aksClusterTags: aksClusterTags
    aksSubnetName: aksSubnetName

    nodePoolAvailabilityZones: nodePoolAvailabilityZones
    nodePoolCount: nodePoolCount
    nodePoolEnableAutoScaling: nodePoolEnableAutoScaling
    nodePoolMaxCount: nodePoolMaxCount
    nodePoolMaxPods: nodePoolMaxPods
    nodePoolMinCount: nodePoolMinCount
    nodePoolMode: nodePoolMode
    nodePoolName: nodePoolName
    nodePoolNodeLabels: nodePoolNodeLabels
    nodePoolNodeTaints: nodePoolNodeTaints
    nodePoolOsDiskSizeGB: nodePoolOsDiskSizeGB
    nodePoolOsType: nodePoolOsType
    nodePoolScaleSetPriority: nodePoolScaleSetPriority
    nodePoolType: nodePoolType
    nodePoolVmSize: nodePoolVmSize

    virtualNetworkId: vnet.outputs.virtualNetworkResourceId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}
