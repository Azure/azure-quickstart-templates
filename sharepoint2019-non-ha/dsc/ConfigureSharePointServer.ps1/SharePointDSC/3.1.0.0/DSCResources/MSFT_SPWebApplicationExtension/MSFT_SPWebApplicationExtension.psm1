function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default","Intranet","Internet","Extranet","Custom")]
        [System.String]
        $Zone,

        [Parameter()]
        [System.Boolean]
        $AllowAnonymous,

        [Parameter()]
        [System.String]
        $HostHeader,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $Port,

        [Parameter()]
        [System.Boolean]
        $UseSSL,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application extension '$Name' config"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($null -eq $wa)
        {
            Write-Verbose -Message "WebApplication $($params.WebAppUrl) does not exist"
            return @{
                WebAppUrl = $params.WebAppUrl
                Name = $params.Name
                Url = $null
                Zone = $null
                AllowAnonymous = $null
                Ensure = "Absent"
            }
        }

        $zone = [Microsoft.SharePoint.Administration.SPUrlZone]::$($params.Zone)
        $waExt = $wa.IisSettings[$zone]

        if ($null -eq $waExt)
        {
            return @{
                WebAppUrl = $params.WebAppUrl
                Name = $params.Name
                Url = $params.Url
                Zone = $params.zone
                AllowAnonymous = $params.AllowAnonymous
                Ensure = "Absent"
            }
        }

        $publicUrl = (Get-SPAlternateURL -WebApplication $params.WebAppUrl -Zone $params.zone).PublicUrl

        if ($null -ne $waExt.SecureBindings.HostHeader) #default to SSL bindings if present
        {
            $HostHeader = $waExt.SecureBindings.HostHeader
            $Port = $waExt.SecureBindings.Port
            $UseSSL = $true
        }
        else
        {
            $HostHeader = $waExt.ServerBindings.HostHeader
            $Port = $waExt.ServerBindings.Port
            $UseSSL = $false
        }

         return @{
            WebAppUrl = $params.WebAppUrl
            Name = $waExt.ServerComment
            Url = $PublicURL
            AllowAnonymous = $waExt.AllowAnonymous
            HostHeader = $HostHeader
            Path = $waExt.Path
            Port = $Port
            Zone = $params.zone
            UseSSL = $UseSSL
            InstallAccount = $params.InstallAccount
            Ensure = "Present"
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
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default","Intranet","Internet","Extranet","Custom")]
        [System.String]
        $Zone,

        [Parameter()]
        [System.Boolean]
        $AllowAnonymous,

        [Parameter()]
        [System.String]
        $HostHeader,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $Port,

        [Parameter()]
        [System.Boolean]
        $UseSSL,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application extension '$Name' config"

    if ($Ensure -eq "Present")
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
            if ($null -eq $wa)
            {
                throw "Web Application with URL $($params.WebAppUrl) does not exist"
            }


            $zone = [Microsoft.SharePoint.Administration.SPUrlZone]::$($params.Zone)
            $waExt = $wa.IisSettings[$zone]

            if ($null -eq $waExt)
            {
                $newWebAppExtParams = @{
                    Name = $params.Name
                    Url = $params.Url
                    Zone = $params.zone
                }

                if ($params.ContainsKey("AllowAnonymous") -eq $true)
                {
                    $newWebAppExtParams.Add("AllowAnonymousAccess", $params.AllowAnonymous)
                }
                if ($params.ContainsKey("HostHeader") -eq $true)
                {
                    $newWebAppExtParams.Add("HostHeader", $params.HostHeader)
                }
                if ($params.ContainsKey("Path") -eq $true)
                {
                    $newWebAppExtParams.Add("Path", $params.Path)
                }
                if ($params.ContainsKey("Port") -eq $true)
                {
                    $newWebAppExtParams.Add("Port", $params.Port)
                }
                if ($params.ContainsKey("UseSSL") -eq $true)
                {
                    $newWebAppExtParams.Add("SecureSocketsLayer", $params.UseSSL)
                }

                $wa | New-SPWebApplicationExtension @newWebAppExtParams | Out-Null
            }
            else
            {
                if ($params.ContainsKey("AllowAnonymous") -eq $true)
                {
                    $waExt.AllowAnonymous = $params.AllowAnonymous
                    $wa.update()
                }
            }
        }
    }

    if ($Ensure -eq "Absent")
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
            if ($null -eq $wa)
            {
                throw "Web Application with URL $($params.WebAppUrl) does not exist"
            }
            if ($null -ne $wa)
            {
                $wa | Remove-SPWebApplication -Zone $params.zone -Confirm:$false -DeleteIISSite
            }
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default","Intranet","Internet","Extranet","Custom")]
        [System.String]
        $Zone,

        [Parameter()]
        [System.Boolean]
        $AllowAnonymous,

        [Parameter()]
        [System.String]
        $HostHeader,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $Port,

        [Parameter()]
        [System.Boolean]
        $UseSSL,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing for web application extension '$Name'config"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $testReturn = Test-SPDscParameterState -CurrentValues $CurrentValues `
                                                     -DesiredValues $PSBoundParameters `
                                                     -ValuesToCheck @("Ensure","AllowAnonymous")
    return $testReturn
}

Export-ModuleMember -Function *-TargetResource
