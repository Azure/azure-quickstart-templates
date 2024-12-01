param (
    [bool] $InstallInsiders = $false
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Install-VSCode {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if ($InstallInsiders) {
        $VSCodeURL = 'https://update.code.visualstudio.com/latest/win32-x64/insider'
    }
    else {
        $VSCodeURL = 'https://update.code.visualstudio.com/latest/win32-x64/stable'
    }

    Write-Host "Downloading from $VSCodeURL"
    $VScodeInstaller = Join-Path $env:TEMP 'VSCodeSetup-x64.exe'
    Invoke-WebRequest -Uri $VSCodeURL -UseBasicParsing -OutFile $VScodeInstaller

    Write-Host "Installing VS Code"
    $arguments = @('/VERYSILENT', '/NORESTART', '/MERGETASKS=!runcode')
    $installerExitCode = (Start-Process -FilePath $VScodeInstaller -ArgumentList $arguments -Wait -Verbose -Passthru).ExitCode
    if ($installerExitCode -ne 0) {
        throw "Failed with exit code $installerExitCode"
    }

    $shortCutPath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk'
    if (Test-Path $shortCutPath) {
        Copy-Item -Path $shortCutPath -Destination C:\Users\Public\Desktop
    }
}
try {
    Install-VSCode
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}