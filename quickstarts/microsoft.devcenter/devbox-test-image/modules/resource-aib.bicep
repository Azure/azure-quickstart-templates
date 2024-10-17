param guidId string = newGuid()
param imageName string
param location string
param revision string
param builderIdentity string
param imageIdentity string
param baseImage string
param artifacts array
param buildProfile object
param publishingProfile object

var artifactsWithEncodedParams = [
  for artifact in artifacts: {
    name: artifact.name
    runAsSystem: contains(artifact, 'runAsSystem') ? artifact.runAsSystem : false
    paramsBase64: contains(artifact, 'parameters') && (!empty(artifact.parameters))
      ? base64(string(artifact.parameters))
      : ''
  }
]

var artifactCustomizers = [
  for artifact in artifactsWithEncodedParams: (artifact.name == 'windows-updates-simple')
    ? {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 40
      }
    : (artifact.name == 'windows-restart')
        ? {
            type: 'WindowsRestart'
          }
        : {
            type: 'PowerShell'
            runAsSystem: artifact.runAsSystem ? true : null
            runElevated: artifact.runAsSystem ? true : null
            name: 'RunArtifact-${artifact.name}'
            validExitCodes: [0]
            inline: [
              'Write-Host \'=== Running: ${artifact.name} ${artifact.paramsBase64}\''
              '. C:/.tools/artifacts/run-artifact.ps1'
              '____Invoke-ImageFactory-Artifact -____ImageFactoryArtifactName ${artifact.name} -____ImageFactoryParamsBase64 \'${artifact.paramsBase64}\''
            ]
          }
]

var downloadArtifactsScriptText = replace(loadTextContent('../tools/download-artifacts.ps1'), '\r\n', '\n')
var downloadArtifactsScriptLines = split(downloadArtifactsScriptText, '\n')

var customizers = concat(
  [
    {
      type: 'PowerShell'
      name: 'EnvVarsOnStart'
      inline: [
        'Write-Host "=== Environment variables on start:"'
        'Get-ChildItem Env: | sort -Property name | ForEach-Object { "$($_.Name)=$($_.Value)" }'
      ]
    }
    {
      type: 'PowerShell'
      name: 'EnvVarsOnStartAsSystem'
      runAsSystem: true
      runElevated: true
      inline: [
        'Write-Host "=== Environment variables on start As System:"'
        'Get-ChildItem Env: | sort -Property name | ForEach-Object { "$($_.Name)=$($_.Value)" }'
      ]
    }
    {
      type: 'PowerShell'
      name: 'DownloadArtifacts'
      inline: downloadArtifactsScriptLines
    }
  ],
  artifactCustomizers,
  [
    {
      type: 'PowerShell'
      name: 'EnvVarsOnEnd'
      inline: [
        'Write-Host "=== Environment variables on end:"'
        'Get-ChildItem Env: | sort -Property name | ForEach-Object { "$($_.Name)=$($_.Value)" }'
      ]
    }
  ]
)

var baseImageParts = split(baseImage, '/')
var imageTemplateName = '${imageName}-${revision}'
var stagingResourceGroupName = '${imageTemplateName}-stg'

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName
  location: location
  tags: {
    imageName: imageName
    imageTemplate: revision
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${builderIdentity}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 720
    // Use deterministic resource group for staging resources
    stagingResourceGroup: '${subscription().id}/resourceGroups/${stagingResourceGroupName}'
    vmProfile: {
      // https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?tabs=json%2Cazure-powershell#user-assigned-identity-for-the-image-builder-build-vm
      userAssignedIdentities: [imageIdentity]
      vmSize: 'Standard_D8_v4' // TODO: use buildProfile as well
      osDiskSizeGB: buildProfile.diskSize
    }
    source: {
      type: 'PlatformImage'
      // TODO: support custom base images
      publisher: baseImageParts[1]
      offer: baseImageParts[2]
      sku: baseImageParts[3]
      version: baseImageParts[4]
    }
    customize: customizers
    distribute: [
      {
        type: 'SharedImage'
        runOutputName: imageName
        galleryImageId: publishingProfile.computeGalleries[0].computeGalleryId // TODO: support multiple galleries
        // TODO: switch to targetRegions https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?tabs=json%2Cazure-powershell#distribute-targetregions
        replicationRegions: [publishingProfile.targetRegions[0].name]
        artifactTags: {
          imageName: imageName
          imageTemplate: revision
        }
      }
    ]
  }
}

resource buildImageTemplateScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${imageName}-build-template-script-${uniqueString(resourceGroup().name)}'
  location: location
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
    azPowerShellVersion: '9.7'
    environmentVariables: [
      {
        name: 'imageTemplateName'
        value: imageTemplateName
      }
      {
        name: 'resourceGroupName'
        value: resourceGroup().name
      }
    ]
    scriptContent: loadTextContent('../tools/run-image-build.ps1')
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
