<#
.SYNOPSIS
    Create a shortcut to a dev repo. 
.DESCRIPTION
    Add enlistment shortcut to the desktop.
.PARAMETER RepoRoot
    Full path to the repo's root directory.
.PARAMETER RepoKind
    Allowed values are MSBuild, Custom or Data.
.PARAMETER DesktopShortcutScriptPath
    Optional relative batch script path used to create shortcut (no arguments). By default Visual Studio's VsDevCmd.bat is used for MSBuild repos.
.PARAMETER ShortcutRunAsAdmin
    Should the shortcut run as Admin (requests elevation when opened). Default is true
.PARAMETER DesktopShortcutName
    Optional name of the shortcut. By default the name is the repo name.
.PARAMETER DesktopShortcutIconPath
    Optional relative path or full path to the icon file to be used for the shortcut. By default the icon is not set.
.PARAMETER DesktopShortcutHost
    Optional launches shortcut in Windows ConsoleHost or Windows Terminal. Default is Windows Console.

.EXAMPLE
    Sample Bicep snippets for using the artifact:
    {
      name: 'windows-create-devenv-shortcut'
      parameters: {
        RepoRoot: repoRootDir
        RepoKind: 'MSBuild'
      }
    }
    {
      name: 'windows-create-devenv-shortcut'
      parameters: {
        RepoRoot: repoRootDir
        RepoKind: 'Custom'
        DesktopShortcutName: 'DevBuildEnv'
        DesktopShortcutScriptPath: 'tools\\devBuildEnv.cmd'
        DesktopShortcutIconPath: 'tools\\devBuildEnv.ico'
        DesktopShortcutHost: 'Terminal'
      }
    }
#>

param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $RepoRoot,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $RepoKind,
    [Parameter(Mandatory = $false)][String] $DesktopShortcutScriptPath,
    [Parameter(Mandatory = $false)][bool] $ShortcutRunAsAdmin = $false,
    [Parameter(Mandatory = $false)][String] $DesktopShortcutIconPath,
    [Parameter(Mandatory = $false)][String] $DesktopShortcutName,
    [Parameter(Mandatory = $false)][String] $DesktopShortcutHost = "Console"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Wrap the actual script to create the shortcut in a function so that it can be mocked in tests
function New-Shortcut($invokecommandScriptPath, $shortcutName, $shortcutTargetPath, $shortcutArguments, $shortcutIcon, $shortcutRunAsAdmin) {
    & $invokecommandScriptPath -ShortcutName $shortcutName -ShortcutTargetPath $shortcutTargetPath -ShortcutArguments $shortcutArguments -ShortcutIcon $shortcutIcon -EnableRunAsAdmin $shortcutRunAsAdmin
}

