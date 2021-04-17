<#

This script runs some validation on an Azure QuickStarts sample locally so that simple errors can be caught before
a PR is submitted.

Usage:

1) cd to the sample folder
2) ../test/test-localsample.bat (Windows)
     or
   ../test/test-localsample.sh (Mac/Linux)

#>

param(
    [string] $SampleFolder = ".", # this is the path to the sample
    [string] $StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME ? $ENV:STORAGE_ACCOUNT_NAME : "azurequickstartsservice",
    [string] $CloudEnvironment = "AzureCloud" # AzureCloud/AzureUSGovernment
)

$ErrorActionPreference = "Continue"
$Error.Clear()

$SampleFolder = Resolve-Path $SampleFolder
$SampleName = Split-Path -Leaf $SampleFolder

if (!(Test-Path "metadata.json")) {
    Write-Error "Test-LocalSample must be run from within a sample folder. This folder contains no metadata.json file."
    return
}

Write-Host "Running local validation on sample $SampleName in folder $SampleFolder"

Import-Module "$PSScriptRoot/Local.psm1" -force

# Check-LanguageSupport
Write-Host "Checking bicep support in the sample"
$checkLanguageHostOutput = & $PSScriptRoot/Check-LanguageSupport.ps1 `
    -SampleFolder $SampleFolder `
    -MainTemplateFilenameBicep "main.bicep" `
    6>&1
Write-Output $checkLanguageHostOutput
$vars = Find-VarsFromWriteHostOutput $checkLanguageHostOutput
$bicepSupported = $vars["BICEP_SUPPORTED"] -eq 'true'
$bicepVersion = $vars["BICEP_VERSION"]
$mainTemplateFilenameJson = $vars["MAINTEMPLATE_FILENAME_JSON"]
Assert-NotEmptyOrNull $mainTemplateFilenameJson "mainTemplateFilenameJson"

# Build-DeploymentFile.ps1
Write-host "Building deployment file if needed"
#TODO: bicepVersion?
$buildHostOutput = & $PSScriptRoot/Build-DeploymentFile.ps1 `
    -SampleFolder $SampleFolder `
    -MainTemplateFilenameBicep "main.bicep" `
    -MainTemplateFilenameJson $mainTemplateFilenameJson `
    -BuildReason "PullRequest" `
    -BicepPath "bicep" `
    -BicepVersion "(current)" `
    -BicepSupported:$bicepSupported `
    6>&1
Write-Output $buildHostOutput
$vars = Find-VarsFromWriteHostOutput $buildHostOutput
$mainTemplateDeploymentFilename = $vars["MAINTEMPLATE_DEPLOYMENT_FILENAME"]
Assert-NotEmptyOrNull $mainTemplateDeploymentFilename "mainTemplateDeploymentFilename"
$CompiledJsonFilename = $vars["COMPILED_JSON_FILENAME"]

# Validate-MetaData
Write-Host "Validating metadata.json"
$metadataHostOutput =
& $PSScriptRoot/Validate-MetaData.ps1 `
    -SampleFolder $SampleFolder `
    -CloudEnvironment $CloudEnvironment `
    -BuildReason "PullRequest" `
    6>&1
Write-Output $metadataHostOutput
$vars = Find-VarsFromWriteHostOutput $metadataHostOutput
$supportedEnvironmentsJson = $vars["SUPPORTED_ENVIRONMENTS"]
Assert-NotEmptyOrNull $supportedEnvironmentsJson "supportedEnvironmentsJson"

# Validate-ReadMe
Write-Host "Validating README.md"
$validateReadMeHostOutput =
& $PSScriptRoot/Validate-ReadMe.ps1 `
    -SampleFolder $SampleFolder `
    -SampleName $SampleName `
    -StorageAccountName $StorageAccountName `
    -ReadMeFileName "README.md" `
    -supportedEnvironmentsJson $supportedEnvironmentsJson `
    -bicepSupported:$bicepSupported `
    6>&1
Write-Output $validateReadMeHostOutput
$vars = Find-VarsFromWriteHostOutput $validateReadMeHostOutput
$resultReadMe = $vars["RESULT_README"] # will be null if fails

# TODO: Test-BestPractices.ps1

# Clean up
if (Test-Path $CompiledJsonFilename) {
    Remove-Item $CompiledJsonFilename
}

Write-host "Validation complete."

if ($error) {
    Write-Error "*** ERRORS HAVE BEEN FOUND. SEE DETAILS ABOVE ***"
} else {
    Write-Host "No errors found."
}