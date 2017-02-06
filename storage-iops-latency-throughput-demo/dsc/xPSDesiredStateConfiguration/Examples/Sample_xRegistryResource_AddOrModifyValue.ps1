<#
    .SYNOPSIS
        If the registry key value MyValue under the key
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' does not exist,
        creates it with the Binary value 0.

        If the registry key value MyValue under the key
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' already exists,
        overwrites it with the Binary value 0.
#>
Configuration Sample_xRegistryResource_AddOrModifyValue
{
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xRegistry Registry1
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            Ensure = 'Present'
            ValueName = 'MyValue'
            ValueType = 'Binary'
            ValueData = '0x00'
            Force = $true
        }
    }
}
