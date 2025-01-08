import * as types from '../exports.bicep'

// Refer to modules/devbox-image.bicep for Dev Box Image Template parameter descriptions

param location string = resourceGroup().location
param imageName string
param isBaseImage bool
param builderIdentity string
param imageIdentity string
param galleryName string
param galleryResourceGroup string = resourceGroup().name
param gallerySubscriptionId string = subscription().subscriptionId
param createDevDrive bool
param osDriveMinSizeGB int
param imageBuildProfile object
param imageBuildTimeoutInMinutes int
param baseImage string = ''
param ignoreBuildFailure bool = false
param artifactSource types.artifactSource

var restoreCommands = [
  'dotnet workload restore'
  'dotnet restore --disable-build-servers'
]

var buildTestCommands = [
  'dotnet build --no-restore --disable-build-servers --framework net9.0 src/ClientApp/ClientApp.sln'
  'dotnet test --no-build --no-restore --disable-build-servers --framework net9.0 tests/ClientApp.UnitTests/ClientApp.UnitTests.csproj'
]

var repos = [
  {
    Url: 'https://github.com/dotnet/eShop'
    Kind: 'MSBuild'
    RestoreScript: join(restoreCommands, ' && ')
    Build: {
      RunBuildScript: join(buildTestCommands, ' && ')
    }
  }
  {
    Url: 'https://github.com/Azure-Samples/eShopOnAzure'
  }
]

module devBoxImage '../modules/devbox-image.bicep' = {
  name: 'eShop-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    imageName: imageName
    isBaseImage: isBaseImage
    baseImage: baseImage
    galleryName: galleryName
    galleryResourceGroup: galleryResourceGroup
    gallerySubscriptionId: gallerySubscriptionId
    repos: repos
    location: location
    imageIdentity: imageIdentity
    builderIdentity: builderIdentity
    createDevDrive: createDevDrive
    osDriveMinSizeGB: osDriveMinSizeGB
    artifactSource: artifactSource
    ignoreBuildFailure: ignoreBuildFailure
    imageBuildProfile: imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
  }
}

output imageBuildLog string = devBoxImage.outputs.imageBuildLog
output stagingResourceGroupName string = devBoxImage.outputs.stagingResourceGroupName
