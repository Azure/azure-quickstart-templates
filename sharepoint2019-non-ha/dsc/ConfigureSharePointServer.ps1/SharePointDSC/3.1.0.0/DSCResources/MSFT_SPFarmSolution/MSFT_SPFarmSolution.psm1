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
        $LiteralPath,

        [Parameter()]
        [System.String[]]
        $WebAppUrls = @(),

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $Version = "1.0.0.0",

        [Parameter()]
        [System.Boolean]
        $Deployed = $true,

        [Parameter()]
        [ValidateSet("14","15","All")]
        [System.String]
        $SolutionLevel,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting farm solution '$Name' settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $solution = Get-SPSolution -Identity $params.Name `
                                   -ErrorAction SilentlyContinue `
                                   -Verbose:$false

        if ($null -ne $solution)
        {
            $currentState = "Present"
            $deployed = $solution.Deployed
            $version = $Solution.Properties["Version"]
            $deployedWebApplications = @($solution.DeployedWebApplications `
                                         | Select-Object -ExpandProperty Url)
        }
        else
        {
            $currentState = "Absent"
            $deployed = $false
            $version = "0.0.0.0"
            $deployedWebApplications = @()
        }

        return @{
            Name            = $params.Name
            LiteralPath     = $LiteralPath
            Deployed        = $deployed
            Ensure          = $currentState
            Version         = $version
            WebAppUrls      = $deployedWebApplications
            SolutionLevel   = $params.SolutionLevel
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
        $LiteralPath,

        [Parameter()]
        [System.String[]]
        $WebAppUrls = @(),

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $Version = "1.0.0.0",

        [Parameter()]
        [System.Boolean]
        $Deployed = $true,

        [Parameter()]
        [ValidateSet("14","15","All")]
        [System.String]
        $SolutionLevel,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting farm solution '$Name' settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $PSBoundParameters.Ensure = $Ensure
    $PSBoundParameters.Version = $Version
    $PSBoundParameters.Deployed = $Deployed

    if ($Ensure -eq "Present")
    {
        if ($CurrentValues.Ensure -eq "Absent")
        {
            Write-Verbose -Message "Upload solution to the farm."

            $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                          -Arguments $PSBoundParameters `
                                          -ScriptBlock {
                $params = $args[0]

                $runParams = @{}
                $runParams.Add("LiteralPath", $params.LiteralPath)
                $runParams.Add("Verbose", $false)

                $solution = Add-SPSolution @runParams

                $solution.Properties["Version"] = $params.Version
                $solution.Update()

                return $solution
            }

            $CurrentValues.Version = $result.Properties["Version"]
        }

        if ($CurrentValues.Version -ne $Version)
        {
            # If the solution is not deployed and the versions do not match we have to
            # remove the current solution and add the new one
            if (-not $CurrentValues.Deployed)
            {
                Write-Verbose -Message ("Remove current version " + `
                                        "('$($CurrentValues.Version)') of solution...")

                $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                              -Arguments $PSBoundParameters `
                                              -ScriptBlock {
                    $params = $args[0]

                    $runParams = @{}
                    $runParams.Add("Identity", $params.Name)
                    $runParams.Add("Confirm", $false)
                    $runParams.Add("Verbose", $false)

                    Remove-SPSolution $runParams

                    $runParams = @{}
                    $runParams.Add("LiteralPath", $params.LiteralPath)

                    $solution = Add-SPSolution @runParams

                    $solution.Properties["Version"] = $params.Version
                    $solution.Update()

                    return $solution
                }

                $CurrentValues.Version = $result.Properties["Version"]
            }
            else
            {
                Write-Verbose -Message ("Update solution from " + `
                                        "'$($CurrentValues.Version)' to $Version...")

                $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                              -Arguments $PSBoundParameters `
                                              -ScriptBlock {
                    $params = $args[0]

                    $solution = Get-SPSolution -Identity $params.Name -Verbose:$false

                    $runParams = @{}
                    $runParams.Add("Identity", $params.Name)
                    $runParams.Add("LiteralPath", $params.LiteralPath)
                    $runParams.Add("GACDeployment", $solution.ContainsGlobalAssembly)
                    $runParams.Add("Confirm", $false)
                    $runParams.Add("Local", $false)
                    $runParams.Add("Verbose", $false)

                    Update-SPSolution @runParams

                    $solution = Get-SPSolution -Identity $params.Name -Verbose:$false
                    $solution.Properties["Version"] = $params.Version
                    $solution.Update()

                    # Install new features...
                    Install-SPFeature -AllExistingFeatures -Confirm:$false
                }
            }
        }

    }
    else
    {
        #If ensure is absent we should also retract the solution first
        $Deployed = $false
    }

    if ($Deployed -ne $CurrentValues.Deployed)
    {
        Write-Verbose -Message ("The deploy state of $Name is " + `
                                "'$($CurrentValues.Deployed)' but should be '$Deployed'.")
        if ($CurrentValues.Deployed)
        {
            # Retract Solution globally
            $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                          -Arguments $PSBoundParameters `
                                          -ScriptBlock {
                $params = $args[0]

                $runParams = @{}
                $runParams.Add("Identity", $params.Name)
                $runParams.Add("Confirm", $false)
                $runParams.Add("Verbose", $false)

                if ($solution.ContainsWebApplicationResource)
                {
                    if ($null -eq $webApps -or $webApps.Length -eq 0)
                    {
                        $runParams.Add("AllWebApplications", $true)

                        Uninstall-SPSolution @runParams
                    }
                    else
                    {
                        foreach ($webApp in $webApps)
                        {
                            $runParams["WebApplication"] = $webApp

                            Uninstall-SPSolution @runParams
                        }
                    }
                }
                else
                {
                    Uninstall-SPSolution @runParams
                }
            }
        }
        else
        {
            # Deploy solution
            $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                          -Arguments $PSBoundParameters `
                                          -ScriptBlock {
                $params = $args[0]

                $solution = Get-SPSolution -Identity $params.Name -Verbose:$false

                $runParams = @{
                    Identity = $solution
                    GACDeployment = $solution.ContainsGlobalAssembly
                    Local = $false
                    Verbose = $false
                }
                if ($params.ContainsKey("SolutionLevel") -eq $true)
                {
                    $runParams.Add("CompatibilityLevel", $params.SolutionLevel)
                }

                if (!$solution.ContainsWebApplicationResource)
                {
                    Install-SPSolution @runParams
                }
                else
                {
                    if ($null -eq $webApps -or $webApps.Length -eq 0)
                    {
                        $runParams.Add("AllWebApplications", $true)

                        Install-SPSolution @runParams
                    }
                    else
                    {
                        foreach ($webApp in $webApps)
                        {
                            $runParams["WebApplication"] = $webApp

                            Install-SPSolution @runParams
                        }
                    }
                }
            }
        }
    }

    Wait-SPDSCSolutionJob -SolutionName $Name -InstallAccount $InstallAccount

    if ($Ensure -eq "Absent")
    {
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
            $params = $args[0]

            $runParams = @{
                Identity = $params.Name
                Confirm = $false
                Verbose = $false
            }

            Remove-SPSolution @runParams

        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LiteralPath,

        [Parameter()]
        [System.String[]]
        $WebAppUrls = @(),

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $Version = "1.0.0.0",

        [Parameter()]
        [System.Boolean]
        $Deployed = $true,

        [Parameter()]
        [ValidateSet("14","15","All")]
        [System.String]
        $SolutionLevel,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing farm solution '$Name' settings"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $valuesToCheck = @("Ensure", "Version", "Deployed")
    if ($WebAppUrls.Count -gt 0)
    {
        $valuesToCheck += "WebAppUrls"
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck $valuesToCheck
}

function Wait-SPDSCSolutionJob
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $SolutionName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Start-Sleep -Seconds 5

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @{ Name = $SolutionName } `
                                  -ScriptBlock {
        $params = $args[0]

        $gc = Start-SPAssignment -Verbose:$false

        $solution = Get-SPSolution -Identity $params.Name -Verbose:$false -AssignmentCollection $gc

        if ($solution.JobExists -eq $true)
        {
            Write-Verbose -Message "Waiting for solution '$($params.Name)'..."
            $loopCount = 0
            while ($solution.JobExists -and $loopCount -lt 600)
            {
                $solution = Get-SPSolution -Identity $params.Name -Verbose:$false -AssignmentCollection $gc

                Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - Waiting for a " + `
                                        "job for solution '$($params.Name)' to complete")
                $loopCount++
                Start-Sleep -Seconds 5

            }

            Write-Verbose -Message "Result: $($solution.LastOperationResult)"
            Write-Verbose -Message "Details: $($solution.LastOperationDetails)"

        }
        else
        {
            Write-Verbose -Message "Solution '$($params.Name)' has no job pending."
            return @{
                LastOperationResult = "DeploymentSucceeded"
                LastOperationDetails = "Solution '$($params.Name)' has no job pending."
            }
        }

        Stop-SPAssignment $gc -Verbose:$false

        return @{
            LastOperationResult = $solution.LastOperationResult
            LastOperationDetails = $solution.LastOperationDetails
        }
    }
}

Export-ModuleMember -Function *-TargetResource
