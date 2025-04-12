$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

function getNewestLink($match) {
    $uri = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $get = Invoke-RestMethod -uri $uri -Method Get
    $data = $get[0].assets | Where-Object name -Match $match
    return $data.browser_download_url
}

# Work around sysprep error: Package Microsoft.Winget.Source_<VERSION>_neutral__8wekyb3d8bbwe was installed for a user, but not provisioned for all users. This package will not function properly in the sysprep image.
# The package is installed by `Add-AppxPackage 'https://cdn.winget.microsoft.com/cache/source2.msix' in windows-install-winget.ps1
Write-Host "=== Removing Microsoft.Winget.Source for all users"
Get-AppxPackage -AllUsers Microsoft.Winget.Source* | Remove-AppPackage -ErrorAction Continue

# Work around sysprep error: Package Microsoft.DesktopAppInstaller_<VERSION>_x64__8wekyb3d8bbwe was installed for a user, but not provisioned for all users. This package will not function properly in the sysprep image.
$wingetUrl = getNewestLink("msixbundle")
$wingetLicenseUrl = getNewestLink("License1.xml")

Write-Host "=== Downloadng winget bundle from $wingetUrl and its license from $wingetLicenseUrl"
$wingetPath = "$env:TEMP/winget.msixbundle"
Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
$wingetLicensePath = "$env:TEMP/winget-license.xml"
Invoke-WebRequest -Uri $wingetLicenseUrl -OutFile $wingetLicensePath

Write-Host "=== Installing winget bundle from $wingetPath and license from $wingetLicensePath"
Add-AppxProvisionedPackage -Online -PackagePath $wingetPath -LicensePath $wingetLicensePath -ErrorAction Continue
