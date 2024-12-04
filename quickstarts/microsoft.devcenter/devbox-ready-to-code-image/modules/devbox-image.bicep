import * as types from '../exports.bicep'

param location string = resourceGroup().location

@description('Used to name "VM image definition" and some other Azure resources.')
param imageName string

@description('Specifies whether the image is a base image, i.e. that is not meant to be used directly by users but as a base for other images. Base images cannot be used with Dev Box service at the moment.')
param isBaseImage bool

@description('''
Name of the Compute Gallery where to publish the resulting image. The gallery is assumed to be in the same resource group as the resulting image.
This parameter is ignored if imagePublishingProfile explicitly defines the list of Compute Galleries via its computeGalleries property.
''')
param galleryName string = ''

@description('Compute Gallery resource group. Ignored if galleryName is not provided.')
param galleryResourceGroup string = resourceGroup().name

@description('Compute Gallery subscription id. Ignored if galleryName is not provided.')
param gallerySubscriptionId string = subscription().subscriptionId

@description('''
Custom image Publishing Profile that can be partially specified with the rest of the properties filled in with the following defaults:
- targetRegions : one replica in the same region as the target image;
- computeGalleries : single gallery but only if galleryName parameter is provided.
''')
param imagePublishingProfile object = {}

@description('Publish image to multiple image galleries')
param imageGalleries array = []

@description('Replicate image to multiple regions')
param targetRegions array = []

@description('Full resource ID of Azure Managed Identity to be associated with Azure Image Builder Template and helper deployment scripts')
param builderIdentity string

@description('Full resource ID of Azure Managed Identity to use when accessing Azure and Azure DevOps resources during image creation')
param imageIdentity string

@description('Git repositories to clone/update and warm up')
param repos array = []

@description('Artifacts to run after all repos are cloned/updated but before packages are restored and repos are built')
param afterReposClonedArtifacts array = []

@description('Artifacts to run before setting up repositories')
param beforeReposSetupArtifacts array = []

@description('Artifacts to run after setting up repositories')
param additionalArtifacts array = []

// Generate ever inscreasing Azure Compute Gallery compiant image version
param imageVersion string = utcNow('yyyy.MMdd.HHmmss')

@description('''
When this parameter is not specified, the default base image used is https://azuremarketplace.microsoft.com/en-us/marketplace/apps/microsoftvisualstudio.visualstudioplustools.
When this parameter is specified, the base image is expected to be in one of the following formats:
1) Azure Marketplace image URN in the format <publisher>:<offer>:sku>:<version> (https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage#terminology)
2) Azure Compute Gallery image resource id (see https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?tabs=bicep%2Cazure-powershell#sharedimageversion-source)
3) Azure Compute Gallery image name by default is assumed to be in the same resource group as the deployment
''')
param baseImage string = ''

@description('Whether to add recommended Windows defender exclusions')
param defenderExclusions bool = true

@description('List of directories to add to Windows Defender exclutions when user logs in for the first time. The entries can reference user specific environment variables like %USERPROFILE%, %LOCALAPPDATA%, etc')
param userDefenderExclusions array = []

@description('''
Whether to create a separate volume, format it with Dev Drive and use the volume for all repos, caches and related tools.
Requires a compatible Win11 22H2 October 2023 or later base image.
''')
param createDevDrive bool = true

@description('Optional configuration for Dev Drive.')
param devDriveOptions object = {}

@description('''
The required minimum size of NTFS C: drive when a Dev Drive volume is created.
Defaults to 160 GB. The Dev Drive will consume the rest of the space on the machine's
main virtual disk. This size must be 50GB or greater to contain the OS and apps.

Parameters osDriveMinSizeGB and imageBuildProfile.diskSize allow full control over the sizes of C: and Q: drives.

Note that because the disk image's linear partition space will now contain two partitions,
the size of C: cannot later be expanded. This means if you are deriving your Dev Box image
from one with a smaller OS drive size than you need, you need to change the base image to a
larger size, or create a new base image with the size you want.
Note: This is only applicable if createDevDrive is set to true.
''')
param osDriveMinSizeGB int = 160

@description('Custom VS SKU to use when allocating the VM for image creation')
param imageBuildProfile object = {}

@description('Timeout in minutes for the image build process')
param imageBuildTimeoutInMinutes int = 180

@description('Configuration of developer tools. See defaultDevTools for defaults.')
param devTools object = {}

@description('Configuration of Azure Artifact credential providers. See defaultCredentialProvider for defaults.')
param credentialProvider object = {}

