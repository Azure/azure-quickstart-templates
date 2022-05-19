<#

    Detect/validate which languages are supported by inspecting the files that are in the sample folder

#>

param(
    $sampleFolder = $ENV:SAMPLE_FOLDER,
    $mainTemplateFilenameBicep = $ENV:MAINTEMPLATE_FILENAME
)

Write-Host "Checking languages supported by sample: $sampleFolder"

$bicepFullPath = "$sampleFolder\$mainTemplateFilenameBicep"
$isBicepFileFound = Test-Path $bicepFullPath

# Support either mainTemplate.json or azuredeploy.json as the main JSON deployment template
# If both files exist, azuredeploy.json must be the one to deploy.
$jsonFilename1 = "azuredeploy.json"
$jsonFilename2 = "mainTemplate.json"
$isJsonFileFound = Test-Path "$($sampleFolder)\$jsonFilename1"
if ($isJsonFileFound) {
    $mainTemplateFilenameJson = $jsonFilename1
}
else {
    $isJsonFileFound = Test-Path "$($sampleFolder)\$jsonFilename2"
    if ($isJsonFileFound) {
        $mainTemplateFilenameJson = $jsonFilename2
    }
    else {
        # Neither is found.  Use azudeploy.json in error messages
        $mainTemplateFilenameJson = $jsonFilename1
    }
}

Write-Host "Found ${mainTemplateFilenameBicep}: $isBicepFileFound"
Write-Host "Found ${mainTemplateFilenameJson}: $isJsonFileFound"

# if bicep and json are found remind user json is no longer needed - but this is only needed if it's in the PR - can probably do it manually for now?
# if ($isBicepFileFound -and $isJsonFileFound) {
#    Write-Error "If $mainTemplateFilenameBicep file is included, $jsonFilename1 should not be modified as it will be automatically updated."
#}
# if (!$isJsonFileFound) {
#     Write-Error "$jsonFilename1 must always be included in the sample"
# }

if($isBicepFileFound){
    $mainTemplateDeploymentFilename = $mainTemplateFilenameBicep
}else{
    $mainTemplateDeploymentFilename = $mainTemplateFilenameJson
}

Write-Host "##vso[task.setvariable variable=bicep.supported]$isBicepFileFound"
Write-Host "##vso[task.setvariable variable=mainTemplate.filename.json]$mainTemplateFilenameJson"
Write-Host "##vso[task.setvariable variable=mainTemplate.deployment.filename]$mainTemplateDeploymentFilename"
#Write-Host "##vso[task.setvariable variable=bicep.version]" # Initialize to empty string, will be filled in by Install-Bicep.ps1
