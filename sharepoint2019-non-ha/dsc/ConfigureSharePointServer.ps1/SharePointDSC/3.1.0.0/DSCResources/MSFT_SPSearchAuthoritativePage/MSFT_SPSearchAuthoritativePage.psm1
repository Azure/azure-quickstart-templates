function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateRange(0.0, 2.0)]
        [System.Single]
        $Level,

        [Parameter()]
        [ValidateSet("Authoratative","Demoted")]
        [System.String]
        $Action,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

     Write-Verbose -Message "Getting Authoratative Page Setting for '$Path'"

     $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $nullReturn = @{
            ServiceAppName = $params.ServiceAppName
            Path = ""
            Level = $params.Level
            Action = $params.Action
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        }  

          $serviceApp = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
        if($null -eq $serviceApp)
        {
            return $nullReturn
        }

        $searchObjectLevel = [Microsoft.Office.Server.Search.Administration.SearchObjectLevel]::Ssa
        $searchOwner = New-Object -TypeName "Microsoft.Office.Server.Search.Administration.SearchObjectOwner" -ArgumentList $searchObjectLevel

        if($params.Action -eq "Authoratative")
        {
            $queryAuthority = Get-SPEnterpriseSearchQueryAuthority -Identity $params.Path `
                                                                   -Owner $searchOwner `
                                                                   -SearchApplication $serviceApp `
                                                                   -ErrorAction SilentlyContinue
            if($null -eq $queryAuthority)
            {
                return $nullReturn
            }
            else 
            {
                
                return @{
                    ServiceAppName = $params.ServiceAppName
                    Path = $params.Path
                    Level = $queryAuthority.Level
                    Action = $params.Action
                    Ensure = "Present"
                    InstallAccount = $params.InstallAccount
                }
            }
        }
        else 
        {
            $queryDemoted = $serviceApp | Get-SPEnterpriseSearchQueryDemoted -Identity $params.Path `
                                                                             -Owner $searchOwner `
                                                                             -SearchApplication $serviceApp `
                                                                             -ErrorAction SilentlyContinue
            if($null -eq $queryDemoted)
            {
                return $nullReturn
            }
            else 
            {
                return @{
                    ServiceAppName = $params.ServiceAppName
                    Path = $params.Path
                    Action = $params.Action
                    Ensure = "Present"
                    InstallAccount = $params.InstallAccount
                }
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
        $ServiceAppName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateRange(0.0, 2.0)]
        [System.Single]
        $Level,

        [Parameter()]
        [ValidateSet("Authoratative","Demoted")]
        [System.String]
        $Action,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )
     
     Write-Verbose -Message "Setting Authoratative Page Settings for '$Path'"

    $CurrentResults = Get-TargetResource @PSBoundParameters

    if($CurrentResults.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                    -Arguments $PSBoundParameters `
                                    -ScriptBlock {
            $params = $args[0]

            $serviceApp = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
            $searchObjectLevel = [Microsoft.Office.Server.Search.Administration.SearchObjectLevel]::Ssa
            $searchOwner = New-Object -TypeName "Microsoft.Office.Server.Search.Administration.SearchObjectOwner" -ArgumentList $searchObjectLevel
            
            if($null -eq $serviceApp)
            {
                throw "Search Service App was not available."
            }
            if($params.Action -eq "Authoratative")
            {
                 New-SPEnterpriseSearchQueryAuthority -Url $params.Path `
                                                      -SearchApplication $serviceApp `
                                                      -Owner $searchOwner `
                                                      -Level $params.Level
            }
            else 
            {
                New-SPEnterpriseSearchQueryDemoted -Url $params.Path -SearchApplication $serviceApp -Owner $searchOwner
            }
        }
    }
    if($CurrentResults.Ensure -eq "Present" -and $Ensure -eq "Present") 
    {
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                    -Arguments $PSBoundParameters `
                                    -ScriptBlock {
            $params = $args[0]

            $serviceApp = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
            $searchObjectLevel = [Microsoft.Office.Server.Search.Administration.SearchObjectLevel]::Ssa
            $searchOwner = New-Object -TypeName "Microsoft.Office.Server.Search.Administration.SearchObjectOwner" -ArgumentList $searchObjectLevel

            if($null -eq $serviceApp)
            {
                throw "Search Service App was not available."
            }

            if($params.Action -eq "Authoratative")
            {
                Set-SPEnterpriseSearchQueryAuthority -Identity $params.ServiceAppName `
                                                     -SearchApplication $ssa `
                                                     -Owner $searchOwner `
                                                     -Level $params.Level
            }
        }
    }
    if($Ensure -eq "Absent")
    {
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                    -Arguments $PSBoundParameters `
                                    -ScriptBlock {
            $params = $args[0]

            $serviceApp = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
            $searchObjectLevel = [Microsoft.Office.Server.Search.Administration.SearchObjectLevel]::Ssa
            $searchOwner = New-Object -TypeName "Microsoft.Office.Server.Search.Administration.SearchObjectOwner" -ArgumentList $searchObjectLevel

            if($null -eq $serviceApp)
            {
                throw "Search Service App was not available."
            }
            if($params.Action -eq "Authoratative")
            {
                Remove-SPEnterpriseSearchQueryAuthority -Identity $params.ServiceAppName `
                                                        -SearchApplication $ssa `
                                                        -Owner $searchOwner `
                                                        -ErrorAction SilentlyContinue
            }
            else 
            {
                Remove-SPEnterpriseSearchQueryDemoted -Identity $params.ServiceAppName `
                                                      -SearchApplication $ssa `
                                                      -Owner $searchOwner `
                                                      -ErrorAction SilentlyContinue
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
        $ServiceAppName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,
        
        [Parameter()]
        [ValidateRange(0.0, 2.0)]
        [System.Single]
        $Level,

        [Parameter()]
        [ValidateSet("Authoratative","Demoted")]
        [System.String]
        $Action,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Authoratative Page Settings '$Path'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters
    if ($Ensure -eq "Present")
    {
        if ($Action -eq "Authoratative")
        {
            return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("ServiceAppName",
                                                         "Path",
                                                         "Level",
                                                         "Action", 
                                                         "Ensure")
        }
        else
        {
            return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("ServiceAppName",
                                                         "Path",
                                                         "Action", 
                                                         "Ensure")
        }
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("ServiceAppName",
                                                         "Action", 
                                                         "Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource

