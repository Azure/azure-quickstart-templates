@description('The name of the Azure Container Registry')
param AcrName string = 'cr${uniqueString(resourceGroup().id)}'

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('An array of fully qualified images names to import')
param images array = [
  'docker.io/bitnami/external-dns:latest'
]

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: AcrName
  location: location
  sku: {
    name: 'Basic'
  }
}

module acrImport 'br/public:deployment-scripts/import-acr:1.0.1' = {
  name: 'ImportAcrImages'
  params: {
    acrName: acr.name
    location: location
    images: images
  }
}
