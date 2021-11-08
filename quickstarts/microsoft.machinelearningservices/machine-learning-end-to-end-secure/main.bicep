// Execute this main file to configure Azure Machine Learning end-to-end in a moderately secure set up
targetScope = 'resourceGroup'

// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Virtual network address prefix')
param vnetAddressPrefix string = '192.168.0.0/16'

@description('Training subnet address prefix')
param trainingSubnetPrefix string = '192.168.0.0/24'

@description('Scoring subnet address prefix')
param scoringSubnetPrefix string = '192.168.1.0/24'

@description('Bastion subnet address prefix')
param azureBastionSubnetPrefix string = '192.168.250.0/27'

@description('Deploy a Bastion jumphost to access the network-isolated environment?')
param deployJumphost bool

@description('Jumphost virtual machine username')
param dsvmJumpboxUsername string

@secure()
@minLength(8)
@description('Jumphost virtual machine password')
param dsvmJumpboxPassword string

@description('Enable public IP for Azure Machine Learning compute nodes')
param amlComputePublicIp bool = true

// Variables
var name = toLower('${prefix}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Virtual network and network security group
module nsg 'modules/nsg.bicep' = { 
  name: 'nsg-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags 
    nsgName: 'nsg-${name}-${uniqueSuffix}'
  }
}

module vnet 'modules/vnet.bicep' = { 
  name: 'vnet-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualNetworkName: 'vnet-${name}-${uniqueSuffix}'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    vnetAddressPrefix: vnetAddressPrefix
    trainingSubnetPrefix: trainingSubnetPrefix
    scoringSubnetPrefix: scoringSubnetPrefix
    tags: tags
  }
  dependsOn: [
    nsg
  ]
}

// Dependent resources for the Azure Machine Learning workspace
module keyvault 'modules/keyvault.bicep' = {
  name: 'kv-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    keyvaultPleName: 'ple-${name}-${uniqueSuffix}-kv'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    virtualNetworkId: '${vnet.outputs.id}'
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}

module storage 'modules/storage.bicep' = {
  name: 'st${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    storagePleBlobName: 'ple-${name}-${uniqueSuffix}-st-blob'
    storagePleFileName: 'ple-${name}-${uniqueSuffix}-st-file'
    storageSkuName: 'Standard_LRS'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    virtualNetworkId: '${vnet.outputs.id}'
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}

module containerRegistry 'modules/containerregistry.bicep' = {
  name: 'cr${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    containerRegistryPleName: 'ple-${name}-${uniqueSuffix}-cr'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    virtualNetworkId: '${vnet.outputs.id}'
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}

module applicationInsights 'modules/applicationinsights.bicep' = {
  name: 'appi-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}

module azuremlWorkspace 'modules/machinelearning.bicep' = {
  name: 'mlw-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    machineLearningName: 'mlw-${name}-${uniqueSuffix}'
    machineLearningFriendlyName: 'Private link endpoint sample workspace'
    machineLearningDescription: 'This is an example workspace having a private link endpoint.'
    location: location
    prefix: name
    tags: tags

    // dependent resources
    applicationInsightsId: applicationInsights.outputs.applicationInsightsId
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    keyVaultId: keyvault.outputs.keyvaultId
    storageAccountId: storage.outputs.storageId

    // networking
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    computeSubnetId: '${vnet.outputs.id}/subnets/snet-training'
    aksSubnetId: '${vnet.outputs.id}/subnets/snet-scoring'
    virtualNetworkId: '${vnet.outputs.id}'
    machineLearningPleName: 'ple-${name}-${uniqueSuffix}-mlw'

    // compute
    amlComputePublicIp: amlComputePublicIp
    mlAksName: 'aks-${name}-${uniqueSuffix}'
  }
  dependsOn: [
    keyvault
    containerRegistry
    applicationInsights
    storage
  ]
}

// Optional VM and Bastion jumphost to help access the network isolated environment
module dsvm 'modules/dsvmjumpbox.bicep' = if (deployJumphost) {
  name: 'vm-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualMachineName: 'vm-${name}-${uniqueSuffix}'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    adminUsername: dsvmJumpboxUsername
    adminPassword: dsvmJumpboxPassword
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup 
  }
}

module bastion 'modules/bastion.bicep' = if (deployJumphost) {
  name: 'bas-${name}-${uniqueSuffix}-deployment'
  params: {
    bastionHostName: 'bas-${name}-${uniqueSuffix}'
    location: location
    vnetName: vnet.outputs.name
    addressPrefix: azureBastionSubnetPrefix
  }
  dependsOn: [
    vnet
  ]
}
