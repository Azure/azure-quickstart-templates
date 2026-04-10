[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $false)]
    [string] $dotnetSdkVersion,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $false)]
    [string] $globalJsonPath,

    [Parameter(Mandatory = $false)]
    [string] $installLocation,

    [Parameter(Mandatory = $false)]
    [string] $architecture,

    [Parameter(Mandatory = $false)]
    [string] $runtime
)

$logfilepath = $null
Function ProcessRunner([string]$command, $arguments) {
    <#
  .SYNOPSIS
  Run a process
  .DESCRIPTION
  Run a process and validate that the process started and completed without any errors  
  .PARAMETER command
  The command that will be run
  .PARAMETER arguments
  The arguments required to run the supplied command
  #>

    $errLog = [System.IO.Path]::GetTempFileName()
    $process = Start-Process -FilePath $command -ArgumentList $arguments -RedirectStandardError $errLog -PassThru -Wait
    # If $process variable is null, something is wrong
    if (!$process) {			
        Write-Error "ERROR command failed to start: $command $arguments"
        return;
    }
 
    $process.WaitForExit()
    
    if ($process.ExitCode -ne 0) {
        Write-Output "Error running: $command $arguments"
        Write-Output "Exit code: $($process.ExitCode)"
        Write-Output "**ERROR**"
        Get-Content -Path $errLog
        throw "Exit code from process was nonzero"
    }
}

$Arch = $null
$dotnet_sdk_version = $null
$InstallDir = $null

try {
    if ($false -eq [System.String]::IsNullOrWhiteSpace($architecture)) { 
        $Arch = $architecture 
    }
    else {
        $Arch = "<auto>"
    }

    if ($false -eq [System.String]::IsNullOrWhiteSpace($installLocation)) { 
        $InstallDir = $installLocation 
    }
    else {
        $InstallDir = "c:\program files\dotnet"
    }

    if ($false -eq [System.String]::IsNullOrWhiteSpace($dotnetSdkVersion)) {
        $dotnet_sdk_version = $dotnetSdkVersion
    }
    elseif ($false -eq [System.String]::IsNullOrWhiteSpace($globalJsonPath)) {
        Write-Host "Attempting to read global.json"
        $globalJsonFullPath = ""
    
        if ($globalJsonPath.EndsWith("global.json")) {
            $globalJsonFullPath = $globalJsonPath
        }
        else {
            $globalJsonFullPath = [System.IO.Path]::Combine($globalJsonPath, "global.json")
        }

        if ($true -eq [System.IO.File]::Exists($globalJsonFullPath)) {
            Write-Host "Reading from global.json"
            Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-json-utils.psm1')
            $dotnet_sdk_version = (Get-JsonFromFile $globalJsonFullPath).sdk.version
            Write-Host "Found version $dotnet_sdk_version"
        }
        else {
            Write-Host "global.json not found, setting version to latest"
            $dotnet_sdk_version = "Latest"
            
        }
    }
    $ErrorActionPreference = 'Stop'
 
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')

    # download the dotnet sdk script and run it
    Write-Host Downloading dotnet-install script
    $scriptLocation = [System.IO.Path]::Combine($env:TEMP, 'dotnet-install.ps1')
    ProcessRunner -command curl -arguments "-SsL https://dot.net/v1/dotnet-install.ps1 -o $scriptLocation"
 
    RunWithRetries -retryAttempts 10 -waitBeforeRetrySeconds 2 -exponentialBackoff -runBlock {
        & "$scriptLocation" -Version $dotnet_sdk_version -InstallDir $InstallDir -Architecture $Arch -Runtime $runtime
    }

    & ([System.IO.Path]::Combine($InstallDir, "dotnet.exe")) --list-sdks
    & ([System.IO.Path]::Combine($InstallDir, "dotnet.exe")) --list-runtimes
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}