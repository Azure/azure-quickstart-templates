<#
    .SYNOPSIS
        Create a new registry key called MyNewKey as a subkey under the key
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'.
#>
Configuration Sample_xRegistryResource_AddKey
{
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xRegistry Registry1
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\MyNewKey'
            Ensure = 'Present'
            ValueName = ''
        }
    }
}
