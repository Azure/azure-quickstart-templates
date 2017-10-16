configuration Sample_xDhcpClient_Enabled
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [string]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily
    )

    Import-DscResource -Module xDhcpClient

    Node $NodeName
    {
        xDhcpClient EnableDhcpClient
        {
            State          = 'Enabled'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}
