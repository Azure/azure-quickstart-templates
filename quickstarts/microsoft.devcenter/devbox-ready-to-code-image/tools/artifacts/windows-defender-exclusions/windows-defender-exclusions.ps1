param(
    [Parameter(Mandatory = $false)] [string] $ExclusionPaths = "",
    [Parameter(Mandatory = $false)] [string] $ExclusionExtensions = "",
    [Parameter(Mandatory = $false)] [string] $ExclusionProcesses = ""
)

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$parameters = @{}
if ($ExclusionPaths.Trim() -ne "") {
    $parameters += @{
        ExclusionPath = $ExclusionPaths -split ","
    }
}

if ($ExclusionExtensions.Trim() -ne "") {
    $parameters += @{
        ExclusionExtension = $ExclusionExtensions -split ","
    }
}

if ($ExclusionProcesses.Trim() -ne "") {
    $parameters += @{
        ExclusionProcess = $ExclusionProcesses -split ","
    }
}

if ($parameters.Count -ne 0) {
    Add-MpPreference @parameters
}
