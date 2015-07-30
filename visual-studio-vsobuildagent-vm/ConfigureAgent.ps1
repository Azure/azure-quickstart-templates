[CmdletBinding(DefaultParameterSetName = 'None')]
Param(
[Parameter(Mandatory=$false)][switch]$Force
)

Write-Verbose "Entering ConfigureAgent.ps1"
$currentLocation = Split-Path -parent $MyInvocation.MyCommand.Definition

# Removing the ZoneIdentifier from files downloaded from the internet so the plugins can be loaded
# Don't recurse down _work or _diag, those files are not blocked and cause the process to take much longer
Write-Host "Unblocking files"
Get-ChildItem -Path $currentLocation | Unblock-File | out-null
Get-ChildItem -Recurse -Path $currentLocation\Agent | Unblock-File | out-null

$agentLocation = [System.IO.Path]::Combine($currentLocation, 'agent', 'vsoAgent.exe')
Write-Verbose "agentLocation = $agentLocation"
if (![System.IO.File]::Exists($agentLocation))
{
    Write-Error "File not found: $agentLocation"
    return
}

if ($Force)
{
    $forceOption = "/force"
}
else
{
    $forceOption = ""
}

# Call the agent with the configure command and all the options (this creates the settings file)
Write-Host "Configuring agent"
&start cmd.exe "/k ""$agentLocation"" /configure $forceOption"

Write-Verbose "Exiting ConfigureAgent.ps1"