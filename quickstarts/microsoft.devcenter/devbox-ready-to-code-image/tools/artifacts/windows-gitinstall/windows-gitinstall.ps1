Param(
    $SetCredHelper = $false
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$VerbosePreference = 'Continue'

function getSimpleValue([string] $url, [string] $filename ) {
    $fullpath = "${env:Temp}\$filename"
    Invoke-WebRequest -Uri $url -OutFile $fullpath
    $value = Get-Content $fullpath -Raw

    return $value
}

# Install the latest version of Git for Windows
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$gitTag = getSimpleValue -url "https://gitforwindows.org/latest-tag.txt" -filename "gitlatesttag.txt"
$gitVersion = getSimpleValue -url "https://gitforwindows.org/latest-version.txt" -filename "gitlatestversion.txt";

$installerFile = "Git-$gitVersion-64-bit.exe";

$uri = "https://github.com/git-for-windows/git/releases/download/$gitTag/$installerFile"
$Installer = "$env:Temp\GitInstaller.exe"
$ProgressPreference = 'SilentlyContinue'
try {
    Invoke-RestMethod -Uri $uri -OutFile $Installer -UseBasicParsing

    # Regarding setting the Components:
    # Download installer from https://git-scm.com/downloads 
    # Run it manually using Git-<version>-64-bit.exe /SAVEINF="C:\.tools\gitinstall.ini"
    # Select needed components in the UI and complete the install.
    # Use value of 'Components' in generated gitinstall.ini.
    # Reference https://jrsoftware.org/ishelp/index.php?topic=setupcmdline

    $arguments = @('/silent', '/norestart', '/Components=ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh,scalar')

    Write-Host "Installing $installerFile"
    Start-Process -FilePath $Installer -ArgumentList $arguments -Wait -Verbose
    Write-Host "Done Installing $installerFile"

    if ($SetCredHelper -eq $true) {
        Write-Host "Setting system git config credential.helper to manager"
        $basePath = "C:\Program Files\Git"
        $binPath = Join-Path $basePath "bin\git.exe"
        $cmdPath = Join-Path $basePath "cmd\git.exe"
        if (Test-Path $binPath) {
            $gitPath = $binPath
        }
        else {
            $gitPath = $cmdPath
        }
        if (-not (Test-Path $gitPath)) {
            throw "Unable to find git.exe"
        }
        $arguments = @('config', '--system', 'credential.helper', 'manager')
        Write-Host "Running $gitPath $($arguments -join ' ')"
        & $gitPath $arguments
        Write-host "Result: $LastExitCode"
        Write-Host "Git system config settings:"
        & $gitPath @('config', '--system', '--list')
        Write-Host "Done updating git config"
    }
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}