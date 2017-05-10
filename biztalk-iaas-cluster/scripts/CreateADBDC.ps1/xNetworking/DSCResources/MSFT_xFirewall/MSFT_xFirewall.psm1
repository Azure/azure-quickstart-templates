# Default Display Group for the Firewall cmdlets
$DefaultDisplayGroup = "DSC_FirewallRule"

# DSC uses the Get-TargetResource cmdlet to fetch the status of the resource instance specified in the parameters for the target machine
function Get-TargetResource 
{    
    param 
    (        
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
                      
        # Permit or Block the supplied configuration 
        [Parameter(Mandatory)]
        [ValidateSet("NotConfigured", "Allow", "Block")]
        [String]$Access        
    )

    # Hash table for Get
    $getTargetResourceResult = @{}
    
    # Populate the properties for get target resource
    $getTargetResourceResult.Name = $Name
    $getTargetResourceResult.Ensure = "Present"

    Write-Verbose "GET: Get Rules for the specified Name[$Name]"
    $firewallRule = Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue
    if (-not $firewallRule)
    {
        Write-Verbose "GET: Firewall Rule does not exist, there is nothing interesting to do"
        $getTargetResourceResult.Ensure = "Absent"
        return $getTargetResourceResult
    }

    $getTargetResourceResult.DisplayName = $firewallRule.DisplayName
    $getTargetResourceResult.DisplayGroup = $firewallRule.DisplayGroup
    $getTargetResourceResult.Access = $Access
    $getTargetResourceResult.State = $firewallRule.Enabled      
    $getTargetResourceResult.Profile = $firewallRule.Profile.ToString() -replace(" ", "") -split(",")
    $getTargetResourceResult.Direction = $firewallRule.Direction

    $properties = Get-FirewallRuleProperty -FirewallRule $firewallRule -Property All
    $getTargetResourceResult.RemotePort = $properties.PortFilters.RemotePort
    $getTargetResourceResult.LocalPort = $properties.PortFilters.LocalPort
    $getTargetResourceResult.Protocol = $properties.PortFilters.Protocol
    $getTargetResourceResult.Description = $firewallRule.Description
    $getTargetResourceResult.ApplicationPath = $properties.ApplicationFilters.Program
    $getTargetResourceResult.Service = $properties.ServiceFilters.Service

    return $getTargetResourceResult;
}

