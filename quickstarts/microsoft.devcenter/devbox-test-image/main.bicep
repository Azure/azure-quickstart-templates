param location string = resourceGroup().location
param builderIdentity string
param imageIdentity string
param galleryName string
param galleryResourceGroup string = resourceGroup().name
param gallerySubscriptionId string = subscription().subscriptionId

// module image 'images/minimal.bicep' = {
//   name: 'minimal'
//   params: {
//     location: location
//     imageName: 'minimal'
//     builderIdentity: builderIdentity
//     imageIdentity: imageIdentity
//     galleryName: galleryName
//     galleryResourceGroup: galleryResourceGroup
//     gallerySubscriptionId: gallerySubscriptionId
//   }
// }

// module getCustomizationsLog 'modules/customizations-log.bicep' = {
//   name: 'get-customizations-log-${uniqueString(deployment().name, resourceGroup().name)}'
//   params: {
//     location: location
//     builderIdentity: builderIdentity
//     imageBuildStagingResourceGroupName: image.outputs.stagingResourceGroupName
//   }
// }

// output stagingResourceGroupName string = image.outputs.stagingResourceGroupName
// output imageBuildLog string = image.outputs.imageBuildLog
// output getCustomizationsLog string = getCustomizationsLog.outputs.copyCustomizationsLogScriptResult

param guidId string = newGuid()

resource deploymentScriptSuccess 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'test-deployment-script-success'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: guidId
    azPowerShellVersion: '9.7'
    scriptContent: '''
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    Write-Host 'Writing to Host: TEST SUCCESS'
    Write-Output 'Writing to Output: TEST SUCCESS'

    $PSVersionTable

    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['testKey'] = 'test key value'

    Start-Sleep -Seconds 15
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}

resource successLogs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: deploymentScriptSuccess
  name: 'default'
}

resource deploymentScriptFailure 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'test-deployment-script-failure'
  location: location
  kind: 'AzurePowerShell'
  dependsOn: [deploymentScriptSuccess]
  properties: {
    forceUpdateTag: guidId
    azPowerShellVersion: '9.7'
    scriptContent: '''
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    Write-Host 'Writing to Host: TEST FAILURE'
    Write-Output 'Writing to Output: TEST FAILURE'
    Start-Sleep -Seconds 15

    Write-Error '!!! TESTING FAILURE'

    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}

resource failureLogs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: deploymentScriptFailure
  name: 'default'
}

output successLlogs string = successLogs.properties.log
output testKey string = deploymentScriptSuccess.properties.outputs.testKey
output failureLogs string = failureLogs.properties.log
