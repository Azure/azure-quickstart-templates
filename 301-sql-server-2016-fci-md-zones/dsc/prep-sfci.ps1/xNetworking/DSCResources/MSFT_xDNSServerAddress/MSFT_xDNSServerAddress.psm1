#######################################################################################
#  xDNSServerAddress : DSC Resource that will set/test/get the current DNS Server
#  Address, by accepting values among those given in xDNSServerAddress.schema.mof
#######################################################################################

data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingDNSServerAddressesMessage=Getting the DNS Server Addresses.
ApplyingDNSServerAddressesMessage=Applying the DNS Server Addresses.
DNSServersSetCorrectlyMessage=DNS Servers are set correctly.
DNSServersAlreadySetMessage=DNS Servers are already set correctly.
CheckingDNSServerAddressesMessage=Checking the DNS Server Addresses.
DNSServersNotCorrectMessage=DNS Servers are not correct. Expected "{0}", actual "{1}".
DNSServersHaveBeenSetCorrectlyMessage=DNS Servers were set to the desired state.
InterfaceNotAvailableError=Interface "{0}" is not available. Please select a valid interface and try again.
AddressFormatError=Address "{0}" is not in the correct format. Please correct the Address parameter in the configuration and try again.
AddressIPv4MismatchError=Address "{0}" is in IPv4 format, which does not match server address family {1}. Please correct either of them in the configuration and try again.
AddressIPv6MismatchError=Address "{0}" is in IPv6 format, which does not match server address family {1}. Please correct either of them in the configuration and try again.
'@
}

######################################################################################
# The Get-TargetResource cmdlet.
# This function will get the present list of DNS ServerAddress DSC Resource
# schema variables on the system
######################################################################################
function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Address,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]$AddressFamily
    )
    
    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingDNSServerAddressesMessage)
        ) -join '')

    $returnValue = @{
        Address = (Get-DnsClientServerAddress `
            -InterfaceAlias $InterfaceAlias `
            -AddressFamily $AddressFamily).ServerAddresses
        AddressFamily = $AddressFamily
        InterfaceAlias = $InterfaceAlias
    }

    $returnValue
}

######################################################################################
# The Set-TargetResource cmdlet.
# This function will set a new Server Address in the current node
######################################################################################
function Set-TargetResource
{
    param
    (    
        #IP Address that has to be set    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Address,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]$AddressFamily,
        
        [Boolean]$Validate = $false
    )

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingDNSServerAddressesMessage)
        ) -join '')

    #Get the current DNS Server Addresses based on the parameters given.
    $PSBoundParameters.Remove('Address')
    $PSBoundParameters.Remove('Validate')
    $currentAddress = (Get-DnsClientServerAddress @PSBoundParameters `
        -ErrorAction Stop).ServerAddresses

    #Check if the Server addresses are the same as the desired addresses.
    [Boolean] $addressDifferent = (@(Compare-Object `
            -ReferenceObject $currentAddress `
            -DifferenceObject $Address `
            -SyncWindow 0).Length -gt 0)

    if ($addressDifferent)
    {
        # Set the DNS settings as well
        $Splat = @{
            InterfaceAlias = $InterfaceAlias
            Address = $Address
            Validate = $Validate
        }
        Set-DnsClientServerAddress @Splat `
            -ErrorAction Stop

        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersHaveBeenSetCorrectlyMessage)
            ) -join '' )
    }
    else 
    { 
        #Test will return true in this case
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersAlreadySetMessage)
            ) -join '' )
    }
}

######################################################################################
# The Test-TargetResource cmdlet.
# This will test if the given Server Address is among the current node's Server Address collection
######################################################################################
function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Address,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]$AddressFamily,
        
        [Boolean]$Validate = $false        
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingDNSServerAddressesMessage)
        ) -join '' )

    #Validate the Settings passed
    Foreach ($ServerAddress in $Address) {       
        Test-ResourceProperty `
            -Address $ServerAddress `
            -AddressFamily $AddressFamily `
            -InterfaceAlias $InterfaceAlias
    }

    #Get the current DNS Server Addresses based on the parameters given.
    $currentAddress = (Get-DnsClientServerAddress `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily `
        -ErrorAction Stop).ServerAddresses

    #Check if the Server addresses are the same as the desired addresses.
    [Boolean] $addressDifferent = (@(Compare-Object `
            -ReferenceObject $currentAddress `
            -DifferenceObject $Address `
            -SyncWindow 0).Length -gt 0)

    if ($addressDifferent)
    {
        $desiredConfigurationMatch = $false
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersNotCorrectMessage) `
                -f ($Address -join ','),($currentAddress -join ',')
            ) -join '' )
    }
    else 
    { 
        #Test will return true in this case
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersSetCorrectlyMessage)
            ) -join '' )
    }
    return $desiredConfigurationMatch
}

#######################################################################################
#  Helper functions
#######################################################################################
function Test-ResourceProperty
{
    # Function will check the Address details are valid and do not conflict with
    # Address family. Ensures interface exists.
    # If any problems are detected an exception will be thrown.
    [CmdletBinding()]
    param
    (
        [String]$Address,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateSet('IPv4', 'IPv6')]
        [String]$AddressFamily = 'IPv4'
    )

    if ( -not (Get-NetAdapter | Where-Object -Property Name -EQ $InterfaceAlias ))
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

    if ( -not ([System.Net.IPAddress]::TryParse($Address, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $Address
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress]$Address).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $Address,$AddressFamily
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
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $Address,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
} # Test-ResourceProperty
#######################################################################################

#  FUNCTIONS TO BE EXPORTED 
Export-ModuleMember -function Get-TargetResource, Set-TargetResource, Test-TargetResource
