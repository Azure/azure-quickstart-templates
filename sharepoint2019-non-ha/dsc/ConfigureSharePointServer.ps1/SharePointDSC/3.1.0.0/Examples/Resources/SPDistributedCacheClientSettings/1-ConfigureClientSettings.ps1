<#
.EXAMPLE
    This example configures the distributed cache client settings.
#>

    Configuration Example
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPDistributedCacheClientSettings Settings
            {
                IsSingleInstance            = "Yes"
                DLTCMaxConnectionsToServer  = 3
                DLTCRequestTimeout          = 1000
                DLTCChannelOpenTimeOut      = 1000
                DVSCMaxConnectionsToServer  = 3
                DVSCRequestTimeout          = 1000
                DVSCChannelOpenTimeOut      = 1000
                DACMaxConnectionsToServer   = 3
                DACRequestTimeout           = 1000
                DACChannelOpenTimeOut       = 1000
                DAFMaxConnectionsToServer   = 3
                DAFRequestTimeout           = 1000
                DAFChannelOpenTimeOut       = 1000
                DAFCMaxConnectionsToServer  = 3
                DAFCRequestTimeout          = 1000
                DAFCChannelOpenTimeOut      = 1000
                DBCMaxConnectionsToServer   = 3
                DBCRequestTimeout           = 1000
                DBCChannelOpenTimeOut       = 1000
                DDCMaxConnectionsToServer   = 3
                DDCRequestTimeout           = 1000
                DDCChannelOpenTimeOut       = 1000
                DSCMaxConnectionsToServer   = 3
                DSCRequestTimeout           = 1000
                DSCChannelOpenTimeOut       = 1000
                DTCMaxConnectionsToServer   = 3
                DTCRequestTimeout           = 1000
                DTCChannelOpenTimeOut       = 1000
                DSTACMaxConnectionsToServer = 3
                DSTACRequestTimeout         = 1000
                DSTACChannelOpenTimeOut     = 1000
                PsDscRunAscredential        = $SetupAccount
            }
        }
    }
