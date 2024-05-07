<#

Verifies that the JSON template included in the sample is the same (via hash) as what we get when
we use bicep to compile the include bicep file.

Note: This script is only needed in the Azure pipeline, not intended for local use.

#>

param (
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $MainTemplateDeploymentFilename = $ENV:MAINTEMPLATE_DEPLOYMENT_FILENAME,
    [string] $ttkFolder = $ENV:TTK_FOLDER,
    [string[]] $Skip = $ENV:TTK_SKIP_TESTS,
    [switch] $bicepSupported = ($ENV:BICEP_SUPPORTED -eq "true")
)

Import-Module "$($ttkFolder)/arm-ttk/arm-ttk.psd1"

# build bicep
if($bicepSupported){
    bicep build "$($SampleFolder)/$MainTemplateDeploymentFilename" --outfile "$($SampleFolder)/azuredeploy.json"
}

Write-Host "Calling Test-AzureTemplate on $SampleFolder"
$testOutput = @(Test-AzTemplate -TemplatePath $SampleFolder -Skip "$Skip")
$testOutput

if ($testOutput | ? { $_.Errors }) {
    exit 1 
}
else {
    Write-Host "##vso[task.setvariable variable=result.best.practice]$true"
    exit 0
} 

# clean up the json
if($bicepSupported){
    Remove-Item "$($SampleFolder)/azuredeploy.json"
}
