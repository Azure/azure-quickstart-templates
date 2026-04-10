<#
.DESCRIPTION
    Utilities for locating and dealing with MSBuild tools (Visual Studio is expected to be alraedy installed).
#>

# Needed for installing modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Install VSSetup Module
Install-Module VSSetup -Scope CurrentUser -Force

# Use the latest MSBuild that comes from VS
function Get-LatestVisualStudioInstallationInfo
{
    $latestVsInstallationInfo = Get-VSSetupInstance -All -Prerelease | Sort-Object -Property InstallationVersion -Descending | Select-Object -First 1
    
    Write-Host "Latest version installed is $($latestVsInstallationInfo.InstallationVersion)"

    return $latestVsInstallationInfo
}

function Get-LatestMsbuildLocation
{
    $latestVsInstallationInfo = Get-LatestVisualStudioInstallationInfo

    if ($latestVsInstallationInfo.InstallationVersion -like "15.*")
    {
        $msbuildLocation = "$($latestVsInstallationInfo.InstallationPath)\MSBuild\15.0\Bin\msbuild.exe"
    
        Write-Host "Located msbuild for Visual Studio 2017 in $msbuildLocation"
    }
    else
    {
        $msbuildLocation = Join-Path $latestVsInstallationInfo.InstallationPath "MSBuild\Current\Bin\msbuild.exe"
        if ($useAmd64IfAvailable)
        {
            $msbuildAmd64Location = Join-Path $latestVsInstallationInfo.InstallationPath "MSBuild\Current\Bin\amd64\msbuild.exe"
            if (Test-Path $msbuildAmd64Location)
            {
                $msbuildLocation = $msbuildAmd64Location
            }
        }
        Write-Host "Located msbuild in $msbuildLocation"
    }

    return $msbuildLocation
}

function Get-LatestVisualStudioDeveloperEnvironmentScriptPath
{
    $latestVsInstallationInfo = Get-LatestVisualStudioInstallationInfo
    return (Join-Path $latestVsInstallationInfo.InstallationPath "Common7\Tools\VsDevCmd.bat")
}
