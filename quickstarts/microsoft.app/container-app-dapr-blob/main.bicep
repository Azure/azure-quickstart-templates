// Bicep version of Microservices tutorial
// https://learn.microsoft.com/en-us/azure/container-apps/microservices-dapr-azure-resource-manager?tabs=bash&pivots=container-apps-bicep

@description('Specifies the name of the client container app.')
param clientAppName string = 'app-py-generate'

@description('Specifies the name of the service container app.')
param serviceAppName string = 'app-node-consume'

@description('Specifies the name of the container app environment.')
param containerAppEnvName string = 'env-${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
param location string = resourceGroup().location 

module myenv 'br/public:app/dapr-containerapps-environment:1.2.1' = {
  name: containerAppEnvName
  params: {
    location: location
    nameseed: 'stateapp'
    applicationEntityName: 'appdata'
    daprComponentType: 'state.azure.blobstorage'
    daprComponentScopes: [
      serviceAppName
    ]
  }
}

module appNodeService 'br/public:app/dapr-containerapp:1.0.2' = {
  name: 'stateNodeApp'
  params: {
    location: location
    containerAppName: serviceAppName
    containerAppEnvName: myenv.outputs.containerAppEnvironmentName
    containerImage: 'ghcr.io/dapr/samples/hello-k8s-node:latest'
    targetPort: 3000
    externalIngress: false
    createUserManagedId: false
    environmentVariables: [
      {
        name: 'APP_PORT'
        value: '3000'
      }
    ]
  }
}

module appPythonClient 'br/public:app/dapr-containerapp:1.0.2' = {
  name: 'statePyApp'
  params: {
    location: location
    containerAppName: clientAppName
    containerAppEnvName: myenv.outputs.containerAppEnvironmentName
    containerImage: 'ghcr.io/dapr/samples/hello-k8s-python:latest'
    enableIngress: false
    createUserManagedId: false
    daprAppProtocol: ''
  }
}
