function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("SharePoint","ProjectServer")]
        [System.String]
        $PermissionMode,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Project Server permission mode for site '$Url'"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16)
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        try
        {
            $mode = Get-SPProjectPermissionMode -Url $params.Url
        }
        catch
        {
            $mode = "unknown"
        }

        return @{
            Url            = $params.Url
            PermissionMode = $mode
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
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("SharePoint","ProjectServer")]
        [System.String]
        $PermissionMode,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Project Server permission mode for site '$Url'"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16)
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        Set-SPProjectPermissionMode -Url $params.Url -Mode $params.PermissionMode
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
        $Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("SharePoint","ProjectServer")]
        [System.String]
        $PermissionMode,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Project Server permission mode for site '$Url'"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("PermissionMode")

}

Export-ModuleMember -Function *-TargetResource
