#
# xComputer: DSC resource to initialize, partition, and format disks.
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [uint32] $DiskNumber,

        [parameter(Mandatory)]
        [string] $DriveLetter,

        [UInt64] $Size,
        [string] $FSLabel,
        [UInt32] $AllocationUnitSize
    )

    $Disk = Get-Disk -Number $DiskNumber -ErrorAction SilentlyContinue
    
    $Partition = Get-Partition -DriveLetter $DriveLetter -ErrorAction SilentlyContinue

    $FSLabel = Get-Volume -DriveLetter $DriveLetter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FileSystemLabel

    $BlockSize = Get-WmiObject -Query "SELECT BlockSize from Win32_Volume WHERE DriveLetter = '$($DriveLetter):'" -ErrorAction SilentlyContinue  | select BlockSize
    if($BlockSize){
        $AllocationUnitSize = $BlockSize.BlockSize
    }

    $returnValue = @{
        DiskNumber = $Disk.Number
        DriveLetter = $Partition.DriveLetter
        Size = $Partition.Size
        FSLabel = $FSLabel
        AllocationUnitSize = $AllocationUnitSize
    }
    $returnValue
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [uint32] $DiskNumber,

        [parameter(Mandatory)]
        [string] $DriveLetter,

        [UInt64] $Size,
        [string] $FSLabel,
        [UInt32] $AllocationUnitSize
    )
    
    try
    {
        $Disk = Get-Disk -Number $DiskNumber -ErrorAction Stop
    
        if ($Disk.IsOffline -eq $true)
        {
            Write-Verbose 'Setting disk Online'
            $Disk | Set-Disk -IsOffline $false
        }
        
        if ($Disk.IsReadOnly -eq $true)
        {
            Write-Verbose 'Setting disk to not ReadOnly'
            $Disk | Set-Disk -IsReadOnly $false
        }

        Write-Verbose -Message "Checking existing disk partition style..."
        if (($Disk.PartitionStyle -ne "GPT") -and ($Disk.PartitionStyle -ne "RAW"))
        {
            Throw "Disk '$($DiskNumber)' is already initialised with '$($Disk.PartitionStyle)'"
        }
        else
        {
            if ($Disk.PartitionStyle -eq "RAW")
            {
                Write-Verbose -Message "Initializing disk number '$($DiskNumber)'..."
                $Disk | Initialize-Disk -PartitionStyle "GPT" -PassThru
            }
            else
            {
                Write-Verbose -Message "Disk number '$($DiskNumber)' is already configured for 'GPT'"
            }
        }

        Write-Verbose -Message "Creating the partition..."
        $PartParams = @{
                        DriveLetter = $DriveLetter;
                        DiskNumber = $DiskNumber
                        }
        if ($Size)
        {
            $PartParams["Size"] = $Size
        }
        else
        {
            $PartParams["UseMaximumSize"] = $true
        }

        $Partition = New-Partition @PartParams
        
        # Sometimes the disk will still be read-only after the call to New-Partition returns.
        Start-Sleep -Seconds 5

        Write-Verbose -Message "Formatting the volume..."
        $VolParams = @{
                      FileSystem = "NTFS";
                      Confirm = $false
                      }

        if ($FSLabel)
        {
            $VolParams["NewFileSystemLabel"] = $FSLabel
        }
        if($AllocationUnitSize)
        {
            $VolParams["AllocationUnitSize"] = $AllocationUnitSize 
        }

        $Volume = $Partition | Format-Volume @VolParams


        if ($Volume)
        {
            Write-Verbose -Message "Successfully initialized '$($DriveLetter)'."
        }
    }
    catch
    {
        Throw "Disk Set-TargetResource failed with the following error: '$($Error[0])'"
    }
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [cmdletbinding()]
    param
    (
        [parameter(Mandatory)]
        [uint32] $DiskNumber,

        [parameter(Mandatory)]
        [string] $DriveLetter,

        [UInt64] $Size,
        [string] $FSLabel,
        [UInt32] $AllocationUnitSize
    )

    Write-Verbose -Message "Checking if disk number '$($DiskNumber)' is initialized..."
    $Disk = Get-Disk -Number $DiskNumber -ErrorAction SilentlyContinue

    if (-not $Disk)
    {
        Write-Verbose "Disk number '$($DiskNumber)' was not found."
        return $false
    }

    if ($Disk.IsOffline -eq $true)
    {
        Write-Verbose 'Disk is not Online'
        return $false
    }
    
    if ($Disk.IsReadOnly -eq $true)
    {
        Write-Verbose 'Disk set as ReadOnly'
        return $false
    }

    if ($Disk.PartitionStyle -ne "GPT")
    {
        Write-Verbose "Disk '$($DiskNumber)' is initialised with '$($Disk.PartitionStyle)' partition style"
        return $false
    }

    $Partition = Get-Partition -DriveLetter $DriveLetter -ErrorAction SilentlyContinue
    if (-not $Partition.DriveLetter -eq $DriveLetter)
    {
        Write-Verbose "Drive $DriveLetter was not found"
        return $false
    }

    # Drive size
    if ($Size)
    {
        if ($Partition.Size -ne $Size)
        {
            Write-Verbose "Drive $DriveLetter size does not match expected value. Current: $($Partition.Size) Expected: $Size"
            return $false
        }
    }
    $BlockSize = Get-WmiObject -Query "SELECT BlockSize from Win32_Volume WHERE DriveLetter = '$($DriveLetter):'" -ErrorAction SilentlyContinue  | select BlockSize
    if($BlockSize.BlockSize -gt 0 -and $AllocationUnitSize -ne 0)
    {
        if($AllocationUnitSize -ne $BlockSize.BlockSize)
        {
            # Just write a warning, we will not try to reformat a drive due to invalid allocation unit sizes
            Write-Verbose "Drive $DriveLetter allocation unit size does not match expected value. Current: $($BlockSize.BlockSize/1kb)kb Expected: $($AllocationUnitSize/1kb)kb"
        }    
    }

    # Volume label
    if (-not [string]::IsNullOrEmpty($FSLabel))
    {
        $Label = Get-Volume -DriveLetter $DriveLetter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FileSystemLabel
        if ($Label -ne $FSLabel)
        {
            Write-Verbose "Volume $DriveLetter label does not match expected value. Current: $Label Expected: $FSLabel)"
            return $false
        }
    }

    return $true
}


Export-ModuleMember -Function *-TargetResource
