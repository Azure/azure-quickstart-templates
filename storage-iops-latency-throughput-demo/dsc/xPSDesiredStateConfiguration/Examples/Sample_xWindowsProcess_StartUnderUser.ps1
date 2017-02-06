<#
    .SYNOPSIS
        Starts the gpresult process under the given credential which generates a log
        about the group policy. The path to the log is provided in 'Arguments'.

    .PARAMETER Credential
        Credential to start the process under.
#>
Configuration Sample_xWindowsProcess_StartUnderUser
{
    [CmdletBinding()]
    param
    (
       [System.Management.Automation.PSCredential]
       [System.Management.Automation.Credential()]
       $Credential = (Get-Credential)
    )

    Import-DSCResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xWindowsProcess GPresult
        {
            Path = 'C:\Windows\System32\gpresult.exe'
            Arguments = '/h C:\gp2.htm'
            Credential = $Credential
            Ensure = 'Present'
        }
    }
}

<#           
    To use the sample(s) with credentials, see blog at:
    http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
#>

