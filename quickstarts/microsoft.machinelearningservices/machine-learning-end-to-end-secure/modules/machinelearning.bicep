// Creates a machine learning workspace, private endpoints and compute resources
// Compute resources include a GPU cluster, CPU cluster, compute instance and attached private AKS cluster
@description('Prefix for resource names')
param prefix string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Machine learning workspace name')
param machineLearningName string

@description('Machine learning workspace display name')
param machineLearningFriendlyName string = machineLearningName

@description('Machine learning workspace description')
param machineLearningDescription string

@description('Name of the Azure Kubernetes services resource to create and attached to the machine learning workspace')
param mlAksName string

@description('Resource ID of the application insights resource')
param applicationInsightsId string

@description('Resource ID of the container registry resource')
param containerRegistryId string

@description('Resource ID of the key vault resource')
param keyVaultId string

@description('Resource ID of the storage account resource')
param storageAccountId string

@description('Resource ID of the subnet resource')
param subnetId string

@description('Resource ID of the compute subnet')
param computeSubnetId string

@description('Resource ID of the Azure Kubernetes services resource')
param aksSubnetId string

@description('Resource ID of the virtual network')
param virtualNetworkId string

@description('Machine learning workspace private link endpoint name')
param machineLearningPleName string

@description('Enable public IP for Azure Machine Learning compute nodes')
param amlComputePublicIp bool = true
 
resource machineLearning 'Microsoft.MachineLearningServices/workspaces@2021-04-01' = {
  name: machineLearningName
  location: location
  tags: tags
  properties: {
    // workspace organization
    friendlyName: machineLearningFriendlyName
    description: machineLearningDescription

    // dependent resources
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    keyVault: keyVaultId
    storageAccount: storageAccountId

    // configuration for workspaces with private link endpoint
    imageBuildCompute: 'cpucluster001'
    allowPublicAccessWhenBehindVnet: false
  }
}

module machineLearningPrivateEndpoint 'machinelearningnetworking.bicep' = {
  name: 'machineLearningNetworking'
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    virtualNetworkId: virtualNetworkId
    workspaceArmId: machineLearning.id
    subnetId: subnetId
    machineLearningPleName: machineLearningPleName
  }
}

module machineLearningCompute 'machinelearningcompute.bicep' = {
  name: 'machineLearningComputes'
  scope: resourceGroup()
  params: {
    machineLearning: machineLearningName
    location: location
    computeSubnetId:computeSubnetId
    aksName: mlAksName
    aksSubnetId: aksSubnetId
    prefix: prefix
    tags: tags
    amlComputePublicIp: amlComputePublicIp
  }
  dependsOn: [
    machineLearning
    machineLearningPrivateEndpoint
  ]
}

output machineLearningId string = machineLearning.id
