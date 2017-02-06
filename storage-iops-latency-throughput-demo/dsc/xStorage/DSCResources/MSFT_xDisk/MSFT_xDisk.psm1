# Suppressed as per PSSA Rule Severity guidelines for unit/integration tests:
# https://github.com/PowerShell/DscResources/blob/master/PSSARuleSeverities.md
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonResourceHelper.psm1')

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xDisk'

# Import the common storage functions
Import-Module -Name ( Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\StorageCommon\StorageCommon.psm1' )

<#
    .SYNOPSIS
    Returns the current state of the Disk and Partition.

    .PARAMETER DriveLetter
    Specifies the preferred letter to assign to the disk volume.

    .PARAMETER DiskNumber
    Specifies the disk number for which disk to modify.

    .PARAMETER Size
    Specifies the size of new volume (use all available space on disk if not provided).

    .PARAMETER FSLabel
    Specifies the volume label to assign to the volume.

    .PARAMETER AllocationUnitSize
    Specifies the allocation unit size to use when formatting the volume.

    .PARAMETER FSFormat
    Specifies the file system format of the new volume.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [System.String] $DriveLetter,

        [parameter(Mandatory)]
        [uint32] $DiskNumber,

        [UInt64] $Size,

        [System.String] $FSLabel,

        [UInt32] $AllocationUnitSize,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FSFormat = 'NTFS'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.GettingDiskMessage -f $DiskNumber,$DriveLetter)
        ) -join '' )

    # Validate the DriveLetter parameter
    $DriveLetter = Assert-DriveLetterValid -DriveLetter $DriveLetter

    $disk = Get-Disk `
        -Number $DiskNumber `
        -ErrorAction SilentlyContinue

    $partition = Get-Partition `
        -DriveLetter $DriveLetter `
        -ErrorAction SilentlyContinue

    $volume = Get-Volume `
        -DriveLetter $DriveLetter `
        -ErrorAction SilentlyContinue

    $fileSystem = $volume.FileSystem
    $FSLabel = $volume.FileSystemLabel

    $blockSize = (Get-CimInstance `
        -Query "SELECT BlockSize from Win32_Volume WHERE DriveLetter = '$($DriveLetter):'" `
        -ErrorAction SilentlyContinue).BlockSize

    if ($blockSize)
    {
        $AllocationUnitSize = $blockSize
    }
    else
    {
        # If Get-CimInstance did not return a value, try again with Get-WmiObject
        $blockSize = (Get-WmiObject `
            -Query "SELECT BlockSize from Win32_Volume WHERE DriveLetter = '$($DriveLetter):'" `
            -ErrorAction SilentlyContinue).BlockSize
    } # if

    $returnValue = @{
        DiskNumber = $disk.Number
        DriveLetter = $partition.DriveLetter
        Size = $partition.Size
        FSLabel = $FSLabel
        AllocationUnitSize = $blockSize
        FSFormat = $fileSystem
    }
    $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    Initializes the Disk and Partition and assigns the drive letter.

    .PARAMETER DriveLetter
    Specifies the preferred letter to assign to the disk volume.

    .PARAMETER DiskNumber
    Specifies the disk number for which disk to modify.

    .PARAMETER Size
    Specifies the size of new volume (use all available space on disk if not provided).

    .PARAMETER FSLabel
    Specifies the volume label to assign to the volume.

    .PARAMETER AllocationUnitSize
    Specifies the allocation unit size to use when formatting the volume.

    .PARAMETER FSFormat
    Specifies the file system format of the new volume.