# DSC uses Set-TargetResource cmdlet to create, delete or configure the resource instance on the target machine
function Set-TargetResource 
{   
    param 
    (        
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        # Localized, user-facing name of the Firewall Rule being created        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayName = $Name,
        
        # Name of the Firewall Group where we want to put the Firewall Rules        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayGroup = $DefaultDisplayGroup,

        # Ensure the presence/absence of the resource
        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present",

        # Permit or Block the supplied configuration 
        [Parameter(Mandatory)]
        [ValidateSet("NotConfigured", "Allow", "Block")]
        [String]$Access = "Allow",

        # Enable or disable the supplied configuration        
        [ValidateSet("Enabled", "Disabled")]
        [String]$State = "Enabled",

        # Specifies one or more profiles to which the rule is assigned        
        [ValidateSet("Any", "Public", "Private", "Domain")]
        [String[]]$Profile = ("Any"),

        # Direction of the connection        
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,

        # Specific Port used for filter. Specified by port number, range, or keyword        
        [ValidateNotNullOrEmpty()]
        [String[]]$RemotePort,

        # Local Port used for the filter        
        [ValidateNotNullOrEmpty()]
        [String[]]$LocalPort,

        # Specific Protocol for filter. Specified by name, number, or range        
        [ValidateNotNullOrEmpty()]
        [String]$Protocol,

        # Documentation for the Rule       
        [String]$Description,

        # Path and file name of the program for which the rule is applied        
        [ValidateNotNullOrEmpty()]
        [String]$ApplicationPath,

        # Specifies the short name of a Windows service to which the firewall rule applies        
        [ValidateNotNullOrEmpty()]
        [String]$Service
    )
    
    Write-Verbose "SET: Find firewall rules with specified parameters for Name = $Name, DisplayGroup = $DisplayGroup"
    $firewallRules = Get-FirewallRules -Name $Name -DisplayGroup $DisplayGroup                                   
    
    $exists = ($firewallRules -ne $null)       
    
    if ($Ensure -eq "Present")
    {        
        Write-Verbose "SET: We want the firewall rule to exist since Ensure is set to $Ensure"
        if ($exists)
        {
            Write-Verbose "SET: We want the firewall rule to exist and it does exist. Check for valid properties"
            foreach ($firewallRule in $firewallRules)
            {
                Write-Verbose "SET: Check each defined parameter against the existing firewall rule - $($firewallRule.Name)"
                if (Test-RuleHasProperties -FirewallRule $firewallRule `
                                           -Name $Name `
                                           -DisplayGroup $DisplayGroup `
                                           -State $State `
                                           -Profile $Profile `
                                           -Direction $Direction `
                                           -Access $Access `
                                           -RemotePort $RemotePort `
                                           -LocalPort $LocalPort `
                                           -Protocol $Protocol `
                                           -Description $Description `
                                           -ApplicationPath $ApplicationPath `
                                           -Service $Service
                )
                {
                }
                else
                {
                    
                    Write-Verbose "SET: Removing existing firewall rule [$Name] to recreate one based on desired configuration"
                    Remove-NetFirewallRule -Name $Name

                    # Set the Firewall rule based on specified parameters
                    Set-FirewallRule    -Name $Name `
                                        -DisplayName $DisplayName `
                                        -DisplayGroup $DisplayGroup `
                                        -State $State `
                                        -Profile $Profile `
                                        -Direction $Direction `
                                        -Access $Access `
                                        -RemotePort $RemotePort `
                                        -LocalPort $LocalPort `
                                        -Protocol $Protocol `
                                        -Description $Description `
                                        -ApplicationPath $ApplicationPath `
                                        -Service $Service -Verbose
                }
            }        
        }        
        else
        {
            Write-Verbose "SET: We want the firewall rule [$Name] to exist, but it does not"

            # Set the Firewall rule based on specified parameters
            Set-FirewallRule    -Name $Name `
                                -DisplayName $DisplayName `
                                -DisplayGroup $DisplayGroup `
                                -State $State `
                                -Profile $Profile `
                                -Direction $Direction `
                                -Access $Access `
                                -RemotePort $RemotePort `
                                -LocalPort $LocalPort `
                                -Protocol $Protocol `
                                -Description $Description `
                                -ApplicationPath $ApplicationPath `
                                -Service $Service -Verbose
        }
    }    
    elseif ($Ensure -eq "Absent")
    {
        Write-Verbose "SET: We do not want the firewall rule to exist"        
        if ($exists)
        {
            Write-Verbose "SET: We do not want the firewall rule to exist, but it does. Removing the Rule(s)"
            foreach ($firewallRule in $firewallRules)
            {
                Remove-NetFirewallRule -Name $firewallRule.Name
            }
        }        
        else
        {
            Write-Verbose "SET: We do not want the firewall rule to exist, and it does not"
            # Do Nothing
        }           
    }
}

