function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TypeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.String]
        $Schedule,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting timer job settings for job '$TypeName'"

    if ($TypeName -eq "Microsoft.SharePoint.Administration.Health.SPHealthAnalyzerJobDefinition")
    {
        throw ("You cannot use SPTimerJobState to change the schedule of " + `
               "health analyzer timer jobs.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        try 
        {
            $spFarm = Get-SPFarm
        } 
        catch 
        {
            throw ("No local SharePoint farm was detected. Timer job " + `
                   "settings will not be applied")
        }

        $returnval = @{
            TypeName = $params.TypeName
        }

        if ($params.WebAppUrl -ne "N/A")
        {
            $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
            if ($null -eq $wa)
            {
                throw ("Specified web application not found!")
            }
    
            $timerjob = Get-SPTimerJob -Type $params.TypeName `
                                        -WebApplication $wa
            
            if ($timerjob.Count -eq 0)
            {
                throw ("No timer jobs found. Please check the input values")
            }

            $returnval.WebAppUrl = $params.WebAppUrl
            $returnval.Enabled   = -not $timerjob.IsDisabled
            $returnval.Schedule  = $null
            if ($null -ne $timerjob.Schedule) 
            {
                $returnval.Schedule = $timerjob.Schedule.ToString()
            }
        } 
        else 
        {
            $timerjob = Get-SPTimerJob -Type $params.TypeName
            if ($timerjob.Count -eq 1)
            {
                $returnval.WebAppUrl = "N/A"
                $returnval.Enabled   = -not $timerjob.IsDisabled
                $returnval.Schedule  = $null
                if ($null -ne $timerjob.Schedule) 
                {
                    $returnval.Schedule = $timerjob.Schedule.ToString()
                }
            }
            else
            {
                throw ("$($timerjob.Count) timer jobs found. Check input " + `
                       "values or use the WebAppUrl parameter.")
            }
        }
        return $returnval
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
        $TypeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.String]
        $Schedule,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting timer job settings for job '$TypeName'"

    if ($TypeName -eq "Microsoft.SharePoint.Administration.Health.SPHealthAnalyzerJobDefinition")
    {
        throw ("You cannot use SPTimerJobState to change the schedule of " + `
               "health analyzer timer jobs.")
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        
        try 
        {
            $spFarm = Get-SPFarm
        } 
        catch 
        {
            throw "No local SharePoint farm was detected. Timer job settings will not be applied"
            return $null
        }
        
        Write-Verbose -Message "Start update"

        if ($params.WebAppUrl -ne "N/A")
        {
            $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
            if ($null -eq $wa)
            {
                throw "Specified web application not found!"
            }

            $timerjob = Get-SPTimerJob -Type $params.TypeName `
                                        -WebApplication $wa
            
            if ($timerjob.Count -eq 0)
            {
                throw ("No timer jobs found. Please check the input values")
            }
            
            if ($params.ContainsKey("Schedule") -eq $true)
            {
                if ($params.Schedule -ne $timerjob.Schedule.ToString())
                {
                    try 
                    {
                        Set-SPTimerJob -Identity $timerjob `
                                       -Schedule $params.Schedule `
                                       -ErrorAction Stop
                    } 
                    catch 
                    {
                        if ($_.Exception.Message -like `
                            "*The time given was not given in the proper format*") 
                        {
                            throw ("Incorrect schedule format used. New schedule will " + `
                                    "not be applied.")
                        } 
                        else 
                        {
                            throw ("Error occurred. Timer job settings will not be applied. " + `
                                    "Error details: $($_.Exception.Message)")
                        }
                    }
                }
            }

            if ($params.ContainsKey("Enabled") -eq $true) 
            {
                if ($params.Enabled -ne (-not $timerjob.IsDisabled))
                {
                    if ($params.Enabled)
                    {
                        Write-Verbose -Message "Enable timer job $($params.TypeName)"
                        try 
                        {
                            Enable-SPTimerJob -Identity $timerjob
                        }
                        catch 
                        {
                            throw ("Error occurred while enabling job. Timer job settings will " + `
                                    "not be applied. Error details: $($_.Exception.Message)")
                            return
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "Disable timer job $($params.Name)"
                        try 
                        {
                            Disable-SPTimerJob -Identity $timerjob
                        } 
                        catch 
                        {
                            throw ("Error occurred while disabling job. Timer job settings will " + `
                                    "not be applied. Error details: $($_.Exception.Message)")
                            return
                        }        
                    } 
                }
            }
        }
        else 
        {
            $timerjob = Get-SPTimerJob -Type $params.TypeName
            if ($timerjob.Count -eq 1)
            {
                if ($params.ContainsKey("Schedule") -eq $true)
                {
                    if ($params.Schedule -ne $timerjob.Schedule.ToString())
                    {
                        try 
                        {
                            Set-SPTimerJob -Identity $timerjob `
                                           -Schedule $params.Schedule `
                                           -ErrorAction Stop
                        } 
                        catch 
                        {
                            if ($_.Exception.Message -like `
                                "*The time given was not given in the proper format*") 
                            {
                                throw ("Incorrect schedule format used. New schedule will " + `
                                        "not be applied.")
                            } 
                            else 
                            {
                                throw ("Error occurred. Timer job settings will not be applied. " + `
                                        "Error details: $($_.Exception.Message)")
                            }
                        }
                    }
                }

                if ($params.ContainsKey("Enabled") -eq $true) 
                {
                    if ($params.Enabled -ne -not $timerjob.IsDisabled)
                    {
                        if ($params.Enabled)
                        {
                            Write-Verbose -Message "Enable timer job $($params.TypeName)"
                            try 
                            {
                                Enable-SPTimerJob -Identity $timerjob
                            }
                            catch 
                            {
                                throw ("Error occurred while enabling job. Timer job settings will " + `
                                        "not be applied. Error details: $($_.Exception.Message)")
                            }
                        }
                        else
                        {
                            Write-Verbose -Message "Disable timer job $($params.Name)"
                            try 
                            {
                                Disable-SPTimerJob -Identity $timerjob
                            } 
                            catch 
                            {
                                throw ("Error occurred while disabling job. Timer job settings will " + `
                                        "not be applied. Error details: $($_.Exception.Message)")
                            }        
                        } 
                    }
                }
            }
            else
            {
                throw ("$($timerjob.Count) timer jobs found. Check input " + `
                        "values or use the WebAppUrl parameter.")
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
        $TypeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.String]
        $Schedule,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing timer job settings for job '$TypeName'"

    if ($TypeName -eq "Microsoft.SharePoint.Administration.Health.SPHealthAnalyzerJobDefinition")
    {
        throw ("You cannot use SPTimerJobState to change the schedule of " + `
               "health analyzer timer jobs.")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues) 
    {
        return $false 
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
