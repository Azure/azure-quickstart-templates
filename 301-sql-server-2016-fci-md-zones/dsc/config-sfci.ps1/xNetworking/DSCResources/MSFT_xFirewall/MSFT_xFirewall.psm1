data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingFirewallRuleMessage=Getting firewall rule with Name '{0}'.
FirewallRuleDoesNotExistMessage=Firewall rule with Name '{0}' does not exist.
FirewallParameterValueMessage=Firewall rule with Name '{0}' parameter {1} is '{2}'.
ApplyingFirewallRuleMessage=Applying settings for firewall rule with Name '{0}'.
FindFirewallRuleMessage=Find firewall rule with Name '{0}'.
FirewallRuleShouldExistMessage=We want the firewall rule with Name '{0}' to exist since Ensure is set to {1}.
FirewallRuleShouldExistAndDoesMessage=We want the firewall rule with Name '{0}' to exist and it does. Check for valid properties.
CheckFirewallRuleParametersMessage=Check each defined parameter against the existing firewall rule with Name '{0}'.
UpdatingExistingFirewallMessage=Updating existing firewall rule with Name '{0}'.
FirewallRuleShouldExistAndDoesNotMessage=We want the firewall rule with Name '{0}' to exist, but it does not.
FirewallRuleShouldNotExistMessage=We do not want the firewall rule with Name '{0}' to exist since Ensure is set to {1}.
FirewallRuleShouldNotExistButDoesMessage=We do not want the firewall rule with Name '{0}' to exist, but it does. Removing it.
FirewallRuleShouldNotExistAndDoesNotMessage=We do not want the firewall rule with Name '{0}' to exist, and it does not.
CheckingFirewallRuleMessage=Checking settings for firewall rule with Name '{0}'.
CheckingFirewallReturningMessage=Check Firewall rule with Name '{0}' returning {1}.
PropertyNoMatchMessage={0} property value '{1}' does not match desired state '{2}'.
TestFirewallRuleReturningMessage=Test Firewall rule with Name '{0}' returning {1}.
FirewallRuleNotFoundMessage=No Firewall Rule found with Name '{0}'.
GetAllPropertiesMessage=Get all the properties and add filter info to rule map.
RuleNotUniqueError={0} Firewall Rules with the Name '{1}' were found. Only one expected.
'@
}

<#
    This is an array of all the parameters used by this resource
    It can be used by several of the functions to reduce the amount of code required
    Each element contains 3 properties:
    Name: The parameter name
    Source: The source where the existing parameter can be pulled from
    Type: This is the content type of the paramater (it is either array or string or blank)
    A blank type means it will not be compared
    data ParameterList
    Delimiter: Only required for Profile parameter, because Get-NetFirewall rule doesn't
    return the profile as an array, but a comma delimited string. Setting this value causes
    the functions to first split the parameter into an array.