# DSC uses Test-TargetResource cmdlet to check the status of the resource instance on the target machine
function Test-TargetResource 
{ 
    param 
    (        
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        # Localized, user-facing name of the Firewall Rule being created        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayName = $Name,
        
        # Name of the Firewall Group where we want to put the Firewall Rules        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayGroup,

        # Ensure the presence/absence of the resource
        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present",

        # Permit or Block the supplied configuration 
        [Parameter(Mandatory)]
        [ValidateSet("NotConfigured", "Allow", "Block")]
        [String]$Access,

        # Enable or disable the supplied configuration        
        [ValidateSet("Enabled", "Disabled")]
        [String]$State,

        # Specifies one or more profiles to which the rule is assigned        
        [ValidateSet("Any", "Public", "Private", "Domain")]
        [String[]]$Profile,

        # Direction of the connection        
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,

        # Specific Port used for filter. Specified by port number, range, or keyword        
        [ValidateNotNullOrEmpty()]
        [String[]]$RemotePort,

        # Local Port used for the filter        
        [ValidateNotNullOrEmpty()]
        [String[]]$LocalPort,

        # Specific Protocol for filter. Specified by name, number, or range        
        [ValidateNotNullOrEmpty()]
        [String]$Protocol,

        # Documentation for the Rule        
        [String]$Description,

        # Path and file name of the program for which the rule is applied        
        [ValidateNotNullOrEmpty()]
        [String]$ApplicationPath,

        # Specifies the short name of a Windows service to which the firewall rule applies        
        [ValidateNotNullOrEmpty()]
        [String]$Service
    )
    
    Write-Verbose "TEST: Find rules with specified parameters"
    $firewallRules = Get-FirewallRules -Name $Name -DisplayGroup $DisplayGroup
    
    if (!$firewallRules)
    {
        Write-Verbose "TEST: Get-FirewallRules returned NULL"
        
        # Returns whether complies with $Ensure
        $returnValue = ($false -eq ($Ensure -eq "Present"))

        Write-Verbose "TEST: Returning $returnValue"
        
        return $returnValue
    }

    $exists = $true
    $valid = $true
    foreach ($firewallRule in $firewallRules)
    {
        Write-Verbose "TEST: Check each defined parameter against the existing Firewall Rule - $($firewallRule.Name)"
        if (Test-RuleHasProperties  -FirewallRule $firewallRule `
                                    -Name $Name `
                                    -DisplayGroup $DisplayGroup `
                                    -State $State `
                                    -Profile $Profile `
                                    -Direction $Direction `
                                    -Access $Access `
                                    -RemotePort $RemotePort `
                                    -LocalPort $LocalPort `
                                    -Protocol $Protocol `
                                    -Description $Description `
                                    -ApplicationPath $ApplicationPath `
                                    -Service $Service
        )
        {
        }
        else
        {
            $valid = $false
        }
    }

    # Returns whether or not $exists complies with $Ensure
    $returnValue = ($valid -and $exists -eq ($Ensure -eq "Present"))

    Write-Verbose "TEST: Returning $returnValue"
    
    return $returnValue
} 

#region HelperFunctions

######################
## Helper Functions ##
######################

# Function to Set a Firewall Rule based on specified parameters
function Set-FirewallRule
{
    param (
        [Parameter(Mandatory)]
        [String]$Name,
        [String]$DisplayName,
        [String]$DisplayGroup,
        [String]$State,
        [String[]]$Profile,
        [String]$Direction,
        [String]$Access,
        [String[]]$RemotePort,
        [String[]]$LocalPort,
        [String]$Protocol,
        [String]$Description,
        [String]$ApplicationPath,
        [String]$Service
    )

    $parameters = @{}
    $commandName = "New-NetFirewallRule"

    $parameters["Name"] = $Name

    if($DisplayName)
    {
        $parameters["DisplayName"] = $DisplayName
    }

    if($DisplayGroup)
    {
        $parameters["Group"] = $DisplayGroup
    }
    else
    {
        $parameters["Group"] = $DefaultGroup
    }

    if($State)
    {
        if($State -eq "Enabled")
        {
            $parameters["Enabled"] = "True"
        }
        else
        {
            $parameters["Enabled"] = "False"
        }
    }

    if($Profile)
    {
        $parameters["Profile"] = $Profile
    }

    if($Direction)
    {
        $parameters["Direction"] = $Direction
    }

    if($Access)
    {
        $parameters["Action"] = $Access
    }

    if($RemotePort)
    {
        $parameters["RemotePort"] = $RemotePort
    }

    if($LocalPort)
    {
        $parameters["LocalPort"] = $LocalPort
    }

    if($Protocol)
    {
        $parameters["Protocol"] = $Protocol
    }

    if($Description)
    {
        $parameters["Description"] = $Description
    }

    if($ApplicationPath)
    {
        $parameters["Program"] = $ApplicationPath
    }

    if($Service)
    {
        $parameters["Service"] = $Service
    }

    Write-Verbose "SET: Invoke Set-NetFirewallRule [$Name] with splatting its parameters"
    & $commandName @parameters
}

