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
        $DatabaseServer,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting Access Services service app '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            DatabaseServer = $params.DatabaseServer
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        } 
        if ($null -eq $serviceApps) 
        {
            return $nullReturn 
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.Office.Access.Services.MossHost.AccessServicesWebServiceApplication"            
        }

        if ($null -eq $serviceApp) 
        {
            return $nullReturn 
        } 
        else 
        {
            ### Find database server name
            $context = [Microsoft.SharePoint.SPServiceContext]::GetContext($serviceApp.ServiceApplicationProxyGroup, [Microsoft.SharePoint.SPSiteSubscriptionIdentifier]::Default)
            $dbserver = (Get-SPAccessServicesDatabaseServer $context).ServerName
            return @{
                Name = $serviceApp.DisplayName
                DatabaseServer = $dbserver
                ApplicationPool = $serviceApp.ApplicationPool.Name
                Ensure = "Present"
            }
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
        $DatabaseServer,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting Access Services service app '$Name'"

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Creating Access Services Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {

            $params = $args[0]

            $app = New-SPAccessServicesApplication -Name $params.Name `
                                                   -ApplicationPool $params.ApplicationPool `
                                                   -Default `
                                                   -DatabaseServer $params.DatabaseServer
                                                   
            $app | New-SPAccessServicesApplicationProxy | Out-Null
        }
    }
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing Access Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {

            $params = $args[0]
            
            $app = Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.Office.Access.Services.MossHost.AccessServicesWebServiceApplication"
            }

            $proxies = Get-SPServiceApplicationProxy
            foreach($proxyInstance in $proxies)
            {
                if($app.IsConnected($proxyInstance))
                {
                    $proxyInstance.Delete()
                }
            }

            Remove-SPServiceApplication -Identity $app -Confirm:$false
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
        $DatabaseServer,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
    
    Write-Verbose -Message "Testing for Access Service Application '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($CurrentValues.DatabaseServer -ne $DatabaseServer)
    {
        Write-Verbose -Message ("Specified database server does not match the actual " + `
                                "database server. This resource cannot move the database " + `
                                "to a different SQL instance.")
        return $false
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
