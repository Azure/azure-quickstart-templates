
<#

    This script will checks to see if there are prereqs and set the flag to deploy them

#>

param(
    $sampleFolder = $ENV:SAMPLE_FOLDER,
    $prereqTemplateFilename = $ENV:PREREQ_TEMPLATE_FILENAME
)

# checks to see if there are prereqs that need to be deployed and sets the env variable to trigger prereq tasks
$deployPrereqs = Test-Path "$sampleFolder\prereqs\"
Write-Host "##vso[task.setvariable variable=deploy.prereqs]$deployPrereqs"

# if this is the bicep pipeline (determined by the env var filename) check for a bicep prereq, if not found use json
if (Test-Path "$sampleFolder\prereqs\$prereqTemplateFilename"){ 
    $prereqTemplateFullPath = "$sampleFolder\prereqs\$prereqTemplateFilename"
}else{
    $prereqTemplateFullPath = "$sampleFolder\prereqs\prereq.azuredeploy.json"
}

Write-Host "##vso[task.setvariable variable=prereq.template.fullpath]$prereqTemplateFullPath"
