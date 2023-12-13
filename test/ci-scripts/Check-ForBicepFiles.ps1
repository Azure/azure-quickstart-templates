<#

    Detect which bicep files need to be compiled and compile them - this should be run upon merge of a sample to auto-create azuredeploy.json

#>

param(
    $sampleFolder = $ENV:SAMPLE_FOLDER,
    $mainTemplateFilenameBicep = $ENV:MAINTEMPLATE_FILENAME,
    $prereqTemplateFilenameBicep = $ENV:PREREQ_TEMPLATE_FILENAME_BICEP,
    $prereqTemplateFileName = $ENV:PREREQ_TEMPLATE_FILENAME_JSON,
    $ttkFolder = $ENV:TTK_FOLDER
)

# there should be an ENV var to determine if bicep is used, checking directly s/b ok as well

Write-Host "Checking for bicep files in: $sampleFolder"

$bicepFullPath = "$sampleFolder\$mainTemplateFilenameBicep"
$isBicepFileFound = Test-Path $bicepFullPath

$prereqBicepFullPath = "$sampleFolder\prereqs\$prereqTemplateFilenameBicep"
$isBicepPrereqFileFound = Test-Path $prereqBicepFullPath

Write-Output "Bicep files:"
Write-Host $bicepFullPath
Write-Host $prereqBicepFullPath
Write-Output "************************"

if($isBicepFileFound -or $isBicepPrereqFileFound){
    # Install Bicep
    & "$ttKFolder\ci-scripts\Install-Bicep.ps1"

    Get-Command bicep.exe

    if($isBicepFileFound){
        # build main.bicep to azuredeploy.json
        Write-Output "Building: $sampleFolder\azuredeploy.json"
        bicep build $bicepFullPath --outfile "$sampleFolder\azuredeploy.json"
    }

    if($isBicepPrereqFileFound){
        # build prereq.main.bicep to prereq.azuredeploy.json
        Write-Output "Building: $sampleFolder\prereqs\$prereqTemplateFileName"
        bicep build $prereqBicepFullPath --outfile "$sampleFolder\prereqs\$prereqTemplateFileName"
    }
}