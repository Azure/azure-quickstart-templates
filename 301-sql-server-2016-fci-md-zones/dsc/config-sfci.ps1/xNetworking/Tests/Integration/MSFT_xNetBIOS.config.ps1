try 
{
    [void][reflection.assembly]::GetAssembly([NetBIOSSetting])
}
catch
{
    Add-Type -TypeDefinition @'
    public enum NetBiosSetting
    {
       Default,
       Enable,
       Disable
    }
'@
}

$adapter = (
    Get-CimInstance -ClassName Win32_NetworkAdapter `
        -Filter 'NetEnabled="True"'
)[0]

$Current = [NETBIOSSetting].GetEnumValues()[(
    $adapter |
    Get-CimAssociatedInstance `
        -ResultClassName Win32_NetworkAdapterConfiguration
).TcpipNetbiosOptions]

configuration MSFT_xNetBIOS_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xNetBIOS Integration_Test {
            InterfaceAlias   = $adapter.NetConnectionID
            Setting = $Current
        }
    }
}
