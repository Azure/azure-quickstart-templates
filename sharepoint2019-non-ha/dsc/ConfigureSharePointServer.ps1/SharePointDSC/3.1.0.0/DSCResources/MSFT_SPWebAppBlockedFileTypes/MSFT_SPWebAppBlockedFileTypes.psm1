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
        [System.String[]]
        $Blocked,

        [Parameter()]
        [System.String[]]
        $EnsureBlocked,

        [Parameter()]
        [System.String[]]
        $EnsureAllowed,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$WebAppUrl' blocked file types"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters,$PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return $null
        }

        $modulePath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.BlockedFileTypes.psm1"
        Import-Module -Name (Join-Path -Path $ScriptRoot -ChildPath $modulePath -Resolve)

        $result = Get-SPDSCWebApplicationBlockedFileTypeConfig -WebApplication $wa
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
        [System.String[]]
        $Blocked,

        [Parameter()]
        [System.String[]]
        $EnsureBlocked,

        [Parameter()]
        [System.String[]]
        $EnsureAllowed,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$WebAppUrl' blocked file types"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters,$PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            throw "Web application $($params.WebAppUrl) was not found"
            return
        }

        $modulePath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.BlockedFileTypes.psm1"
        Import-Module -Name (Join-Path -Path $ScriptRoot -ChildPath $modulePath -Resolve)

        Set-SPDSCWebApplicationBlockedFileTypeConfig -WebApplication $wa -Settings $params
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
        [System.String[]]
        $Blocked,

        [Parameter()]
        [System.String[]]
        $EnsureBlocked,

        [Parameter()]
        [System.String[]]
        $EnsureAllowed,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing for web application '$WebAppUrl' blocked file types"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    $modulePath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.BlockedFileTypes.psm1"
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath $modulePath -Resolve)

    return Test-SPDSCWebApplicationBlockedFileTypeConfig -CurrentSettings $CurrentValues `
                                                         -DesiredSettings $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
