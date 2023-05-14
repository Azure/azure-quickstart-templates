
<#

    This script will check to see if there are prereqs and set the flag to deploy them

#>

param(
    $sampleFolder = $ENV:SAMPLE_FOLDER,
    $prereqTemplateFilenameBicep = $ENV:PREREQ_TEMPLATE_FILENAME_BICEP,
    $prereqTemplateFilenameJson = $ENV:PREREQ_TEMPLATE_FILENAME_JSON
)

# checks to see if there are prereqs that need to be deployed and sets the env variable to trigger prereq tasks
$deployPrereqs = Test-Path "$sampleFolder\prereqs\"
Write-Host "##vso[task.setvariable variable=deploy.prereqs]$deployPrereqs"

# Check for a bicep prereq.
$bicepPrereqTemplateFullPath = "$sampleFolder\prereqs\$prereqTemplateFilenameBicep"
$jsonPrereqTemplateFullPath = "$sampleFolder\prereqs\$prereqTemplateFilenameJson"

Write-Host "Checking for bicep: $bicepPrereqTemplateFullPath"
Write-Host "Checking for JSON: $jsonPrereqTemplateFullPath"

# if there is a bicep file use it
if(Test-Path -Path $bicepPrereqTemplateFullPath){
    Write-Host "Using bicep..."
    $prereqTemplateFullPath = $bicepPrereqTemplateFullPath
}else{
    Write-Host "Using JSON..."
    $prereqTemplateFullPath = $jsonPrereqTemplateFullPath
}

Write-Output "Using prereq template: $prereqTemplateFullPath"
if ($deployPrereqs) {
    Write-Host "##vso[task.setvariable variable=prereq.template.fullpath]$prereqTemplateFullPath"
}