#>
function Set-TargetResource
{
    # Should process is called in a helper functions but not directly in Set-TargetResource
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [parameter(Mandatory)]
        [System.String] $DriveLetter,

        [parameter(Mandatory)]
        [uint32] $DiskNumber,

        [UInt64] $Size,

        [System.String] $FSLabel,

        [UInt32] $AllocationUnitSize,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FSFormat = 'NTFS'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingDiskMessage -f $DiskNumber,$DriveLetter)
        ) -join '' )

    # Validate the DriveLetter parameter
    $DriveLetter = Assert-DriveLetterValid -DriveLetter $DriveLetter

    $disk = Get-Disk `
        -Number $DiskNumber `
        -ErrorAction Stop

    if ($disk.IsOffline)
    {
        # Disk is offline, so bring it online
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.SetDiskOnlineMessage -f $DiskNumber)
            ) -join '' )

        $disk | Set-Disk -IsOffline $false
    } # if

    if ($disk.IsReadOnly)
    {
        # Disk is read-only, so make it read/write
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.SetDiskReadwriteMessage -f $DiskNumber)
            ) -join '' )

        $disk | Set-Disk -IsReadOnly $false
    } # if

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.CheckingDiskPartitionStyleMessage -f $DiskNumber)
        ) -join '' )

    switch ($disk.PartitionStyle)
    {
        "RAW"
        {
            # The disk partition table is not yet initialized, so initialize it with GPT
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.InitializingDiskMessage -f $DiskNumber)
                ) -join '' )

            $disk | Initialize-Disk `
                -PartitionStyle "GPT"

            break
        } # "RAW"
        "GPT"
        {
            # The disk partition is already initialized with GPT.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.DiskAlreadyInitializedMessage -f $DiskNumber)
                ) -join '' )

            break
        } # "GPT"
        default
        {
            # This disk is initialized but not as GPT - so raise an exception.
            New-InvalidOperationException `
                -Message ($LocalizedData.DiskAlreadyInitializedError -f `
                    $DiskNumber,$Disk.PartitionStyle)
        } # default
    } # switch

    $volume = $disk | Get-Partition | Get-Volume

    # Check if existing partition already has file system on it
    if ($null -eq $volume)
    {
        # There is no partiton on the disk, so create one
        $partitionParams = @{
            DriveLetter = $DriveLetter
            DiskNumber = $DiskNumber
        }

        if ($Size)
        {
            # Use only a specific size
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.CreatingPartitionMessage `
                        -f $DiskNumber,$DriveLetter,"$($Size/1KB) KB")
                ) -join '' )

            $partitionParams["Size"] = $Size
        }
        else
        {
            # Use the entire disk
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.CreatingPartitionMessage `
                        -f $DiskNumber,$DriveLetter,'all free space')
                ) -join '' )

            $partitionParams["UseMaximumSize"] = $true
        } # if

        # Create the partition.
        $partition = New-Partition @partitionParams

        # After creating the partition it can take a few seconds for it to become writeable
        # Wait for up to 30 seconds for the parition to become writeable
        $start = Get-Date
        $timeout = (Get-Date) + (New-Timespan -Second 30)
        While ($partition.IsReadOnly -and (Get-Date) -lt $timeout)
        {
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    ($LocalizedData.NewPartitionIsReadOnlyMessage `
                        -f $partition.DiskNumber,$partition.PartitionNumber)
                ) -join '' )

            Start-Sleep -Seconds 1

            # Pull the partition details again to check if it is readonly
            $partition = $partition | Get-Partition
        } # while

        if ($partition.IsReadOnly)
        {
            # The partition is still readonly - throw an exception
            New-InvalidOperationException `
                -Message ($LocalizedData.ParitionIsReadOnlyError -f `
                    $partition.DiskNumber,$partition.PartitionNumber)
        } # if

        $volParams = @{
            FileSystem = $FSFormat
            Confirm = $false
        }

        if ($FSLabel)
        {
            # Set the File System label on the new volume
            $volParams["NewFileSystemLabel"] = $FSLabel
        } # if

        if ($AllocationUnitSize)
        {
            # Set the Allocation Unit Size on the new volume
            $volParams["AllocationUnitSize"] = $AllocationUnitSize
        } # if

        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FormattingVolumeMessage -f $volParams.FileSystem)
            ) -join '' )

        # Format the volume
        $volume = $partition | Format-Volume @VolParams

        if ($volume)
        {
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.SuccessfullyInitializedMessage -f $DriveLetter)
                ) -join '' )
        } # if
    }
    else
    {
        # The disk already has a partition on it

        # Check the volume format matches
        if ($PSBoundParameters.ContainsKey('FSFormat'))
        {
            # Check the filesystem format
            $fileSystem = $volume.FileSystem
            if ($fileSystem -ne $FSFormat)
            {
                # The file system format does not match
                # There is nothing we can do to resolve this (yet)
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.FileSystemFormatMismatch `
                            -f $DriveLetter,$fileSystem,$FSFormat)
                    ) -join '' )
            } # if
        } # if

        if ($volume.DriveLetter)
        {
            # A volume also exists in the partition
            if ($volume.DriveLetter -ne $DriveLetter)
            {
                # The drive letter assigned to the volume is different, so change it.
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.ChangingDriveLetterMessage `
                            -f $volume.DriveLetter,$DriveLetter)
                    ) -join '' )

                Set-Partition `
                    -DriveLetter $Volume.DriveLetter `
                    -NewDriveLetter $DriveLetter
            } # if
        }
        else
        {
            # Volume doesn't have an assigned letter, so set one.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.AssigningDriveLetterMessage -f $DriveLetter)
                ) -join '' )

            Set-Partition `
                -DiskNumber $DiskNumber `
                -PartitionNumber 2 `
                -NewDriveLetter $DriveLetter
        } # if

        if ($PSBoundParameters.ContainsKey('FSLabel'))
        {
            # The volume should have a label assigned
            if ($volume.FileSystemLabel -ne $FSLabel)
            {
                # The volume lable needs to be changed because it is different.
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.ChangingVolumeLabelMessage `
                            -f $volume.DriveLetter,$FSLabel)
                    ) -join '' )

                $volume | Set-Volume -NewFileSystemLabel $FSLabel
            } # if
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests if the disk is initialized, the partion exists and the drive letter is assigned.

    .PARAMETER DriveLetter
    Specifies the preferred letter to assign to the disk volume.

    .PARAMETER DiskNumber
    Specifies the disk number for which disk to modify.

    .PARAMETER Size
    Specifies the size of new volume (use all available space on disk if not provided).

    .PARAMETER FSLabel
    Specifies the volume label to assign to the volume.

    .PARAMETER AllocationUnitSize
    Specifies the allocation unit size to use when formatting the volume.

    .PARAMETER FSFormat
    Specifies the file system format of the new volume.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [System.String] $DriveLetter,

        [parameter(Mandatory)]
        [uint32] $DiskNumber,

        [UInt64] $Size,

        [System.String] $FSLabel,

        [UInt32] $AllocationUnitSize,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FSFormat = 'NTFS'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestingDiskMessage -f $DiskNumber,$DriveLetter)
        ) -join '' )

    # Validate the DriveLetter parameter
    $DriveLetter = Assert-DriveLetterValid -DriveLetter $DriveLetter

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.CheckDiskInitializedMessage -f $DiskNumber)
        ) -join '' )

    $disk = Get-Disk `
        -Number $DiskNumber `
        -ErrorAction SilentlyContinue

    if (-not $disk)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DiskNotFoundMessage -f $DiskNumber)
            ) -join '' )

        return $false
    } # if

    if ($disk.IsOffline)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DiskNotOnlineMessage -f $DiskNumber)
            ) -join '' )

        return $false
    } # if

    if ($disk.IsReadOnly)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DiskReadOnlyMessage -f $DiskNumber)
            ) -join '' )

        return $false
    } # if

    if ($disk.PartitionStyle -ne "GPT")
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DiskNotGPTMessage -f $DiskNumber,$Disk.PartitionStyle)
            ) -join '' )

        return $false
    } # if

    $partition = Get-Partition `
        -DriveLetter $DriveLetter `
        -ErrorAction SilentlyContinue
    if ($partition.DriveLetter -ne $DriveLetter)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DriveLetterNotFoundMessage -f $DriveLetter)
            ) -join '' )

        return $false
    } # if

    # Drive size
    if ($Size)
    {
        if ($partition.Size -ne $Size)
        {
            # The partition size mismatches but can't be changed (yet)
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.DriveSizeMismatchMessage `
                        -f $DriveLetter,$Partition.Size,$Size)
                ) -join '' )
        } # if
    } # if

    $blockSize = (Get-CimInstance `
        -Query "SELECT BlockSize from Win32_Volume WHERE DriveLetter = '$($DriveLetter):'" `
        -ErrorAction SilentlyContinue).BlockSize
    if (-not ($blockSize))
    {
        # If Get-CimInstance did not return a value, try again with Get-WmiObject
        $blockSize = (Get-WmiObject `
            -Query "SELECT BlockSize from Win32_Volume WHERE DriveLetter = '$($DriveLetter):'" `
            -ErrorAction SilentlyContinue).BlockSize
    } # if

    if ($blockSize -gt 0 -and $AllocationUnitSize -ne 0)
    {
        if ($AllocationUnitSize -ne $blockSize)
        {
            # The allocation unit size mismatches but can't be changed (yet)
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.DriveAllocationUnitSizeMismatchMessage `
                        -f $DriveLetter,$($blockSize.BlockSize/1KB),$($AllocationUnitSize/1KB))
                ) -join '' )
        } # if
    } # if

    # Get the volume so the properties can be checked
    $volume = Get-Volume `
        -DriveLetter $DriveLetter `
        -ErrorAction SilentlyContinue

    if ($PSBoundParameters.ContainsKey('FSFormat'))
    {
        # Check the filesystem format
        $fileSystem = $volume.FileSystem
        if ($fileSystem -ne $FSFormat)
        {
            # The file system format does not match but can't be changed (yet)
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileSystemFormatMismatch `
                        -f $DriveLetter,$fileSystem,$FSFormat)
                ) -join '' )
        } # if
    } # if

    if ($PSBoundParameters.ContainsKey('FSLabel'))
    {
        # Check the volume label
        $label = $volume.FileSystemLabel
        if ($label -ne $FSLabel)
        {
            # The assigned volume label is different and needs updating
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.DriveLabelMismatch `
                        -f $DriveLetter,$label,$FSLabel)
                ) -join '' )

            return $false
        } # if
    } # if

    return $true
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
