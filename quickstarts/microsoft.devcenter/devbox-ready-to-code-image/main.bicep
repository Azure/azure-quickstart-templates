import * as types from 'exports.bicep'

// Refer to modules/devbox-image.bicep for parameter descriptions
param location string = resourceGroup().location
param builderIdentity string
param imageIdentity string
param galleryName string
param galleryResourceGroup string = resourceGroup().name
param gallerySubscriptionId string = subscription().subscriptionId
param createDevDrive bool = true
param osDriveMinSizeGB int = 160
param imageBuildProfile object = {}
param isBaseImage bool = false
param imageBuildTimeoutInMinutes int = 180

// In the case of an error do not fail the deployment but rather return the tail of the customization log.
// Useful when debugging image build failures in PR validation pipelines (https://dev.azure.com/azurequickstarts/azure-quickstart-templates/_build).
param ignoreBuildFailure bool = false

param artifactSource {
  Url: string
  Branch: string
  Path: string
}?

param images types.images = {}

var defaultImages = {
  eShop: {
    name: 'quickstart-eShop'
    shouldBuild: true
  }
  axios: {
    name: 'quickstart-axios'
    shouldBuild: true
  }
  MSBuildSdks: {
    name: 'quickstart-MSBuildSdks'
    shouldBuild: true
  }
}

var imagesWithDefaults = union(defaultImages, images)

var artifactSourceWithDefaults = union(
  {
    // TODO: Switch to 'https://github.com/Azure/azure-quickstart-templates' after the changes are merged
    Url: 'https://github.com/dmgonch/azure-quickstart-templates'
    Path: 'quickstarts/microsoft.devcenter/devbox-ready-to-code-image/tools/artifacts'
    // TODO: Switch to 'master' branch after the changes are merged
    Branch: 'add-devbox-ready-to-code-image-sample'
  },
  artifactSource ?? {}
)

module eShop 'images/eShop.bicep' = if (imagesWithDefaults.eShop.shouldBuild) {
  name: 'eShopImg-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    location: location
    imageName: imagesWithDefaults.eShop.name
    isBaseImage: isBaseImage
    baseImage: imagesWithDefaults.eShop.?baseImage ?? ''
    builderIdentity: builderIdentity
    imageIdentity: imageIdentity
    galleryName: galleryName
    galleryResourceGroup: galleryResourceGroup
    gallerySubscriptionId: gallerySubscriptionId
    artifactSource: artifactSourceWithDefaults
    ignoreBuildFailure: ignoreBuildFailure
    createDevDrive: createDevDrive
    osDriveMinSizeGB: osDriveMinSizeGB
    imageBuildProfile: imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
  }
}

module axios 'images/axios.bicep' = if (imagesWithDefaults.axios.shouldBuild) {
  name: 'axiosImg-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    location: location
    imageName: imagesWithDefaults.axios.name
    isBaseImage: isBaseImage
    baseImage: imagesWithDefaults.axios.?baseImage ?? ''
    builderIdentity: builderIdentity
    imageIdentity: imageIdentity
    galleryName: galleryName
    galleryResourceGroup: galleryResourceGroup
    gallerySubscriptionId: gallerySubscriptionId
    artifactSource: artifactSourceWithDefaults
    ignoreBuildFailure: ignoreBuildFailure
    createDevDrive: createDevDrive
    osDriveMinSizeGB: osDriveMinSizeGB
    imageBuildProfile: imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
  }
}

module MSBuildSdks 'images/MSBuildSdks.bicep' = if (imagesWithDefaults.MSBuildSdks.shouldBuild) {
  name: 'MSBuildSdksImg-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    location: location
    imageName: imagesWithDefaults.MSBuildSdks.name
    builderIdentity: builderIdentity
    imageIdentity: imageIdentity
    galleryName: galleryName
    artifactSource: artifactSourceWithDefaults
    ignoreBuildFailure: ignoreBuildFailure
    imageBuildProfile: imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
  }
}

output imageResults types.results = {
  eShop: imagesWithDefaults.eShop.shouldBuild
    ? {
        buildLog: eShop.outputs.imageBuildLog
        stagingResourceGroupName: eShop.outputs.stagingResourceGroupName
      }
    : {}
  axios: imagesWithDefaults.axios.shouldBuild
    ? {
        buildLog: axios.outputs.imageBuildLog
        stagingResourceGroupName: axios.outputs.stagingResourceGroupName
      }
    : {}
  MSBuildSdks: imagesWithDefaults.MSBuildSdks.shouldBuild
    ? {
        buildLog: MSBuildSdks.outputs.imageBuildLog
        stagingResourceGroupName: MSBuildSdks.outputs.stagingResourceGroupName
      }
    : {}
}
