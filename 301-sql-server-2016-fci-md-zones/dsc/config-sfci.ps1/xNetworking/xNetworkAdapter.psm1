#######################################################################################
#  xNetworkAdapterName : DSC Resource Helper that will set/test/get a network adapter name,
#  by accepting existing properties (given in xNetworkAdapterName.schema.mof)
#  other than the name and ensuring the name matches for that adapter
#######################################################################################

data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingNetAdapetrMessage=Getting the NetAdapter.
ApplyingNetAdapterMessage=Applying the NetAdapter.
NetAdapterSetStateMessage=NetAdapter was set to the desired state.
CheckingNetAdapterMessage=Checking the NetAdapter.
NetAdapterNotFoundError=A NetAdapter matching the properties was not found. Please correct the properties and try again.
MultipleMatchingNetAdapterFound=Multiple matching NetAdapters where found for the properties. Please correct the properties or specify IgnoreMultipleMatchingAdapters to only use the first and try again.
'@
}

######################################################################################
# The Get-xNetworkAdapterName cmdlet.
# This function will get the present network adapter name based on the provided properties
######################################################################################
function Get-xNetworkAdapterName
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [String]$PhysicalMediaType,

        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [String]$Status = 'Up',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )
    Write-Warning -Message "This is investigational, names and parameters are subject to change"
    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingNetAdapetrMessage)
        ) -join '')

    Test-xNetworkAdapterNameProperty -PhysicalMediaType $PhysicalMediaType -Status $Status -Name $Name
    
    $Adapter  =  @(Get-NetAdapter | Where-Object {$_.Status -eq $Status})
    if(![string]::IsNullOrWhiteSpace($PhysicalMediaType))
    {
         $Adapter = @($Adapter| Where-Object {$_.PhysicalMediaType -eq $PhysicalMediaType})
    }
    
    $exactAdapter = @($Adapter | Where-Object {$_.Name -eq $Name} )
    if($exactAdapter.Count -eq 0)
    {
        $exactAdapter = $Adapter
    }
    elseif($exactAdapter.Count -eq 1)
    {
        $Adapter = $exactAdapter
    }
    
    
    if($Adapter.Count -gt 0)
    {
        $returnValue = [PSCustomObject] @{
            PhysicalMediaType    = $PhysicalMediaType
            Status               = $Status
            Name                 = $exactAdapter[0].Name
            MatchingAdapterCount = $Adapter.Count
        }
    }
    else
    {
        $returnValue = [PSCustomObject] @{
            PhysicalMediaType    = $PhysicalMediaType
            Status               = $Status
            Name                 = $null
            MatchingAdapterCount = 0
        }
    }

    $returnValue
}

######################################################################################
# The Set-xNetworkAdapterName cmdlet.
# This function will set a new network adapter name of the adapter found
# based on the provided properites
######################################################################################
function Set-xNetworkAdapterName
{
    param
    (
        [String]$PhysicalMediaType,

        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [String]$Status = 'Up',


        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        
        [Switch] $IgnoreMultipleMatchingAdapters
    )
    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingNetAdapterMessage)
        ) -join '')
    
    Test-xNetworkAdapterNameProperty -PhysicalMediaType $PhysicalMediaType -Status $Status -Name $Name

    # Get the current NetAdapter based on the parameters given.
    [HashTable] $getParameters = @{}
    foreach($key in $PSBoundParameters.Keys)
    {
        if($key -ne 'IgnoreMultipleMatchingAdapters')
        {
            $getParameters.$key = $PSBoundParameters.$key
        }
    }
    $getResults = Get-xNetworkAdapterName @getParameters
    
    # Test if no adapter was found, if so return false
    if(!$getResults.Name)
    {
        $errorId = 'NetAdapterNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $LocalizedData.NetAdapterNotFoundError
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)        
    }
    elseif($getResults.MatchingAdapterCount -ne 1 -and !$IgnoreMultipleMatchingAdapters) 
    {
        # Mulitple matching adapters, and IgnoreMultipleMatchingAdapters is not specified
        # throw an error to indicating we found multiple adapters
        
        $errorId = 'MultipleMatchingNetAdapterFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $LocalizedData.MultipleMatchingNetAdapterFound
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)        
    }
    elseif($getResults.name -ne $Name)
    {
        Rename-NetAdapter -Name $getResults.Name -NewName $Name
    }
    else
    {
        Write-Verbose -Message 'Already in desired state'
    }

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.NetAdapterSetStateMessage)
        ) -join '' )
} # Set-xNetworkAdapterName

######################################################################################
# The Test-xNetworkAdapterName cmdlet.
# This will test if the given Network adapter is named correctly
######################################################################################
function Test-xNetworkAdapterName
{
    [OutputType([System.Boolean])]
    param
    (
        [String]$PhysicalMediaType,

        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [String]$Status = 'Up',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingNetAdapterMessage)
        ) -join '')

    Test-xNetworkAdapterNameProperty -PhysicalMediaType $PhysicalMediaType -Status $Status -Name $Name

    # Get the current NetAdapter based on the parameters given.
    $getResults = Get-xNetworkAdapterName @PSBoundParameters
    
    # Test if no adapter was found, if so return false
    if(!$getResults.Name)
    {
        $desiredConfigurationMatch = $false
    }
    elseif($getResults.Name -ne $Name) # Test if a found adapter name mismatches, if so return false
    {
        $desiredConfigurationMatch = $false
    }
    
    # return desiredConfigurationMatch     
    return $desiredConfigurationMatch
} # Test-xNetworkAdapterName

#######################################################################################
#  Helper functions
#######################################################################################
function Test-xNetworkAdapterNameProperty {
    # Function will check the propertes to find a network adapter 
    # are valid.
    # If any problems are detected an exception will be thrown.
    [CmdletBinding()]
    param
    (
        [String]$PhysicalMediaType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [String]$Status,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        
        [Switch] $IgnoreMultipleMatchingAdapters
    )
    
    # TODO add any parameter validation

} # Test-ResourceProperty
#######################################################################################

#  FUNCTIONS TO BE EXPORTED
Export-ModuleMember -function Get-xNetworkAdapterName, Set-xNetworkAdapterName, Test-xNetworkAdapterName
