// Creates compute resources in the specified machine learning workspace
// Includes Compute Instance, Compute Cluster and attached Azure Kubernetes Service compute types
targetScope = 'resourceGroup'

@description('Prefix for resource names')
param prefix string

@description('Azure Machine Learning workspace to create the compute resources in')
param machineLearning string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Resource ID of the compute subnet')
param computeSubnetId string

@description('Name of the Azure Kubernetes services resource')
param aksName string

@description('Resource ID of the Azure Kubernetes services resource')
param aksSubnetId string

resource machineLearningCpuCluster001 'Microsoft.MachineLearningServices/workspaces/computes@2021-04-01' = {
  name: '${machineLearning}/cpucluster001'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'AmlCompute'
    computeLocation: location
    description: 'Machine Learning cluster 001'
    disableLocalAuth: true
    properties: {
      vmPriority: 'Dedicated'
      vmSize: 'Standard_Ds3_v2'
      enableNodePublicIp: false
      isolatedNetwork: false
      osType: 'Linux'
      remoteLoginPortPublicAccess: 'Disabled'
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 8
        nodeIdleTimeBeforeScaleDown: 'PT120S'
      }
      subnet: {
        id: computeSubnetId
      }
    }
  }
}

resource machineLearningGpuCluster001 'Microsoft.MachineLearningServices/workspaces/computes@2021-04-01' = {
  name: '${machineLearning}/gpucluster001'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'AmlCompute'
    computeLocation: location
    description: 'Machine Learning cluster 001'
    disableLocalAuth: true
    properties: {
      enableNodePublicIp: false
      isolatedNetwork: false
      osType: 'Linux'
      remoteLoginPortPublicAccess: 'Disabled'
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 8
        nodeIdleTimeBeforeScaleDown: 'PT120S'
      }
      subnet: {
        id: computeSubnetId
      }
      vmPriority: 'Dedicated'
      vmSize: 'Standard_NC6'
    }
  }
}

resource machineLearningComputeInstance001 'Microsoft.MachineLearningServices/workspaces/computes@2021-04-01' = {
  name: '${machineLearning}/${prefix}-ci001'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'ComputeInstance'
    computeLocation: location
    description: 'Machine Learning compute instance 001'
    disableLocalAuth: true
    properties: {
      applicationSharingPolicy: 'Personal'
      computeInstanceAuthorizationType: 'personal'
      sshSettings: {
        sshPublicAccess: 'Disabled'
        adminPublicKey: ''
      }
      subnet: {
        id: computeSubnetId
      }
      vmSize: 'Standard_DS3_v2'
    }
  }
}

module machineLearningAksCompute 'privateaks.bicep' = {
  name: aksName
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    aksClusterName: aksName
    computeName: aksName
    aksSubnetId: aksSubnetId
    workspaceName: machineLearning
  }
}
