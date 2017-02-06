$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

<#
    .SYNOPSIS
        Stops all instances of the process with the given name.

    .PARAMETER ProcessName
        The name of the process to stop.
#>
function Stop-ProcessByName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ProcessName
    )

    Stop-Process -Name $ProcessName -ErrorAction 'SilentlyContinue' -Force
    Wait-ScriptBlockReturnTrue -ScriptBlock { return $null -eq (Get-Process -Name $ProcessName -ErrorAction 'SilentlyContinue') } `
                               -TimeoutSeconds 15
}

Export-ModuleMember -Function Stop-ProcessByName