@description('Custom metadata for the image to write into ImageBuildReport.txt on the desktop and report in telemetry. A proposed use case is to add information about image owners, support contacts, etc.')
param customMetadata object = {}

@description('Turns off disk write cache buffer flushing for 3-5% faster builds and 20-30% faster cache downloads.')
param disableAllDiskWriteCacheFlushing bool = true

@description('''
Pre-install winget during image creation and make it available to the user right away on logging in. 
By default, winget is installed lazily after user is logged in for the first time.
More at https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget
''')
param installLatestWinGet bool = true

@description('Git repository containing artifacts to be used in the image build')
param artifactSource types.artifactSource

@description('Number of lines to print from the end of the customization log. Value of -1 will print the entire log. Value of 0 will print nothing.')
param printCustomizationLogLastLines int = 1000

@description('Set to true to ignore image build failure and return through imageBuildLog the tail of the build customization log as defined by printCustomizationLogLastLines. Useful for debugging build failures.')
param ignoreBuildFailure bool = false

// ****NOTE****
// If new parameters are added to this file they must be added to the allParamsForLogging variable below in order to be logged
var allParamsForLogging = {
  imageName: imageName
  isBaseImage: isBaseImage
  baseImage: baseImage
  deploymentName: deployment().name
  galleryName: galleryName
  galleryResourceGroup: galleryResourceGroup
  gallerySubscriptionId: gallerySubscriptionId
  imagePublishingProfile: imagePublishingProfile
  imageGalleries: imageGalleries
  targetRegions: targetRegions
  builderIdentity: builderIdentity
  imageIdentity: imageIdentity
  repos: repos
  afterReposClonedArtifacts: afterReposClonedArtifacts
  beforeReposSetupArtifacts: beforeReposSetupArtifacts
  additionalArtifacts: additionalArtifacts
  imageVersion: imageVersion
  defenderExclusions: defenderExclusions
  userDefenderExclusions: userDefenderExclusions
  createDevDrive: createDevDrive
  devDriveOptions: devDriveOptions
  osDriveMinSizeGB: osDriveMinSizeGB
  imageBuildProfile: imageBuildProfile
  devTools: devTools
  installLatestWinGet: installLatestWinGet
  credentialProvider: credentialProvider
  customMetadata: customMetadata
  disableAllDiskWriteCacheFlushing: disableAllDiskWriteCacheFlushing
  artifactSource: artifactSource
  printCustomizationLogLastLines: printCustomizationLogLastLines
  ignoreBuildFailure: ignoreBuildFailure
}

// Defaults for properties that were not explicitly specified
var defaultDevTools = {
  VisualStudioSKU: 'Enterprise'
  VisualStudioWorkloads: 'minimal'
  VisualStudioBootstrapperURL: 'https://aka.ms/vs/17/release/vs_Enterprise.exe'
  // VisualStudioInstallationDirectory - Install into the default directory if not specified

  // By default Visual Studio is not re-installed when the base image is coming from Azure Gallery and it is known to contain the latest VS.
  AlwaysInstallVisualStudio: false
}

var defaultCredentialProvider = {
  version: '' // Installs latest officially released version (not a preview) by default
  installNet6: true
  msal: true // Force MSAL by default because ADAL is deprecated and out of the compliance
  canShowDialog: true // Override tooling behavior and show dialog or system browser instead of device flow
}

// Whether to create a separate drive (Q:) for for all repos, caches and related tools.
var createSeparateSourcesDrive = createDevDrive

module config 'artifacts-config.bicep' = {
  name: 'config-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    createSeparateSourcesDrive: createSeparateSourcesDrive
    imageBuildProfile: imageBuildProfile
    baseImage: baseImage
    galleryName: galleryName
    galleryResourceGroup: galleryResourceGroup
    gallerySubscriptionId: gallerySubscriptionId
  }
}

// Fill missing devTools values with defaults
var devToolsWithDefaults = union(defaultDevTools, devTools)

var credentialProviderWithDefaults = union(defaultCredentialProvider, credentialProvider)

var imageContainsLatestVisualStudio = startsWith(
  config.outputs.baseImageFull,
  'MicrosoftVisualStudio:visualstudio2022:'
) || startsWith(config.outputs.baseImageFull, 'MicrosoftVisualStudio:visualstudioplustools:vs-2022')

module devtools 'artifacts-devtools.bicep' = {
  name: 'devtools-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    devTools: devToolsWithDefaults
    imageContainsLatestVisualStudio: imageContainsLatestVisualStudio
  }
}

