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
        [System.Boolean] 
        $Enabled,

        [Parameter()] 
        [ValidateSet("All Servers","Any Server")] 
        [System.String] 
        $RuleScope,

        [Parameter()] 
        [ValidateSet("Hourly","Daily","Weekly","Monthly","OnDemandOnly")] 
        [System.String] 
        $Schedule,

        [Parameter()] 
        [System.Boolean] 
        $FixAutomatically,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting Health Rule configuration settings"

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
            Write-Verbose -Message ("No local SharePoint farm was detected. Health " + `
                                    "Analyzer Rule settings will not be applied")
            return $null
        }

        $caWebapp = Get-SPwebapplication -IncludeCentralAdministration `
            | Where-Object -FilterScript {
                $_.IsAdministrationWebApplication 
        }

        if ($null -eq $caWebapp) 
        {
            Write-Verbose -Message "Unable to locate central administration website"
            return $null
        }

        # Get CA SPWeb
        $caWeb = Get-SPWeb($caWebapp.Url)
        $healthRulesList = $caWeb.Lists | Where-Object -FilterScript {
            $_.BaseTemplate -eq "HealthRules"
        }

        if ($null -ne $healthRulesList) 
        {
            $spQuery = New-Object Microsoft.SharePoint.SPQuery 
            $querytext = "<Where><Eq><FieldRef Name='Title'/><Value Type='Text'>" + `
                         "$($params.Name)</Value></Eq></Where>"
            $spQuery.Query = $querytext
            $results = $healthRulesList.GetItems($spQuery)
            if ($results.Count -eq 1) 
            {
                $item = $results[0]

                # Additional check for incorrect default value of the schedule for rule
                # "One or more app domains for web applications aren't configured correctly."
                $ruleschedule = $item["HealthRuleSchedule"]
                if ($ruleschedule -eq "On Demand")
                {
                    $ruleschedule = "OnDemandOnly"
                }

                return @{
                    # Set the Health Analyzer Rule settings
                    Name = $params.Name
                    Enabled = $item["HealthRuleCheckEnabled"]
                    RuleScope = $item["HealthRuleScope"]
                    Schedule = $ruleschedule
                    FixAutomatically = $item["HealthRuleAutoRepairEnabled"]
                    InstallAccount = $params.InstallAccount
                }
            } 
            else 
            {
                Write-Verbose -Message ("Unable to find specified Health Analyzer Rule. Make " + `
                                        "sure any related service applications exists.")
                return $null                
            }
        } 
        else 
        {
            Write-Verbose -Message "Unable to locate Health Analyzer Rules list"
            return $null
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
        [System.Boolean] 
        $Enabled,

        [Parameter()] 
        [ValidateSet("All Servers","Any Server")] 
        [System.String] 
        $RuleScope,

        [Parameter()] 
        [ValidateSet("Hourly","Daily","Weekly","Monthly","OnDemandOnly")] 
        [System.String] 
        $Schedule,

        [Parameter()] 
        [System.Boolean] 
        $FixAutomatically,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting Health Analyzer Rule configuration settings"

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
            throw ("No local SharePoint farm was detected. Health Analyzer Rule " + `
                   "settings will not be applied")
            return
        }

        $caWebapp = Get-SPwebapplication -IncludeCentralAdministration `
            | Where-Object -FilterScript {
                $_.IsAdministrationWebApplication 
        }

        if ($null -eq $caWebapp) 
        {
            throw ("No Central Admin web application was found. Health Analyzer Rule " + `
                   "settings will not be applied")
            return
        }

        # Get Central Admin SPWeb
        $caWeb = Get-SPWeb($caWebapp.Url)
        $healthRulesList = $caWeb.Lists | Where-Object -FilterScript {
            $_.BaseTemplate -eq "HealthRules"
        }

        if ($null -ne $healthRulesList) 
        {
            $spQuery = New-Object Microsoft.SharePoint.SPQuery 
            $querytext = "<Where><Eq><FieldRef Name='Title'/><Value Type='Text'>" + `
                         "$($params.Name)</Value></Eq></Where>"
            $spQuery.Query = $querytext
            $results = $healthRulesList.GetItems($spQuery)
            if ($results.Count -eq 1) 
            {
                $item = $results[0]

                $item["HealthRuleCheckEnabled"] = $params.Enabled
                if ($params.ContainsKey("RuleScope")) 
                {
                    $item["HealthRuleScope"] = $params.RuleScope 
                }
                if ($params.ContainsKey("Schedule")) 
                {
                    $item["HealthRuleSchedule"] = $params.Schedule 
                }
                if ($params.ContainsKey("FixAutomatically")) 
                {
                    $item["HealthRuleAutoRepairEnabled"] = $params.FixAutomatically 
                }

                $item.Update()
            } 
            else 
            {
                throw ("Could not find specified Health Analyzer Rule. Health Analyzer Rule " + `
                       "settings will not be applied. Make sure any related service " + `
                       "applications exists")
                return
            }
        } 
        else 
        {
            throw ("Could not find Health Analyzer Rules list. Health Analyzer Rule settings " + `
                   "will not be applied")
            return
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
        [System.Boolean] 
        $Enabled,

        [Parameter()] 
        [ValidateSet("All Servers","Any Server")] 
        [System.String] 
        $RuleScope,

        [Parameter()] 
        [ValidateSet("Hourly","Daily","Weekly","Monthly","OnDemandOnly")] 
        [System.String] 
        $Schedule,

        [Parameter()] 
        [System.Boolean] 
        $FixAutomatically,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing Health Analyzer rule configuration settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
