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
        [ValidateSet("Present","Absent")] 
        $Ensure = "Present",

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxies,

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxiesToInclude,

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxiesToExclude,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
 
    Write-Verbose -Message "Getting Service Application Proxy Group $Name"

    if (($Ensure -eq "Present") `
        -and $ServiceAppProxies `
        -and (($ServiceAppProxiesToInclude) -or ($ServiceAppProxiesToExclude))) 
    {
        Write-Verbose -Message ("Cannot use the ServiceAppProxies parameter together " + `
                                "with the ServiceAppProxiesToInclude or " + `
                                "ServiceAppProxiesToExclude parameters")
        return $null
    }
    
    if (($Ensure -eq "Present") `
        -and !$ServiceAppProxies `
        -and !$ServiceAppProxiesToInclude `
        -and !$ServiceAppProxiesToExclude) 
    {
        Write-Verbose -Message ("At least one of the following parameters must be specified: " + `
                                "ServiceAppProxies, ServiceAppProxiesToInclude, " + `
                                "ServiceAppProxiesToExclude")
        return $null  
    }
       
    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]
    
            #Try to get the proxy group
            if ($params.Name -eq "Default")
            {
                $ProxyGroup = Get-SPServiceApplicationProxyGroup -Default
            }
            else
            {
                $ProxyGroup = Get-SPServiceApplicationProxyGroup $params.name -ErrorAction SilentlyContinue 
            }
            
            if ($ProxyGroup)
            {
                $Ensure = "Present"
            }
            else
            {
                $Ensure = "Absent"    
            }
            
            $ServiceAppProxies = $ProxyGroup.Proxies.DisplayName
            
            return @{
                Name = $params.name
                Ensure = $Ensure
                ServiceAppProxies = $ServiceAppProxies 
                ServiceAppProxiesToInclude = $param.ServiceAppProxiesToInclude
                ServiceAppProxiesToExclude = $param.ServiceAppProxiesToExclude
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
        $Name,

        [Parameter()]
        [System.String]
        [ValidateSet("Present","Absent")] 
        $Ensure = "Present",

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxies,

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxiesToInclude,

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxiesToExclude,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
 
    Write-Verbose -Message "Setting Service Application Proxy Group $Name"
    
    if (($Ensure -eq "Present") `
        -and $ServiceAppProxies `
        -and (($ServiceAppProxiesToInclude) -or ($ServiceAppProxiesToExclude))) 
    {
        throw ("Cannot use the ServiceAppProxies parameter together " + `
               "with the ServiceAppProxiesToInclude or " + `
               "ServiceAppProxiesToExclude parameters")
    }
    
    if (($Ensure -eq "Present") `
        -and !$ServiceAppProxies `
        -and !$ServiceAppProxiesToInclude `
        -and !$ServiceAppProxiesToExclude) 
    {
        throw ("At least one of the following parameters must be specified: " + `
               "ServiceAppProxies, ServiceAppProxiesToInclude, " + `
               "ServiceAppProxiesToExclude")  
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        
        if ($params.Ensure -eq "Present")
        {
            if ($params.Name -eq "Default") 
            {
                $ProxyGroup = Get-SPServiceApplicationProxyGroup -Default
            } 
            else 
            {
                $ProxyGroup = Get-SPServiceApplicationProxyGroup -Identity $params.Name `
                                                                 -ErrorAction SilentlyContinue 
            }   
            
            if (!($ProxyGroup)) 
            {
                Write-Verbose -Message "Creating new Service Application Proxy Group $($params.Name)"
                $ProxyGroup = New-SPServiceApplicationProxyGroup -Name $params.Name
            }
            #Explicit Service Applications
            if ($params.ServiceAppProxies) 
            {
                if ($ProxyGroup.Proxies.DisplayName) 
                {
                    $differences = Compare-Object -ReferenceObject $ProxyGroup.Proxies.DisplayName `
                                                  -DifferenceObject $params.ServiceAppProxies
                
                    if ($null -eq $Differences) 
                    {
                        Write-Verbose -Message ("Service Proxy Group $($params.name) " + `
                                                "membership matches desired state")
                    }
                    else 
                    {
                        foreach ($difference in $differences) 
                        {
                            if ($difference.SideIndicator -eq "=>") 
                            {
                                $ServiceProxyName = $difference.InputObject
                                $ServiceProxy = Get-SPServiceApplicationProxy | `
                                    Where-Object -FilterScript {
                                        $_.DisplayName -eq $ServiceProxyName
                                    }
                            
                                if (!$ServiceProxy) 
                                {
                                    throw "Invalid Service Application Proxy $ServiceProxyName"
                                }
                            
                                Write-Verbose -Message "Adding $ServiceProxyName to $($params.name) Proxy Group"
                                $ProxyGroup | Add-SPServiceApplicationProxyGroupMember -Member $ServiceProxy
                            
                            } 
                            elseif ($difference.SideIndicator -eq "<=") 
                            {
                                $ServiceProxyName = $difference.InputObject
                                $ServiceProxy = Get-SPServiceApplicationProxy | `
                                    Where-Object -FilterScript {
                                        $_.DisplayName -eq $ServiceProxyName
                                    }
                            
                                if (!$ServiceProxy) 
                                {
                                    throw "Invalid Service Application Proxy $ServiceProxyName"
                                }
                            
                                Write-Verbose -Message "Removing $ServiceProxyName from $($params.name) Proxy Group"
                                $ProxyGroup | Remove-SPServiceApplicationProxyGroupMember -member $ServiceProxy                            
                            }
                        }
                    }
                }
                else 
                {
                    foreach ($ServiceProxyName in $params.ServiceAppProxies) 
                    {
                        $ServiceProxy = Get-SPServiceApplicationProxy | Where-Object -FilterScript {
                            $_.DisplayName -eq $ServiceProxyName
                        }
                            
                        if (!$ServiceProxy) 
                        {
                            throw "Invalid Service Application Proxy $ServiceProxyName"
                        }
                            
                        Write-Verbose -Message "Adding $ServiceProxyName to $($params.name) Proxy Group"
                        $ProxyGroup | Add-SPServiceApplicationProxyGroupMember -member $ServiceProxy
                    }
                }
            }
            
            if ($params.ServiceAppProxiesToInclude) 
            {
                if ($ProxyGroup.Proxies.DisplayName) 
                {
                    $differences = Compare-Object -ReferenceObject $ProxyGroup.Proxies.DisplayName `
                                                  -DifferenceObject $params.ServiceAppProxiesToInclude 
                    
                    if ($null -eq $Differences) 
                    {
                        Write-Verbose -Message "Service Proxy Group $($params.name) Membership matches desired state"
                    }
                    else 
                    {
                        foreach ($difference in $differences) 
                        {
                            if ($difference.SideIndicator -eq "=>") 
                            {
                                $ServiceProxyName = $difference.InputObject
                                $ServiceProxy = Get-SPServiceApplicationProxy | `
                                    Where-Object -FilterScript {
                                        $_.DisplayName -eq $ServiceProxyName
                                    }
                                
                                if (!$ServiceProxy) 
                                {
                                    throw "Invalid Service Application Proxy $ServiceProxyName"
                                }
                                
                                Write-Verbose -Message "Adding $ServiceProxyName to $($params.name) Proxy Group"
                                $ProxyGroup | Add-SPServiceApplicationProxyGroupMember -member $ServiceProxy
                                
                            }
                        }
                    }
                }
                else 
                {
                    foreach ($ServiceProxyName in $params.ServiceAppProxies) 
                    {
                        $ServiceProxy = Get-SPServiceApplicationProxy | `
                            Where-Object -FilterScript {
                                $_.DisplayName -eq $ServiceProxyName
                            }
                            
                        if (!$ServiceProxy) 
                        {
                            throw "Invalid Service Application Proxy $ServiceProxyName"
                        }
                            
                        Write-Verbose "Adding $ServiceProxyName to $($params.name) Proxy Group"
                        $ProxyGroup | Add-SPServiceApplicationProxyGroupMember -member $ServiceProxy
                    }
                }
            }
            
            if ($params.ServiceAppProxiesToExclude) 
            {
                if ($ProxyGroup.Proxies.Displayname) 
                {
                    $differences = Compare-Object -ReferenceObject $ProxyGroup.Proxies.DisplayName `
                                                  -DifferenceObject $params.ServiceAppProxiesToExclude `
                                                  -IncludeEqual
                    
                    if ($null -eq $Differences) 
                    {
                        throw "Error comparing ServiceAppProxiesToExclude for Service Proxy Group $($params.name)"
                    }
                    else 
                    {
                        foreach ($difference in $differences) 
                        {
                            if ($difference.SideIndicator -eq "==") 
                            {
                                $ServiceProxyName = $difference.InputObject
                                $ServiceProxy = Get-SPServiceApplicationProxy | Where-Object -FilterScript {
                                    $_.DisplayName -eq $ServiceProxyName
                                }
                                
                                if (!$ServiceProxy) 
                                {
                                    throw "Invalid Service Application Proxy $ServiceProxyName"
                                }
                                
                                Write-Verbose -Message "Removing $ServiceProxyName to $($params.name) Proxy Group"
                                $ProxyGroup | Remove-SPServiceApplicationProxyGroupMember -member $ServiceProxy                                
                            }
                        }
                    }
                } 
            }
        }
        else 
        {
            Write-Verbose "Removing $($params.name) Proxy Group"
            $ProxyGroup | Remove-SPServiceApplicationProxyGroup -confirm:$false
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
        [ValidateSet("Present","Absent")] 
        $Ensure = "Present",

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxies,

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxiesToInclude,

        [Parameter()] 
        [System.String[]] 
        $ServiceAppProxiesToExclude,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
 
    Write-Verbose -Message "Testing Service Application Proxy Group $Name"
    
    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues) 
    {
        return $false 
    }
    
    if ($CurrentValues.Ensure -ne $Ensure) 
    {
        return $false
    }
    
    if ($ServiceAppProxies)
    {
        Write-Verbose -Message "Testing ServiceAppProxies property for $Name Proxy Group"
        
        if (-not $CurrentValues.ServiceAppProxies) 
        {
            return $false 
        }
        
        $differences = Compare-Object -ReferenceObject $CurrentValues.ServiceAppProxies `
                                      -DifferenceObject $ServiceAppProxies

        if ($null -eq $differences) 
        {
            Write-Verbose -Message "ServiceAppProxies match"
        } 
        else 
        {
            Write-Verbose -Message "ServiceAppProxies do not match"
            return $false
        }   
    }
    
    if ($ServiceAppProxiesToInclude)
    {
        Write-Verbose -Message "Testing ServiceAppProxiesToInclude property for $Name Proxy Group"
        
        if (-not $CurrentValues.ServiceAppProxies) 
        {
            return $false 
        }
        
        $differences = Compare-Object -ReferenceObject $CurrentValues.ServiceAppProxies `
                                      -DifferenceObject $ServiceAppProxiesToInclude

        if ($null -eq $differences) 
        {
            Write-Verbose -Message "ServiceAppProxiesToInclude matches"
        } 
        elseif ($differences.sideindicator -contains "=>") 
        {
            Write-Verbose -Message "ServiceAppProxiesToInclude does not match"
            return $false
        }
    }
    
    if ($ServiceAppProxiesToExclude)
    {
        Write-Verbose -Message "Testing ServiceAppProxiesToExclude property for $Name Proxy Group"
        
        if (-not $CurrentValues.ServiceAppProxies) 
        {
            return $true 
        }
        
        $differences = Compare-Object -ReferenceObject $CurrentValues.ServiceAppProxies `
                                      -DifferenceObject $ServiceAppProxiesToExclude `
                                      -IncludeEqual

        if ($null -eq $differences) 
        {
           return $false
        } 
        elseif ($differences.sideindicator -contains "==") 
        {
            Write-Verbose -Message "ServiceAppProxiesToExclude does not match"
            return $false
        }   
    }
    
    return $true 
}
