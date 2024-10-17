$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

$scriptsRepoUrl = 'https://github.com/dmgonch/azure-quickstart-templates'
$scriptsRepoBranch = "test-infra"
$scriptsRepoPath = "quickstarts\microsoft.devcenter\devbox-test-image\tools\artifacts"

$toolsRoot = "C:\.tools"
$expandedArchiveRoot = "$toolsRoot\tmp"
mkdir $expandedArchiveRoot -Force | Out-Null

Write-Host "=== Downloading artifacts from branch $scriptsRepoBranch of repo $scriptsRepoUrl"
$zip = "$toolsRoot\artifacts.zip"
$requestUri = "$scriptsRepoUrl/archive/refs/heads/$scriptsRepoBranch.zip"
Invoke-RestMethod -Uri $requestUri -Method Get -OutFile $zip

Write-Host "-- Extracting to $expandedArchiveRoot"
Expand-Archive -Path $zip -DestinationPath $expandedArchiveRoot

$expandedScriptsPath = "$((Get-ChildItem $expandedArchiveRoot)[0].FullName)\$scriptsRepoPath"
Write-Host "-- Moving $expandedScriptsPath to $toolsRoot"
Move-Item -Path $expandedScriptsPath -Destination $toolsRoot

Write-Host "-- Cleaning unneeded files"
Remove-Item -Path $expandedArchiveRoot -Recurse -Force

Write-Host "-- Content of $toolsRoot"
Get-ChildItem $toolsRoot -Recurse
Write-Host "=== Completed downloading artifacts from branch $scriptsRepoBranch of repo $scriptsRepoUrl"
