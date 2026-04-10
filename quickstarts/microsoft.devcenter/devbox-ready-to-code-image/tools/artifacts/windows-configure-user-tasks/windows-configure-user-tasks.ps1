<#
.DESCRIPTION
    Configures a set of tasks that will run when a user logs into a VM.
#>

param(
    [Parameter(Mandatory = $false)][string] $FirstLogonTasksBase64
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function GetTaskID {
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSObject] $taskObj
    )

    # By default use task's name as its ID which means that only a single (last) instance of such task will be executed on when user logs on
    $taskId = $taskObj.Task

    if ($taskObj.PSobject.Properties.Name -contains 'UniqueID') {
        $taskId = $taskObj.UniqueID
    }

    return $taskId
}

try {
    $setupDir = "c:\.tools\Setup"
    $setupScriptsDir = "$setupDir\Scripts"
    $logsDir = "$setupDir\Logs"

    if (Test-Path -Path $setupScriptsDir) {
        Write-Host "=== To avoid scripts versioning issues remove $setupScriptsDir in case it was created by the base image build"
        Remove-Item $setupScriptsDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "=== Create $setupScriptsDir before copying scripts there"
    mkdir $setupScriptsDir -Force
    mkdir $logsDir -Force

    Write-Host "=== Copy setup scripts to $setupScriptsDir"
    @(
    (Join-Path $PSScriptRoot 'customization-utils.psm1')
    (Join-Path $PSScriptRoot 'setup-user-tasks.ps1')
    (Join-Path $PSScriptRoot 'run-firstlogon-tasks.ps1')
    (Join-Path $PSScriptRoot 'runonce-user-tasks.ps1')
    (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')
    (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-run-program.psm1')
    ) | ForEach-Object { Copy-Item $_ $setupScriptsDir -Force }
    Copy-Item "$PSScriptRoot\FirstLogonTasks" "$setupScriptsDir\FirstLogonTasks" -Recurse -Force -Exclude '*.Tests.ps1'
    Get-ChildItem -Recurse -File -Path $setupScriptsDir | Select-Object -First 100

    # Hook the event invoked when Azure VM starts for the first time
    # - https://matt.kotsenas.com/posts/azure-setupcomplete2
    # - https://learn.microsoft.com/en-us/dynamics-nav/setupcomplete2.cmd-file-example
    # - https://learn.microsoft.com/en-us/previous-versions/dynamicsnav-2018-developer/How-to--Create-a-Microsoft-Azure-Virtual-Machine-Operating-System-Image-for-Microsoft-Dynamics-NAV
    Write-Host "=== Configure Azure VM first startup event"
    $vmStartupScriptsDir = 'C:\Windows\OEM'
    $vmStartupScript = "$vmStartupScriptsDir\SetupComplete2.cmd"
    $vmOrigStartupScript = "$vmStartupScriptsDir\SetupComplete2FromOrigBaseImage.cmd"

    # If the base image for this VM was not created by Dev Box image templates then preserve the original SetupComplete2.cmd
    if ((!(Test-Path -Path $vmOrigStartupScript)) -and (Test-Path -Path $vmStartupScript) ) {
        Write-Host "=== Save SetupComplete2.cmd from the original base image to $vmOrigStartupScript"
        Move-Item $vmStartupScript $vmOrigStartupScript
    }

    mkdir $vmStartupScriptsDir -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $PSScriptRoot 'SetupComplete2.cmd') $vmStartupScriptsDir -Force

    $firstLogonTasksFile = "$setupDir\FirstLogonTasks.json"
    if (!([string]::IsNullOrWhiteSpace($FirstLogonTasksBase64))) {
        $firstLogonTasks = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($FirstLogonTasksBase64)) | ConvertFrom-Json

        $baseImageLogonTasks = @()
        if (Test-Path -Path $firstLogonTasksFile -PathType Leaf) {
            Write-Host "=== Found following logon tasks configured for the base image in $firstLogonTasksFile"
            Get-Content $firstLogonTasksFile
            $baseImageLogonTasks = Get-Content $firstLogonTasksFile -Raw | ConvertFrom-Json
        }

        # Only keep unique tasks that were configured for the base image
        $uniqueBaseImageLogonTasks = @()
        foreach ($baseImageLogonTask in $baseImageLogonTasks) {
            $baseImageTaskID = GetTaskID $baseImageLogonTask
            if ($null -eq ($firstLogonTasks | Where-Object { (GetTaskID $_) -eq $baseImageTaskID })) {
                $uniqueBaseImageLogonTasks += $baseImageLogonTask
            }
            else {
                Write-Host "== Skipped base image task $($baseImageLogonTask | ConvertTo-Json -Depth 10)"
            }
        }

        $firstLogonTasks = $uniqueBaseImageLogonTasks + $firstLogonTasks
        # Always use -Depth with ConvertTo-Json to preserve object structure (otherwise arrays fo example are turned into space separated strings)
        $firstLogonTasks | ConvertTo-Json -Depth 10 | Out-File -FilePath $firstLogonTasksFile
        Write-Host "=== Saved following tasks to run on user first logon to $firstLogonTasksFile"
        Get-Content $firstLogonTasksFile
    }
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
