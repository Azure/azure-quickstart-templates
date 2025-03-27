<#
.DESCRIPTION
    The script is executed only once per a Dev Box VM, the very first time a user logs in.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. {
    try {
        # Allows showing the script output in the console window as well as capturing it in the log file. Unlike Tee-Object doesn't hang when output is redirected to a file in Run-Program arguments.
        Start-Transcript -Path 'C:\.tools\Setup\Logs\runonce-user-tasks.log' -Append

        if ($env:PACKER_BUILD_NAME) {
            Write-Host "=== Ignore the event during image creation in case it was configured by the base image"
            return
        }

        $host.UI.RawUI.WindowTitle = "Running Dev Box initialization steps"

        Write-Host "=== Run first logon tasks"
        & (Join-Path $PSScriptRoot 'run-firstlogon-tasks.ps1')

        # Copy machine specific metadata from C:\Program Files\Microsoft Dev Box Agent\...\appsettings.Production.json to C:\.tools\Setup\DevBoxAgent.json.
        Write-Host "=== Copying DevBoxAgent.json"
        $devBoxAgentInstallLocation = 'C:\Program Files\Microsoft Dev Box Agent'
        if (Test-Path $devBoxAgentInstallLocation -PathType Container) {
            $devBoxSettingsFiles = @(Get-ChildItem -Recurse -File -Path $devBoxAgentInstallLocation -Filter 'appsettings.Production.json')
            if ($devBoxSettingsFiles.Count -gt 0) {
                Copy-Item $devBoxSettingsFiles[0].FullName C:\.tools\Setup\DevBoxAgent.json
            }
        }
    }
    catch {
        Write-Host "[WARN] Unhandled exception:"
        Write-Host -Object $_
        Write-Host -Object $_.ScriptStackTrace
    }
    finally {
        $ErrorActionPreference = "SilentlyContinue"
        Stop-Transcript | Out-Null
        $ErrorActionPreference = "Stop"
    }
    # Ensure all output is captured (https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/output-missing-from-transcript?view=powershell-7.3#a-way-to-ensure-full-transcription)
} Out-Default

# Never fail this script since it is ran as an async event on user logon and its result is discarded
exit 0
