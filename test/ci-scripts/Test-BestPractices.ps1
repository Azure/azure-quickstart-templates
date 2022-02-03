<#

Verifies that the JSON template included in the sample is the same (via hash) as what we get when
we use bicep to compile the include bicep file.

Note: This script is only needed in the Azure pipeline, not intended for local use.

#>

param (
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $MainTemplateDeploymentFilename = $ENV:MAINTEMPLATE_DEPLOYMENT_FILENAME,
    [string] $ttkFolder = $ENV:TTK_FOLDER,
    [string[]] $Skip = $ENV:TTK_SKIP_TESTS 
)

Import-Module "$($ttkFolder)/arm-ttk/arm-ttk.psd1"

$templatePath = "$($SampleFolder)/$MainTemplateDeploymentFilename"
Write-Host "Calling Test-AzureTemplate on $templatePath"
$testOutput = @(Test-AzTemplate -TemplatePath $templatePath -Skip "$Skip")
$testOutput

if ($testOutput | ? { $_.Errors }) {
    exit 1 
}
else {
    Write-Host "##vso[task.setvariable variable=result.best.practice]$true"
    exit 0
} 
