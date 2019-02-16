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
        $ListViewThreshold,

        [Parameter()]
        [System.Boolean]
        $AllowObjectModelOverride,

        [Parameter()]
        [System.UInt32]
        $AdminThreshold,

        [Parameter()]
        [System.UInt32]
        $ListViewLookupThreshold,

        [Parameter()]
        [System.Boolean]
        $HappyHourEnabled,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $HappyHour,

        [Parameter()]
        [System.UInt32]
        $UniquePermissionThreshold,

        [Parameter()]
        [System.Boolean]
        $RequestThrottling,

        [Parameter()]
        [System.Boolean]
        $ChangeLogEnabled,

        [Parameter()]
        [System.UInt32]
        $ChangeLogExpiryDays,

        [Parameter()]
        [System.Boolean]
        $EventHandlersEnabled,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$WebAppUrl' throttling settings"

    $paramArgs = @($PSBoundParameters,$PSScriptRoot)
    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $paramArgs -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return $null
        }

        $relPath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.Throttling.psm1"
        Import-Module -Name (Join-Path -Path $ScriptRoot -ChildPath $relPath -Resolve)

        $result = Get-SPDSCWebApplicationThrottlingConfig -WebApplication $wa
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
        $ListViewThreshold,

        [Parameter()]
        [System.Boolean]
        $AllowObjectModelOverride,

        [Parameter()]
        [System.UInt32]
        $AdminThreshold,

        [Parameter()]
        [System.UInt32]
        $ListViewLookupThreshold,

        [Parameter()]
        [System.Boolean]
        $HappyHourEnabled,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $HappyHour,

        [Parameter()]
        [System.UInt32]
        $UniquePermissionThreshold,

        [Parameter()]
        [System.Boolean]
        $RequestThrottling,

        [Parameter()]
        [System.Boolean]
        $ChangeLogEnabled,

        [Parameter()]
        [System.UInt32]
        $ChangeLogExpiryDays,

        [Parameter()]
        [System.Boolean]
        $EventHandlersEnabled,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$WebAppUrl' throttling settings"

    $paramArgs = @($PSBoundParameters,$PSScriptRoot)

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $paramArgs -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            throw "Web application $($params.WebAppUrl) was not found"
            return
        }

        $relPath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.Throttling.psm1"
        Import-Module -Name (Join-Path -Path $ScriptRoot -ChildPath $relPath -Resolve)
        Set-SPDSCWebApplicationThrottlingConfig -WebApplication $wa -Settings $params
        $wa.HttpThrottleSettings.Update()
        $wa.Update()

        # Happy hour settings
        if ($params.ContainsKey("HappyHour") -eq $true)
        {
            # Happy hour settins use separate update method so use a fresh web app to update these
            $wa2 = Get-SPWebApplication -Identity $params.WebAppUrl
            Set-SPDSCWebApplicationHappyHourConfig -WebApplication $wa2 -Settings $params.HappyHour
            $wa2.Update()
        }
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
        $ListViewThreshold,

        [Parameter()]
        [System.Boolean]
        $AllowObjectModelOverride,

        [Parameter()]
        [System.UInt32]
        $AdminThreshold,

        [Parameter()]
        [System.UInt32]
        $ListViewLookupThreshold,

        [Parameter()]
        [System.Boolean]
        $HappyHourEnabled,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $HappyHour,

        [Parameter()]
        [System.UInt32]
        $UniquePermissionThreshold,

        [Parameter()]
        [System.Boolean]
        $RequestThrottling,

        [Parameter()]
        [System.Boolean]
        $ChangeLogEnabled,

        [Parameter()]
        [System.UInt32]
        $ChangeLogExpiryDays,

        [Parameter()]
        [System.Boolean]
        $EventHandlersEnabled,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing web application '$WebAppUrl' throttling settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    $relPath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.Throttling.psm1"
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath $relPath -Resolve)
    return Test-SPDSCWebApplicationThrottlingConfig -CurrentSettings $CurrentValues `
                                                    -DesiredSettings $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
