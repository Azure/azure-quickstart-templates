function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ProxyLibraries,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ProxyLibrariesToInclude,

        [Parameter()]
        [System.String[]]
        $ProxyLibrariesToExclude,

        [Parameter()]
        [System.UInt32]
        $MaxResourcesPerRequest,

        [Parameter()]
        [System.UInt32]
        $MaxObjectPaths,

        [Parameter()]
        [System.UInt32]
        $ExecutionTimeout,

        [Parameter()]
        [System.UInt32]
        $RequestXmlMaxDepth,

        [Parameter()]
        [Boolean]
        $EnableXsdValidation,

        [Parameter()]
        [Boolean]
        $EnableStackTrace,

        [Parameter()]
        [System.UInt32]
        $RequestUsageExecutionTimeThreshold,

        [Parameter()]
        [Boolean]
        $EnableRequestUsage,

        [Parameter()]
        [Boolean]
        $LogActionsIfHasRequestException,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$WebAppUrl' client callable settings"

    if ($ProxyLibraries -and (($ProxyLibrariesToInclude) -or ($ProxyLibrariesToExclude)))
    {
        throw ("Cannot use the ProxyLibraries parameter together with the ProxyLibrariesToInclude or " + `
               "ProxyLibrariesToExclude parameters")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters) `
                                  -ScriptBlock {
        $params = $args[0]

        $webApplication = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $webApplication)
        {
            Write-Verbose "Web application $($params.WebAppUrl) was not found"
            return @{
                WebAppUrl = $null
                ProxyLibraries = $null
                ProxyLibrariesToInclude = $null
                ProxyLibrariesToExclude = $null
                MaxResourcesPerRequest = $null
                MaxObjectPaths = $null
                ExecutionTimeout = $null
                RequestXmlMaxDepth = $null
                EnableXsdValidation = $null
                EnableStackTrace = $null
                RequestUsageExecutionTimeThreshold = $null
                EnableRequestUsage = $null
                LogActionsIfHasRequestException = $null
            }
        }

        $proxyLibraries = @()
        $clientCallableSettings = $webApplication.ClientCallableSettings
        $clientCallableSettings.ProxyLibraries | ForEach-Object -Process {
            $proxyLibraries += $_
        }

        if($params.ContainsKey("ProxyLibrariesToInclude"))
        {
            $include = $params.ProxyLibrariesToInclude
        }
        else
        {
            $include = $null;
        }

        if($params.ContainsKey("ProxyLibrariesToExclude"))
        {
            $exclude = $params.ProxyLibrariesToExclude
        }
        else
        {
            $exclude = $null;
        }

        return @{
            WebAppUrl = $params.WebAppUrl
            ProxyLibraries = $clientCallableSettings.ProxyLibraries #$proxyLibraries
            ProxyLibrariesToInclude = $include
            ProxyLibrariesToExclude = $exclude
            MaxResourcesPerRequest = $clientCallableSettings.MaxResourcesPerRequest
            MaxObjectPaths = $clientCallableSettings.MaxObjectPaths
            ExecutionTimeout = $clientCallableSettings.ExecutionTimeout.TotalMinutes
            RequestXmlMaxDepth = $clientCallableSettings.RequestXmlMaxDepth
            EnableXsdValidation = $clientCallableSettings.EnableXsdValidation
            EnableStackTrace = $clientCallableSettings.EnableStackTrace
            RequestUsageExecutionTimeThreshold = $clientCallableSettings.RequestUsageExecutionTimeThreshold
            EnableRequestUsage = $clientCallableSettings.EnableRequestUsage
            LogActionsIfHasRequestException = $clientCallableSettings.LogActionsIfHasRequestException
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

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ProxyLibraries,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ProxyLibrariesToInclude,

        [Parameter()]
        [System.String[]]
        $ProxyLibrariesToExclude,

        [Parameter()]
        [System.UInt32]
        $MaxResourcesPerRequest,

        [Parameter()]
        [System.UInt32]
        $MaxObjectPaths,

        [Parameter()]
        [System.UInt32]
        $ExecutionTimeout,

        [Parameter()]
        [System.UInt32]
        $RequestXmlMaxDepth,

        [Parameter()]
        [Boolean]
        $EnableXsdValidation,

        [Parameter()]
        [Boolean]
        $EnableStackTrace,

        [Parameter()]
        [System.UInt32]
        $RequestUsageExecutionTimeThreshold,

        [Parameter()]
        [Boolean]
        $EnableRequestUsage,

        [Parameter()]
        [Boolean]
        $LogActionsIfHasRequestException,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$WebAppUrl' client callable settings"

    if ($ProxyLibraries -and (($ProxyLibrariesToInclude) -or ($ProxyLibrariesToExclude)))
    {
        throw ("Cannot use the ProxyLibraries parameter together with the ProxyLibrariesToInclude or " + `
               "ProxyLibrariesToExclude parameters")
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters) `
                        -ScriptBlock {
        $params = $args[0]

        $webApplication = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $webApplication)
        {
            throw "Web application $($params.WebAppUrl) was not found"
        }

        $clientCallableSettings = $webApplication.ClientCallableSettings
        $webApplicationNeedsUpdate = $false

        if ($params.ContainsKey("ProxyLibraries") -eq $true)
        {
            foreach($desiredProxyLibrary in $params.ProxyLibraries)
            {
                if ($clientCallableSettings.ProxyLibraries.AssemblyName -contains $desiredProxyLibrary.AssemblyName)
                {
                    $existingProxyLibrary = $clientCallableSettings.ProxyLibraries | Where-Object -FilterScript {
                        $_.AssemblyName -eq $desiredProxyLibrary.AssemblyName
                    } | Select-Object -First 1

                    if ($existingProxyLibrary.SupportAppAuthentication -ne $desiredProxyLibrary.SupportAppAuthentication)
                    {
                        $existingProxyLibrary.SupportAppAuthentication = $desiredProxyLibrary.SupportAppAuthentication
                        $webApplicationNeedsUpdate = $true
                    }
                }
                else
                {
                    $newProxyLibrary = New-Object Microsoft.SharePoint.Administration.SPClientCallableProxyLibrary
                    $newProxyLibrary.AssemblyName = $desiredProxyLibrary.AssemblyName
                    $newProxyLibrary.SupportAppAuthentication = $desiredProxyLibrary.SupportAppAuthentication
                    $clientCallableSettings.ProxyLibraries.Add($newProxyLibrary);
                    $webApplicationNeedsUpdate = $true
                }
            }

            [System.Collections.ObjectModel.Collection[System.Object]]$proxyLibrariesToRemove = @{}
            foreach($currentProxyLibrary in $clientCallableSettings.ProxyLibraries)
            {
                if ($params.ProxyLibraries.Count -eq 0 -or (-not ($params.ProxyLibraries.AssemblyName -contains $currentProxyLibrary.AssemblyName)))
                {
                    $proxyLibrariesToRemove.Add($currentProxyLibrary);
                }
            }

            foreach($proxyLibraryToRemove in $proxyLibrariesToRemove)
            {
                    $clientCallableSettings.ProxyLibraries.Remove($proxyLibraryToRemove)
                    $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("ProxyLibrariesToInclude") -eq $true)
        {
            foreach($desiredProxyLibrary in $params.ProxyLibrariesToInclude)
            {
                if ($clientCallableSettings.ProxyLibraries.AssemblyName -contains $desiredProxyLibrary.AssemblyName)
                {
                    $existingProxyLibrary = $clientCallableSettings.ProxyLibraries | Where-Object -FilterScript {
                        $_.AssemblyName -eq $desiredProxyLibrary.AssemblyName
                    } | Select-Object -First 1

                    if ( $existingProxyLibrary.SupportAppAuthentication -ne $desiredProxyLibrary.SupportAppAuthentication)
                    {
                        $existingProxyLibrary.SupportAppAuthentication = $desiredProxyLibrary.SupportAppAuthentication
                        $webApplicationNeedsUpdate = $true
                    }
                }
                else
                {
                    $newProxyLibrary = New-Object Microsoft.SharePoint.Administration.SPClientCallableProxyLibrary
                    $newProxyLibrary.AssemblyName = $desiredProxyLibrary.AssemblyName
                    $newProxyLibrary.SupportAppAuthentication = $desiredProxyLibrary.SupportAppAuthentication
                    $clientCallableSettings.ProxyLibraries.Add($newProxyLibrary);
                    $webApplicationNeedsUpdate = $true
                }
            }
        }

        if ($params.ContainsKey("ProxyLibrariesToExclude") -eq $true)
        {
            foreach($excludeProxyLibrary in $params.ProxyLibrariesToExclude)
            {
                $existingProxyLibrary = $clientCallableSettings.ProxyLibraries | Where-Object -FilterScript {
                    $_.AssemblyName -eq $excludeProxyLibrary
                } | Select-Object -First 1
                if($null -ne $existingProxyLibrary)
                {
                    $clientCallableSettings.ProxyLibraries.Remove($existingProxyLibrary)
                    $webApplicationNeedsUpdate = $true
                }
            }
        }

        if ($params.ContainsKey("MaxObjectPaths") -eq $true)
        {
            if ($params.MaxObjectPaths -ne $clientCallableSettings.MaxObjectPaths)
            {
                $clientCallableSettings.MaxObjectPaths = $params.MaxObjectPaths
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("MaxResourcesPerRequest") -eq $true)
        {
            if ($params.MaxResourcesPerRequest -ne $clientCallableSettings.MaxResourcesPerRequest)
            {
                $clientCallableSettings.MaxResourcesPerRequest = $params.MaxResourcesPerRequest
                $webApplicationNeedsUpdate = $true
            }
        }


        if ($params.ContainsKey("ExecutionTimeout") -eq $true)
        {
            if ($params.ExecutionTimeout -ne $clientCallableSettings.ExecutionTimeout.TotalMinutes)
            {
                $clientCallableSettings.ExecutionTimeout = [System.TimeSpan]::FromMinutes($params.ExecutionTimeout)
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("RequestXmlMaxDepth") -eq $true)
        {
            if ($params.RequestXmlMaxDepth -ne $clientCallableSettings.RequestXmlMaxDepth)
            {
                $clientCallableSettings.RequestXmlMaxDepth = $params.RequestXmlMaxDepth
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("EnableXsdValidation") -eq $true)
        {
            if ($params.EnableXsdValidation -ne $clientCallableSettings.EnableXsdValidation)
            {
                $clientCallableSettings.EnableXsdValidation = $params.EnableXsdValidation
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("EnableStackTrace") -eq $true)
        {
            if ($params.EnableStackTrace -ne $clientCallableSettings.EnableStackTrace)
            {
                $clientCallableSettings.EnableStackTrace = $params.EnableStackTrace
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("RequestUsageExecutionTimeThreshold") -eq $true)
        {
            if ($params.RequestUsageExecutionTimeThreshold -ne $clientCallableSettings.RequestUsageExecutionTimeThreshold)
            {
                $clientCallableSettings.RequestUsageExecutionTimeThreshold = $params.RequestUsageExecutionTimeThreshold
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("EnableRequestUsage") -eq $true)
        {
            if ($params.EnableRequestUsage -ne $clientCallableSettings.EnableRequestUsage)
            {
                $clientCallableSettings.EnableRequestUsage = $params.EnableRequestUsage
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("LogActionsIfHasRequestException") -eq $true)
        {
            if ($params.LogActionsIfHasRequestException -ne $clientCallableSettings.LogActionsIfHasRequestException)
            {
                $clientCallableSettings.LogActionsIfHasRequestException = $params.LogActionsIfHasRequestException
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($webApplicationNeedsUpdate -eq $true)
        {
            Write-Verbose -Message "Updating web application"
            $webApplication.Update()
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

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ProxyLibraries,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ProxyLibrariesToInclude,

        [Parameter()]
        [System.String[]]
        $ProxyLibrariesToExclude,

        [Parameter()]
        [System.UInt32]
        $MaxResourcesPerRequest,

        [Parameter()]
        [System.UInt32]
        $MaxObjectPaths,

        [Parameter()]
        [System.UInt32]
        $ExecutionTimeout,

        [Parameter()]
        [System.UInt32]
        $RequestXmlMaxDepth,

        [Parameter()]
        [Boolean]
        $EnableXsdValidation,

        [Parameter()]
        [Boolean]
        $EnableStackTrace,

        [Parameter()]
        [System.UInt32]
        $RequestUsageExecutionTimeThreshold,

        [Parameter()]
        [Boolean]
        $EnableRequestUsage,

        [Parameter()]
        [Boolean]
        $LogActionsIfHasRequestException,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing for web application '$WebAppUrl' client callable settings"

    $currentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $currentValues.ProxyLibraries)
    {
        Write-Verbose -Message "Proxy library list does not have a valid value"
        return $false
    }

    if ($null -ne $ProxyLibraries)
    {
        Write-Verbose -Message "Processing ProxyLibraries parameter"

        if ($currentValues.ProxyLibraries.Count -eq 0)
        {
            if ($ProxyLibraries.Count -gt 0)
            {
                Write-Verbose -Message "Proxy library list does not match"
                return $false
            }
        }
        else
        {
            if ($ProxyLibraries.Count -eq 0)
            {
                Write-Verbose -Message "Proxy library list does not match"
                return $false
            }

            $differences = Compare-Object -ReferenceObject $currentValues.ProxyLibraries.AssemblyName `
                                        -DifferenceObject $ProxyLibraries.AssemblyName

            if ($null -eq $differences)
            {
                Write-Verbose -Message "Proxy library list matches - checking that SupportAppAuthentication match on each object"
                foreach($currentProxyLibrary in $currentValues.ProxyLibraries)
                {
                    if ($currentProxyLibrary.SupportAppAuthentication -ne ($ProxyLibraries | Where-Object -FilterScript {
                            $_.AssemblyName -eq $currentProxyLibrary.AssemblyName
                        } | Select-Object -First 1).SupportAppAuthentication)
                    {
                        Write-Verbose -Message "$($currentProxyLibrary.AssemblyName) has incorrect SupportAppAuthentication. Test failed."
                        return $false
                    }
                }
            }
            else
            {
                Write-Verbose -Message "Proxy library list does not match"
                return $false
            }
        }
    }

    if ($ProxyLibrariesToInclude)
    {
        Write-Verbose -Message "Processing ProxyLibrariesToInclude parameter"

        if ($currentValues.ProxyLibraries.Count -eq 0)
        {
            if ($ProxyLibrariesToInclude.Count -gt 0)
            {
                Write-Verbose -Message "Proxy library list to include does not match"
                return $false
            }
        }

        Write-Verbose -Message "Processing ProxyLibrariesToInclude parameter"
        foreach ($proxyLibrary in $ProxyLibrariesToInclude)
        {
            if (-not($currentValues.ProxyLibraries.AssemblyName -contains $proxyLibrary.AssemblyName))
            {
                Write-Verbose -Message "$($proxyLibrary.AssemblyName) is not registered as a proxy library. Set result to false"
                return $false
            }
            else
            {
                Write-Verbose -Message "$($proxyLibrary.AssemblyName) is already registered as a proxy library. Checking SupportAppAuthentication..."
                if ($proxyLibrary.SupportAppAuthentication -ne ($currentValues.ProxyLibraries | Where-Object -FilterScript {
                        $_.AssemblyName -eq $proxyLibrary.AssemblyName
                    } | Select-Object -First 1).SupportAppAuthentication)
                {
                    Write-Verbose -Message "$($proxyLibrary.AssemblyName) has incorrect SupportAppAuthentication. Test failed."
                    return $false
                }
            }
        }
    }

    if ($ProxyLibrariesToExclude)
    {
        Write-Verbose -Message "Processing ProxyLibrariesToExclude parameter"

        if ($currentValues.ProxyLibraries.Count -gt 0)
        {
            foreach ($proxyLibrary in $ProxyLibrariesToExclude)
            {
                if ($currentValues.ProxyLibraries.AssemblyName -contains $proxyLibrary)
                {
                    Write-Verbose -Message "$proxyLibrary is already registered as proxy library. Set result to false"
                    return $false
                }
                else
                {
                    Write-Verbose -Message "$proxyLibrary is not registered as proxy library. Skipping"
                }
            }
        }
    }

    return Test-SPDscParameterState -CurrentValues $currentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("WebAppUrl",
                                                    "MaxResourcesPerRequest",
                                                    "MaxObjectPaths",
                                                    "ExecutionTimeout",
                                                    "RequestXmlMaxDepth",
                                                    "EnableXsdValidation",
                                                    "EnableStackTrace",
                                                    "RequestUsageExecutionTimeThreshold",
                                                    "LogActionsIfHasRequestException",
                                                    "EnableRequestUsage")
}

Export-ModuleMember -Function *-TargetResource
