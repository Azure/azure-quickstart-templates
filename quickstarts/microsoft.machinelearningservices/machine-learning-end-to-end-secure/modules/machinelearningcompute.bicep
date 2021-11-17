// Creates compute resources in the specified machine learning workspace
// Includes Compute Instance, Compute Cluster and attached Azure Kubernetes Service compute types
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

@description('Resource ID of the Azure Kubernetes services resource')
param amlComputePublicIp bool

@description('VM size for the default CPU compute cluster')
param cpuDefaultVmSize string = 'Standard_Ds3_v2'

@description('VM size for the default GPU compute cluster')
param gpuDefaultVmSize string = 'Standard_NC6'

resource machineLearningCpuCluster001 'Microsoft.MachineLearningServices/workspaces/computes@2021-07-01' = {
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
      vmSize: cpuDefaultVmSize
      enableNodePublicIp: amlComputePublicIp
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

resource machineLearningGpuCluster001 'Microsoft.MachineLearningServices/workspaces/computes@2021-07-01' = {
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
      enableNodePublicIp: amlComputePublicIp
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
      vmSize: gpuDefaultVmSize
    }
  }
}

resource machineLearningComputeInstance001 'Microsoft.MachineLearningServices/workspaces/computes@2021-07-01' = {
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
      }
      subnet: {
        id: computeSubnetId
      }
      vmSize: cpuDefaultVmSize
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
