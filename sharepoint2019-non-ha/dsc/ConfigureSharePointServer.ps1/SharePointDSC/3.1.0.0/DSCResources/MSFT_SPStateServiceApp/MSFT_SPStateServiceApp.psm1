function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DatabaseCredentials,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting state service application '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApp = Get-SPStateServiceApplication -Identity $params.Name `
                                                    -ErrorAction SilentlyContinue

        if ($null -eq $serviceApp)
        {
            return @{
                Name = $params.Name
                DatabaseName = $params.DatabaseName
                Ensure = "Absent"
                InstallAccount = $params.InstallAccount
            }
        }

        $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue
        if ($null -ne $serviceAppProxies)
        {
            $serviceAppProxy = $serviceAppProxies | Where-Object -FilterScript {
                $serviceApp.IsConnected($_)
            }
            if ($null -ne $serviceAppProxy)
            {
                $proxyName = $serviceAppProxy.Name
            }
        }

        return @{
            Name = $serviceApp.DisplayName
            ProxyName = $proxyName
            DatabaseName = $serviceApp.Databases.Name
            DatabaseServer = $serviceApp.Databases.NormalizedDataSource
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

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DatabaseCredentials,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount

    )

    Write-Verbose -Message "Setting state service application '$Name'"

    if ($Ensure -eq "Present")
    {
        Write-Verbose -Message "Creating State Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {

            $params = $args[0]

            $dbParams = @{}

            if ($params.ContainsKey("DatabaseName"))
            {
                $dbParams.Add("Name", $params.DatabaseName)
            }
            if ($params.ContainsKey("DatabaseServer"))
            {
                $dbParams.Add("DatabaseServer", $params.DatabaseServer)
            }
            if ($params.ContainsKey("DatabaseCredentials"))
            {
                $dbParams.Add("DatabaseCredentials", $params.DatabaseCredentials)
            }

            if ($params.ContainsKey("ProxyName"))
            {
                $pName = $params.ProxyName
            }
            if ($null -eq $pName)
            {
                $pName = "$($params.Name) Proxy"
            }

            $database = New-SPStateServiceDatabase @dbParams
            $app = New-SPStateServiceApplication -Name $params.Name -Database $database
            New-SPStateServiceApplicationProxy -Name $pName `
                                               -ServiceApplication $app `
                                               -DefaultProxyGroup | Out-Null
        }
    }
    if ($Ensure -eq "Absent")
    {
        Write-Verbose -Message "Removing State Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]

            $serviceApp =  Get-SPStateServiceApplication -Name $params.Name

            # Remove the connected proxy(ies)
            $proxies = Get-SPServiceApplicationProxy
            foreach($proxyInstance in $proxies)
            {
                if($serviceApp.IsConnected($proxyInstance))
                {
                    $proxyInstance.Delete()
                }
            }

            Remove-SPServiceApplication $serviceApp -Confirm:$false
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

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DatabaseCredentials,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing for state service application $Name"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Name", "Ensure")
}

Export-ModuleMember -Function *-TargetResource
