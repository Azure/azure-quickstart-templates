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
        [System.Boolean]
        $ExternalWorkflowParticipantsEnabled,

        [Parameter()]
        [System.Boolean]
        $UserDefinedWorkflowsEnabled,

        [Parameter()]
        [System.Boolean]
        $EmailToNoPermissionWorkflowParticipantsEnable,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$WebAppUrl' workflow settings"

    $paramArgs = @($PSBoundParameters,$PSScriptRoot)
    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $paramArgs -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]


        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return $null
        }

        $relPath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.Workflow.psm1"
        Import-Module (Join-Path $ScriptRoot $relPath -Resolve)

        $result = Get-SPDSCWebApplicationWorkflowConfig -WebApplication $wa
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
        [System.Boolean]
        $ExternalWorkflowParticipantsEnabled,

        [Parameter()]
        [System.Boolean]
        $UserDefinedWorkflowsEnabled,

        [Parameter()]
        [System.Boolean]
        $EmailToNoPermissionWorkflowParticipantsEnable,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$WebAppUrl' workflow settings"

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

        $relpath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.Workflow.psm1"
        Import-Module (Join-Path $ScriptRoot $relPath -Resolve)
        Set-SPDSCWebApplicationWorkflowConfig -WebApplication $wa -Settings $params
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
        [System.Boolean]
        $ExternalWorkflowParticipantsEnabled,

        [Parameter()]
        [System.Boolean]
        $UserDefinedWorkflowsEnabled,

        [Parameter()]
        [System.Boolean]
        $EmailToNoPermissionWorkflowParticipantsEnable,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing web application '$WebAppUrl' workflow settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues) { return $false }

    $relPath = "..\..\Modules\SharePointDsc.WebApplication\SPWebApplication.Workflow.psm1"
        Import-Module (Join-Path $PSScriptRoot $relPath -Resolve)
    return Test-SPDSCWebApplicationWorkflowConfig -CurrentSettings $CurrentValues `
                                                  -DesiredSettings $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
