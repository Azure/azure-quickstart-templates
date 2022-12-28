@description('Used for the naming of all the Azure resources')
param nameseed string = 'pubsubsb'

@description('Overrides the name of the container registry.')
param containerRegistryName string = 'cr${nameseed}${uniqueString(resourceGroup().id)}'

@description('Overrides the name of the keyvault.')
param keyvaultName string = 'kv-${nameseed}${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('This array is provided to both Container Apps as Environment Variables')
var pubSubAppEnvVars = [{
  name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
  value: myenv.outputs.appInsightsInstrumentationKey
}
{
  name: 'AZURE_KEY_VAULT_ENDPOINT'
  value: keyvault.properties.vaultUri
}]

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    //You will need to enable an admin user account in your Azure Container Registry even when you use an Azure managed identity https://docs.microsoft.com/azure/container-apps/containers
    adminUserEnabled: true 
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
  }
}

module nodePublisherImage 'br/public:deployment-scripts/build-acr:1.0.1' = {
  name: 'buildAcrImage-linux-dapr-node-pub'
  params: {
    AcrName: acr.name
    location: location
    gitRepositoryUrl:  'https://github.com/Azure-Samples/pubsub-dapr-nodejs-servicebus.git'
    gitRepoDirectory:  'checkout'
    imageName: 'checkout'
  }
}

module nodeSubscriberImage 'br/public:deployment-scripts/build-acr:1.0.1' = {
  name: 'buildAcrImage-linux-dapr-node-sub'
  params: {
    AcrName: acr.name
    location: location
    gitRepositoryUrl:  'https://github.com/Azure-Samples/pubsub-dapr-nodejs-servicebus.git'
    gitRepoDirectory:  'order-processor'
    imageName: 'order-processor'
  }
  dependsOn: [
    nodePublisherImage
  ]
}

module myenv 'br/public:app/dapr-containerapps-environment:1.2.1' = {
  name: 'pubsub'
  params: {
    location: location
    nameseed: 'pubsub-sb'
    applicationEntityName: 'orders'
    daprComponentType: 'pubsub.azure.servicebus'
  }
}

module appSubscriber 'br/public:app/dapr-containerapp:1.0.1' = {
  name: 'subscriber'
  params: {
    location: location
    containerAppEnvName: myenv.outputs.containerAppEnvironmentName
    containerAppName: 'subscriber-orders'
    containerImage: nodeSubscriberImage.outputs.acrImage
    azureContainerRegistry: acr.name
    environmentVariables: pubSubAppEnvVars
    targetPort: 5001
  }
}

module appPublisher 'br/public:app/dapr-containerapp:1.0.1' = {
  name: 'publisher'
  params: {
    location: location
    containerAppEnvName: myenv.outputs.containerAppEnvironmentName
    containerAppName: 'publisher-checkout'
    containerImage: nodePublisherImage.outputs.acrImage
    azureContainerRegistry: acr.name
    environmentVariables: pubSubAppEnvVars
    enableIngress: false
  }
}
