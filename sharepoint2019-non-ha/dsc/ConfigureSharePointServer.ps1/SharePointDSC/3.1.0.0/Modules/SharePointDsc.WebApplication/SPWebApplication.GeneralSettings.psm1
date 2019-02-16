function Get-SPDSCWebApplicationGeneralConfig
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        $WebApplication
    )

    if ($WebApplication.DefaultTimeZone -eq -1)
    {
        $timezone = $null
    }
    else
    {
        $timezone = $WebApplication.DefaultTimeZone
    }

    return @{
        TimeZone = $timezone
        Alerts = $WebApplication.AlertsEnabled
        AlertsLimit = $WebApplication.AlertsMaximum
        RSS = $WebApplication.SyndicationEnabled
        BlogAPI = $WebApplication.MetaWeblogEnabled
        BlogAPIAuthenticated = $WebApplication.MetaWeblogAuthenticationEnabled
        BrowserFileHandling = $WebApplication.BrowserFileHandling
        SecurityValidation = $WebApplication.FormDigestSettings.Enabled
        SecurityValidationExpires = $WebApplication.FormDigestSettings.Expires
        SecurityValidationTimeoutMinutes = $WebApplication.FormDigestSettings.Timeout.TotalMinutes
        RecycleBinEnabled = $WebApplication.RecycleBinEnabled
        RecycleBinCleanupEnabled = $WebApplication.RecycleBinCleanupEnabled
        RecycleBinRetentionPeriod = $WebApplication.RecycleBinRetentionPeriod
        SecondStageRecycleBinQuota = $WebApplication.SecondStageRecycleBinQuota
        MaximumUploadSize = $WebApplication.MaximumFileSize
        CustomerExperienceProgram = $WebApplication.BrowserCEIPEnabled
        PresenceEnabled = $WebApplication.PresenceEnabled
        AllowOnlineWebPartCatalog = $WebApplication.AllowAccessToWebPartCatalog
        SelfServiceSiteCreationEnabled = $WebApplication.SelfServiceSiteCreationEnabled
        DefaultQuotaTemplate = $WebApplication.DefaultQuotaTemplate
    }
}

function Set-SPDSCWebApplicationGeneralConfig
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $WebApplication,

        [Parameter(Mandatory = $true)]
        $Settings
    )

    if ($Settings.SecurityValidationTimeoutMinutes)
    {
        Write-Verbose -Message "timeout minutes: $($Settings.SecurityValidationTimeOutMinutes)"
        $mins = New-TimeSpan -Minutes $Settings.SecurityValidationTimeoutMinutes
        $Settings.SecurityValidationTimeoutMinutes = $mins
    }

    # Format here is SPWebApplication property = Custom settings property
    $mapping = @{
        DefaultTimeZone = "TimeZone"
        AlertsEnabled = "Alerts"
        AlertsMaximum = "AlertsLimit"
        SyndicationEnabled = "RSS"
        MetaWeblogEnabled = "BlogAPI"
        MetaWeblogAuthenticationEnabled = "BlogAPIAuthenticated"
        BrowserFileHandling = "BrowserFileHandling"
        MaximumFileSize = "MaximumUploadSize"
        RecycleBinEnabled = "RecycleBinEnabled"
        RecycleBinCleanupEnabled = "RecycleBinCleanupEnabled"
        RecycleBinRetentionPeriod = "RecycleBinRetentionPeriod"
        SecondStageRecycleBinQuota = "SecondStageRecycleBinQuota"
        BrowserCEIPEnabled = "CustomerExperienceProgram"
        PresenceEnabled = "Presence"
        AllowAccessToWebPartCatalog = "AllowOnlineWebPartCatalog"
        SelfServiceSiteCreationEnabled = "SelfServiceSiteCreationEnabled"
        DefaultQuotaTemplate = "DefaultQuotaTemplate"
    }
    $mapping.Keys | ForEach-Object -Process {
        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $WebApplication `
                                                   -PropertyToSet $_ `
                                                   -ParamsValue $settings `
                                                   -ParamKey $mapping[$_]
    }

    # Set form digest settings child properties
    Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $WebApplication.FormDigestSettings `
                                          -PropertyToSet "Enabled" `
                                          -ParamsValue $settings `
                                          -ParamKey "SecurityValidation"

   Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $WebApplication.FormDigestSettings `
                                         -PropertyToSet "Expires" `
                                         -ParamsValue $settings `
                                         -ParamKey "SecurityValidationExpires"

    Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $WebApplication.FormDigestSettings `
                                          -PropertyToSet "Timeout" `
                                          -ParamsValue $settings `
                                          -ParamKey "SecurityValidationTimeOutMinutes"
}

function Test-SPDSCWebApplicationGeneralConfig
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        $CurrentSettings,

        [Parameter(Mandatory = $true)]
        $DesiredSettings
    )

    $relPath = "..\..\Modules\SharePointDsc.Util\SharePointDsc.Util.psm1"
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath $relPath -Resolve)
    $valuesToCheck = @("TimeZone",
                       "Alerts",
                       "AlertsLimit",
                       "RSS",
                       "BlogAPI",
                       "BlogAPIAuthenticated",
                       "BrowserFileHandling",
                       "SecurityValidation",
                       "SecurityValidationExpires",
                       "SecurityValidationTimeoutMinutes",
                       "RecycleBinEnabled",
                       "RecycleBinCleanupEnabled",
                       "RecycleBinRetentionPeriod",
                       "SecondStageRecycleBinQuota",
                       "MaximumUploadSize",
                       "CustomerExperienceProgram",
                       "PresenceEnabled",
                       "AllowOnlineWebPartCatalog",
                       "SelfServiceSiteCreationEnabled",
                       "DefaultQuotaTemplate"
                      )
    $testReturn = Test-SPDscParameterState -CurrentValues $CurrentSettings `
                                           -DesiredValues $DesiredSettings `
                                           -ValuesToCheck $valuesToCheck
    return $testReturn
}