module repoArtifacts 'artifacts-repos.bicep' = {
  name: 'repoArtifacts-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    ntfsDriveRoot: config.outputs.ntfsDriveRoot
    sourcesDriveRoot: config.outputs.sourcesDriveRoot
    sourcesDirWithoutDriveLetter: config.outputs.sourcesDirWithoutDriveLetter
    toolsRoot: config.outputs.toolsRoot
    credentialProvider: credentialProviderWithDefaults
    repos: repos
    shortcutDriveRoot: config.outputs.shortcutDriveRoot
  }
}

// Add ntfs sources directory path in defender exclusion list if AvoidDevDrive is enabled for any repo
var updatedDefenderExclusionPathList = (createSeparateSourcesDrive && repoArtifacts.outputs.anyAvoidDevDriveRepos)
  ? '${config.outputs.defenderExclusionPathList},${config.outputs.ntfsSourcesDirExclusionPath}'
  : config.outputs.defenderExclusionPathList

module common 'artifacts-common.bicep' = {
  name: 'common-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    toolsRoot: config.outputs.toolsRoot
    defenderExclusions: defenderExclusions
    userDefenderExclusions: userDefenderExclusions
    createDevDrive: createDevDrive
    devDriveOptions: devDriveOptions
    osDriveMinSizeGB: osDriveMinSizeGB
    sourcesDriveRoot: config.outputs.sourcesDriveRoot
    defenderExclusionPathList: updatedDefenderExclusionPathList
    allParamsForLogging: allParamsForLogging
    credentialProvider: credentialProviderWithDefaults
    disableAllDiskWriteCacheFlushing: disableAllDiskWriteCacheFlushing
    installLatestWinGet: installLatestWinGet
  }
}

var reposSetupSourcesFlattened = flatten(map(repoArtifacts.outputs.repoSetupSourcesObjects, obj => obj.Artifacts))
var reposWarmupFlattened = flatten(map(repoArtifacts.outputs.repoWarmupObjects, obj => obj.Artifacts))

// If the base image is a custom one (i.e. not from Azure Marketplace), assume it was built using the image template defined in this file.
// This allows decide whether to skip installing tools that are already present on the base image and therefore speed up the build time of the derived image.
var runningFirstImageGen = !contains(config.outputs.baseImageFull, '/providers/Microsoft.Compute/galleries/')

var artifacts = concat(
  common.outputs.artifacts.runBeforeAll,

  // Create Dev Drive volume, if configured, before installing anything.
  common.outputs.artifacts.optionalCreateDevDrive,

  // It is OK to add Windows Defender exclusions for folders that might not exist yet
  common.outputs.artifacts.optionalDefenderExclusions,

  // Before installing tools or running builds, turn off disk cache buffer flushing for all disks.
  // Must come after creating the Dev Drive code drive.
  common.outputs.artifacts.optionalDisableAllDiskWriteCacheFlushing,

  runningFirstImageGen ? concat(common.outputs.artifacts.runInstalls, devtools.outputs.installOnce) : [],

  beforeReposSetupArtifacts,

  // Always install repo configuration artifacts to create/update repos and their caches/outputs
  repoArtifacts.outputs.commonArtifacts,
  reposSetupSourcesFlattened,

  afterReposClonedArtifacts,

  reposWarmupFlattened,

  additionalArtifacts,
  common.outputs.artifacts.runAfterAll
)

module publishProfile 'publish-profile.bicep' = {
  name: 'publishProfile-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    location: location
    imageName: imageName
    galleryName: galleryName
    galleryResourceGroup: galleryResourceGroup
    gallerySubscriptionId: gallerySubscriptionId
    imageGalleries: imageGalleries
    targetRegions: targetRegions
    imagePublishingProfile: imagePublishingProfile
    isBaseImage: isBaseImage
  }
}

module aibImage 'resource-aib.bicep' = {
  name: 'aibImage-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    imageName: imageName
    location: location
    builderIdentity: builderIdentity
    imageIdentity: imageIdentity
    baseImage: config.outputs.baseImageFull
    buildProfile: config.outputs.imageBuildProfile
    imageBuildTimeoutInMinutes: imageBuildTimeoutInMinutes
    artifacts: artifacts
    publishingProfile: publishProfile.outputs.publishingProfile
    imageVersion: imageVersion
    artifactSource: artifactSource
    printCustomizationLogLastLines: printCustomizationLogLastLines
    ignoreBuildFailure: ignoreBuildFailure
  }
}

output imageBuildLog string = aibImage.outputs.imageBuildLog
output stagingResourceGroupName string = aibImage.outputs.stagingResourceGroupName
