import * as types from '../exports.bicep'

param guidId string = newGuid()
param imageName string
param location string
param imageVersion string
param builderIdentity string
param imageIdentity string
param baseImage string
param artifacts array
param buildProfile object
param imageBuildTimeoutInMinutes int
param publishingProfile object
param artifactSource types.artifactSource
param printCustomizationLogLastLines int
param ignoreBuildFailure bool

var artifactsWithEncodedParams = [
  for artifact in artifacts: {
    name: artifact.name
    runAsSystem: artifact.?runAsSystem ?? false
    paramsBase64: contains(artifact, 'parameters') && (!empty(artifact.parameters))
      ? base64(string(artifact.parameters))
      : ''
  }
]

var artifactCustomizers = [
  for artifact in artifactsWithEncodedParams: (artifact.name == 'WindowsUpdate')
    // This is the place to configure WindowsUpdate artifact as described in https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?tabs=json%2Cazure-powershell#windows-update-customizer
    // Or possibly add more customizers to run before or after WindowsUpdate
    ? {
        type: 'WindowsUpdate'
      }
    : (artifact.name == 'WindowsRestart')
        // This is the place to configure WindowsRestart artifact as described in https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?tabs=bicep%2Cazure-powershell#windows-restart-customizer
        // Or possibly add more customizers to run before or after WindowsRestart
        ? {
            type: 'WindowsRestart'
          }
        : {
            type: 'PowerShell'
            // runElevated needs to be set to true only when running as system because by default customizers alrady run elevated.
            // Settting runElevated to true without runAsSystem results in a hang.
            runAsSystem: artifact.runAsSystem ? true : null
            runElevated: artifact.runAsSystem ? true : null
            name: 'RunArtifact-${artifact.name}'
            validExitCodes: [0]
            inline: [
              '. C:/.tools/Setup/artifacts/run-artifact.ps1'
              '____Invoke-Artifact -____ArtifactName ${artifact.name} -____ParamsBase64 \'${artifact.paramsBase64}\''
            ]
          }
]

var downloadArtifactsScriptText = replace(loadTextContent('../tools/download-artifacts.ps1'), '\r\n', '\n')
var downloadArtifactsScriptLines = concat(
  [
    '$scriptsRepoUrl = \'${artifactSource.Url}\''
    '$scriptsRepoBranch = \'${artifactSource.Branch}\''
    '$scriptsRepoPath = \'${artifactSource.Path}\''
  ],
  split(downloadArtifactsScriptText, '\n')
)

var customizers = concat(
  [
    {
      type: 'PowerShell'
      name: 'EnvVarsOnStart'
      runAsSystem: false
      runElevated: false
      inline: [
        'Write-Host "=== Environment variables on start:"'
        'Get-ChildItem Env: | Sort-Object -Property name | ForEach-Object { "$($_.Name)=$($_.Value)" }'
      ]
    }
    {
      type: 'PowerShell'
      name: 'DownloadArtifacts'
      inline: downloadArtifactsScriptLines
    }
  ],
  artifactCustomizers
)

var tags = {
  imageName: imageName
  imageTemplate: imageVersion
  deploymentName: deployment().name
}

// Generate new template resource for each deployment to be able to control all image properties. 
// An attempt to update an existing template resource fails with 'Update/Upgrade of image templates is currently not supported. Please change the name of the template you are submitting'
// See more at https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-troubleshoot#error
var imageTemplateName = '${imageName}-${imageVersion}'

var stagingResourceGroupName = '${imageTemplateName}-stg'

var baseUrnImageParts = split(baseImage, ':')
var imageSource = startsWith(baseImage, '/subscriptions/')
  ? {
      type: 'SharedImageVersion'
      imageVersionId: baseImage
    }
  : {
      type: 'PlatformImage'
      publisher: baseUrnImageParts[0]
      offer: baseUrnImageParts[1]
      sku: baseUrnImageParts[2]
      version: baseUrnImageParts[3]
    }

var replicationRegions = map(publishingProfile.targetRegions, targetRegion => targetRegion.name)

var distribute = [
  for computeGallery in publishingProfile.computeGalleries: {
    type: 'SharedImage'
    runOutputName: imageName
    #disable-next-line use-resource-id-functions
    galleryImageId: '${computeGallery.computeGalleryId}/versions/${imageVersion}'
    replicationRegions: replicationRegions
    artifactTags: tags
  }
]

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${builderIdentity}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: imageBuildTimeoutInMinutes
    // Use deterministic resource group for staging resources
    stagingResourceGroup: '${subscription().id}/resourceGroups/${stagingResourceGroupName}'
    vmProfile: {
      // https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?tabs=json%2Cazure-powershell#user-assigned-identity-for-the-image-builder-build-vm
      userAssignedIdentities: [imageIdentity]
      vmSize: buildProfile.sku
      osDiskSizeGB: buildProfile.diskSize
    }
    source: imageSource
    customize: customizers
    distribute: distribute
  }
}

var scripts = [
  loadTextContent('../tools/deployment-script-utils.ps1')
  loadTextContent('../tools/run-image-build.ps1')
]

resource buildImageTemplateScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${imageName}-build'
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${builderIdentity}': {}
    }
  }
  dependsOn: [
    imageTemplate
  ]
  properties: {
    forceUpdateTag: guidId
    azPowerShellVersion: '13.0'
    environmentVariables: [
      {
        name: 'imageTemplateName'
        value: imageTemplateName
      }
      {
        name: 'resourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'stagingResourceGroupName'
        value: stagingResourceGroupName
      }
      {
        name: 'ignoreBuildFailure'
        value: '${ignoreBuildFailure}'
      }
      {
        name: 'printCustomizationLogLastLines'
        value: '${printCustomizationLogLastLines}'
      }
    ]
    scriptContent: join(scripts, '\n\n')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: buildImageTemplateScript
  name: 'default'
}

output imageBuildLog string = logs.properties.log
output stagingResourceGroupName string = stagingResourceGroupName
