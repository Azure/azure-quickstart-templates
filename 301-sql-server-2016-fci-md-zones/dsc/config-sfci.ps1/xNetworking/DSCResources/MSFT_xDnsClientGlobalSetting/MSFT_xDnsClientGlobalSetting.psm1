#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xDnsClientGlobalSetting.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    #fallback to en-US
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xDnsClientGlobalSetting.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
    This is an array of all the parameters used by this resource.
#>
data ParameterList
{
    @(
        @{ Name = 'SuffixSearchList'; Type = 'String'  },
        @{ Name = 'UseDevolution';    Type = 'Boolean' },
        @{ Name = 'DevolutionLevel';  Type = 'Uint32'  }
    )
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.GettingDnsClientGlobalSettingsMessage)
        ) -join '' )

    # Get the current Dns Client Global Settings
    $DnsClientGlobalSetting = Get-DnsClientGlobalSetting `
        -ErrorAction Stop

    # Generate the return object.
    $ReturnValue = @{
        IsSingleInstance = 'Yes'
    }
    foreach ($parameter in $ParameterList)
    {
        $ReturnValue += @{ $parameter.Name = $DnsClientGlobalSetting.$($parameter.name) }
    } # foreach

    return $ReturnValue
} # Get-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [String[]]
        $SuffixSearchList,

        [Boolean]
        $UseDevolution,

        [Uint32]
        $DevolutionLevel
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingDnsClientGlobalSettingMessage)
        ) -join '' )

    # Get the current Dns Client Global Settings
    $DnsClientGlobalSetting = Get-DnsClientGlobalSetting `
        -ErrorAction Stop

    # Generate a list of parameters that will need to be changed.
    $ChangeParameters = @{}
    foreach ($parameter in $ParameterList)
    {
        $ParameterSource = $DnsClientGlobalSetting.$($parameter.name)
        $ParameterNew = (Invoke-Expression -Command "`$$($parameter.name)")
        if ($PSBoundParameters.ContainsKey($parameter.Name) `
            -and ($ParameterSource -ne $ParameterNew))
        {
            $ChangeParameters += @{
                $($parameter.name) = $ParameterNew
            }
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DnsClientGlobalSettingUpdateParameterMessage) `
                    -f $parameter.Name,$ParameterNew
                ) -join '' )
        } # if
    } # foreach
    if ($ChangeParameters.Count -gt 0)
    {
        # Update any parameters that were identified as different
        $null = Set-DnsClientGlobalSetting `
            @ChangeParameters `
            -ErrorAction Stop

        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.DnsClientGlobalSettingUpdatedMessage)
            ) -join '' )
    } # if
} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [String[]]
        $SuffixSearchList,

        [Boolean]
        $UseDevolution,

        [Uint32]
        $DevolutionLevel
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestingDnsClientGlobalSettingMessage)
        ) -join '' )

    # Flag to signal whether settings are correct
    [Boolean] $DesiredConfigurationMatch = $true

    # Get the current Dns Client Global Settings
    $DnsClientGlobalSetting = Get-DnsClientGlobalSetting `
        -ErrorAction Stop

    # Check each parameter
    foreach ($parameter in $ParameterList)
    {
        $ParameterSource = $DnsClientGlobalSetting.$($parameter.name)
        $ParameterNew = (Invoke-Expression -Command "`$$($parameter.name)")
        if ($PSBoundParameters.ContainsKey($parameter.Name) `
            -and ($ParameterSource -ne $ParameterNew)) {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DnsClientGlobalSettingParameterNeedsUpdateMessage) `
                    -f $parameter.Name,$ParameterSource,$ParameterNew
                ) -join '' )
            $desiredConfigurationMatch = $false
        } # if
    } # foreach

    return $DesiredConfigurationMatch
} # Test-TargetResource

# Helper Functions
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String] $ErrorId,

        [Parameter(Mandatory)]
        [String] $ErrorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory] $ErrorCategory
    )

    $exception = New-Object `
        -TypeName System.InvalidOperationException `
        -ArgumentList $errorMessage
    $errorRecord = New-Object `
        -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $errorId, $errorCategory, $null
    $PSCmdlet.ThrowTerminatingError($errorRecord)
}

Export-ModuleMember -Function *-TargetResource
