# Suppressed as per PSSA Rule Severity guidelines for unit/integration tests:
# https://github.com/PowerShell/DscResources/blob/master/PSSARuleSeverities.md
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonResourceHelper.psm1')

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xWaitForVolume'

# Import the common storage functions
Import-Module -Name ( Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\StorageCommon\StorageCommon.psm1' )

<#
    .SYNOPSIS
    Returns the current state of the wait for drive resource.

    .PARAMETER DriveLetter
    Specifies the name of the drive to wait for.

    .PARAMETER RetryIntervalSec
    Specifies the number of seconds to wait for the drive to become available.

    .PARAMETER RetryCount
    The number of times to loop the retry interval while waiting for the drive.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [String] $DriveLetter,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 60
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.GettingWaitForVolumeStatusMessage -f $DriveLetter)
        ) -join '' )

    # Validate the DriveLetter parameter
    $DriveLetter = Assert-DriveLetterValid -DriveLetter $DriveLetter

    $returnValue = @{
        DriveLetter      = $DriveLetter
        RetryIntervalSec = $RetryIntervalSec
        RetryCount       = $RetryCount
    }
    return $returnValue
} # function Get-TargetResource

<#
    .SYNOPSIS
    Sets the current state of the wait for drive resource.

    .PARAMETER DriveLetter
    Specifies the name of the drive to wait for.

    .PARAMETER RetryIntervalSec
    Specifies the number of seconds to wait for the drive to become available.

    .PARAMETER RetryCount
    The number of times to loop the retry interval while waiting for the drive.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [String] $DriveLetter,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 60
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.CheckingForVolumeStatusMessage -f $DriveLetter)
        ) -join '' )

    # Validate the DriveLetter parameter
    $DriveLetter = Assert-DriveLetterValid -DriveLetter $DriveLetter

    $volumeFound = $false

    for ($count = 0; $count -lt $RetryCount; $count++)
    {
        $volume = Get-Volume -DriveLetter $DriveLetter -ErrorAction SilentlyContinue
        if ($volume)
        {
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.VolumeFoundMessage -f $DriveLetter)
                ) -join '' )

            $volumeFound = $true
            break
        }
        else
        {
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.VolumeNotFoundMessage -f $DriveLetter,$RetryIntervalSec)
                ) -join '' )

            Start-Sleep -Seconds $RetryIntervalSec

            # This command forces a refresh of the PS Drive subsystem.
            # So triggers any "missing" drives to show up.
            $null = Get-PSDrive
        } # if
    } # for

    if (-not $volumeFound)
    {
        New-InvalidOperationException `
            -Message $($LocalizedData.VolumeNotFoundAfterError -f $DriveLetter,$RetryCount)
    } # if
} # function Set-TargetResource

<#
    .SYNOPSIS
    Tests the current state of the wait for drive resource.

    .PARAMETER DriveLetter
    Specifies the name of the drive to wait for.

    .PARAMETER RetryIntervalSec
    Specifies the number of seconds to wait for the drive to become available.

    .PARAMETER RetryCount
    The number of times to loop the retry interval while waiting for the drive.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [String] $DriveLetter,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 60
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestingWaitForVolumeStatusMessage -f $DriveLetter)
        ) -join '' )

    # Validate the DriveLetter parameter
    $DriveLetter = Assert-DriveLetterValid -DriveLetter $DriveLetter

    # This command forces a refresh of the PS Drive subsystem.
    # So triggers any "missing" drives to show up.
    $null = Get-PSDrive

    $volume = Get-Volume -DriveLetter $DriveLetter -ErrorAction SilentlyContinue
    if ($volume)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.VolumeFoundMessage -f $DriveLetter)
            ) -join '' )

        return $true
    }

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.VolumeNotFoundMessage -f $DriveLetter)
        ) -join '' )

    return $false
} # function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
