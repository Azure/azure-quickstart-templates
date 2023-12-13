<#
This script will generate the resource group names for deployment and check for prereqs

If specified, the prereq and the sample resource group name will be the same - this is required by some samples, but should not be the default

#>

param(
    [string] $ResourceGroupNamePrefix = "azdo",
    [string] $sampleFolder
)

# check for .settings.json file 
$settingsFilePath = "$sampleFolder\prereqs\.settings.json"

if(Test-Path "$settingsFilePath"){
    Write-Host "Found settings file... $settingsFilePath"
    $settings = Get-Content -Path "$settingsFilePath" -Raw | ConvertFrom-Json
    Write-Host $settings
}

# check the prereq resource group name suffix property
if($settings.psobject.Members.Name -contains "PrereqResourceGroupNameSuffix"){
    $PrereqResourceGroupNameSuffix = $settings.PrereqResourceGroupNameSuffix
}
else{
    $PrereqResourceGroupNameSuffix = "-prereqs" # by default we will deploy to a separate resource group - it's a more thorough test on resourceIds
}

# Generate a resourceGroup Name
$resourceGroupName = "$ResourceGroupNamePrefix-$(New-Guid)"
Write-Host "##vso[task.setvariable variable=resourceGroup.name]$resourceGroupName"
Write-Host "##vso[task.setvariable variable=prereq.resourceGroup.name]$resourceGroupName$PrereqResourceGroupNameSuffix"
