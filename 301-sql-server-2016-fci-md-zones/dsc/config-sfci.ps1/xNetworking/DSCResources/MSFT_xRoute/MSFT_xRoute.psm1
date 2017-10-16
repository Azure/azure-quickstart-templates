data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingRouteMessage=Getting {0} Route on "{1}" dest {2} nexthop {3}.
RouteExistsMessage={0} Route on "{1}" dest {2} nexthop {3} exists.
RouteDoesNotExistMessage={0} Route on "{1}" dest {2} nexthop {3} does not exist.
SettingRouteMessage=Setting {0} Route on "{1}" dest {2} nexthop {3}.
EnsureRouteExistsMessage=Ensuring {0} Route on "{1}" dest {2} nexthop {3} exists.
EnsureRouteDoesNotExistMessage=Ensuring {0} Route on "{1}" dest {2} nexthop {3} does not exist.
RouteCreatedMessage={0} Route on "{1}" dest {2} nexthop {3} has been created.
RouteUpdatedMessage={0} Route on "{1}" dest {2} nexthop {3} has been updated.
RouteRemovedMessage={0} Route on "{1}" dest {2} nexthop {3} has been removed.
TestingRouteMessage=Testing {0} Route on "{1}" dest {2} nexthop {3}.
RoutePropertyNeedsUpdateMessage={4} property on {0} Route on "{1}" dest {2} nexthop {3} is different. Change required.
RouteDoesNotExistButShouldMessage={0} Route on "{1}" dest {2} nexthop {3} does not exist but should. Change required.
RouteExistsButShouldNotMessage={0} Route on "{1}" dest {2} nexthop {3} exists but should not. Change required.
RouteDoesNotExistAndShouldNotMessage={0} Route on "{1}" dest {2} nexthop {3} does not exist and should not. Change not required.
InterfaceNotAvailableError=Interface "{0}" is not available. Please select a valid interface and try again.
AddressFormatError=Address "{0}" is not in the correct format. Please correct the Address parameter in the configuration and try again.
AddressIPv4MismatchError=Address "{0}" is in IPv4 format, which does not match address family {1}. Please correct either of them in the configuration and try again.
AddressIPv6MismatchError=Address "{0}" is in IPv6 format, which does not match address family {1}. Please correct either of them in the configuration and try again.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPrefix,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $NextHop
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingRouteMessage) `
            -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
        ) -join '' )

    # Lookup the existing Route
    $Route = Get-Route @PSBoundParameters

    $returnValue = @{
        InterfaceAlias    = $InterfaceAlias
        AddressFamily     = $AddressFamily
        DestinationPrefix = $DestinationPrefix
        NextHop           = $NextHop
    }
    if ($Route)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.RouteExistsMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            RouteMetric = [Uint16] $Route.RouteMetric
            Publish = $Route.Publish
            PreferredLifetime = [Double] $Route.PreferredLifetime.TotalSeconds
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.RouteDoesNotExistMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }

    $returnValue
} # Get-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPrefix,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [Uint16] $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String] $Publish = 'No',

        [Double] $PreferredLifetime
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing Route
    $Route = Get-Route @PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureRouteExistsMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        if ($Route)
        {
            # The Route exists - update it
            Set-NetRoute @PSBoundParameters `
                -Confirm:$false `
                -ErrorAction Stop


            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.RouteUpdatedMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        }
        else
        {
            # The Route does not exit - create it
            New-NetRoute @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.RouteCreatedMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureRouteDoesNotExistMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        if ($Route)
        {
            <#
            The Route exists - remove it
            Use the parameters passed to Set-TargetResource to delete the appropriate route.
            Clear the Publish and PreferredLifetime parameters so they aren't passed to the
            Remove-NetRoute cmdlet.
            #>

            $null = $PSBoundParameters.Remove('Publish')
            $null = $PSBoundParameters.Remove('PreferredLifetime')

            Remove-NetRoute @PSBoundParameters `
                -Confirm:$false `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.RouteRemovedMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPrefix,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [Uint16] $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String] $Publish = 'No',

        [Double] $PreferredLifetime
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingRouteMessage) `
           -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
        ) -join '' )

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Check the parameters
    Test-ResourceProperty @PSBoundParameters

    # Lookup the existing Route
    $Route = Get-Route @PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        # The route should exist
        if ($Route)
        {
            # The route exists and does - but check the parameters
            if (($PSBoundParameters.ContainsKey('RouteMetric')) `
                -and ($Route.RouteMetric -ne $RouteMetric))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.RoutePropertyNeedsUpdateMessage) `
                       -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop,'RouteMetric' `
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Publish')) `
                -and ($Route.Publish -ne $Publish))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.RoutePropertyNeedsUpdateMessage) `
                       -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop,'Publish' `
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('PreferredLifetime')) `
                -and ($Route.PreferredLifetime.TotalSeconds -ne $PreferredLifetime))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.RoutePropertyNeedsUpdateMessage) `
                       -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop,'PreferredLifetime' `
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # The route doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.RouteDoesNotExistButShouldMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The route should not exist
        if ($Route)
        {
            # The route exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.RouteExistsButShouldNotMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The route does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.RouteDoesNotExistAndShouldNotMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

<#
.Synopsis
    This function looks up the route using the parameters and returns
    it. If the route is not found $null is returned.
#>
Function Get-Route {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPrefix,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [Uint16] $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String] $Publish = 'No',

        [Double] $PreferredLifetime
    )

    try
    {
        $Route = Get-NetRoute `
            -InterfaceAlias $InterfaceAlias `
            -AddressFamily $AddressFamily `
            -DestinationPrefix $DestinationPrefix `
            -NextHop $NextHop `
            -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $Route = $null
    }
    catch
    {
        Throw $_
    }
    Return $Route
}
<#
.Synopsis
    This function validates the parameters passed. Called by Test-Resource.
    Will throw an error if any parameters are invalid.
#>
Function Test-ResourceProperty {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPrefix,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [Uint16] $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String] $Publish = 'No',

        [Double] $PreferredLifetime
    )

    # Validate the Adapter exists
    if (-not (Get-NetAdapter | Where-Object -Property Name -EQ $InterfaceAlias ))
    {
        $errorId = 'InterfaceNotAvailable'
        $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
        $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $InterfaceAlias
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # Validate the DestinationPrefix Parameter
    $Components = $DestinationPrefix -split '/'
    $Prefix = $Components[0]
    $Subnet = $Components[1]

    if (-not ([System.Net.Ipaddress]::TryParse($Prefix, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $Prefix
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress] $Prefix).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $Prefix,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6.ToString()) `
        -and ($AddressFamily -ne 'IPv6'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $Prefix,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # Validate the NextHop Parameter
    if (-not ([System.Net.Ipaddress]::TryParse($NextHop, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $NextHop
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress] $NextHop).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $NextHop,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6.ToString()) `
        -and ($AddressFamily -ne 'IPv6'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $NextHop,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}

Export-ModuleMember -Function *-TargetResource
