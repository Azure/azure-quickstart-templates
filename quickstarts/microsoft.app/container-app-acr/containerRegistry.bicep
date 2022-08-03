@description('Specifies the location for all resources.')
param location string 

param containerRegistryName string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
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

output id string = containerRegistry.id
output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
