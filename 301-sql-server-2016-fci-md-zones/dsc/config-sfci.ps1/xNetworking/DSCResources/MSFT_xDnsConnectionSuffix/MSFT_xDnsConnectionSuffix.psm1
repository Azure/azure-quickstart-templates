data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
PropertyMismatch          = Property '{0}' does NOT match. Expected '{1}', actual '{2}'.
CheckingConnectionSuffix  = Checking connection suffix matches '{0}'.
ResourceInDesiredState    = Resource is in the desired state.
ResourceNotInDesiredState = Resource is NOT in the desired state.
SettingConnectionSuffix   = Setting connection suffix '{0}' on interface '{1}'.
RemovingConnectionSuffix  = Removing connection suffix '{0}' on interface '{1}'.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $InterfaceAlias,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ConnectionSpecificSuffix,
        
        [Parameter()]
        [System.Boolean] $RegisterThisConnectionsAddress = $true,

        [Parameter()]
        [System.Boolean] $UseSuffixWhenRegistering = $false, 

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    $dnsClient = Get-DnsClient -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue;
    $targetResource = @{
        InterfaceAlias = $dnsClient.InterfaceAlias;
        ConnectionSpecificSuffix = $dnsClient.ConnectionSpecificSuffix;
        RegisterThisConnectionsAddress = $dnsClient.RegisterThisConnectionsAddress;
        UseSuffixWhenRegistering = $dnsClient.UseSuffixWhenRegistering;
    }
    if ($Ensure -eq 'Present')
    {
        ## Test to see if the connection-specific suffix matches
        Write-Verbose -Message ($LocalizedData.CheckingConnectionSuffix -f $ConnectionSpecificSuffix);
        if ($dnsClient.ConnectionSpecificSuffix -eq $ConnectionSpecificSuffix)
        {
            $Ensure = 'Present'
        }
        else
        {
            $Ensure = 'Absent'
        }
    }
    else
    {
        ## ($Ensure -eq 'Absent'). Test to see if there is a connection-specific suffix
        Write-Verbose -Message ($LocalizedData.CheckingConnectionSuffix -f '');
        if ([System.String]::IsNullOrEmpty($dnsClient.ConnectionSpecificSuffix))
        {
            $Ensure = 'Absent'
        }
        else
        {
            $Ensure = 'Present'
        }
    }
    $targetResource['Ensure'] = $Ensure
    return $targetResource;
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $InterfaceAlias,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ConnectionSpecificSuffix,
        
        [Parameter()]
        [System.Boolean] $RegisterThisConnectionsAddress = $true,

        [Parameter()]
        [System.Boolean] $UseSuffixWhenRegistering = $false, 

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;
    if ($targetResource.Ensure -ne $Ensure)
    {
        Write-Verbose -Message ($LocalizedData.PropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
        $inDesiredState = $false;
    }
    if ($targetResource.RegisterThisConnectionsAddress -ne $RegisterThisConnectionsAddress)
    {
        Write-Verbose -Message ($LocalizedData.PropertyMismatch -f 'RegisterThisConnectionsAddress', $RegisterThisConnectionsAddress, $targetResource.RegisterThisConnectionsAddress);
        $inDesiredState = $false;
    }
    if ($targetResource.UseSuffixWhenRegistering -ne $UseSuffixWhenRegistering)
    {
        Write-Verbose -Message ($LocalizedData.PropertyMismatch -f 'UseSuffixWhenRegistering', $UseSuffixWhenRegistering, $targetResource.UseSuffixWhenRegistering);
        $inDesiredState = $false;
    }
    if ($inDesiredState)
    {
        Write-Verbose -Message $LocalizedData.ResourceInDesiredState;
    }
    else {
        Write-Verbose -Message $LocalizedData.ResourceNotInDesiredState;
    }
    return $inDesiredState;
}

function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $InterfaceAlias,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ConnectionSpecificSuffix,
        
        [Parameter()]
        [System.Boolean] $RegisterThisConnectionsAddress = $true,

        [Parameter()]
        [System.Boolean] $UseSuffixWhenRegistering = $false, 

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    $setDnsClientParams = @{
        InterfaceAlias = $InterfaceAlias;
        RegisterThisConnectionsAddress = $RegisterThisConnectionsAddress;
        UseSuffixWhenRegistering = $UseSuffixWhenRegistering;
    }
    if ($Ensure -eq 'Present')
    {
        $setDnsClientParams['ConnectionSpecificSuffix'] = $ConnectionSpecificSuffix;
        Write-Verbose -Message ($LocalizedData.SettingConnectionSuffix -f $ConnectionSpecificSuffix, $InterfaceAlias);
    }
    else
    {
        $setDnsClientParams['ConnectionSpecificSuffix'] = '';
        Write-Verbose -Message ($LocalizedData.RemovingConnectionSuffix -f $ConnectionSpecificSuffix, $InterfaceAlias);
    }
    Set-DnsClient @setDnsClientParams;
}