#>
data ParameterList
{
    @( 
        @{ Name = 'Name'; Source = '$FirewallRule.Name'; Type = 'String' },
        @{ Name = 'DisplayName'; Source = '$FirewallRule.DisplayName'; Type = 'String' },
        @{ Name = 'Group'; Source = '$FirewallRule.Group'; Type = 'String' },
        @{ Name = 'DisplayGroup'; Source = '$FirewallRule.DisplayGroup'; Type = '' },
        @{ Name = 'Enabled'; Source = '$FirewallRule.Enabled'; Type = 'String' },
        @{ Name = 'Action'; Source = '$FirewallRule.Action'; Type = 'String' },
        @{ Name = 'Profile'; Source = '$firewallRule.Profile'; Type = 'Array'; Delimiter = ', ' },
        @{ Name = 'Direction'; Source = '$FirewallRule.Direction'; Type = 'String' },
        @{ Name = 'Description'; Source = '$FirewallRule.Description'; Type = 'String' },
        @{ Name = 'RemotePort'; Source = '$properties.PortFilters.RemotePort'; Type = 'Array' },
        @{ Name = 'LocalPort'; Source = '$properties.PortFilters.LocalPort'; Type = 'Array' },
        @{ Name = 'Protocol'; Source = '$properties.PortFilters.Protocol'; Type = 'String' },
        @{ Name = 'Program'; Source = '$properties.ApplicationFilters.Program'; Type = 'String' },
        @{ Name = 'Service'; Source = '$properties.ServiceFilters.Service'; Type = 'String' },
        @{ Name = 'Authentication'; Source = '$properties.SecurityFilters.Authentication'; Type = 'String' },
        @{ Name = 'Encryption'; Source = '$properties.SecurityFilters.Encryption'; Type = 'String' }
        @{ Name = 'InterfaceAlias'; Source = '$properties.InterfaceFilters.InterfaceAlias'; Type = 'Array' }
        @{ Name = 'InterfaceType'; Source = '$properties.InterfaceTypeFilters.InterfaceType'; Type = 'String' }
        @{ Name = 'LocalAddress'; Source = '$properties.AddressFilters.LocalAddress'; Type = 'Array' }
        @{ Name = 'LocalUser'; Source = '$properties.SecurityFilters.LocalUser'; Type = 'String' }
        @{ Name = 'Package'; Source = '$properties.ApplicationFilters.Package'; Type = 'String' }
        @{ Name = 'Platform'; Source = '$firewallRule.Platform'; Type = 'Array' }
        @{ Name = 'RemoteAddress'; Source = '$properties.AddressFilters.RemoteAddress'; Type = 'Array' }
        @{ Name = 'RemoteMachine'; Source = '$properties.SecurityFilters.RemoteMachine'; Type = 'String' }
        @{ Name = 'RemoteUser'; Source = '$properties.SecurityFilters.RemoteUser'; Type = 'String' }
        @{ Name = 'DynamicTransport'; Source = '$properties.PortFilters.DynamicTransport'; Type = 'String' }
        @{ Name = 'EdgeTraversalPolicy'; Source = '$FirewallRule.EdgeTraversalPolicy'; Type = 'String' }
        @{ Name = 'IcmpType'; Source = '$properties.PortFilters.IcmpType'; Type = 'Array' }
        @{ Name = 'LocalOnlyMapping'; Source = '$FirewallRule.LocalOnlyMapping'; Type = 'Boolean' }
        @{ Name = 'LooseSourceMapping'; Source = '$FirewallRule.LooseSourceMapping'; Type = 'Boolean' }
        @{ Name = 'OverrideBlockRules'; Source = '$properties.SecurityFilters.OverrideBlockRules'; Type = 'Boolean' }
        @{ Name = 'Owner'; Source = '$FirewallRule.Owner'; Type = 'String' }
    )
}

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )
    $ErrorActionPreference = 'Stop'
    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingFirewallRuleMessage) -f $Name
        ) -join '')

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.FindFirewallRuleMessage) -f $Name
        ) -join '')
    $firewallRule = Get-FirewallRule -Name $Name

    if (-not $firewallRule)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.FirewallRuleDoesNotExistMessage) -f $Name
            ) -join '')
        return @{
            Ensure = 'Absent'
            Name   = $Name
        }
    }

    $properties = Get-FirewallRuleProperty -FirewallRule $firewallRule

    $Result = @{
        Ensure = 'Present'
    }

    # Populate the properties for get target resource by looping through
    # the parameter array list and adding the values to 
    foreach ($parameter in $ParameterList)
    {

        if ($parameter.type -eq 'Array')
        {
            $Value = @(Invoke-Expression -Command "`$($($parameter.source))")
            $Result += @{
                $parameter.Name = $Value
            }

            if ($parameter.delimiter)
            {
                $Value = $Value -split $parameter.delimiter
            }
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.FirewallParameterValueMessage) -f $Name,$parameter.Name,($Value -join ',')
                ) -join '')
        }
        else 
        {
            $Value = (Invoke-Expression -Command "`$($($parameter.source))")
            $Result += @{
                $parameter.Name = $Value
            }

            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.FirewallParameterValueMessage) -f $Name,$parameter.Name,$Value
                ) -join '')

        }
    }
    return $Result
}

