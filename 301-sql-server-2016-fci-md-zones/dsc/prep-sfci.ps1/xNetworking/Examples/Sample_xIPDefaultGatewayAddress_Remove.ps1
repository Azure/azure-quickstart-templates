Configuration Sample_xDefaultGatewayAddress_Remove
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xDefaultGatewayAddress RemoveDefaultGateway
        {
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}
