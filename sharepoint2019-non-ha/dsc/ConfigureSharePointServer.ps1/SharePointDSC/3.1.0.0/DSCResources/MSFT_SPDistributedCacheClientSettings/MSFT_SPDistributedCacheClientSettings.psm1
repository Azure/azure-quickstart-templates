function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.UInt32]
        $DLTCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DLTCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DLTCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DVSCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DVSCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DVSCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DACMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DACRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DACChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DAFMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DAFRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DAFChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DAFCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DAFCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DAFCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DBCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DBCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DBCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DDCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DDCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DDCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DSCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DSCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DSCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DTCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DTCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DTCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DSTACMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DSTACRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DSTACChannelOpenTimeOut,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting the Distributed Cache Client Settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $nullReturnValue = @{
            IsSingleInstance = "Yes"
            DLTCMaxConnectionsToServer = $null
            DLTCRequestTimeout = $null
            DLTCChannelOpenTimeOut = $null
            DVSCMaxConnectionsToServer = $null
            DVSCRequestTimeout = $null
            DVSCChannelOpenTimeOut = $null
            DACMaxConnectionsToServer = $null
            DACRequestTimeout = $null
            DACChannelOpenTimeOut = $null
            DAFMaxConnectionsToServer = $null
            DAFRequestTimeout = $null
            DAFChannelOpenTimeOut = $null
            DAFCMaxConnectionsToServer = $null
            DAFCRequestTimeout = $null
            DAFCChannelOpenTimeOut = $null
            DBCMaxConnectionsToServer = $null
            DBCRequestTimeout = $null
            DBCChannelOpenTimeOut = $null
            DDCMaxConnectionsToServer = $null
            DDCRequestTimeout = $null
            DDCChannelOpenTimeOut = $null
            DSCMaxConnectionsToServer = $null
            DSCRequestTimeout = $null
            DSCChannelOpenTimeOut = $null
            DTCMaxConnectionsToServer = $null
            DTCRequestTimeout = $null
            DTCChannelOpenTimeOut = $null
            DSTACMaxConnectionsToServer = $null
            DSTACRequestTimeout = $null
            DSTACChannelOpenTimeOut = $null
            InstallAccount = $params.InstallAccount
        }

        try
        {
            $DLTC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedLogonTokenCache"
            $DVSC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedViewStateCache"
            $DAC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedAccessCache"
            $DAF = Get-SPDistributedCacheClientSetting -ContainerType "DistributedActivityFeedCache"
            $DAFC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedActivityFeedLMTCache"
            $DBC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedBouncerCache"
            $DDC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedDefaultCache"
            $DSC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedSearchCache"
            $DTC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedSecurityTrimmingCache"
            $DSTAC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedServerToAppServerAccessTokenCache"

            $returnValue = @{
                IsSingleInstance = "Yes"
                DLTCMaxConnectionsToServer = $DLTC.MaxConnectionsToServer
                DLTCRequestTimeout = $DLTC.RequestTimeout
                DLTCChannelOpenTimeOut = $DLTC.ChannelOpenTimeOut
                DVSCMaxConnectionsToServer = $DVSC.MaxConnectionsToServer
                DVSCRequestTimeout = $DVSC.RequestTimeout
                DVSCChannelOpenTimeOut = $DVSC.ChannelOpenTimeOut
                DACMaxConnectionsToServer = $DAC.MaxConnectionsToServer
                DACRequestTimeout = $DAC.RequestTimeout
                DACChannelOpenTimeOut = $DAC.ChannelOpenTimeOut
                DAFMaxConnectionsToServer = $DAF.MaxConnectionsToServer
                DAFRequestTimeout = $DAF.RequestTimeout
                DAFChannelOpenTimeOut = $DAF.ChannelOpenTimeOut
                DAFCMaxConnectionsToServer = $DAFC.MaxConnectionsToServer
                DAFCRequestTimeout = $DAFC.RequestTimeout
                DAFCChannelOpenTimeOut = $DAFC.ChannelOpenTimeOut
                DBCMaxConnectionsToServer = $DBC.MaxConnectionsToServer
                DBCRequestTimeout = $DBC.RequestTimeout
                DBCChannelOpenTimeOut = $DBC.ChannelOpenTimeOut
                DDCMaxConnectionsToServer = $DDC.MaxConnectionsToServer
                DDCRequestTimeout = $DDC.RequestTimeout
                DDCChannelOpenTimeOut = $DDC.ChannelOpenTimeOut
                DSCMaxConnectionsToServer = $DSC.MaxConnectionsToServer
                DSCRequestTimeout = $DSC.RequestTimeout
                DSCChannelOpenTimeOut = $DSC.ChannelOpenTimeOut
                DTCMaxConnectionsToServer = $DTC.MaxConnectionsToServer
                DTCRequestTimeout = $DTC.RequestTimeout
                DTCChannelOpenTimeOut = $DTC.ChannelOpenTimeOut
                DSTACMaxConnectionsToServer = $DSTAC.MaxConnectionsToServer
                DSTACRequestTimeout = $DSTAC.RequestTimeout
                DSTACChannelOpenTimeOut = $DSTAC.ChannelOpenTimeOut
                InstallAccount = $params.InstallAccount
            }
            return $returnValue
        }
        catch
        {
            return $nullReturnValue
        }
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.UInt32]
        $DLTCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DLTCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DLTCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DVSCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DVSCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DVSCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DACMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DACRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DACChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DAFMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DAFRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DAFChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DAFCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DAFCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DAFCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DBCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DBCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DBCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DDCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DDCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DDCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DSCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DSCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DSCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DTCMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DTCRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DTCChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.UInt32]
        $DSTACMaxConnectionsToServer = 1,

        [Parameter()]
        [System.UInt32]
        $DSTACRequestTimeout = 3000,

        [Parameter()]
        [System.UInt32]
        $DSTACChannelOpenTimeOut = 3000,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting the Distributed Cache Client Settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                    -Arguments $PSBoundParameters `
                    -ScriptBlock {
        $params = $args[0]

        #DistributedLogonTokenCache
        $DLTC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedLogonTokenCache"

        if($params.DLTCMaxConnectionsToServer)
        {
            $DLTC.MaxConnectionsToServer = $params.DLTCMaxConnectionsToServer
        }
        if($params.DLTCRequestTimeout)
        {
            $DLTC.RequestTimeout = $params.DLTCRequestTimeout
        }
        if($params.DLTCChannelOpenTimeOut)
        {
            $DLTC.ChannelOpenTimeOut = $params.DLTCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedLogonTokenCache" $DLTC

        #DistributedViewStateCache
        $DVSC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedViewStateCache"
        if($params.DVSCMaxConnectionsToServer)
        {
            $DVSC.MaxConnectionsToServer = $params.DVSCMaxConnectionsToServer
        }
        if($params.DVSCRequestTimeout)
        {
            $DVSC.RequestTimeout = $params.DVSCRequestTimeout
        }
        if($params.DVSCChannelOpenTimeOut)
        {
            $DVSC.ChannelOpenTimeOut = $params.DVSCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedViewStateCache" $DVSC

        #DistributedAccessCache
        $DAC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedAccessCache"
        if($params.DACMaxConnectionsToServer)
        {
            $DAC.MaxConnectionsToServer = $params.DACMaxConnectionsToServer
        }
        if($params.DACRequestTimeout)
        {
            $DAC.RequestTimeout = $params.DACRequestTimeout
        }
        if($params.DACChannelOpenTimeOut)
        {
            $DAC.ChannelOpenTimeOut = $params.DACChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedAccessCache" $DAC

        #DistributedActivityFeedCache
        $DAF = Get-SPDistributedCacheClientSetting -ContainerType "DistributedActivityFeedCache"
        if($params.DAFMaxConnectionsToServer)
        {
            $DAF.MaxConnectionsToServer = $params.DAFMaxConnectionsToServer
        }
        if($params.DAFRequestTimeout)
        {
            $DAF.RequestTimeout = $params.DAFRequestTimeout
        }
        if($params.DAFChannelOpenTimeOut)
        {
            $DAF.ChannelOpenTimeOut = $params.DAFChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedActivityFeedCache" $DAF

        #DistributedActivityFeedLMTCache
        $DAFC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedActivityFeedLMTCache"
        if($params.DAFCMaxConnectionsToServer)
        {
            $DAFC.MaxConnectionsToServer = $params.DAFCMaxConnectionsToServer
        }
        if($params.DAFCRequestTimeout)
        {
            $DAFC.RequestTimeout = $params.DAFCRequestTimeout
        }
        if($params.DAFCChannelOpenTimeOut)
        {
            $DAFC.ChannelOpenTimeOut = $params.DAFCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedActivityFeedLMTCache" $DAFC

        #DistributedBouncerCache
        $DBC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedBouncerCache"
        if($params.DBCMaxConnectionsToServer)
        {
            $DBC.MaxConnectionsToServer = $params.DBCMaxConnectionsToServer
        }
        if($params.DBCRequestTimeout)
        {
            $DBC.RequestTimeout = $params.DBCRequestTimeout
        }
        if($params.DBCChannelOpenTimeOut)
        {
            $DBC.ChannelOpenTimeOut = $params.DBCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedBouncerCache" $DBC

        #DistributedDefaultCache
        $DDC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedDefaultCache"
        if($params.DDCMaxConnectionsToServer)
        {
            $DDC.MaxConnectionsToServer = $params.DDCMaxConnectionsToServer
        }
        if($params.DDCRequestTimeout)
        {
            $DDC.RequestTimeout = $params.DDCRequestTimeout
        }
        if($params.DDCChannelOpenTimeOut)
        {
            $DDC.ChannelOpenTimeOut = $params.DDCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedDefaultCache" $DDC

        #DistributedSearchCache
        $DSC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedSearchCache"
        if($params.DSCMaxConnectionsToServer)
        {
            $DSC.MaxConnectionsToServer = $params.DSCMaxConnectionsToServer
        }
        if($params.DSCRequestTimeout)
        {
            $DSC.RequestTimeout = $params.DSCRequestTimeout
        }
        if($params.DSCChannelOpenTimeOut)
        {
            $DSC.ChannelOpenTimeOut = $params.DSCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedSearchCache" $DSC

        #DistributedSecurityTrimmingCache
        $DTC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedSecurityTrimmingCache"
        if($params.DTCMaxConnectionsToServer)
        {
            $DTC.MaxConnectionsToServer = $params.DTCMaxConnectionsToServer
        }
        if($params.DTCRequestTimeout)
        {
            $DTC.RequestTimeout = $params.DTCRequestTimeout
        }
        if($params.DTCChannelOpenTimeOut)
        {
            $DTC.ChannelOpenTimeOut = $params.DTCChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedSecurityTrimmingCache" $DTC

        #DistributedServerToAppServerAccessTokenCache
        $DSTAC = Get-SPDistributedCacheClientSetting -ContainerType "DistributedServerToAppServerAccessTokenCache"
        if($params.DSTACMaxConnectionsToServer)
        {
            $DSTAC.MaxConnectionsToServer = $params.DSTACMaxConnectionsToServer
        }
        if($params.DSTACRequestTimeout)
        {
            $DSTAC.RequestTimeout = $params.DSTACRequestTimeout
        }
        if($params.DSTACChannelOpenTimeOut)
        {
            $DSTAC.ChannelOpenTimeOut = $params.DSTACChannelOpenTimeOut
        }
        Set-SPDistributedCacheClientSetting -ContainerType "DistributedServerToAppServerAccessTokenCache" $DSTAC
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.UInt32]
        $DLTCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DLTCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DLTCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DVSCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DVSCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DVSCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DACMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DACRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DACChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DAFMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DAFRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DAFChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DAFCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DAFCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DAFCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DBCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DBCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DBCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DDCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DDCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DDCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DSCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DSCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DSCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DTCMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DTCRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DTCChannelOpenTimeOut,

        [Parameter()]
        [System.UInt32]
        $DSTACMaxConnectionsToServer,

        [Parameter()]
        [System.UInt32]
        $DSTACRequestTimeout,

        [Parameter()]
        [System.UInt32]
        $DSTACChannelOpenTimeOut,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing the Distributed Cache Client Settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("DLTCMaxConnectionsToServer",
                                    "DLTCRequestTimeout",
                                    "DLTCChannelOpenTimeOut",
                                    "DVSCMaxConnectionsToServer",
                                    "DVSCRequestTimeout",
                                    "DVSCChannelOpenTimeOut",
                                    "DACMaxConnectionsToServer",
                                    "DACRequestTimeout",
                                    "DACChannelOpenTimeOut",
                                    "DAFMaxConnectionsToServer",
                                    "DAFRequestTimeout",
                                    "DAFChannelOpenTimeOut",
                                    "DAFCMaxConnectionsToServer",
                                    "DAFCRequestTimeout",
                                    "DAFCChannelOpenTimeOut",
                                    "DBCMaxConnectionsToServer",
                                    "DBCRequestTimeout",
                                    "DBCChannelOpenTimeOut",
                                    "DDCMaxConnectionsToServer",
                                    "DDCRequestTimeout",
                                    "DDCChannelOpenTimeOut",
                                    "DSCMaxConnectionsToServer",
                                    "DSCRequestTimeout",
                                    "DSCChannelOpenTimeOut",
                                    "DTCMaxConnectionsToServer",
                                    "DTCRequestTimeout",
                                    "DTCChannelOpenTimeOut",
                                    "DSTACMaxConnectionsToServer",
                                    "DSTACRequestTimeout",
                                    "DSTACChannelOpenTimeOut"
                                    )
}

Export-ModuleMember -Function *-TargetResource
