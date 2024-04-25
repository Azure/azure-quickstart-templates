// Execute this main file to depoy Azure AI studio resources in the basic security configuraiton

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiHubName string = 'demo'

@description('Friendly name for your Azure AI resource')
param aiHubFriendlyName string = 'Demo AI resource'

@description('Description of your Azure AI resource dispayed in AI studio')
param aiHubDescription string = 'This is an example AI resource for use in Azure AI Studio.'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Virtual network address prefix')
param vnetAddressPrefix string = '192.168.0.0/16'

@description('Default subnet address prefix')
param defaultSubnetPrefix string = '192.168.0.0/24'

@description('Bastion subnet address prefix')
param azureBastionSubnetPrefix string = '192.168.250.0/27'

@description('Deploy a Bastion jumphost to access the network-isolated environment?')
param deployJumphost bool = true

@description('Jumphost virtual machine username')
param dsvmJumpboxUsername string

@secure()
@minLength(8)
@description('Jumphost virtual machine password')
param dsvmJumpboxPassword string

@description('VM size for the default compute cluster')
param amlComputeDefaultVmSize string = 'Standard_DS3_v2'

// Variables
var name = toLower('${aiHubName}')

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


module vnet 'modules/ai-vnet.bicep' = { 
  name: 'vnet-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualNetworkName: 'vnet-${name}-${uniqueSuffix}'
    vnetAddressPrefix: vnetAddressPrefix
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    defaultSubnetPrefix: defaultSubnetPrefix
    tags: tags
  }
}

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    aiServicesName: 'ais${name}${uniqueSuffix}'
    tags: tags
  }
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'aihub-${name}-${uniqueSuffix}-deployment'
  params: {
    aiHubName: aiHubName
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    location: location
    tags: tags
    virtualNetworkId: vnet.outputs.id
    aiInboundPrivateEndpoint: 'ple-${name}-${uniqueSuffix}-ai'
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
    subnetId: '${vnet.outputs.id}/subnets/snet-default'
  }
}


// Optional VM and Bastion jumphost to help access the network isolated environment
module dsvm 'modules/ai-jumpbox.bicep' = if (deployJumphost) {
  name: 'vm${uniqueSuffix}'
  params: {
    location: location
    virtualMachineName: 'vm-${name}-${uniqueSuffix}'
    subnetId: '${vnet.outputs.id}/subnets/snet-default'
    adminUsername: dsvmJumpboxUsername
    adminPassword: dsvmJumpboxPassword
    vmSizeParameter: amlComputeDefaultVmSize
  }
}

module bastion 'modules/ai-bastion.bicep' = if (deployJumphost) {
  name: 'bas${uniqueSuffix}'
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
