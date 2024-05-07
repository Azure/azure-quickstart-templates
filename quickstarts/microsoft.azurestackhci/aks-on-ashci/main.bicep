param location string
param aksClusterName string
param aksAdminGroupObjectId string = ''
param aksControlPlaneIP string
@maxValue(5)
param aksControlPlaneNodeCount int = 1
param aksControlPlaneNodeSize string = 'Standard_A4_v2'
param aksPodCidr string = '10.244.0.0/16'
param aksKubernetesVersion string = 'v1.26.6'
param aksNodePoolName string
param aksNodePoolNodeCount int = 1
param aksNodePoolNodeSize string = 'Standard_A4_v2'
@allowed(['Linux', 'Windows'])
param aksNodePoolOSType string = 'Linux'
param sshPublicKey string
param hciLogicalNetworkName string
param hciCustomLocationName string

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', hciCustomLocationName) // full custom location ID

// retrieve the existing logical network resource - ensures the logical network exists before creating cluster
resource logicalNetwork 'Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview' existing = {
  name: hciLogicalNetworkName
}


// create the connected cluster - this is the Arc representation of the AKS cluster, used to create a Managed Identity for the provisioned cluster
resource connectedCluster 'Microsoft.Kubernetes/ConnectedClusters@2024-01-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'ProvisionedCluster'
  properties: {
    agentPublicKeyCertificate: ''
    aadProfile: {
      enableAzureRBAC: false
      adminGroupObjectIDs: [aksAdminGroupObjectId]
    }
  }
}

// create the provisioned cluster instance - this is the actual AKS cluster and provisioned on your HCI cluster via the Arc Resource Bridge
resource provisionedClusterInstance 'Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01' = {
  name: 'default'
  scope: connectedCluster
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    linuxProfile: {
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKey
          }
        ]
      }
    }
    controlPlane: {
      count: aksControlPlaneNodeCount
      controlPlaneEndpoint: {
        hostIP: aksControlPlaneIP
      }
      vmSize: aksControlPlaneNodeSize
    }
    kubernetesVersion: aksKubernetesVersion
    networkProfile: {
      loadBalancerProfile: {
        count: 0 // use MetalLB
      }
      networkPolicy: 'calico'
      podCidr: aksPodCidr
    }
    agentPoolProfiles: [
      {
        name: aksNodePoolName
        count: aksNodePoolNodeCount
        vmSize: aksNodePoolNodeSize
        osType: aksNodePoolOSType
      }
    ]
    cloudProviderProfile: {
      infraNetworkProfile: {
        vnetSubnetIds: [
          logicalNetwork.id
        ]
      }
    }
    storageProfile: {
      nfsCsiDriver: {
        enabled: false
      }
      smbCsiDriver: {
        enabled: false
      }
    }
  }
}
