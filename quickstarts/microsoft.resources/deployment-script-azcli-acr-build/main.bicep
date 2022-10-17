@description('The name of the Azure Container Registry')
param AcrName string = 'cr${uniqueString(resourceGroup().id)}'

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('The Git Repository URL, eg. https://github.com/YOURORG/YOURREPO.git')
param gitRepositoryUrl string = 'https://github.com/Azure-Samples/DotNet47WinContainerModernize.git'

@description('The name of the repository branch to use')
param gitBranch string = 'main'

@description('The directory in the repo that contains the dockerfile')
param gitRepoDirectory string = 'eShopLegacyWebFormsSolution'

@description('The image name/path you want to create in ACR')
param imageName string = 'dotnet/framework/aspnet'

param imageTag string = '4.8-windowsservercore-ltsc2019'

@description('The ACR compute platform needed to build the image')
param acrBuildPlatform string = 'windows'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: AcrName
  location: location
  sku: {
    name: 'Basic'
  }
}

module buildAcrImage 'br/public:deployment-scripts/build-acr:1.0.1' = {
  name: 'buildAcrImage-${replace(imageName,'/','-')}'
  params: {
    AcrName: acr.name
    location: location
    gitRepositoryUrl: gitRepositoryUrl
    gitBranch: gitBranch
    gitRepoDirectory: gitRepoDirectory
    imageName: imageName
    imageTag: imageTag
    acrBuildPlatform: acrBuildPlatform
  }
}

output acrImage string = buildAcrImage.outputs.acrImage