function Set-TargetResource
{
    param
    (
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        # Localized, user-facing name of the Firewall Rule being created
        [ValidateNotNullOrEmpty()]
        [String] $DisplayName,

        # Name of the Firewall Group where we want to put the Firewall Rules
        [ValidateNotNullOrEmpty()]
        [String] $Group,

        # Ensure the presence/absence of the resource
        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        # Enable or disable the supplied configuration
        [ValidateSet('True', 'False')]
        [String] $Enabled,

        [ValidateSet('NotConfigured', 'Allow', 'Block')]
        [String] $Action,

        # Specifies one or more profiles to which the rule is assigned
        [String[]] $Profile,

        # Direction of the connection
        [ValidateSet('Inbound', 'Outbound')]
        [String] $Direction,

        # Specific Port used for filter. Specified by port number, range, or keyword
        [ValidateNotNullOrEmpty()]
        [String[]] $RemotePort,

        # Local Port used for the filter
        [ValidateNotNullOrEmpty()]
        [String[]] $LocalPort,

        # Specific Protocol for filter. Specified by name, number, or range
        [ValidateNotNullOrEmpty()]
        [String] $Protocol,

        # Documentation for the Rule
        [String] $Description,

        # Path and file name of the program for which the rule is applied
        [ValidateNotNullOrEmpty()]
        [String] $Program,

        # Specifies the short name of a Windows service to which the firewall rule applies
        [ValidateNotNullOrEmpty()]
        [String] $Service,

        # Specifies that authentication is required on firewall rules
        [ValidateSet('NotRequired', 'Required', 'NoEncap')]
        [String] $Authentication,

        # Specifies that encryption in authentication is required on firewall rules
        [ValidateSet('NotRequired', 'Required', 'Dynamic')]
        [String] $Encryption,

        # Specifies the alias of the interface that applies to the traffic
        [ValidateNotNullOrEmpty()]
        [String[]] $InterfaceAlias,

        # Specifies that only network connections made through the indicated interface types are
        # subject to the requirements of this rule
        [ValidateSet('Any', 'Wired', 'Wireless', 'RemoteAccess')]
        [String] $InterfaceType,

        # Specifies that network packets with matching IP addresses match this rule
        [ValidateNotNullOrEmpty()]
        [String[]] $LocalAddress,

        # Specifies the principals to which network traffic this firewall rule applies
        [ValidateNotNullOrEmpty()]
        [String] $LocalUser,

        # Specifies the Windows Store application to which the firewall rule applies
        [ValidateNotNullOrEmpty()]
        [String] $Package,

        # Specifies which version of Windows the associated rule applies
        [ValidateNotNullOrEmpty()]
        [String[]] $Platform,

        # Specifies that network packets with matching IP addresses match this rule
        [ValidateNotNullOrEmpty()]
        [String[]] $RemoteAddress,

        # Specifies that matching IPsec rules of the indicated computer accounts are created
        [ValidateNotNullOrEmpty()]
        [String] $RemoteMachine,

        # Specifies that matching IPsec rules of the indicated user accounts are created
        [ValidateNotNullOrEmpty()]
        [String] $RemoteUser,
        
        # Specifies a dynamic transport
        [ValidateSet('Any','ProximityApps','ProximitySharing','WifiDirectPrinting','WifiDirectDisplay','WifiDirectDevices')]
        [String] $DynamicTransport,
        
        # Specifies that matching firewall rules of the indicated edge traversal policy are created
        [ValidateSet('Block','Allow','DeferToUser','DeferToApp')]
        [String] $EdgeTraversalPolicy,
        
        # Specifies the ICMP type codes
        [ValidateNotNullOrEmpty()]
        [String[]] $IcmpType,
        
        # Indicates that matching firewall rules of the indicated value are created
        [Boolean] $LocalOnlyMapping,

        # Indicates that matching firewall rules of the indicated value are created
        [Boolean] $LooseSourceMapping,

        # Indicates that matching network traffic that would otherwise be blocked are allowed
        [Boolean] $OverrideBlockRules,

        # Specifies that matching firewall rules of the indicated owner are created
        [ValidateNotNullOrEmpty()]
        [String] $Owner
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingFirewallRuleMessage) -f $Name
        ) -join '')

    # Remove any parameters not used in Splats
    $null = $PSBoundParameters.Remove('Ensure')

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.FindFirewallRuleMessage) -f $Name
        ) -join '')
    $firewallRule = Get-FirewallRule -Name $Name

    $exists = ($firewallRule -ne $null)

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.FirewallRuleShouldExistMessage) -f $Name,$Ensure
            ) -join '')

        if ($exists)
        {
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.FirewallRuleShouldExistAndDoesMessage) -f $Name
                ) -join '')
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.CheckFirewallRuleParametersMessage) -f $Name
                ) -join '')

            if (-not (Test-RuleProperties -FirewallRule $firewallRule @PSBoundParameters))
            {
                Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                    $($LocalizedData.UpdatingExistingFirewallMessage) -f $Name
                    ) -join '')

                # If the Group is being changed the the rule needs to be recreated
                if ($PSBoundParameters.ContainsKey('Group') `
                    -and ($Group -ne $FirewallRule.Group))
                {

                    Remove-NetFirewallRule -Name $Name

                    # Merge the existing rule values into the PSBoundParameters
                    # so that it can be splatted.

                    $properties = Get-FirewallRuleProperty -FirewallRule $firewallRule

                    # Loop through each possible property and if it is not passed as a parameter
                    # then set the PSBoundParameter property to the exiting rule value.
                    Foreach ($parameter in $ParametersList) {
                        if (-not $PSBoundParameters.ContainsKey($parameter.Name))
                        {
                            $ParameterValue = (Invoke-Expression -Command "`$($($parameter.source))")
                            if ($ParameterValue) {
                                $null = $PSBoundParameters.Add($parameter.Name,$ParameterValue)
                            }
                        }
                    }

                    New-NetFirewallRule @PSBoundParameters
                }
                else
                {
                    # If the DisplayName is provided then need to remove it
                    # And change it to NewDisplayName if it is different.
                    if ($PSBoundParameters.ContainsKey('DisplayName'))
                    {
                        $null = $PSBoundParameters.Remove('DisplayName')
                        if ($DisplayName -ne $FirewallRule.DisplayName)
                        {
                            $null = $PSBoundParameters.Add('NewDisplayName',$Name)
                        }
                    }

                    # Set the existing Firewall rule based on specified parameters
                    Set-NetFirewallRule @PSBoundParameters
                }
            }
        }
        else
        {
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.FirewallRuleShouldExistAndDoesNotMessage) -f $Name
                ) -join '')

            # Set any default parameter values
            if (-not $DisplayName) {
                if (-not $PSBoundParameters.ContainsKey('DisplayName')) {
                    $null = $PSBoundParameters.Add('DisplayName',$Name)
                } else {
                    $PSBoundParameters.DisplayName = $Name
                }
            }

            # Add the new Firewall rule based on specified parameters
            New-NetFirewallRule @PSBoundParameters
        }
    }
    else
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.FirewallRuleShouldNotExistMessage) -f $Name,$Ensure
            ) -join '')

        if ($exists)
        {
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.FirewallRuleShouldNotExistButDoesMessage) -f $Name
                ) -join '')

            # Remove the existing Firewall rule
            Remove-NetFirewallRule -Name $Name
        }
        else
        {
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.FirewallRuleShouldNotExistAndDoesNotMessage) -f $Name
                ) -join '')
            # Do Nothing
        }
    }
}


