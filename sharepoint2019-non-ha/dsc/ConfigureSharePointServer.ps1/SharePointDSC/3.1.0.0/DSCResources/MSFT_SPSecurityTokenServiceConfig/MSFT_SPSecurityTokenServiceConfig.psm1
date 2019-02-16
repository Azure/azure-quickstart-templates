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
        $Name,

        [Parameter()]
        [System.String]
        $NameIdentifier,

        [Parameter()]
        [System.Boolean]
        $UseSessionCookies = $false,

        [Parameter()]
        [System.Boolean]
        $AllowOAuthOverHttp = $false,

        [Parameter()]
        [System.Boolean]
        $AllowMetadataOverHttp = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Getting Security Token Service Configuration"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $config = Get-SPSecurityTokenServiceConfig
        $nullReturn = @{
            IsSingleInstance = "Yes"
            Name = $params.Name
            NameIdentifier = $params.NameIdentifier
            UseSessionCookies = $params.UseSessionCookies
            AllowOAuthOverHttp = $params.AllowOAuthOverHttp
            AllowMetadataOverHttp = $params.AllowMetadataOverHttp
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        }
        if ($null -eq $config)
        {
            return $nullReturn
        }

        return @{
            IsSingleInstance = "Yes"
            Name = $config.Name
            NameIdentifier = $config.NameIdentifier
            UseSessionCookies = $config.UseSessionCookies
            AllowOAuthOverHttp = $config.AllowOAuthOverHttp
            AllowMetadataOverHttp = $config.AllowMetadataOverHttp
            Ensure = "Present"
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
        $Name,

        [Parameter()]
        [System.String]
        $NameIdentifier,

        [Parameter()]
        [System.Boolean]
        $UseSessionCookies = $false,

        [Parameter()]
        [System.Boolean]
        $AllowOAuthOverHttp = $false,

        [Parameter()]
        [System.Boolean]
        $AllowMetadataOverHttp = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting Security Token Service Configuration"

    if($Ensure -eq "Absent")
    {
        throw "This resource cannot undo Security Token Service Configuration changes. `
        Please set Ensure to Present or omit the resource"
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        $config = Get-SPSecurityTokenServiceConfig
        $config.Name = $params.Name

        if($params.ContainsKey("NameIdentifier"))
        {
            $config.NameIdentifier = $params.NameIdentifier
        }

        if($params.ContainsKey("UseSessionCookies"))
        {
            $config.UseSessionCookies = $params.UseSessionCookies
        }

        if($params.ContainsKey("AllowOAuthOverHttp"))
        {
            $config.AllowOAuthOverHttp = $params.AllowOAuthOverHttp
        }

        if($params.ContainsKey("AllowMetadataOverHttp"))
        {
            $config.AllowMetadataOverHttp = $params.AllowMetadataOverHttp
        }

        $config.Update()
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
        $Name,

        [Parameter()]
        [System.String]
        $NameIdentifier,

        [Parameter()]
        [System.Boolean]
        $UseSessionCookies = $false,

        [Parameter()]
        [System.Boolean]
        $AllowOAuthOverHttp = $false,

        [Parameter()]
        [System.Boolean]
        $AllowMetadataOverHttp = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing the Security Token Service Configuration"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure",
                                                     "NameIdentifier",
                                                     "UseSessionCookies",
                                                     "AllowOAuthOverHttp",
                                                     "AllowMetadataOverHttp")
}

Export-ModuleMember -Function *-TargetResource
