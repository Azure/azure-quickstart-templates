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

Write-Host "Using bicep at: $bicepPath"
Write-Host "##vso[task.setvariable variable=bicep.path]$bicepPath"

# Display and save bicep version
& $bicepPath --version | Tee-Object -variable fullVersionString
$fullVersionString | select-string -Pattern "(?<version>[0-9]+\.[-0-9a-z.]+)" | ForEach-Object { $_.matches.groups[1].value } | Tee-Object -variable bicepVersion

Write-Host "Using bicep version: $bicepVersion"
Write-Host "##vso[task.setvariable variable=bicep.version]$bicepVersion"
