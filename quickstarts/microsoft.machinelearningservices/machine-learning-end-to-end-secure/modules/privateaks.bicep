// Creates an Azure Kubernetes Services and attaches it to the Azure Machine Learning workspace
@description('Name of the Azure Kubernetes Service cluster')
param aksClusterName string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Resource ID for the Azure Kubernetes Service subnet')
param aksSubnetId string

@description('Name of the Azure Machine Learning workspace')
param workspaceName string

@description('Name of the Azure Machine Learning attached compute')
param computeName string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2020-07-01' = {
  name: aksClusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.22.4'
    dnsPrefix: '${aksClusterName}-dns'
    agentPoolProfiles: [
      {
        name: toLower('agentpool')
        count: 3
        vmSize: 'Standard_DS2_v2'
        osDiskSizeGB: 128
        vnetSubnetID: aksSubnetId
        maxPods: 110
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'kubenet'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
  }
}

output aksResourceId string = aksCluster.id

resource workspaceName_computeName 'Microsoft.MachineLearningServices/workspaces/computes@2021-01-01' = {
  name: '${workspaceName}/${computeName}'
  location: location
  properties: {
    computeType: 'AKS'
    resourceId: aksCluster.id
    properties: {
      aksNetworkingConfiguration:  {
        subnetId: aksSubnetId
      }
    }
  }
}
