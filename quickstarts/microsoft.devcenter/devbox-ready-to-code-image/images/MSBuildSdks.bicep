// Refer to modules/devbox-image.bicep for parameter descriptions

param location string = resourceGroup().location
param imageName string
param builderIdentity string
param imageIdentity string
param galleryName string
param imageBuildProfile object
param imageBuildTimeoutInMinutes int
param ignoreBuildFailure bool = false

param artifactSource {
  Url: string
  Branch: string
  Path: string
}

module devBoxImage '../modules/devbox-image.bicep' = {
  name: 'MSBuildSdks-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    location: location
    imageName: imageName
    isBaseImage: false
    galleryName: galleryName
    repos: [
      {
        Url: 'https://github.com/microsoft/MSBuildSdks'
        Kind: 'MSBuild'
      }
    ]

    imageIdentity: imageIdentity
    builderIdentity: builderIdentity
    artifactSource: artifactSource
    ignoreBuildFailure: ignoreBuildFailure
    imageBuildProfile: imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
  }
}

output imageBuildLog string = devBoxImage.outputs.imageBuildLog
output stagingResourceGroupName string = devBoxImage.outputs.stagingResourceGroupName
