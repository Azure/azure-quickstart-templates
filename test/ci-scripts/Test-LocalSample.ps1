<#

This script runs some validation on an Azure QuickStarts sample locally so that simple errors can be caught before
a PR is submitted.

Usage:

1) cd to the sample folder
2) ../test/Test-LocalSample.bat (Windows)
     or
   ../test/Test-LocalSample.sh (Mac/Linux)

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
$vars = Find-VarsFromWriteHostOutput $checkLanguageHostOutput
$bicepSupported = $vars["BICEP_SUPPORTED"] -eq 'true'
$bicepVersion = $vars["BICEP_VERSION"]
$mainTemplateFilenameJson = $vars["MAIN_TEMPLATE_FILENAME_JSON"]

# Validate-MetaData
Write-Host "Validating metadata.json"
$metadataHostOutput =
& $PSScriptRoot/Validate-MetaData.ps1 `
    -SampleFolder $SampleFolder `
    -CloudEnvironment $CloudEnvironment `
    -BuildReason "PullRequest" `
    6>&1
$vars = Find-VarsFromWriteHostOutput $metadataHostOutput
$supportedEnvironmentsJson = $vars["SUPPORTED_ENVIRONMENTS"]

# Validate-ReadMe
Write-Host "Validating README.md"
$validateReadMeHostOutput =
& $PSScriptRoot/Validate-ReadMe.ps1 `
    -SampleFolder $SampleFolder `
    -SampleName $SampleName `
    -StorageAccountName $StorageAccountName `
    -ReadMeFileName "README.md" `
    -supportedEnvironmentsJson $supportedEnvironmentsJson `
    -bicepSupported $bicepSupported
$vars = Find-VarsFromWriteHostOutput $validateReadMeHostOutput
$resultReadMe = $vars["RESULT_README"]

Write-host "Validation complete."

if ($error) {
    Write-Error "*** ERRORS HAVE BEEN FOUND. SEE DETAILS ABOVE ***"
} else {
    Write-Host "No errors found."
}