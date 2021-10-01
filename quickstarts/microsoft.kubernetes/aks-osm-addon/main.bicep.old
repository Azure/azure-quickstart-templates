@description('Provide a name for the AKS cluster. The only allowed characters are letters, numbers, dashes, and underscore. The first and last character must be a letter or a number.')
@minLength(3)
@maxLength(63)
param clusterName string = 'aks-osm-addon-quickstart'

@description('Provide a name for the AKS dnsPrefix. Valid characters include alphanumeric values and hyphens (-). The dnsPrefix can\'t include special characters such as a period (.)')
@minLength(3)
@maxLength(54)
param clusterDNSPrefix string

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('The Kubernetes version of the Managed Cluster resource.')
param k8Version string = '1.20.9'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string
param sshPubKey string

resource clusterName_resource 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: k8Version
    dnsPrefix: clusterDNSPrefix
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osDiskSizeGB: 30
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshPubKey
          }
        ]
      }
    }
    addonProfiles: {
      openServiceMesh: {
        enabled: true
      }
    }
  }
}