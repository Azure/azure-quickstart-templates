<#
.EXAMPLE
    This example applies the specified diagnostic logging settings to the local
    SharPoint farm. Any setting not defined will be left as it default, or to
    whatever value has been manually configured outside of DSC.
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
            SPDiagnosticLoggingSettings ApplyDiagnosticLogSettings
            {
                IsSingleInstance                            = "Yes"
                LogPath                                     = "L:\ULSLogs"
                LogSpaceInGB                                = 10
                AppAnalyticsAutomaticUploadEnabled          = $false
                CustomerExperienceImprovementProgramEnabled = $true
                DaysToKeepLogs                              = 7
                DownloadErrorReportingUpdatesEnabled        = $false
                ErrorReportingAutomaticUploadEnabled        = $false
                ErrorReportingEnabled                       = $false
                EventLogFloodProtectionEnabled              = $true
                EventLogFloodProtectionNotifyInterval       = 5
                EventLogFloodProtectionQuietPeriod          = 2
                EventLogFloodProtectionThreshold            = 5
                EventLogFloodProtectionTriggerPeriod        = 2
                LogCutInterval                              = 15
                LogMaxDiskSpaceUsageEnabled                 = $true
                ScriptErrorReportingDelay                   = 30
                ScriptErrorReportingEnabled                 = $true
                ScriptErrorReportingRequireAuth             = $true
                PsDscRunAsCredential                        = $SetupAccount
            }
        }
    }