function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        # Localized, user-facing name of the Firewall Rule being created
        [ValidateNotNullOrEmpty()]
        [String] $DisplayName,

        # Name of the Firewall Group where we want to put the Firewall Rules
        [ValidateNotNullOrEmpty()]
        [String] $Group,

        # Ensure the presence/absence of the resource
        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        # Enable or disable the supplied configuration
        [ValidateSet('True', 'False')]
        [String] $Enabled,

        [ValidateSet('NotConfigured', 'Allow', 'Block')]
        [String] $Action,

        # Specifies one or more profiles to which the rule is assigned
        [String[]] $Profile,

        # Direction of the connection
        [ValidateSet('Inbound', 'Outbound')]
        [String] $Direction,

        # Specific Port used for filter. Specified by port number, range, or keyword
        [ValidateNotNullOrEmpty()]
        [String[]] $RemotePort,

        # Local Port used for the filter
        [ValidateNotNullOrEmpty()]
        [String[]] $LocalPort,

        # Specific Protocol for filter. Specified by name, number, or range
        [ValidateNotNullOrEmpty()]
        [String] $Protocol,

        # Documentation for the Rule
        [String] $Description,

        # Path and file name of the program for which the rule is applied
        [ValidateNotNullOrEmpty()]
        [String] $Program,

        # Specifies the short name of a Windows service to which the firewall rule applies
        [ValidateNotNullOrEmpty()]
        [String] $Service,

        # Specifies that authentication is required on firewall rules
        [ValidateSet('NotRequired', 'Required', 'NoEncap')]
        [String] $Authentication,
        
        # Specifies that encryption in authentication is required on firewall rules
        [ValidateSet('NotRequired', 'Required', 'Dynamic')]
        [String] $Encryption,

        # Specifies the alias of the interface that applies to the traffic
        [ValidateNotNullOrEmpty()]
        [String[]] $InterfaceAlias,

        # Specifies that only network connections made through the indicated interface types are
        # subject to the requirements of this rule
        [ValidateSet('Any', 'Wired', 'Wireless', 'RemoteAccess')]
        [String] $InterfaceType,

        # Specifies that network packets with matching IP addresses match this rule
        [ValidateNotNullOrEmpty()]
        [String[]] $LocalAddress,

        # Specifies the principals to which network traffic this firewall rule applies
        [ValidateNotNullOrEmpty()]
        [String] $LocalUser,

        # Specifies the Windows Store application to which the firewall rule applies
        [ValidateNotNullOrEmpty()]
        [String] $Package,

        # Specifies which version of Windows the associated rule applies
        [ValidateNotNullOrEmpty()]
        [String[]] $Platform,

        # Specifies that network packets with matching IP addresses match this rule
        [ValidateNotNullOrEmpty()]
        [String[]] $RemoteAddress,

        # Specifies that matching IPsec rules of the indicated computer accounts are created
        [ValidateNotNullOrEmpty()]
        [String] $RemoteMachine,

        # Specifies that matching IPsec rules of the indicated user accounts are created
        [ValidateNotNullOrEmpty()]
        [String] $RemoteUser,
        
        # Specifies a dynamic transport
        [ValidateSet('Any','ProximityApps','ProximitySharing','WifiDirectPrinting','WifiDirectDisplay','WifiDirectDevices')]
        [String] $DynamicTransport,
        
        # Specifies that matching firewall rules of the indicated edge traversal policy are created
        [ValidateSet('Block','Allow','DeferToUser','DeferToApp')]
        [String] $EdgeTraversalPolicy,
        
        # Specifies the ICMP type codes
        [ValidateNotNullOrEmpty()]
        [String[]] $IcmpType,
        
        # Indicates that matching firewall rules of the indicated value are created
        [Boolean] $LocalOnlyMapping,

        # Indicates that matching firewall rules of the indicated value are created
        [Boolean] $LooseSourceMapping,

        # Indicates that matching network traffic that would otherwise be blocked are allowed
        [Boolean] $OverrideBlockRules,

        # Specifies that matching firewall rules of the indicated owner are created
        [ValidateNotNullOrEmpty()]
        [String] $Owner
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingFirewallRuleMessage) -f $Name
        ) -join '')

    # Remove any parameters not used in Splats
    $null = $PSBoundParameters.Remove('Ensure')

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.FindFirewallRuleMessage) -f $Name
        ) -join '')
    $firewallRule = Get-FirewallRule -Name $Name

    $exists = ($firewallRule -ne $null)

    if (-not $exists)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.FirewallRuleDoesNotExistMessage) -f $Name
            ) -join '')

        # Returns whether complies with $Ensure
        $returnValue = ($false -eq ($Ensure -eq 'Present'))

        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.CheckingFirewallReturningMessage) -f $Name,$returnValue
            ) -join '')

        return $returnValue
    }

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckFirewallRuleParametersMessage) -f $Name
        ) -join '')
    $desiredConfigurationMatch = Test-RuleProperties -FirewallRule $firewallRule @PSBoundParameters

    # Returns whether or not $exists complies with $Ensure
    $returnValue = ($desiredConfigurationMatch -and $exists -eq ($Ensure -eq 'Present'))

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingFirewallReturningMessage) -f $Name,$returnValue
        ) -join '')

    return $returnValue
}

