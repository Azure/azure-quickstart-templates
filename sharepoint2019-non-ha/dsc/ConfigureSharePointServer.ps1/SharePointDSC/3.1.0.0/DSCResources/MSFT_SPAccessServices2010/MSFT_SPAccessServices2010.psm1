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
        
        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Access 2010 Service app '$Name'"
    
    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            Ensure = "Absent"
        }
        if($null -eq $serviceApps) 
        {
            return $nullReturn
        }
    
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.Office.Access.Server.MossHost.AccessServerWebServiceApplication"
        }
    
        if($null -eq $serviceApp)
        {
            return $nullReturn
        }
        else 
        {
            return @{
                Name = $serviceApp.DisplayName
                ApplicationPool = $serviceApp.ApplicationPool.Name
                Ensure = "Present"
                InstallAccount = $params.InstallAccount
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
    
        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",
    
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Access 2010 Services app '$Name'"
    $result = Get-TargetResource @PSBoundParameters
    
    if($result.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        Write-Verbose "Creating Access 2010 Service Application '$Name'"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            $accessApp = New-SPAccessServiceApplication -Name $params.Name `
                                                        -ApplicationPool $params.ApplicationPool       
        }
    }
    if($result.Ensure -eq "Present" -and $Ensure -eq "Present") 
    {
        Write-Verbose "Updating Access 2010 service application '$Name'"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
             $params = $args[0]
             $apps = Get-SPServiceApplication -Name $params.Name `
                                              -ErrorAction SilentlyContinue
             if($null -ne $apps)
             {
                $app = $apps | Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.Office.Access.Server.MossHost.AccessServerWebServiceApplication"
                }
                if($null -ne $app)
                {
                    $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool   
                    if($null -ne $appPool)
                    {
                        $app.ApplicationPool = $appPool
                        $app.Update()
                        return;
                    }
                }
             }
    
             $accessApp = New-SPAccessServiceApplication -Name $params.Name `
                                                         -ApplicationPool $params.ApplicationPool                    
        }
    }
    if($Ensure -eq "Absent")
    {
        Write-Verbose "Removing Access 2010 service application '$Name'"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $apps = Get-SPServiceApplication -Name $params.Name `
                                             -ErrorAction SilentlyContinue
            if($null -eq $apps)
            {
                return
            }

            $app = $apps | Where-Object -FilterScript {
                   $_.GetType().FullName -eq "Microsoft.Office.Access.Server.MossHost.AccessServerWebServiceApplication"
            }
        
            if($null -ne $app)
            {
                Remove-SPServiceApplication -Identity $app -Confirm:$false
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
        
        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )
    Write-Verbose -Message "Testing Access 2010 service app '$Name'"
    
    $PSBoundParameters.Ensure = $Ensure
    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Name", "ApplicationPool", "Ensure")
}

Export-ModuleMember -Function *-TargetResource
