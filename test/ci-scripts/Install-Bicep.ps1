#Requires -Version 3.0

<#

Installs the bicep CLI

#>

param(
    $ttkFolder = $ENV:TTK_FOLDER,
    $bicepUri = $ENV:BICEP_URI
)

# See https://github.com/Azure/bicep/blob/main/docs/installing.md#windows-installer

# Create the install folder
$installPath = "$ttkFolder\bicep"
$bicepFolder = New-Item -ItemType Directory -Path $installPath -Force
$bicepPath = "$bicepFolder\bicep.exe"
Write-Host "$bicepPath"
(New-Object Net.WebClient).DownloadFile($bicepUri, $bicepPath)
if (!(Test-Path $bicepPath)) {
    Write-Error "Couldn't find downloaded file $bicepPath"
}

# add bicep to the path (for deployment scripts)
# $ENV:PATH = "$(Split-Path $bicepPath);$($ENV:PATH)"
# need to set the path for the machine otherwise each task will reset the path - careful about running this locally
#[Environment]::SetEnvironmentVariable("PATH", "$(Split-Path $bicepPath);$($ENV:PATH)", [EnvironmentVariableTarget]::Machine) #doesn't work

$p = $(Split-Path $bicepPath)
Write-Host "adding: $p"
Write-Host "##vso[task.prependpath]$p" # this doesn't seem to work - see: https://github.com/microsoft/azure-pipelines-tasks/blob/master/docs/authoring/commands.md

$ENV:PATH = "$p;$($ENV:PATH)" # since the prependpath task isn't working explicitly set it here and will have to for each subsequent task since it doesn't carry across processes

Write-Host $ENV:PATH
$bicepPath = $(Get-command bicep.exe).source # rewrite the var to make sure we have the correct bicep.exe

Write-Host "Using bicep at: $bicepPath"
Write-Host "##vso[task.setvariable variable=bicep.path]$bicepPath"

# Display and save bicep version
& bicep --version | Tee-Object -variable fullVersionString
$fullVersionString | select-string -Pattern "(?<version>[0-9]+\.[-0-9a-z.]+)" | ForEach-Object { $_.matches.groups[1].value } | Tee-Object -variable bicepVersion

Write-Host "Using bicep version: $bicepVersion"
Write-Host "##vso[task.setvariable variable=bicep.version]$bicepVersion"