#region HelperFunctions
<#
    .SYNOPSIS
    Function to validate if the supplied Rule adheres to all parameters set
#>
function Test-RuleProperties
{
    param
    (
        [Parameter(Mandatory)]
        $FirewallRule,
        [String] $Name,
        [String] $DisplayName,
        [string] $Group,
        [String] $DisplayGroup,
        [String] $Enabled = 'True',
        [string] $Action = 'Allow',
        [String[]] $Profile = 'Any',
        [String] $Direction = 'Inbound',
        [String[]] $RemotePort,
        [String[]] $LocalPort,
        [String] $Protocol,
        [String] $Description,
        [String] $Program,
        [String] $Service,
        [String] $Authentication,
        [String] $Encryption,
        [String[]] $InterfaceAlias,
        [String] $InterfaceType,
        [String[]] $LocalAddress,
        [String] $LocalUser,
        [String] $Package,
        [String[]] $Platform,
        [String[]] $RemoteAddress,
        [String] $RemoteMachine,
        [String] $RemoteUser,
        [String] $DynamicTransport,
        [String] $EdgeTraversalPolicy,
        [String[]] $IcmpType,
        [Boolean] $LocalOnlyMapping,
        [Boolean] $LooseSourceMapping,
        [Boolean] $OverrideBlockRules,
        [String] $Owner
    )

    $properties = Get-FirewallRuleProperty -FirewallRule $FirewallRule

    $desiredConfigurationMatch = $true

    # Loop through the $ParameterList array and compare the source
    # with the value of each parameter. If different then
    # set $desiredConfigurationMatch to false.
    foreach ($parameter in $ParameterList)
    {
        $ParameterSource = (Invoke-Expression -Command "`$($($parameter.source))")
        $ParameterNew = (Invoke-Expression -Command "`$$($parameter.name)")
        switch ($parameter.type)
        {
            'String'
            {
                # Perform a plain string comparison.
                if ($ParameterNew -and ($ParameterSource -ne $ParameterNew))
                {
                    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                        $($LocalizedData.PropertyNoMatchMessage) `
                            -f $parameter.Name,$ParameterSource,$ParameterNew
                        ) -join '')
                    $desiredConfigurationMatch = $false
                }
            }
            'Boolean'
            {
                # Perform a boolean comparison.
                if ($ParameterNew -and ($ParameterSource -ne $ParameterNew))
                {
                    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                        $($LocalizedData.PropertyNoMatchMessage) `
                            -f $parameter.Name,$ParameterSource,$ParameterNew
                        ) -join '')
                    $desiredConfigurationMatch = $false
                }
            }
            'Array'
            {
                # Array comparison uses Compare-Object
                if ($ParameterSource -eq $null)
                {
                    $ParameterSource = @()
                }
                if ($parameter.delimiter)
                {
                    $ParameterSource = $ParameterSource -split $parameter.delimiter
                }
                if ($ParameterNew `
                    -and ((Compare-Object `
                        -ReferenceObject $ParameterSource `
                        -DifferenceObject $ParameterNew).Count -ne 0))
                {
                    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                        $($LocalizedData.PropertyNoMatchMessage) `
                            -f $parameter.Name,($ParameterSource -join ','),($ParameterNew -join ',')
                        ) -join '')
                    $desiredConfigurationMatch = $false
                }
            }
        }
    }

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestFirewallRuleReturningMessage) -f $Name,$desiredConfigurationMatch
        ) -join '')
    return $desiredConfigurationMatch
}


