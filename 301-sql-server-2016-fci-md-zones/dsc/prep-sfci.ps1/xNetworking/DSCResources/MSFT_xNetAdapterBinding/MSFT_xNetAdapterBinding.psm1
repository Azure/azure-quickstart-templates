data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingNetAdapterBindingMessage=Getting the '{0}' Inerface '{1}' Binding.
ApplyingNetAdapterBindingMessage=Applying the '{0}' Inerface '{1}' Binding.
NetAdapterBindingEnabledMessage='{0}' Inerface '{1}' Binding was Enabled.
NetAdapterBindingDisabledMessage='{0}' Inerface '{1}' Binding was Disabled.
CheckingNetAdapterBindingMessage=Checking the '{0}' Inerface '{1}' Binding.
NetAdapterBindingDoesNotMatchMessage='{0}' Inerface '{1}' Binding does NOT match desired state. Expected {2}, actual {3}.
NetAdapterBindingMatchMessage='{0}' Inerface '{1}' Binding is in desired state.
InterfaceNotAvailableError=Interface '{0}' is not available. Please select a valid interface and try again.
ComponentIdNotAvailableError=Inerface '{0}' does not have '{1}' bound to it. Please select a bound component Id and try again.
'@
}

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]$State = 'Enabled'
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingNetAdapterBindingMessage -f `
            $InterfaceAlias,$ComponentId)
        ) -join '')

    $CurrentNetAdapterBinding = Get-Binding @PSBoundParameters

    $AdaptersState = $CurrentNetAdapterBinding.Enabled |
        Sort-Object -Unique

    If ( $AdaptersState.Count -eq 2)
    {
        $CurrentEnabled = 'Mixed'
    }         
    ElseIf ( $AdaptersState -eq $true )
    {
        $CurrentEnabled = 'Enabled'
    }
    Else
    {
        $CurrentEnabled = 'Disabled'
    }

    $returnValue = @{
        InterfaceAlias = $InterfaceAlias
        ComponentId    = $ComponentId
        State          = $State
        CurrentState   = $CurrentEnabled
    }

    $returnValue
} # Get-TargetResource

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]$State = 'Enabled'
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingNetAdapterBindingMessage -f `
            $InterfaceAlias,$ComponentId)
        ) -join '')

    $CurrentNetAdapterBinding = Get-Binding @PSBoundParameters

    # Remove the State so we can splat
    $null = $PSBoundParameters.Remove('State')

    if ($State -eq 'Enabled')
    {
        Enable-NetAdapterBinding @PSBoundParameters
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingEnabledMessage -f `
                $InterfaceAlias,$ComponentId)
            ) -join '' )
    }
    else
    {
        Disable-NetAdapterBinding @PSBoundParameters
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingDisabledMessage -f `
                $InterfaceAlias,$ComponentId)
            ) -join '' )
    } # if
} # Set-TargetResource

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]$State = 'Enabled'
    )

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingNetAdapterBindingMessage -f `
            $InterfaceAlias,$ComponentId)
        ) -join '')

    $CurrentNetAdapterBinding = Get-Binding @PSBoundParameters

    $AdaptersState = $CurrentNetAdapterBinding.Enabled |
        Sort-Object -Unique

    If ( $AdaptersState.Count -eq 2)
    {
        $CurrentEnabled = 'Mixed'
    }         
    ElseIf ( $AdaptersState -eq $true )
    {
        $CurrentEnabled = 'Enabled'
    }
    Else
    {
        $CurrentEnabled = 'Disabled'
    }

    # Test if the binding is in the correct state
    if ($CurrentEnabled -ne $State)
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingDoesNotMatchMessage -f `
                $InterfaceAlias,$ComponentId,$State,$CurrentEnabled)
            ) -join '' )
        return $false
    }
    else
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingMatchMessage -f `
                $InterfaceAlias,$ComponentId)
            ) -join '' )
        return $true
    } # if
} # Test-TargetResource

function Get-Binding {
    # Function ensures the interface and component Id exists and
    # returns the Net Adapter binding object.
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]$State = 'Enabled'
    )

    if (-not (Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue))
    {
        $errorId = 'InterfaceNotAvailable'
        $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
        $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $InterfaceAlias
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    } # if

    $Binding = Get-NetAdapterBinding `
        -InterfaceAlias $InterfaceAlias `
        -ComponentId $ComponentId `
        -ErrorAction Stop

    return $Binding
} # Get-Binding

Export-ModuleMember -function *-TargetResource
