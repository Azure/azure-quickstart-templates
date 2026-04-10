<#
.SYNOPSIS
    Installs the Sysinternals Suite
.DESCRIPTION
    Downloads and installs the Sysinternals Suite
    If the AddShortcuts parameter is set to true, it will also add shortcuts to the desktop for Procmon and Procexp
#>

param(
    [Parameter(Mandatory = $false)]
    [bool] $AddShortcuts = $false,
    [Parameter()]
    [string] $SoftwareDir = "C:\.tools"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$SysinternalsSuiteUrl = "https://download.sysinternals.com/files/SysinternalsSuite.zip";

filter timestamp {"$(Get-Date ([datetime]::UtcNow) -Format G) UTC: $_"}

if (!(Test-Path -Path $SoftwareDir)) {
    Write-Output "Path $SoftwareDir doesn't exist. Creating new path" | timestamp
    New-Item -Path $SoftwareDir -Type Directory
}

try{
    Write-Output "start download of Sysinternal tool suite" | timestamp
    $fileName="SysinternalsSuite.zip"
    $SysInternal =  [System.IO.Path]::Combine($SoftwareDir, $fileName)
    Invoke-WebRequest -Uri $SysinternalsSuiteUrl -UseBasicParsing -OutFile $SysInternal
    Write-Output "Download of Sysinternal tool suite done." | timestamp

    $DestinationDirectory = Join-Path -Path $SoftwareDir -ChildPath "SysinternalsSuite"
    if(!(Test-Path -Path $DestinationDirectory)){
        New-Item -Path $DestinationDirectory -Type Directory
    }
    $Zip = Join-Path -Path $SoftwareDir -ChildPath $fileName
    Write-Output "Extracting $fileName to $DestinationDirectory" | timestamp
    Expand-Archive -Path $Zip -DestinationPath $DestinationDirectory -Force
    Write-Output "Extraction of $fileName to $DestinationDirectory done" | timestamp

    Write-Output "Deleting $fileName from $SoftwareDir" | timestamp
    rm $Zip

    # Add desktop shortcut for Procmon and Procexp if requested
    if ($AddShortcuts) {
        $invokecommandScriptPath = (Join-Path $(Split-Path -Parent $PSScriptRoot) 'windows-create-shortcut/windows-create-shortcut.ps1')
        # Add shortcut on the desktop for Procmon64 and set run as admin.
        & $invokecommandScriptPath  -ShortcutName "Procmon64" -ShortcutTargetPath "$DestinationDirectory\Procmon64.exe" -EnableRunAsAdmin 'true'
        # Add shortcut on the desktop for Procexp64  and set run as admin.
        & $invokecommandScriptPath  -ShortcutName "Procexp64" -ShortcutTargetPath "$DestinationDirectory\procexp64.exe" -EnableRunAsAdmin 'true'
    }
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}