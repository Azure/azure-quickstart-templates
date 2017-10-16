configuration Sample_xNetBIOS_Disabled
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -ModuleName xNetworking

    node $NodeName 
    {
        xNetBIOS DisableNetBIOS 
        {
            InterfaceAlias   = 'Ethernet'
            Setting = 'Disable'
        }
    }
}

Sample_xNetBIOS_Disabled
Start-DscConfiguration -Path Sample_xNetBIOS_Disabled -Wait -Verbose -Force 
