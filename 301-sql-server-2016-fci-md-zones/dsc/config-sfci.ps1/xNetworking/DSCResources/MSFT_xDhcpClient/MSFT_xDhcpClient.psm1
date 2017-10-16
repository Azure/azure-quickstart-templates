data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingDHCPClientMessage=Getting the DHCP Client on {1} interface "{0}".
ApplyingDHCPClientMessage=Applying the DHCP Client on {1} interface "{0}".
DHCPClientSetStateMessage=DHCP Client was set to the desired state {2} on {1} interface "{0}".
CheckingDHCPClientMessage=Checking the DHCP Client on {1} interface "{0}".
DHCPClientDoesNotMatchMessage=DHCP Client is not in the desired state {2} on {1} interface "{0}".
InterfaceNotAvailableError=Interface "{0}" is not available. Please select a valid interface and try again.
'@
}

function Get-TargetResource
{
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
        [ValidateSet('Enabled', 'Disabled')]
        [String] $State
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingDHCPClientMessage) `
        -f $InterfaceAlias,$AddressFamily `
        ) -join '')

    Test-ResourceProperty @PSBoundParameters
    
    $CurrentDHCPClient = Get-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily

    $returnValue = @{
        State          = $CurrentDHCPClient.Dhcp
        AddressFamily  = $AddressFamily
        InterfaceAlias = $InterfaceAlias
    }

    $returnValue
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory)]
        [ValidateSet('Enabled', 'Disabled')]
        [String] $State
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingDHCPClientMessage) `
        -f $InterfaceAlias,$AddressFamily `
        ) -join '')

    Test-ResourceProperty @PSBoundParameters
    
    $CurrentDHCPClient = Get-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily
        
    # The DHCP Client is in a different state - so change it.
    Set-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily `
        -Dhcp $State `
        -ErrorAction Stop

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.DHCPClientSetStateMessage) `
        -f $InterfaceAlias,$AddressFamily,$State `
        ) -join '' )
        
} # Set-TargetResource

function Test-TargetResource
{
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
        [ValidateSet('Enabled', 'Disabled')]
        [String] $State
    )

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingDHCPClientMessage) `
        -f $InterfaceAlias,$AddressFamily `
        ) -join '')

    Test-ResourceProperty @PSBoundParameters

    $CurrentDHCPClient = Get-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily
        
    # The DHCP Client is in a different state - so change it.
    if ($CurrentDHCPClient.DHCP -ne $State)
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.DHCPClientDoesNotMatchMessage) `
            -f $InterfaceAlias,$AddressFamily,$State `
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    return $desiredConfigurationMatch
} # Test-TargetResource

function Test-ResourceProperty {
    # Function will check the interface exists.
    # If any problems are detected an exception will be thrown.
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
        [ValidateSet('Enabled', 'Disabled')]
        [String] $State
    )

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
} # Test-ResourceProperty

Export-ModuleMember -function *-TargetResource
