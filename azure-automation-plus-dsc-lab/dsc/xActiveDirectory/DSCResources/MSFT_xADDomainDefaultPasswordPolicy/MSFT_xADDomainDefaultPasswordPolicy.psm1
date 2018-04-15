# Localized messages
data localizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        RoleNotFoundError              = Please ensure that the PowerShell module for role '{0}' is installed.
        QueryingDomainPasswordPolicy   = Querying Active Directory domain '{0}' default password policy.
        UpdatingDomainPasswordPolicy   = Updating Active Directory domain '{0}' default password policy.
        SettingPasswordPolicyValue     = Setting password policy '{0}' property to '{1}'.
        ResourcePropertyValueIncorrect = Property '{0}' value is incorrect; expected '{1}', actual '{2}'.
        ResourceInDesiredState         = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState      = Resource '{0}' is NOT in the desired state.
'@
}

## List of changeable policy properties
$mutablePropertyMap = @(
    @{ Name = 'ComplexityEnabled'; }
    @{ Name = 'LockoutDuration'; IsTimeSpan = $true; }
    @{ Name = 'LockoutObservationWindow'; IsTimeSpan = $true; }
    @{ Name = 'LockoutThreshold'; }
    @{ Name = 'MinPasswordAge'; IsTimeSpan = $true; }
    @{ Name = 'MaxPasswordAge'; IsTimeSpan = $true; }
    @{ Name = 'MinPasswordLength'; }
    @{ Name = 'PasswordHistoryCount'; }
    @{ Name = 'ReversibleEncryptionEnabled'; }
)

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DomainController,
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential      
    )
    Assert-Module -ModuleName 'ActiveDirectory';
    
    $PSBoundParameters['Identity'] = $DomainName;
    $getADDefaultDomainPasswordPolicyParams = Get-ADCommonParameters @PSBoundParameters;
    Write-Verbose -Message ($localizedData.QueryingDomainPasswordPolicy -f $DomainName);
    $policy = Get-ADDefaultDomainPasswordPolicy @getADDefaultDomainPasswordPolicyParams;
    $targetResource = @{
        DomainName = $DomainName;
        ComplexityEnabled = $policy.ComplexityEnabled;
        LockoutDuration = ConvertFrom-Timespan -Timespan $policy.LockoutDuration -TimeSpanType Minutes;
        LockoutObservationWindow = ConvertFrom-Timespan -Timespan $policy.LockoutObservationWindow -TimeSpanType Minutes;
        LockoutThreshold = $policy.LockoutThreshold;
        MinPasswordAge = ConvertFrom-Timespan -Timespan $policy.MinPasswordAge -TimeSpanType Minutes;
        MaxPasswordAge = ConvertFrom-Timespan -Timespan $policy.MaxPasswordAge -TimeSpanType Minutes;
        MinPasswordLength = $policy.MinPasswordLength;
        PasswordHistoryCount = $policy.PasswordHistoryCount;
        ReversibleEncryptionEnabled = $policy.ReversibleEncryptionEnabled;
    }
    return $targetResource;
} #end Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        [Parameter()]
        [System.Boolean] $ComplexityEnabled,
        
        [Parameter()]
        [System.UInt32] $LockoutDuration,
        
        [Parameter()]
        [System.UInt32] $LockoutObservationWindow,
        
        [Parameter()]
        [System.UInt32] $LockoutThreshold,
        
        [Parameter()]
        [System.UInt32] $MinPasswordAge,
        
        [Parameter()]
        [System.UInt32] $MaxPasswordAge,
        
        [Parameter()]
        [System.UInt32] $MinPasswordLength,
        
        [Parameter()]
        [System.UInt32] $PasswordHistoryCount,
        
        [Parameter()]
        [System.Boolean] $ReversibleEncryptionEnabled,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DomainController,
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential        
    )
    $getTargetResourceParams = @{
        DomainName = $DomainName;
    }
    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $getTargetResourceParams['Credential'] = $Credential;
    }
    if ($PSBoundParameters.ContainsKey('DomainController'))
    {
        $getTargetResourceParams['DomainController'] = $DomainController;
    }
    $targetResource = Get-TargetResource @getTargetResourceParams;
    
    $inDesiredState = $true;
    foreach ($property in $mutablePropertyMap)
    {
        $propertyName = $property.Name;
        if ($PSBoundParameters.ContainsKey($propertyName))
        {
            $expectedValue = $PSBoundParameters[$propertyName];
            $actualValue = $targetResource[$propertyName];
            if ($expectedValue -ne $actualValue)
            {
                $valueIncorrectMessage = $localizedData.ResourcePropertyValueIncorrect -f $propertyName, $expectedValue, $actualValue;
                Write-Verbose -Message $valueIncorrectMessage;
                $inDesiredState = $false;
            }
        }
    }

    if ($inDesiredState)
    {
        Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $DomainName);
        return $true;
    }
    else
    {
        Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $DomainName);
        return $false;
    }
} #end Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        [Parameter()]
        [System.Boolean] $ComplexityEnabled,
        
        [Parameter()]
        [System.UInt32] $LockoutDuration,
        
        [Parameter()]
        [System.UInt32] $LockoutObservationWindow,
        
        [Parameter()]
        [System.UInt32] $LockoutThreshold,
        
        [Parameter()]
        [System.UInt32] $MinPasswordAge,
        
        [Parameter()]
        [System.UInt32] $MaxPasswordAge,
        
        [Parameter()]
        [System.UInt32] $MinPasswordLength,
        
        [Parameter()]
        [System.UInt32] $PasswordHistoryCount,
        
        [Parameter()]
        [System.Boolean] $ReversibleEncryptionEnabled,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DomainController,
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential        
    )
    Assert-Module -ModuleName 'ActiveDirectory';
    $PSBoundParameters['Identity'] = $DomainName;
    $setADDefaultDomainPasswordPolicyParams = Get-ADCommonParameters @PSBoundParameters;

    foreach ($property in $mutablePropertyMap)
    {
        $propertyName = $property.Name;
        if ($PSBoundParameters.ContainsKey($propertyName))
        {
            $propertyValue = $PSBoundParameters[$propertyName];
            if ($property.IsTimeSpan -eq $true)
            {
                $propertyValue = ConvertTo-TimeSpan -TimeSpan $propertyValue -TimeSpanType Minutes;
            }
            $setADDefaultDomainPasswordPolicyParams[$propertyName] = $propertyValue;
            Write-Verbose -Message ($localizedData.SettingPasswordPolicyValue -f $propertyName, $propertyValue);
        }
    }

    Write-Verbose -Message ($localizedData.UpdatingDomainPasswordPolicy -f $DomainName);
    [ref] $null = Set-ADDefaultDomainPasswordPolicy @setADDefaultDomainPasswordPolicyParams;
} #end Set-TargetResource

## Import the common AD functions
$adCommonFunctions = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1';
. $adCommonFunctions;

Export-ModuleMember -Function *-TargetResource;
