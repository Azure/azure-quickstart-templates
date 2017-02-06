<#
    .SYNOPSIS
        Removes the registry key called MyNewKey under the parent key
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'.
#>
Configuration Sample_xRegistryResource_RemoveKey
{
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xRegistry Registry1
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\MyNewKey'
            Ensure = 'Absent'
            ValueName = ''
        }
    }
}
