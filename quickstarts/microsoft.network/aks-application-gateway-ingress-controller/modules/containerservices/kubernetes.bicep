param location string
param aksClusterUserDefinedManagedIdentityPrincipalId string
param aksClusterUserDefinedManagedIdentityId string
param contributorRoleId string
param workspaceId string
param aksClusterName string
param aksClusterTags object
param aksClusterDnsPrefix string
param aksClusterSkuName string
param aksClusterSkuTier string
param systemNodePoolName string
param systemNodePoolAgentCount int
param systemNodePoolVmSize string
param systemNodePoolOsDiskSizeGB int
param aksSubnetId string
param systemNodePoolMaxPods int
param systemNodePoolOsType string
param systemNodePoolMaxCount int
param systemNodePoolMinCount int
param systemNodePoolScaleSetPriority string
param systemNodePoolScaleSetEvictionPolicy string
param systemNodePoolEnableAutoScaling bool
param systemNodePoolType string
param userNodePoolName string
param userNodePoolAgentCount int
param userNodePoolVmSize string
param userNodePoolOsDiskSizeGB int
param userNodePoolMaxPods int
param userNodePoolOsType string
param userNodePoolMaxCount int
param userNodePoolMinCount int
param userNodePoolScaleSetPriority string
param userNodePoolScaleSetEvictionPolicy string
param userNodePoolEnableAutoScaling bool
param userNodePoolType string
param aksClusterAdminUsername string
param aksClusterSshPublicKey string
param httpApplicationRoutingEnabled bool
param aciConnectorLinuxEnabled bool
param azurePolicyEnabled bool
param kubeDashboardEnabled bool
param applicationGatewayId string
param podIdentityProfileEnabled bool
param aksClusterNetworkPlugin string
param aksClusterNetworkPolicy string
param aksClusterPodCidr string
param aksClusterServiceCidr string
param aksClusterDnsServiceIP string
param aksClusterOutboundType string
param aksClusterLoadBalancerSku string
param autoScalerProfileScanInterval string
param autoScalerProfileScaleDownDelayAfterAdd string
param autoScalerProfileScaleDownDelayAfterDelete string
param autoScalerProfileScaleDownDelayAfterFailure string
param autoScalerProfileScaleDownUnneededTime string
param autoScalerProfileScaleDownUnreadyTime string
param autoScalerProfileUtilizationThreshold string
param autoScalerProfileMaxGracefulTerminationSec string
param aksClusterEnablePrivateCluster bool

resource aksContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksClusterUserDefinedManagedIdentityPrincipalId, 'Contributor')
  properties: {
    roleDefinitionId: contributorRoleId
    description: 'Assign the cluster user-defined managed identity contributor role on the resource group.'
    principalId: aksClusterUserDefinedManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-07-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksClusterUserDefinedManagedIdentityId}': {}
    }
  }
  tags: aksClusterTags
  sku: {
    name: aksClusterSkuName
    tier: aksClusterSkuTier
  }
  properties: {
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
      outboundType: aksClusterOutboundType
      loadBalancerSku: aksClusterLoadBalancerSku
    }
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

resource aksClusterDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: aksCluster
  name: '${aksClusterName}-Diag'
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

output aksClusterKubeletidentityObjectId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
output aksClusteringressApplicationGatewayIdentity string = aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
