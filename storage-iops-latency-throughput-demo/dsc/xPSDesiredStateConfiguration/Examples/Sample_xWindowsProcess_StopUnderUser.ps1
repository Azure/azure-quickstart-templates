<#
    .SYNOPSIS
        Stops the gpresult process running under the given credential if it is running.
        Since the Arguments parameter isn't needed to stop the process,
        an empty string is passed in.

    .PARAMETER Credential
        Credential that the process is running under.
#>
Configuration Sample_xWindowsProcess_StopUnderUser
{
    [CmdletBinding()]
    param
    (
       [ValidateNotNullOrEmpty()]
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
            Arguments = ''
            Credential = $Credential
            Ensure = 'Absent'
        }
    }
}
            
<#           
    To use the sample(s) with credentials, see blog at:
    http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
#>


