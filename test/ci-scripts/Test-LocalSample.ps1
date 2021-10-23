<#

This script runs some validation on an Azure QuickStarts sample locally so that simple errors can be caught before
a PR is submitted.

Prerequesites:

1) Install bicep
    - Make sure it's on the path, or set environment variable BICEP_PATH to point to the executable
2) Install the Azure TTK (https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit)
    - Set environment variable TTK_FOLDER to the installation folder location

Usage:

1) cd to the sample folder
2) ../test/test-localsample.bat (Windows)
     or
   ../test/test-localsample.sh (Mac/Linux)

#>

param(
    [string][Parameter(Mandatory = $true)][AllowEmptyString()] $SampleFolder, # this is the path to the sample
    [string] $StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME ? $ENV:STORAGE_ACCOUNT_NAME : "azurequickstartsservice",
    [string] $CloudEnvironment = "AzureCloud", # AzureCloud/AzureUSGovernment
    [string] $TtkFolder = $ENV:TTK_FOLDER,
    [string] $BicepPath = $ENV:BICEP_PATH ? $ENV:BICEP_PATH : "bicep",
    [switch] $Fix # If true, fixes will be made if possible
)

$SampleFolder = $SampleFolder -eq "" ? "." : $SampleFolder

$PreviousErrorPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$Error.Clear()

Import-Module "$PSScriptRoot/Local.psm1" -force

$ResolvedSampleFolder = Resolve-Path $SampleFolder
if (!$ResolvedSampleFolder) {
    throw "Could not resolve folder $SampleFolder"
}
$SampleFolder = $ResolvedSampleFolder

$SampleName = SampleNameFromFolderPath $SampleFolder

if (!(Test-Path (Join-Path $SampleFolder "metadata.json"))) {
    $ErrorActionPreference = $PreviousErrorPreference
    Write-Error "Test-LocalSample must be run from within a sample folder. This folder contains no metadata.json file."
    return
}

Write-Host "Running local validation on sample $SampleName in folder $SampleFolder"

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

# Validate-DeploymentFile.ps1
Write-host "Validating deployment file"
#TODO: bicepVersion?
$buildHostOutput = & $PSScriptRoot/Validate-DeploymentFile.ps1 `
    -SampleFolder $SampleFolder `
    -MainTemplateFilenameBicep "main.bicep" `
    -MainTemplateFilenameJson $mainTemplateFilenameJson `
    -BuildReason "PullRequest" `
    -BicepPath $BicepPath `
    -BicepVersion "(current)" `
    -BicepSupported:$bicepSupported `
    6>&1
Write-Output $buildHostOutput
$vars = Find-VarsFromWriteHostOutput $buildHostOutput
$mainTemplateDeploymentFilename = $vars["MAINTEMPLATE_DEPLOYMENT_FILENAME"]
Assert-NotEmptyOrNull $mainTemplateDeploymentFilename "mainTemplateDeploymentFilename"
$CompiledJsonFilename = $vars["COMPILED_JSON_FILENAME"] # $null if not bicep sample
$labelBicepWarnings = $vars["LABEL_BICEP_WARNINGS"] -eq "TRUE"

# Validate-Metadata
Write-Host "Validating metadata.json"
$metadataHostOutput =
& $PSScriptRoot/Validate-Metadata.ps1 `
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
    -Fix:$Fix `
    6>&1
Write-Output $validateReadMeHostOutput
$vars = Find-VarsFromWriteHostOutput $validateReadMeHostOutput
$resultReadMe = $vars["RESULT_README"] # will be null if fails
$fixedReadme = $vars["FIXED_README"] -eq "TRUE"

# Test-BestPractices
if (!$TtkFolder) {
    # Check if the TTK is in a local repo as a sibling to this repo
    $TtkFolder = "$PSScriptRoot/../../../arm-ttk"
    if (test-path $TtkFolder) {
        $TtkFolder = Resolve-Path $TtkFolder
    }
    else {
        $ErrorActionPreference = $PreviousErrorPreference
        Write-Error "Could not find the ARM TTK. Please install from https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit and set environment variable TTK_FOLDER to the installation folder location."
        Return
    }
}
Write-Host "Validating JSON best practices (using ARM TTK)"
$validateBPOutput =
& $PSScriptRoot/Test-BestPractices.ps1 `
    -SampleFolder $SampleFolder `
    -MainTemplateDeploymentFilename $mainTemplateDeploymentFilename `
    -ttkFolder $TtkFolder `
    6>&1
Write-Output $validateBPOutput
$vars = Find-VarsFromWriteHostOutput $validateBPOutput

# Check misc labels
Write-Host "Checking for miscellaneous labels"
$miscLabelsHostOutput =
& $PSScriptRoot/Check-MiscLabels.ps1 `
    -SampleName $SampleName `
    6>&1
Write-Output $miscLabelsHostOutput
$vars = Find-VarsFromWriteHostOutput $miscLabelsHostOutput
$isRootSample = $vars["ISROOTSAMPLE"] -eq "true"
$sampleHasUpperCase = $vars["SampleHasUpperCase"] -eq "true"
$isPortalSample = $vars["IsPortalSample"] -eq "true"

# Clean up
if ($null -ne $CompiledJsonFilename -and (Test-Path $CompiledJsonFilename)) {
    Remove-Item $CompiledJsonFilename
}

Write-host "Validation complete."

$fixesMade = $fixedReadme
if ($fixedReadme) {
    Write-Warning "A fix has been made in the README. See details above."
}

if ($error) {
    $ErrorActionPreference = $PreviousErrorPreference
    Write-Error "*** ERRORS HAVE BEEN FOUND. SEE DETAILS ABOVE ***"
}
else {
    if (!$fixesMade) {
        Write-Host "No errors found."
    }
}

if ($labelBicepWarnings) {
    Write-Warning "LABEL: bicep warnings"
}
if ($isRootSample) {
    Write-Warning "LABEL: ROOT"
}
if ($sampleHasUpperCase) {
    Write-Warning "LABEL: UPPERCASE"
}
if ($isPortalSample) {
    Write-Warning "LABEL: PORTAL SAMPLE"
}
