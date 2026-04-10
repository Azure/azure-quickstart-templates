$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

# Fail the image build a bit earlier to capture error details from the log.
$imageBuildTimeoutInMinutes = ([int]$Env:PIPELINE_TIMEOUT_IN_MINUTES) - 5

$imageBicepPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'main.bicep'

$imageBuildProfileParam = 'imageBuildProfile={}'
if ($Env:VM_SKU) {
    $imageBuildProfileParam = "imageBuildProfile={""sku"": ""$Env:VM_SKU""}"
}

$artifactSourceParam = '{}'
if ($Env:ARTIFACTS_SOURCE_OBJ) {
    $artifactSourceParam = "artifactSource=$Env:ARTIFACTS_SOURCE_OBJ"
}

Write-Host "=== Building images with deployment $Env:DEPLOYMENT_NAME"
$deploymentOutput = az deployment group create --template-file $imageBicepPath --name $Env:DEPLOYMENT_NAME --subscription $Env:SUBSCRIPTION_ID --resource-group $Env:RESOURCE_GROUP `
    --parameters location=$Env:RESOURCES_LOCATION builderIdentity=$Env:BUILDER_IDENTITY imageIdentity=$Env:IMAGE_IDENTITY galleryName=$Env:GALLERY_NAME `
    ignoreBuildFailure=true imageBuildTimeoutInMinutes=$imageBuildTimeoutInMinutes $imageBuildProfileParam $artifactSourceParam

# Print the deployment output after fixing end-of-line characters in image build logs
$deploymentOutput -Replace '\\n', [Environment]::NewLine

Write-Host "=== Getting deployment result"
$deploymentResult = (az deployment group show --subscription $Env:SUBSCRIPTION_ID --resource-group $Env:RESOURCE_GROUP --name $Env:DEPLOYMENT_NAME) | ConvertFrom-Json

$deploymentResultProps = $deploymentResult.PSobject.Properties | Where-Object { $_.Name -eq 'properties' } | Select-Object -ExpandProperty Value
$outputResources = $deploymentResultProps | Select-Object -ExpandProperty outputResources
$imageTemplates = @($outputResources | Where-Object { $_ -match 'Microsoft.VirtualMachineImages' })

$failuresCount = 0
foreach ($imageTemplate in $imageTemplates) {
    Write-Host "=== Validating build result for image $($imageTemplate.id)"
    $templateInfo = (az image builder show --ids $imageTemplate.Id) | ConvertFrom-Json
    if ($templateInfo.lastRunStatus.runState -ne "Succeeded") {
        $failuresCount++
        Write-Warning "!!! [ERROR] Image build failed with status '$($templateInfo.lastRunStatus.runState)', message '$($templateInfo.lastRunStatus.message)'"
    }
}

if (($failuresCount -gt 0) -or ($imageTemplates.Count -eq 0)) {
    Write-Error "!!! [ERROR] $failuresCount image build(s) failed"
}
else {
    Write-Host "=== Success: $($imageTemplates.Count) image build(s) succeeded"
}
