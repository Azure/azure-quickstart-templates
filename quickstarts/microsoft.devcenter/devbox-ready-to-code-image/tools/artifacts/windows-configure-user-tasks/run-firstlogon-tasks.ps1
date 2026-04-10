<#
.DESCRIPTION
    Executes user first logon tasks configured for the image in C:\.tools\Setup\FirstLogonTasks.json
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$setupScriptsDir = $PSScriptRoot
$setupDir = Split-Path -Parent $PSScriptRoot
$firstLogonTasksDir = "$setupScriptsDir\FirstLogonTasks"
$firstLogonTasksFile = "$setupDir\FirstLogonTasks.json"

if (!(Test-Path -Path $firstLogonTasksFile -PathType Leaf)) {
    Write-Host "=== Nothing to do because $firstLogonTasksFile doesn't exist"
    return  # Do not call `exit` to allow the caller script to continue
}

Write-Host "=== Executing tasks from $firstLogonTasksFile"
$firstLogonTasks = Get-Content $firstLogonTasksFile -Raw | ConvertFrom-Json
foreach ($firstLogonTask in $firstLogonTasks) {
    $taskName = $firstLogonTask.Task
    $taskScript = "$firstLogonTasksDir\$taskName.ps1"
    if (!(Test-Path -Path $taskScript -PathType Leaf)) {
        Write-Host "[WARN] Skipped task $taskName : couldn't find $taskScript"
        continue
    }

    try {
        if ($firstLogonTask.PSobject.Properties.Name -contains 'Parameters') {
            $taskParams = $firstLogonTask.Parameters
            Write-Host "=== Executing task $taskName with arguments $($taskParams | ConvertTo-Json -Depth 10)"
            & $taskScript -TaskParams $taskParams
        } else {
            Write-Host "=== Executing task $taskName"
            & $taskScript
        }
    }
    catch {
        # Log but keep running other tasks
        Write-Host "=== [WARN] Task $taskName failed"
        Write-Host -Object $_
        Write-Host -Object $_.ScriptStackTrace
    }
}

Write-Host "=== Done executing tasks from $firstLogonTasksFile"
