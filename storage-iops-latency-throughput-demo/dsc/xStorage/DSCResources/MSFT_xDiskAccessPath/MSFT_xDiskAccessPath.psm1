# Suppressed as per PSSA Rule Severity guidelines for unit/integration tests:
# https://github.com/PowerShell/DscResources/blob/master/PSSARuleSeverities.md
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonResourceHelper.psm1')

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xDiskAccessPath'

# Import the common storage functions
Import-Module -Name ( Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\StorageCommon\StorageCommon.psm1' )

<#
    .SYNOPSIS
    Returns the current state of the Disk and Partition.

    .PARAMETER AccessPath
    Specifies the access path folder to the assign the disk volume to

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
        [System.String] $AccessPath,

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
            $($LocalizedData.GettingDiskMessage -f $DiskNumber,$AccessPath)
        ) -join '' )

    # Validate the AccessPath parameter adding a trailing slash
    $AccessPath = Assert-AccessPathValid -AccessPath $AccessPath -Slash

    $disk = Get-Disk `
        -Number $DiskNumber `
        -ErrorAction SilentlyContinue

    $partition = Get-Partition `
        -DiskNumber $DiskNumber `
        -ErrorAction SilentlyContinue |
            Where-Object -Property AccessPaths -Contains -Value $AccessPath

    $volume = $partition | Get-Volume

    $fileSystem = $volume.FileSystem
    $FSLabel = $volume.FileSystemLabel

    # Prepare the AccessPath used in the CIM/WMI query (replaces '\' with '\\')
    $queryAccessPath = $AccessPath -replace '\\','\\'

    $blockSize = (Get-CimInstance `
        -Query "SELECT BlockSize from Win32_Volume WHERE Name = '$queryAccessPath'" `
        -ErrorAction SilentlyContinue).BlockSize

    if ($blockSize)
    {
        $AllocationUnitSize = $blockSize
    }
    else
    {
        # If Get-CimInstance did not return a value, try again with Get-WmiObject
        $blockSize = (Get-WmiObject `
            -Query "SELECT BlockSize from Win32_Volume WHERE Name = '$queryAccessPath'" `
            -ErrorAction SilentlyContinue).BlockSize
    } # if

    $returnValue = @{
        DiskNumber = $disk.Number
        AccessPath = $AccessPath
        Size = $partition.Size
        FSLabel = $FSLabel
        AllocationUnitSize = $blockSize
        FSFormat = $fileSystem
    }
    $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    Initializes the Disk and Partition and assigns the access path.

    .PARAMETER AccessPath
    Specifies the access path folder to the assign the disk volume to

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
        [System.String] $AccessPath,

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
            $($LocalizedData.SettingDiskMessage -f $DiskNumber,$AccessPath)
        ) -join '' )

    # Validate the AccessPath parameter adding a trailing slash
    $AccessPath = Assert-AccessPathValid -AccessPath $AccessPath -Slash

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

    # Get the partitions on the disk
    $partition = Get-Partition `
        -DiskNumber $DiskNumber `
        -ErrorAction SilentlyContinue

    # Check if the disk has an existing partition assigned to the access path
    $assignedPartition = $partition |
            Where-Object -Property AccessPaths -Contains -Value $AccessPath

    if ($null -eq $assignedPartition)
    {
        # There is no partiton with this access path
        $createPartition = $true

        # Are there any partitions defined on this disk?
        if ($partition)
        {
            # There are partitions defined - identify if one matches the size required
            if ($Size)
            {
                # Find the first basic partition matching the size
                $partition = $partition |
                    Where-Object -Filter { $_.Type -eq 'Basic' -and $_.Size -eq $Size } |
                    Select-Object -First 1
            }
            else
            {
                # Find the first basic partition of any size
                $partition = $partition |
                    Where-Object -Filter { $_.Type -eq 'Basic' } |
                    Select-Object -First 1
            } # if

            if ($partition)
            {
                # A partition matching the required size was found
                Write-Verbose -Message ($LocalizedData.MatchingPartitionFoundMessage -f `
                    $DiskNumber,$partition.PartitionNumber)

                $createPartition = $false
            }
            else
            {
                # A partition matching the required size was not found
                Write-Verbose -Message ($LocalizedData.MatchingPartitionNotFoundMessage -f `
                    $DiskNumber)
            } # if
        } # if

        # Do we need to create a new partition?
        if ($createPartition)
        {
            # Attempt to create a new partition
            $partitionParams = @{
                DiskNumber = $DiskNumber
            }

            if ($Size)
            {
                # Use only a specific size
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.CreatingPartitionMessage `
                            -f $DiskNumber,"$($Size/1KB) KB")
                    ) -join '' )
                $partitionParams["Size"] = $Size
            }
            else
            {
                # Use the entire disk
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.CreatingPartitionMessage `
                            -f $DiskNumber,'all free space')
                    ) -join '' )
                $partitionParams["UseMaximumSize"] = $true
            } # if

            # Create the partition
            $partition = New-Partition @partitionParams

            # After creating the partition it can take a few seconds for it to become writeable
            # Wait for up to 30 seconds for the parition to become writeable
            $start = Get-Date
            $timeout = (Get-Date) + (New-Timespan -Second 30)
            While ($partition.IsReadOnly -and (Get-Date) -lt $timeout)
            {
                Write-Verbose -Message ($LocalizedData.NewPartitionIsReadOnlyMessage -f `
                    $partition.DiskNumber,$partition.PartitionNumber)

                Start-Sleep -Seconds 1

                # Pull the partition details again to check if it is readonly
                $partition = $partition | Get-Partition
            } # while
        } # if

        if ($partition.IsReadOnly)
        {
            # The partition is still readonly - throw an exception
            New-InvalidOperationException `
                -Message ($LocalizedData.ParitionIsReadOnlyError -f `
                    $partition.DiskNumber,$partition.PartitionNumber)
        } # if

        $assignAccessPath = $true
    }
    else
    {
        # The disk already has a partition on it that is assigned to the access path
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.PartitionAlreadyAssignedMessage -f `
                    $AccessPath,$partition.PartitionNumber)
            ) -join '' )

        $assignAccessPath = $false
    }

    # Get the Volume on the partition
    $volume = $partition | Get-Volume

    # Is the volume already formatted?
    if ($volume.FileSystem -eq '')
    {
        # The volume is not formatted
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
    }
    else
    {
        # The volume is already formatted
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
                        $($LocalizedData.FileSystemFormatMismatch -f `
                            $AccessPath,$fileSystem,$FSFormat)
                    ) -join '' )
            } # if
        } # if

        # Check the volume label
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

    # Assign the access path if it isn't assigned
    if ($assignAccessPath)
    {
        $null = Add-PartitionAccessPath `
            -AccessPath $AccessPath `
            -DiskNumber $DiskNumber `
            -PartitionNumber $partition.PartitionNumber

        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.SuccessfullyInitializedMessage -f $AccessPath)
            ) -join '' )
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests if the disk is initialized, the partion exists and the access path is assigned.

    .PARAMETER AccessPath
    Specifies the access path folder to the assign the disk volume to

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
        [System.String] $AccessPath,

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
            $($LocalizedData.TestingDiskMessage -f $DiskNumber,$AccessPath)
        ) -join '' )

    # Validate the AccessPath parameter adding a trailing slash
    $AccessPath = Assert-AccessPathValid -AccessPath $AccessPath -Slash

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
        -DiskNumber $DiskNumber `
        -ErrorAction SilentlyContinue |
            Where-Object -Property AccessPaths -Contains -Value $AccessPath

    if (-not $partition)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.AccessPathNotFoundMessage -f $AccessPath)
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
                    $($LocalizedData.SizeMismatchMessage -f `
                        $AccessPath,$Partition.Size,$Size)
                ) -join '' )
        } # if
    } # if

    # Prepare the AccessPath used in the CIM/WMI query (replaces '\' with '\\')
    $queryAccessPath = $AccessPath -replace '\\','\\'

    $blockSize = (Get-CimInstance `
        -Query "SELECT BlockSize from Win32_Volume WHERE Name = '$queryAccessPath'" `
        -ErrorAction SilentlyContinue).BlockSize
    if (-not ($blockSize))
    {
        # If Get-CimInstance did not return a value, try again with Get-WmiObject
        $blockSize = (Get-WmiObject `
            -Query "SELECT BlockSize from Win32_Volume WHERE Name = '$queryAccessPath'" `
            -ErrorAction SilentlyContinue).BlockSize
    } # if

    if ($blockSize -gt 0 -and $AllocationUnitSize -ne 0)
    {
        if ($AllocationUnitSize -ne $blockSize)
        {
            # The allocation unit size mismatches but can't be changed (yet)
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.AllocationUnitSizeMismatchMessage -f `
                        $AccessPath,$($blockSize.BlockSize/1KB),$($AllocationUnitSize/1KB))
                ) -join '' )
        } # if
    } # if

    # Get the volume so the properties can be checked
    $volume = $partition | Get-Volume

    if ($PSBoundParameters.ContainsKey('FSFormat'))
    {
        # Check the filesystem format
        $fileSystem = $volume.FileSystem
        if ($fileSystem -ne $FSFormat)
        {
            # The file system format does not match but can't be changed (yet)
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileSystemFormatMismatch -f `
                        $AccessPath,$fileSystem,$FSFormat)
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
                    $($LocalizedData.DriveLabelMismatch -f `
                        $DriveLetter,$label,$FSLabel)
                ) -join '' )
            return $false
        } # if
    } # if

    return $true
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
