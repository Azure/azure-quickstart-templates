function Get-SPDSCWebApplicationWorkflowConfig
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        $WebApplication
    )
    return @{
        ExternalWorkflowParticipantsEnabled = `
            $WebApplication.ExternalWorkflowParticipantsEnabled
        UserDefinedWorkflowsEnabled = `
            $WebApplication.UserDefinedWorkflowsEnabled
        EmailToNoPermissionWorkflowParticipantsEnable = `
            $WebApplication.EmailToNoPermissionWorkflowParticipantsEnabled
    }
}

function Set-SPDSCWebApplicationWorkflowConfig
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $WebApplication,

        [Parameter(Mandatory = $true)]
        $Settings
    )
    if ($Settings.ContainsKey("UserDefinedWorkflowsEnabled") -eq $true)
    {
        $WebApplication.UserDefinedWorkflowsEnabled = `
            $Settings.UserDefinedWorkflowsEnabled;
    }
    if ($Settings.ContainsKey("EmailToNoPermissionWorkflowParticipantsEnable") -eq $true)
    {
        $WebApplication.EmailToNoPermissionWorkflowParticipantsEnabled = `
            $Settings.EmailToNoPermissionWorkflowParticipantsEnable;
    }
    if ($Settings.ContainsKey("ExternalWorkflowParticipantsEnabled") -eq $true)
    {
        $WebApplication.ExternalWorkflowParticipantsEnabled = `
            $Settings.ExternalWorkflowParticipantsEnabled;
    }
    $WebApplication.UpdateWorkflowConfigurationSettings();
}

function Test-SPDSCWebApplicationWorkflowConfig {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        $CurrentSettings,

        [Parameter(Mandatory = $true)]
        $DesiredSettings
    )

    $relPath = "..\..\Modules\SharePointDsc.Util\SharePointDsc.Util.psm1"
    Import-Module (Join-Path $PSScriptRoot $relPath -Resolve)
    $valuesTocheck = @("UserDefinedWorkflowsEnabled",
                       "EmailToNoPermissionWorkflowParticipantsEnable",
                       "ExternalWorkflowParticipantsEnabled")
    $testReturn = Test-SPDscParameterState -CurrentValues $CurrentSettings `
                                           -DesiredValues $DesiredSettings `
                                           -ValuesToCheck $valuesTocheck
    return $testReturn
}