<#
    .SYNOPSIS
    Returns a list of FirewallRules that comply to the specified parameters.
#>
function Get-FirewallRule
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    $firewallRule = @(Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue)

    if (-not $firewallRule)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.FirewallRuleNotFoundMessage) -f $Name
            ) -join '')
        return $null
    }
    # If more than one rule is returned for a name, then throw an exception
    # because this should not be possible.
    if ($firewallRule.Count -gt 1) {
        $errorId = 'RuleNotUnique'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
        $errorMessage = $($LocalizedData.RuleNotUniqueError) -f $firewallRule.Count,$Name
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # The array will only contain a single rule so only return the first one (not the array)
    return $firewallRule[0]
}


<#
    .SYNOPSIS
    Returns the filters associated with the given firewall rule
#>
function Get-FirewallRuleProperty
{
    param (
        [Parameter(Mandatory)]
        $FirewallRule
     )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GetAllPropertiesMessage)
        ) -join '')
    return @{
        AddressFilters       = @(Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $FirewallRule)
        ApplicationFilters   = @(Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $FirewallRule)
        InterfaceFilters     = @(Get-NetFirewallInterfaceFilter -AssociatedNetFirewallRule $FirewallRule)
        InterfaceTypeFilters = @(Get-NetFirewallInterfaceTypeFilter -AssociatedNetFirewallRule $FirewallRule)
        PortFilters          = @(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $FirewallRule)
        Profile              = @(Get-NetFirewallProfile -AssociatedNetFirewallRule $FirewallRule)
        SecurityFilters      = @(Get-NetFirewallSecurityFilter -AssociatedNetFirewallRule $FirewallRule)
        ServiceFilters       = @(Get-NetFirewallServiceFilter -AssociatedNetFirewallRule $FirewallRule)
    }
}
#endregion

Export-ModuleMember -Function *-TargetResource
