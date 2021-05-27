param
(
    [String] $luns = "0,1,2",	
    [String] $names = "3",
    [string] $paths = "S:",
    [string] $sizes = "L:"
)

$ErrorActionPreference = "Stop";
function Log
{
    param
    (
        [string] $message
    )
    $message = (Get-Date).ToString() + ": " + $message;
    Write-Host $message;
    if (-not (Test-Path ("c:" + [char]92 + "sapcd")))
    {
        $nul = mkdir ("c:" + [char]92 + "sapcd");
    }
    $message | Out-File -Append -FilePath ("c:" + [char]92 + "sapcd" + [char]92 + "log.txt");
}

$SEP_CONFIGS = "#"
$SEP_DISKS = ","
$SEP_PARTS = ","

$lunsSplit  = @($luns  -split $SEP_CONFIGS)
$namesSplit = @($names -split $SEP_CONFIGS)
$pathsSplit = @($paths -split $SEP_CONFIGS)
$sizesSplit = @($sizes -split $SEP_CONFIGS)
#todo parts must be same size

for ($index = 0; $index -lt $lunsSplit.Count; $index++)
{
    $lunParts = @($lunsSplit[$index]  -split $SEP_DISKS)
    $poolname = $namesSplit[$index]

    $pathsPartSplit = $pathsSplit[$index] -split $SEP_PARTS
    $sizesPartSplit = $sizesSplit[$index] -split $SEP_PARTS
    #todo parts must be same size

    if ($lunParts.Count -gt 1)
    {
        $count = 0;
        
        $subsystem = Get-StorageSubSystem;
        $pool = Get-StoragePool -FriendlyName $poolname -ErrorAction SilentlyContinue
        if (-not ($pool))
        {
            Log "Creating Pool";
            $disks = Get-WmiObject Win32_DiskDrive | where InterfaceType -eq SCSI | where SCSILogicalUnit -In $lunParts | % { Get-PhysicalDisk | where DeviceId -eq $_.Index }
            $pool = New-StoragePool -FriendlyName $poolname -StorageSubSystemUniqueId $subsystem.UniqueId -PhysicalDisks $disks -ResiliencySettingNameDefault Simple -ProvisioningTypeDefault Fixed;
        }
        
        $diskname = "$($poolname)"
        $disk = Get-VirtualDisk -FriendlyName $diskname -ErrorAction SilentlyContinue
        if (-not $disk)
        {
            Log "Creating disk";                
            $disk = New-VirtualDisk -StoragePoolUniqueId $pool.UniqueId -FriendlyName $diskname -UseMaximumSize
        }
        Initialize-Disk -PartitionStyle GPT -UniqueId $disk.UniqueId -ErrorAction SilentlyContinue
        
        for ($partIndex = 0; $partIndex -lt $pathsPartSplit.Count; $partIndex++)
        {            
            $name = "$($poolname)-$($partIndex)"
            $path = $pathsPartSplit[$partIndex]
            $size = $sizesPartSplit[$partIndex]
            $args = @{}

            if ($path.Length -eq 1)
            {
                $args += @{"DriveLetter"=$path}
            }
            if ($size -eq "100")
            {
                $args += @{"UseMaximumSize"=$true}
            }
            else
            {
                $unallocatedSize = $disk.Size - ($disk | Get-Disk | Get-Partition | Measure-Object -Property Size -Sum).Sum
                [UInt64] $sizeToUse = ($unallocatedSize / 100) * ([int]$size)
                $args += @{"Size"=$sizeToUse}
            }

            $volume = $disk | Get-Disk | Get-Partition | Get-Volume | where FileSystemLabel -eq $name
            if (-not $volume)
            {
                $partition = New-Partition -DiskId $disk.UniqueId @args
                $partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $name -Confirm:$false;
            }

            if ($path.Length -ne 1)
            {
                $partition = $disk | Get-Disk | Get-Partition | Get-Volume | where FileSystemLabel -eq $name | Get-Partition
                $ddisk = $disk | Get-Disk

                $diskMounted = $false
                foreach ($accessPath in $partition.AccessPaths)
                {
                    $diskMounted = (Join-Path $accessPath '') -eq (Join-Path $path '')
                    if ($diskMounted)
                    {
                        break
                    }
                }

                if (-not $diskMounted)
                {
                    if (-not (Test-Path $path))
                    {
                        $nul = mkdir $path
                    }
                    Add-PartitionAccessPath -PartitionNumber $partition.PartitionNumber -DiskNumber $ddisk.Number -AccessPath $path
                }
            }
        }
    }
    elseif ($lunParts.Length -eq 1)
    {		
        $lun = $lunParts[0];
        Log ("Creating volume for disk " + $lun);
        $disk = Get-WmiObject Win32_DiskDrive | where InterfaceType -eq SCSI | where SCSILogicalUnit -eq $lun | % { Get-Disk -Number $_.Index } | select -First 1;
        Initialize-Disk -PartitionStyle GPT -UniqueId $disk.UniqueId -ErrorAction SilentlyContinue

        for ($partIndex = 0; $partIndex -lt $pathsPartSplit.Count; $partIndex++)
        {
            $name = "$($poolname)-$($partIndex)"
            $path = $pathsPartSplit[$partIndex]
            $size = $sizesPartSplit[$partIndex]

            $args = @{}

            if ($path.Length -eq 1)
            {
                $args += @{"DriveLetter"=$path}
            }
            if ($size -eq "100")
            {
                $args += @{"UseMaximumSize"=$true}
            }
            else
            {
                $unallocatedSize = $disk.Size - $disk.AllocatedSize
                [UInt64] $sizeToUse = ($unallocatedSize / 100) * ([int]$size)
                $args += @{"Size"=$sizeToUse}
            }

            $volume = $disk | Get-Disk | Get-Partition | Get-Volume | where FileSystemLabel -eq $name
            if (-not $volume)
            {
                $partition = New-Partition -DiskId $disk.UniqueId @args
                $partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $name -Confirm:$false;
            }

            if ($path.Length -ne 1)
            {
                $partition = $disk | Get-Disk | Get-Partition | Get-Volume | where FileSystemLabel -eq $name | Get-Partition
                $ddisk = $disk | Get-Disk

                $diskMounted = $false
                foreach ($accessPath in $partition.AccessPaths)
                {
                    $diskMounted = (Join-Path $accessPath '') -eq (Join-Path $path '')
                    if ($diskMounted)
                    {
                        break
                    }
                }

                if (-not $diskMounted)
                {
                    if (-not (Test-Path $path))
                    {
                        $nul = mkdir $path
                    }
                    Add-PartitionAccessPath -PartitionNumber $partition.PartitionNumber -DiskNumber $ddisk.Number -AccessPath $path
                }
            }
        }
    }
}
