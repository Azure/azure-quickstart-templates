import * as types from 'exports.bicep'

// Find full list of Dev Box Image Template parameters in to modules/devbox-image.bicep

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Full resource ID of Azure Managed Identity to be associated with Azure Image Builder Template and helper deployment scripts')
param builderIdentity string

@description('Full resource ID of Azure Managed Identity to use when accessing Azure and Azure DevOps resources during image creation')
param imageIdentity string

@description('''
Name of the Compute Gallery where to publish the resulting image. The gallery is assumed to be in the same resource group as the resulting image.
This parameter is ignored if imagePublishingProfile explicitly defines the list of Compute Galleries via its computeGalleries property.
''')
param galleryName string

@description('Compute Gallery resource group. Ignored if galleryName is not provided.')
param galleryResourceGroup string = resourceGroup().name

@description('Compute Gallery subscription id. Ignored if galleryName is not provided.')
param gallerySubscriptionId string = subscription().subscriptionId

@description('Whether to create a separate volume, format it with Dev Drive and use the volume for all repos, caches and related tools.')
param createDevDrive bool = true

@description('Minimum size of the OS drive in GB if a separate Dev Drive volume is created.')
param osDriveMinSizeGB int = 160

@description('Custom VS SKU to use when allocating the VM for image creation')
// The default SKU value allows building images with in PR validation pipelines (https://dev.azure.com/azurequickstarts/azure-quickstart-templates/_build).
param imageBuildProfile object = {
  sku: 'Standard_D2_v4'
}

@description('Specifies whether the image is a base image, i.e. that is not meant to be used directly by users but as a base for other images. Base images cannot be used with Dev Box service at the moment.')
param isBaseImage bool = false

@description('Timeout in minutes for the image build process')
param imageBuildTimeoutInMinutes int = 180

@description('Git repository containing artifacts to be used in the image build')
param artifactSource types.artifactSource = {
  Url: 'https://github.com/Azure/azure-quickstart-templates'
  Path: 'quickstarts/microsoft.devcenter/devbox-ready-to-code-image/tools/artifacts'
  Branch: 'master'
}

@description('''
In the case of an error do not fail the deployment but rather return the tail of the customization log.
Useful when debugging image build failures in PR validation pipelines (https://dev.azure.com/azurequickstarts/azure-quickstart-templates/_build).
''')
param ignoreBuildFailure bool = false

@description('Custom sample images configuration')
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
    artifactSource: artifactSource
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
    artifactSource: artifactSource
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
    artifactSource: artifactSource
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
