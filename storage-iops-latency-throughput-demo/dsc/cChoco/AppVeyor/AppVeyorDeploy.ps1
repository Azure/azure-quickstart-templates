#---------------------------------# 
# Header                          # 
#---------------------------------# 
Write-Host 'Running AppVeyor deploy script' -ForegroundColor Yellow

#---------------------------------# 
# Update module manifest          # 
#---------------------------------# 
Write-Host 'Creating new module manifest'

$ModuleManifestPath = Join-Path -path "$pwd" -ChildPath ("$env:ModuleName"+'.psd1')
$ModuleManifest     = Get-Content $ModuleManifestPath -Raw

Write-Host "Updating module manifest to version: $env:APPVEYOR_BUILD_VERSION"
[regex]::replace($ModuleManifest,'(ModuleVersion = )(.*)',"`$1'$env:APPVEYOR_BUILD_VERSION'") | Out-File -LiteralPath $ModuleManifestPath

#---------------------------------# 
# Publish to PS Gallery           # 
#---------------------------------# 

if ( ($env:APPVEYOR_REPO_NAME -notmatch 'PowerShellOrg') -or ($env:APPVEYOR_REPO_BRANCH -notmatch 'master') )
{
    Write-Host "Finished testing of branch: $env:APPVEYOR_REPO_BRANCH - Exiting"
    exit;
}

Write-Host "Publishing module to Powershell Gallery: "
Publish-Module -Name $env:ModuleName -NuGetApiKey $env:nugetKey

Write-Host 'Done!' -ForegroundColor Green