function RunScriptCreatehortcut($RepoRoot, $RepoKind, $DesktopShortcutScriptPath, $ShortcutRunAsAdmin, $DesktopShortcutIconPath, $DesktopShortcutName, $DesktopShortcutHost) {
    # Check RepoKind
    if ([string]::IsNullOrEmpty($DesktopShortcutScriptPath)) {
        if ($RepoKind -eq 'MSBuild') {
            Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-msbuild-utils.psm1')
            $DesktopShortcutScriptPath = $(Get-LatestVisualStudioDeveloperEnvironmentScriptPath)
        }
        elseif ($RepoKind -eq 'Custom') {
            Write-Host "No value provided for DesktopShortcutScriptPath" 
        }
        elseif ($RepoKind -eq 'Data') {
            Write-Host "No value provided for DesktopShortcutScriptPath"
        }
        else {
            throw "Unknown repo kind $RepoKind"
        }
    }
    else {
        if (!(($RepoKind -eq 'MSBuild') -or ($RepoKind -eq 'Custom') -or ($RepoKind -eq 'Data'))) {
            throw "Unknown repo kind $RepoKind"
        }
    }

    if (![string]::IsNullOrEmpty($DesktopShortcutScriptPath)) {     
        # If the path is relative then calculate the full path
        if (!([System.IO.Path]::IsPathRooted($DesktopShortcutScriptPath))) {
            $DesktopShortcutScriptPath = "$RepoRoot\$DesktopShortcutScriptPath"
        }
    }
    
    Write-Host "Getting ready to create shortcut for $RepoKind repo $RepoRoot with script path $DesktopShortcutScriptPath run as admin $ShortcutRunAsAdmin"

    $ShortcutIcon = '';

    # Calculate the full path if the icon path is relative
    if ($DesktopShortcutIconPath -and ([System.IO.Path]::IsPathRooted($DesktopShortcutIconPath) -eq $false)) {
        $ShortcutIcon = Join-Path -Path $RepoRoot -ChildPath $DesktopShortcutIconPath
    }
    else {
        $ShortcutIcon = $DesktopShortcutIconPath
    }

    [String] $ShortcutName = '';

    if ($DesktopShortcutName) {
        $ShortcutName = $DesktopShortcutName
    }
    else {
        $ShortcutName = $RepoRoot.Split("\") | Where-Object { $_ -ne '' } | Select-Object -Last 1;
    }

    [String] $shortcutTargetPath = '';
    [String] $shortcutArguments = '';

    # Check script file extension
    $isTerminalHost = ![string]::IsNullOrEmpty($DesktopShortcutHost) -and ($DesktopShortcutHost -eq "Terminal" )
    if ([string]::IsNullOrEmpty($DesktopShortcutScriptPath)) {
        $shortcutTargetPath = $env:ComSpec
        $shortcutArguments = "/k cd /d $RepoRoot"
    }
    elseif (($DesktopShortcutScriptPath -Like "*.cmd") -or ($DesktopShortcutScriptPath -Like "*.bat")) {
        $shortcutTargetPath = $env:ComSpec
        if (!$isTerminalHost) {
            $shortcutArguments = "/k cd /d $RepoRoot&""$DesktopShortcutScriptPath"""
        }
        else {
            # Weird but seems like the only combination of quotes that works whether the path has spaces or not
            $shortcutArguments = "/k ""cd /d $RepoRoot&""$DesktopShortcutScriptPath"""""""
        }
    }
    elseif ($DesktopShortcutScriptPath -Like "*.ps1") {
        $shortcutTargetPath = "powershell.exe"
        $shortcutArguments = "-NoExit -File ""$DesktopShortcutScriptPath"""
    }
    else {
        throw "Unknown enviroment to create desktop shortcut with given script path: $DesktopShortcutScriptPath"
    }
    if ($isTerminalHost) {
        $shortcutArguments = $shortcutTargetPath + " " + $shortcutArguments
        $shortcutTargetPath = "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe"
    }

    Write-Host "Creating shortcut with Target path: $shortcutTargetPath and Arguments: $shortcutArguments " 
    
    $invokecommandScriptPath = (Join-Path $(Split-Path -Parent $PSScriptRoot) 'windows-create-shortcut/windows-create-shortcut.ps1')
    New-Shortcut $invokecommandScriptPath $ShortcutName $ShortcutTargetPath $shortcutArguments $ShortcutIcon $ShortcutRunAsAdmin

    Write-Host "Sucessfully created shortcut with $invokecommandScriptPath"
}

if ((-not (Test-Path variable:global:IsUnderTest)) -or (-not $global:IsUnderTest)) {
    try {
        RunScriptCreatehortcut -RepoRoot $RepoRoot `
            -RepoKind $RepoKind `
            -DesktopShortcutScriptPath $DesktopShortcutScriptPath `
            -ShortcutRunAsAdmin $ShortcutRunAsAdmin `
            -DesktopShortcutIconPath $DesktopShortcutIconPath `
            -DesktopShortcutName $DesktopShortcutName `
            -DesktopShortcutHost $DesktopShortcutHost
    }
    catch {
        Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
    }
}