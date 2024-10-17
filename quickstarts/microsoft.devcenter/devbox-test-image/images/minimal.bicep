param location string = resourceGroup().location
param imageName string
param builderIdentity string
param imageIdentity string
param galleryName string
param galleryResourceGroup string = resourceGroup().name
param gallerySubscriptionId string = subscription().subscriptionId
param revision string = '${utcNow('yyyy-MM-dd-HH-mm-ss')}Z'

module config '../modules/artifacts-config.bicep' = {
  name: 'config-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    imageBuildProfile: {}
    createSeparateSourcesDrive: false
  }
}

module publishProfile '../modules/publish-profile.bicep' = {
  name: 'publishProfile-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    location: location
    imageName: imageName
    galleryName: galleryName
    galleryResourceGroup: galleryResourceGroup
    gallerySubscriptionId: gallerySubscriptionId
    imageGalleries: []
    targetRegions: []
    imagePublishingProfile: {}
  }
}

var artifacts = [
  {
    name: 'windows-setenvvar'
    parameters: {
      Variable: 'BUILT_WITH_AIB'
      Value: 'true'
      PrintValue: 'true'
    }
  }
]

module aibImage '../modules/resource-aib.bicep' = {
  name: 'aibImage-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    imageName: imageName
    location: location
    builderIdentity: builderIdentity
    imageIdentity: imageIdentity
    baseImage: config.outputs.baseImageFull
    buildProfile: config.outputs.imageBuildProfile
    artifacts: artifacts
    publishingProfile: publishProfile.outputs.publishingProfile
    revision: revision
  }
}

output imageBuildLog string = aibImage.outputs.imageBuildLog
output stagingResourceGroupName string = aibImage.outputs.stagingResourceGroupName