# Function to validate if the supplied Rule adheres to all parameters set
function Test-RuleHasProperties
{
    param (
        [Parameter(Mandatory)]
        $FirewallRule,        
        [String]$Name,
        [String]$DisplayGroup,
        [String]$State,
        [String[]]$Profile,
        [String]$Direction,
        [String]$Access,
        [String[]]$RemotePort,
        [String[]]$LocalPort,
        [String]$Protocol,
        [String]$Description,
        [String]$ApplicationPath,
        [String]$Service
    )

    $properties = Get-FirewallRuleProperty -FirewallRule $FirewallRule -Property All
       
    $desiredConfigurationMatch = $true

    if ($Name -and ($FirewallRule.Name -ne $Name))
    {
        Write-Verbose "Test-RuleHasProperties: Name property value - $FirewallRule.Name does not match desired state - $Name"

        $desiredConfigurationMatch = $false
    }

    if ($Access -and ($FirewallRule.Action -ne $Access))
    {
        Write-Verbose "Test-RuleHasProperties: Access property value - $($FirewallRule.Action) does not match desired state - $Access"

        $desiredConfigurationMatch = $false
    }

    if ($State -and ($FirewallRule.Enabled.ToString() -eq ("Enabled" -ne $State)))
    {
        Write-Verbose "Test-RuleHasProperties: State property value - $FirewallRule.Enabled.ToString() does not match desired state - $State"

        $desiredConfigurationMatch = $false
    }

    if ($Profile)
    {
        [String[]]$networkProfileinRule = $FirewallRule.Profile.ToString() -replace(" ", "") -split(",")

        if ($networkProfileinRule.Count -eq $Profile.Count)
        {
            foreach($networkProfile in $Profile)
            {
                if (-not ($networkProfileinRule -contains($networkProfile)))
                {
                    Write-Verbose "Test-RuleHasProperties: Profile property value - '$networkProfileinRule' does not match desired state - '$Profile'"
        
                    $desiredConfigurationMatch = $false                           
                }
            }
        }
        else
        {
            Write-Verbose "Test-RuleHasProperties: Profile property value - '$networkProfileinRule' does not match desired state - '$Profile'"
            
            $desiredConfigurationMatch = $false  
        }             
    }

    if ($Direction -and ($FirewallRule.Direction -ne $Direction))
    {
        Write-Verbose "Test-RuleHasProperties: Direction property value - $FirewallRule.Direction does not match desired state - $Direction"
        
        $desiredConfigurationMatch = $false

    }

    if ($RemotePort)
    {
        [String[]]$remotePortInRule = $properties.PortFilters.RemotePort
     
        if ($remotePortInRule.Count -eq $RemotePort.Count)
        {
            foreach($port in $RemotePort)
            {
                if (-not ($remotePortInRule -contains($port)))
                {
                    Write-Verbose "Test-RuleHasProperties: RemotePort property value - '$remotePortInRule' does not match desired state - '$RemotePort'"
                    
                    $desiredConfigurationMatch = $false                   
                }
            }
        }
        else
        {
            Write-Verbose "Test-RuleHasProperties: RemotePort property value - '$remotePortInRule' does not match desired state - '$RemotePort'"

            $desiredConfigurationMatch = $false
        } 
    }

    if ($LocalPort)
    {
        [String[]]$localPortInRule = $properties.PortFilters.LocalPort
     
        if ($localPortInRule.Count -eq $LocalPort.Count)
        {
            foreach($port in $LocalPort)
            {
                if (-not ($localPortInRule -contains($port)))
                {
                    Write-Verbose "Test-RuleHasProperties: LocalPort property value - '$localPortInRule' does not match desired state - '$LocalPort'"

                    $desiredConfigurationMatch = $false                 
                }
            }
        }
        else
        {
            Write-Verbose "Test-RuleHasProperties: LocalPort property value - '$localPortInRule' does not match desired state - '$LocalPort'"

            $desiredConfigurationMatch = $false
        } 
    }

    if ($Protocol -and ($properties.PortFilters.Protocol -ne $Protocol)) 
    {
        Write-Verbose "Test-RuleHasProperties: Protocol property value - $properties.PortFilters.Protocol does not match desired state - $Protocol"

        $desiredConfigurationMatch = $false
    }

    if ($Description -and ($FirewallRule.Description -ne $Description)) 
    {
        Write-Verbose "Test-RuleHasProperties: Description property value - $FirewallRule.Description does not match desired state - $Description"

        $desiredConfigurationMatch = $false
    }

    if ($ApplicationPath -and ($properties.ApplicationFilters.Program -ne $ApplicationPath)) 
    {
        Write-Verbose "Test-RuleHasProperties: ApplicationPath property value - $properties.ApplicationFilters.Program does not match desired state - $ApplicationPath"

        $desiredConfigurationMatch = $false
    }

    if ($Service -and ($properties.ServiceFilters.Service -ne $Service)) 
    {
        Write-Verbose "Test-RuleHasProperties: Service property value - $properties.ServiceFilters.Service  does not match desired state - $Service"

        $desiredConfigurationMatch = $false
    }

    Write-Verbose "Test-RuleHasProperties returning $desiredConfigurationMatch"
    return $desiredConfigurationMatch
}

