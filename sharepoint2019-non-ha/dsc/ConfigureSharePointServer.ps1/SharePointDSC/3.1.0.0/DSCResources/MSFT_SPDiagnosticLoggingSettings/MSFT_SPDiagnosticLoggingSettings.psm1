function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogPath,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $LogSpaceInGB,

        [Parameter()]
        [System.Boolean]
        $AppAnalyticsAutomaticUploadEnabled,

        [Parameter()]
        [System.Boolean]
        $CustomerExperienceImprovementProgramEnabled,

        [Parameter()]
        [System.UInt32]
        $DaysToKeepLogs,

        [Parameter()]
        [System.Boolean]
        $DownloadErrorReportingUpdatesEnabled,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingAutomaticUploadEnabled,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $EventLogFloodProtectionEnabled,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionNotifyInterval,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionQuietPeriod,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionThreshold,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionTriggerPeriod,

        [Parameter()]
        [System.UInt32]
        $LogCutInterval,

        [Parameter()]
        [System.Boolean]
        $LogMaxDiskSpaceUsageEnabled,

        [Parameter()]
        [System.UInt32]
        $ScriptErrorReportingDelay,

        [Parameter()]
        [System.Boolean]
        $ScriptErrorReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $ScriptErrorReportingRequireAuth,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting diagnostic configuration settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $dc = Get-SPDiagnosticConfig -ErrorAction SilentlyContinue
        if ($null -eq $dc)
        {
            return $null
        }

        return @{
            IsSingleInstance = "Yes"
            AppAnalyticsAutomaticUploadEnabled = $dc.AppAnalyticsAutomaticUploadEnabled
            CustomerExperienceImprovementProgramEnabled = `
                $dc.CustomerExperienceImprovementProgramEnabled
            ErrorReportingEnabled = $dc.ErrorReportingEnabled
            ErrorReportingAutomaticUploadEnabled = $dc.ErrorReportingAutomaticUploadEnabled
            DownloadErrorReportingUpdatesEnabled = $dc.DownloadErrorReportingUpdatesEnabled
            DaysToKeepLogs = $dc.DaysToKeepLogs
            LogMaxDiskSpaceUsageEnabled = $dc.LogMaxDiskSpaceUsageEnabled
            LogSpaceInGB = $dc.LogDiskSpaceUsageGB
            LogPath = $dc.LogLocation
            LogCutInterval = $dc.LogCutInterval
            EventLogFloodProtectionEnabled = $dc.EventLogFloodProtectionEnabled
            EventLogFloodProtectionThreshold = $dc.EventLogFloodProtectionThreshold
            EventLogFloodProtectionTriggerPeriod = $dc.EventLogFloodProtectionTriggerPeriod
            EventLogFloodProtectionQuietPeriod = $dc.EventLogFloodProtectionQuietPeriod
            EventLogFloodProtectionNotifyInterval = $dc.EventLogFloodProtectionNotifyInterval
            ScriptErrorReportingEnabled = $dc.ScriptErrorReportingEnabled
            ScriptErrorReportingRequireAuth = $dc.ScriptErrorReportingRequireAuth
            ScriptErrorReportingDelay = $dc.ScriptErrorReportingDelay
            InstallAccount = $params.InstallAccount
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
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogPath,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $LogSpaceInGB,

        [Parameter()]
        [System.Boolean]
        $AppAnalyticsAutomaticUploadEnabled,

        [Parameter()]
        [System.Boolean]
        $CustomerExperienceImprovementProgramEnabled,

        [Parameter()]
        [System.UInt32]
        $DaysToKeepLogs,

        [Parameter()]
        [System.Boolean]
        $DownloadErrorReportingUpdatesEnabled,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingAutomaticUploadEnabled,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $EventLogFloodProtectionEnabled,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionNotifyInterval,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionQuietPeriod,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionThreshold,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionTriggerPeriod,

        [Parameter()]
        [System.UInt32]
        $LogCutInterval,

        [Parameter()]
        [System.Boolean]
        $LogMaxDiskSpaceUsageEnabled,

        [Parameter()]
        [System.UInt32]
        $ScriptErrorReportingDelay,

        [Parameter()]
        [System.Boolean]
        $ScriptErrorReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $ScriptErrorReportingRequireAuth,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting diagnostic configuration settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        if ($params.ContainsKey("IsSingleInstance"))
        {
            $params.Remove("IsSingleInstance") | Out-Null
        }

        if ($params.ContainsKey("InstallAccount"))
        {
            $params.Remove("InstallAccount") | Out-Null
        }
        $params = $params | Rename-SPDSCParamValue -oldName "LogPath" `
                                                   -newName "LogLocation" `
                          | Rename-SPDSCParamValue -oldName "LogSpaceInGB" `
                                                   -newName "LogDiskSpaceUsageGB"

        Set-SPDiagnosticConfig @params
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogPath,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $LogSpaceInGB,

        [Parameter()]
        [System.Boolean]
        $AppAnalyticsAutomaticUploadEnabled,

        [Parameter()]
        [System.Boolean]
        $CustomerExperienceImprovementProgramEnabled,

        [Parameter()]
        [System.UInt32]
        $DaysToKeepLogs,

        [Parameter()]
        [System.Boolean]
        $DownloadErrorReportingUpdatesEnabled,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingAutomaticUploadEnabled,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $EventLogFloodProtectionEnabled,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionNotifyInterval,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionQuietPeriod,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionThreshold,

        [Parameter()]
        [System.UInt32]
        $EventLogFloodProtectionTriggerPeriod,

        [Parameter()]
        [System.UInt32]
        $LogCutInterval,

        [Parameter()]
        [System.Boolean]
        $LogMaxDiskSpaceUsageEnabled,

        [Parameter()]
        [System.UInt32]
        $ScriptErrorReportingDelay,

        [Parameter()]
        [System.Boolean]
        $ScriptErrorReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $ScriptErrorReportingRequireAuth,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing diagnostic configuration settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
