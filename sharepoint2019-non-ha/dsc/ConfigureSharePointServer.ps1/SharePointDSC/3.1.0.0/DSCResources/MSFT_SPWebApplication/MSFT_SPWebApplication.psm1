function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPoolAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $AllowAnonymous,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

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
        $UseClassic = $false,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$Name' config"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.Name -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return @{
                Name = $params.Name
                ApplicationPool = $params.ApplicationPool
                ApplicationPoolAccount = $params.ApplicationPoolAccount
                WebAppUrl = $params.WebAppUrl
                Ensure = "Absent"
            }
        }

        ### COMMENT: Are we making an assumption here, about Default Zone
        $classicAuth = $false
        $authProvider = Get-SPAuthenticationProvider -WebApplication $wa.Url -Zone "Default"
        if ($null -eq $authProvider)
        {
            $classicAuth = $true
        }

        return @{
            Name = $wa.DisplayName
            ApplicationPool = $wa.ApplicationPool.Name
            ApplicationPoolAccount = $wa.ApplicationPool.Username
            WebAppUrl = $wa.Url
            AllowAnonymous = $authProvider.AllowAnonymous
            DatabaseName = $wa.ContentDatabases[0].Name
            DatabaseServer = $wa.ContentDatabases[0].Server
            HostHeader = (New-Object -TypeName System.Uri $wa.Url).Host
            Path = $wa.IisSettings[0].Path
            Port = (New-Object -TypeName System.Uri $wa.Url).Port
            UseClassic = $classicAuth
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPoolAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $AllowAnonymous,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

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
        $UseClassic = $false,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$Name' config"

    $PSBoundParameters.UseClassic = $UseClassic

    if ($Ensure -eq "Present")
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $wa = Get-SPWebApplication -Identity $params.Name -ErrorAction SilentlyContinue
            if ($null -eq $wa)
            {
                $newWebAppParams = @{
                    Name = $params.Name
                    ApplicationPool = $params.ApplicationPool
                    Url = $params.WebAppUrl
                }

                # Get a reference to the Administration WebService
                $admService = Get-SPDSCContentService
                $appPools = $admService.ApplicationPools | Where-Object -FilterScript {
                    $_.Name -eq $params.ApplicationPool
                }
                if ($null -eq $appPools)
                {
                    # Application pool does not exist, create a new one.
                    # Test if the specified managed account exists. If so, add
                    # ApplicationPoolAccount parameter to create the application pool
                    try
                    {
                        Get-SPManagedAccount $params.ApplicationPoolAccount -ErrorAction Stop | Out-Null
                        $newWebAppParams.Add("ApplicationPoolAccount", $params.ApplicationPoolAccount)
                    }
                    catch
                    {
                        if ($_.Exception.Message -like "*No matching accounts were found*")
                        {
                            throw ("The specified managed account was not found. Please make " + `
                                   "sure the managed account exists before continuing.")
                            return
                        }
                        else
                        {
                            throw ("Error occurred. Web application was not created. Error " + `
                                   "details: $($_.Exception.Message)")
                            return
                        }
                    }
                }

                if ($params.UseClassic -eq $false)
                {
                    $ap = New-SPAuthenticationProvider
                    $newWebAppParams.Add("AuthenticationProvider", $ap)
                }

                if ($params.ContainsKey("AllowAnonymous") -eq $true)
                {
                    $newWebAppParams.Add("AllowAnonymousAccess", $params.AllowAnonymous)
                }
                if ($params.ContainsKey("DatabaseName") -eq $true)
                {
                    $newWebAppParams.Add("DatabaseName", $params.DatabaseName)
                }
                if ($params.ContainsKey("DatabaseServer") -eq $true)
                {
                    $newWebAppParams.Add("DatabaseServer", $params.DatabaseServer)
                }
                if ($params.ContainsKey("HostHeader") -eq $true)
                {
                    $newWebAppParams.Add("HostHeader", $params.HostHeader)
                }
                if ($params.ContainsKey("Path") -eq $true)
                {
                    $newWebAppParams.Add("Path", $params.Path)
                }
                if ($params.ContainsKey("Port") -eq $true)
                {
                    $newWebAppParams.Add("Port", $params.Port)
                }
                if ((New-Object -TypeName System.Uri $params.WebAppUrl).Scheme -eq "https")
                {
                    $newWebAppParams.Add("SecureSocketsLayer", $true)
                }

                New-SPWebApplication @newWebAppParams | Out-Null
            }
        }
    }

    if ($Ensure -eq "Absent")
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $wa = Get-SPWebApplication -Identity $params.Name -ErrorAction SilentlyContinue
            if ($null -ne $wa)
            {
                $wa | Remove-SPWebApplication -Confirm:$false -DeleteIISSite
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPoolAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $AllowAnonymous,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

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
        $UseClassic = $false,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing for web application '$Name' config"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $testReturn = Test-SPDscParameterState -CurrentValues $CurrentValues `
                                                     -DesiredValues $PSBoundParameters `
                                                     -ValuesToCheck @("Ensure")
    return $testReturn
}

Export-ModuleMember -Function *-TargetResource
