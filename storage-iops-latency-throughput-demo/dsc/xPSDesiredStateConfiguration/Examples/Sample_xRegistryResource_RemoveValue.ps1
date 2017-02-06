<#
    .SYNOPSIS
        Removes the registry key value MyValue from the key
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'.
#>
Configuration Sample_xRegistryResource_RemoveValue
{
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xRegistry Registry1
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            Ensure = 'Absent'
            ValueName = 'MyValue'
        }
    }
}
