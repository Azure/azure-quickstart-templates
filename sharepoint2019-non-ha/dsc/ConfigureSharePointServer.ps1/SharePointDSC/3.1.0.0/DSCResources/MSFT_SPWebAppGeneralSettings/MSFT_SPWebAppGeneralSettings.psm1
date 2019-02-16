function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.UInt32]
        $TimeZone,

        [Parameter()]
        [System.Boolean]
        $Alerts,

        [Parameter()]
        [System.UInt32]
        $AlertsLimit,

        [Parameter()]
        [System.Boolean]
        $RSS,

        [Parameter()]
        [System.Boolean]
        $BlogAPI,

        [Parameter()]
        [System.Boolean]
        $BlogAPIAuthenticated,

        [Parameter()]
        [ValidateSet("Strict","Permissive")]
        [System.String]
        $BrowserFileHandling,

        [Parameter()]
        [System.Boolean]
        $SecurityValidation,

        [Parameter()]
        [System.Boolean]
        $SecurityValidationExpires,

        [Parameter()]
        [System.Uint32]
        $SecurityValidationTimeoutMinutes,

        [Parameter()]
        [System.Boolean]
        $RecycleBinEnabled,

        [Parameter()]
        [System.Boolean]
        $RecycleBinCleanupEnabled,

        [Parameter()]
        [System.UInt32]
        $RecycleBinRetentionPeriod,

        [Parameter()]
        [System.UInt32]
        $SecondStageRecycleBinQuota,

        [Parameter()]
        [System.UInt32]
        $MaximumUploadSize,

        [Parameter()]
        [System.Boolean]
        $CustomerExperienceProgram,

        [Parameter()]
        [System.Boolean]
        $PresenceEnabled,

        [Parameter()]
        [System.Boolean]
        $AllowOnlineWebPartCatalog,

        [Parameter()]
        [System.Boolean]
        $SelfServiceSiteCreationEnabled,

        [Parameter()]
        [System.String]
        $DefaultQuotaTemplate,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$WebAppUrl' general settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters,$PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return @{
                WebAppUrl = $params.WebAppUrl
                TimeZone = $null
                Alerts = $null
                AlertsLimit = $null
                RSS = $null
                BlogAPI = $null
                BlogAPIAuthenticated = $null
                BrowserFileHandling = $null
                SecurityValidation = $null
                SecurityValidationExpires = $null
                SecurityValidationTimeoutMinutes = $null
                RecycleBinEnabled = $null
                RecycleBinCleanupEnabled = $null
                RecycleBinRetentionPeriod = $null
                SecondStageRecycleBinQuota = $null
                MaximumUploadSize = $null
                CustomerExperienceProgram = $null
                PresenceEnabled = $null
                AllowOnlineWebPartCatalog = $null
                SelfServiceSiteCreationEnabled = $null
                DefaultQuotaTemplate = $null
            }
        }

        $modulePath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.GeneralSettings.psm1"
        Import-Module -Name (Join-Path -Path $ScriptRoot -ChildPath $modulePath -Resolve)

        $result = Get-SPDSCWebApplicationGeneralConfig -WebApplication $wa
        $result.Add("WebAppUrl", $params.WebAppUrl)
        $result.Add("InstallAccount", $params.InstallAccount)
        return $result
    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
       (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.UInt32]
        $TimeZone,

        [Parameter()]
        [System.Boolean]
        $Alerts,

        [Parameter()]
        [System.UInt32]
        $AlertsLimit,

        [Parameter()]
        [System.Boolean]
        $RSS,

        [Parameter()]
        [System.Boolean]
        $BlogAPI,

        [Parameter()]
        [System.Boolean]
        $BlogAPIAuthenticated,

        [Parameter()]
        [ValidateSet("Strict","Permissive")]
        [System.String]
        $BrowserFileHandling,

        [Parameter()]
        [System.Boolean]
        $SecurityValidation,

        [Parameter()]
        [System.Boolean]
        $SecurityValidationExpires,

        [Parameter()]
        [System.Uint32]
        $SecurityValidationTimeoutMinutes,

        [Parameter()]
        [System.Boolean]
        $RecycleBinEnabled,

        [Parameter()]
        [System.Boolean]
        $RecycleBinCleanupEnabled,

        [Parameter()]
        [System.UInt32]
        $RecycleBinRetentionPeriod,

        [Parameter()]
        [System.UInt32]
        $SecondStageRecycleBinQuota,

        [Parameter()]
        [System.UInt32]
        $MaximumUploadSize,

        [Parameter()]
        [System.Boolean]
        $CustomerExperienceProgram,

        [Parameter()]
        [System.Boolean]
        $PresenceEnabled,

        [Parameter()]
        [System.Boolean]
        $AllowOnlineWebPartCatalog,

        [Parameter()]
        [System.Boolean]
        $SelfServiceSiteCreationEnabled,

        [Parameter()]
        [System.String]
        $DefaultQuotaTemplate,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$WebAppUrl' general settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters,$PSScriptRoot) `
                        -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            throw "Web application $($params.WebAppUrl) was not found"
        }

        if ($params.ContainsKey("DefaultQuotaTemplate"))
        {
            $admService = Get-SPDSCContentService

            $quotaTemplate = $admService.QuotaTemplates[$params.DefaultQuotaTemplate]
            if ($null -eq $quotaTemplate)
            {
                throw "Quota template $($params.DefaultQuotaTemplate) was not found"
            }
        }

        $modulePath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.GeneralSettings.psm1"
        Import-Module -Name (Join-Path -Path $ScriptRoot -ChildPath $modulePath -Resolve)

        Set-SPDSCWebApplicationGeneralConfig -WebApplication $wa -Settings $params
        $wa.Update()
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
     (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.UInt32]
        $TimeZone,

        [Parameter()]
        [System.Boolean]
        $Alerts,

        [Parameter()]
        [System.UInt32]
        $AlertsLimit,

        [Parameter()]
        [System.Boolean]
        $RSS,

        [Parameter()]
        [System.Boolean]
        $BlogAPI,

        [Parameter()]
        [System.Boolean]
        $BlogAPIAuthenticated,

        [Parameter()]
        [ValidateSet("Strict","Permissive")]
        [System.String]
        $BrowserFileHandling,

        [Parameter()]
        [System.Boolean]
        $SecurityValidation,

        [Parameter()]
        [System.Boolean]
        $SecurityValidationExpires,

        [Parameter()]
        [System.Uint32]
        $SecurityValidationTimeoutMinutes,

        [Parameter()]
        [System.Boolean]
        $RecycleBinEnabled,

        [Parameter()]
        [System.Boolean]
        $RecycleBinCleanupEnabled,

        [Parameter()]
        [System.UInt32]
        $RecycleBinRetentionPeriod,

        [Parameter()]
        [System.UInt32]
        $SecondStageRecycleBinQuota,

        [Parameter()]
        [System.UInt32]
        $MaximumUploadSize,

        [Parameter()]
        [System.Boolean]
        $CustomerExperienceProgram,

        [Parameter()]
        [System.Boolean]
        $PresenceEnabled,

        [Parameter()]
        [System.Boolean]
        $AllowOnlineWebPartCatalog,

        [Parameter()]
        [System.Boolean]
        $SelfServiceSiteCreationEnabled,

        [Parameter()]
        [System.String]
        $DefaultQuotaTemplate,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing web application '$WebAppUrl' general settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $modulePath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.GeneralSettings.psm1"
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath $modulePath -Resolve)

    return Test-SPDSCWebApplicationGeneralConfig -CurrentSettings $CurrentValues -DesiredSettings $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
