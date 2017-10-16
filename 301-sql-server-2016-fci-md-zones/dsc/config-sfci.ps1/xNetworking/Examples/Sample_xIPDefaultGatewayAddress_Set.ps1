Configuration Sample_xDefaultGatewayAddress
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$DefaultGateway,
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xDefaultGatewayAddress SetDefaultGateway
        {
            Address        = $DefaultGateway
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}