# Returns a list of FirewallRules that comply to the specified parameters.
function Get-FirewallRules
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [String]$DisplayGroup
    )

    $firewallRules = @(Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue)

    if (-not $firewallRules)
    {
        Write-Verbose "Get-FirewallRules: No Firewall Rules found for [$Name]"
        return $null
    }
    else
    {
        if ($DisplayGroup)
        {        
            foreach ($firewallRule in $firewallRules)
            {
                if ($firewallRule.DisplayGroup -eq $DisplayGroup)
                {
                    Write-Verbose "Get-FirewallRules: Found a Firewall Rule for Name: [$Name] and DisplayGroup [$DisplayGroup]"
                    return $firewallRule
                }
            }
        }
    }
        
    return $firewallRules    
}

# Returns the filters associated with the given firewall rule
function Get-FirewallRuleProperty
{

    param ( 
        [Parameter(Mandatory)]
        $FirewallRule,
        
        [Parameter(Mandatory)]
        [ValidateSet("All", "AddressFilter", "ApplicationFilter", "InterfaceFilter",
        "InterfaceTypeFilter", "PortFilter", "Profile", "SecurityFilter", "ServiceFilter")]
        $Property
     )
    
    if ($Property -eq "All")
    {
        Write-Verbose "Get-FirewallRuleProperty:  Get all the properties"

        $properties = @{}

        Write-Verbose "Get-FirewallRuleProperty: Add filter info to rule map"
        $properties.AddressFilters =  @(Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $FirewallRule)
        $properties.ApplicationFilters = @(Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $FirewallRule)
        $properties.InterfaceFilters = @(Get-NetFirewallInterfaceFilter -AssociatedNetFirewallRule $FirewallRule)
        $properties.InterfaceTypeFilters = @(Get-NetFirewallInterfaceTypeFilter -AssociatedNetFirewallRule $FirewallRule)
        $properties.PortFilters = @(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $FirewallRule)
        $properties.Profile = @(Get-NetFirewallProfile -AssociatedNetFirewallRule $FirewallRule)
        $properties.SecurityFilters = @(Get-NetFirewallSecurityFilter -AssociatedNetFirewallRule $FirewallRule)
        $properties.ServiceFilters = @(Get-NetFirewallServiceFilter -AssociatedNetFirewallRule $FirewallRule)
    
        return $properties
    }        

    if ($Property -eq "AddressFilter" -or $Property -eq "ApplicationFilter" -or $Property -eq "InterfaceFilter" `
        -or $Property -eq "InterfaceTypeFilter" -or $Property -eq "PortFilter" -or $Property -eq "Profile" `
        -or $Property -eq "SecurityFilter" -or $Property -eq "ServiceFilter")
    {
        Write-Verbose "Get-FirewallRuleProperty: Get only [$Property] property"

        return &(Get-Command "Get-NetFirewall$Property")  -AssociatedNetFireWallRule $FireWallRule
    }    
}

#endregion

Export-ModuleMember -Function *-TargetResource