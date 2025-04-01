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

var repos = [
  {
    Url: 'https://github.com/axios/axios'
    Kind: 'Custom'
    HistoryDepth: 100
    CustomScript: 'npm install && npm run build'

    DesktopShortcutName: 'axios repo'
  }
  {
    Url: 'https://github.com/Azure/azure-quickstart-templates'
    DesktopShortcutEnable: true
  }
]

var afterReposClonedArtifacts = [
  {
    Name: 'windows-NodeJS'
    Parameters: {
      Version: '20.14.0'
    }
  }
  {
    name: 'windows-npm-global'
    Parameters: {
      packages: 'gulp-cli,vsts-npm-auth'
      addToPath: 'true'
    }
  }
]

// WinGet packages to install for all users during image creation.
// To discover ids of WinGet packages use 'winget search' command.
// To check whether a package supports machine-wide install, run: winget show --scope Machine --id <package-id>
var winGetPackageIds = [
  'Helm.Helm'
  'Kubernetes.kubectl'
  'Microsoft.Azure.Kubelogin'
  'Microsoft.Azure.AZCopy.10'
]

var winGetPackageArtifacts = [
  {
    name: 'windows-install-winget-packages'
    parameters: {
      packages: join(winGetPackageIds, ',')
    }
  }
]

// Visual Studio Code extensions
var visualStudioCodeExtensionArtifacts = [
  for extension in [
    'GitHub.copilot'
    'ms-azuretools.vscode-bicep'
  ]: {
    name: 'windows-install-visualstudiocode-extension'
    parameters: {
      ExtensionName: extension
    }
  }
]

var additionalArtifacts = concat(winGetPackageArtifacts, visualStudioCodeExtensionArtifacts)

module devBoxImage '../modules/devbox-image.bicep' = {
  name: 'axios-${uniqueString(deployment().name, resourceGroup().name)}'
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
    afterReposClonedArtifacts: afterReposClonedArtifacts
    additionalArtifacts: additionalArtifacts
    ignoreBuildFailure: ignoreBuildFailure
    imageBuildProfile: imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
  }
}

output imageBuildLog string = devBoxImage.outputs.imageBuildLog
output stagingResourceGroupName string = devBoxImage.outputs.stagingResourceGroupName
