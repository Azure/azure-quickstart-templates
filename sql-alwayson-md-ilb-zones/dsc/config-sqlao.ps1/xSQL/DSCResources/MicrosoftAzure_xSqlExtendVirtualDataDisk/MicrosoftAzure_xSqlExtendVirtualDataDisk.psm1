#
# xSqlExtendVirtualDataDisk: DSC resource to extend a virtual data disk 
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $NumberOfDisks,
        
        [parameter(Mandatory = $true)]
        [System.String]$DiskLetter,

        [parameter(Mandatory = $true)]
        [System.String]$VirtualDiskName,

        [parameter(Mandatory = $true)]
        [System.String]$StoragePoolName,

        [parameter(Mandatory = $true)]
        [System.Uint32]$StartingDeviceID,

        [System.Uint64]$DiskSizeInByte = 1099511627776

    )
    
    $bConfigured = Test-TargetResource -DiskSizeInByte $DiskSizeInByte -NumberOfDisks $NumberOfDisks -DiskLetter $DiskLetter -StartingDeviceID $StartingDeviceID -VirtualDiskName $VirtualDiskName -StoragePoolName $StoragePoolName

    $retVal = @{
        NumberOfDisks = $NumberOfDisks
        DiskLetter = $DiskLetter
        VirtualDiskName = $VirtualDiskName
        StoragePoolName = $StoragePoolName
        StartingDeviceID = $StartingDeviceID
        DiskSizeInByte = $DiskSizeInByte   
    }

    $retVal
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $NumberOfDisks,
        
        [parameter(Mandatory = $true)]
        [System.String]$DiskLetter,

        [parameter(Mandatory = $true)]
        [System.String]$VirtualDiskName,

        [parameter(Mandatory = $true)]
        [System.String]$StoragePoolName,

        [parameter(Mandatory = $true)]
        [System.Uint32]$StartingDeviceID,

        [System.Uint64]$DiskSizeInByte = 1099511627776
    )
    
    $result = [System.Boolean]
    
    $result = $true

    #Validating available disks
    $DisksForStoragePool = GetPhysicalDisks -DeviceID $StartingDeviceID -NumberOfDisks $NumberOfDisks

    if (($DisksForStoragePool) -or ($DisksForStoragePool.Count -eq $NumberOfDisks)) 
    {
        Write-Verbose "Target Disks still available , exiting Test-TargetResource ....."

        return $false
    }

    $result    
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $NumberOfDisks,
        
        [parameter(Mandatory = $true)]
        [System.String]$DiskLetter,

        [parameter(Mandatory = $true)]
        [System.String]$VirtualDiskName,

        [parameter(Mandatory = $true)]
        [System.String]$StoragePoolName,

        [parameter(Mandatory = $true)]
        [System.Uint32]$StartingDeviceID,

        [System.Uint64]$DiskSizeInByte = 1099511627776
    )
    
    #Validating Virtual Disk
    Verify-VirtualDisk -TimeOut 20

    Write-Verbose "Virtual Disk $($VirtualDiskName) found successfully."      

    #Validating Storage Pool
    Verify-NewStoragePool -TimeOut 20

    Write-Verbose "Storage Pool $($StoragePoolName) found successfully."        

    #Get Disks for storage pool
    $DisksForStoragePool = GetPhysicalDisks -DeviceID $StartingDeviceID -NumberOfDisks $NumberOfDisks

    if (!$DisksForStoragePool)
    {
        Write-Error "Unable to get any disks for creating Storage Pool. exiting"
        return $false
    }

    if ($DisksForStoragePool -and (1 -eq $NumberOfDisks))
    {
        Write-Verbose "Got $($NumberOfDisks) disks for creating Storage Pool. "
    }
    elseif ($DisksForStoragePool -and ($DisksForStoragePool.Count -eq $NumberOfDisks))
    {
        Write-Verbose "Got $($NumberOfDisks) disks for creating Storage Pool. "
    }
    else 
    {
        Write-Error "Unable to get $($NumberOfDisks) disks for creating Storage Pool. exiting"
        return $false
    }

    #Get the current storage pool size
    $OldStoragePoolSize =  (Get-StoragePool -FriendlyName $StoragePoolName).Size

    #Adding to Storage Pool
    Add-PhysicalDisk -PhysicalDisks $DisksForStoragePool -StoragePoolFriendlyName $StoragePoolName 

    $NewStoragePoolSize =  (Get-StoragePool -FriendlyName $StoragePoolName).Size

    Verify-StoragePoolSize -TimeOut 40

    #Storage Pool always a little bit smaller than the ideal size
    $NewStoragePoolSize = [int64]($NewStoragePoolSize *0.998)

    #Resize Virtual Disk
    $OldPartitionSize = Get-PartitionSupportedSize -DriveLetter $DiskLetter

    Write-Verbose "Current available partition Size is $($OldPartitionSize), Reizing Virtual Disk....."

    Resize-VirtualDisk -FriendlyName $VirtualDiskName -Size $NewStoragePoolSize

    #Resize Partition

    $NewPartitionSize = Get-PartitionSupportedSize -DriveLetter $DiskLetter

    Verify-PartitionSize -TimeOut 40

    $NewPartitionSize = Get-PartitionSupportedSize -DriveLetter $DiskLetter
    
    Write-Verbose "New available partition Size is $($NewPartitionSize) , Reizing Partition ...."        
    
    Resize-Partition -DriveLetter $DiskLetter -Size $NewPartitionSize.SizeMax

    Start-Sleep -Seconds 10
}

function GetPhysicalDisks
{
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $DeviceID,

        [parameter(Mandatory = $true)]
        [System.Uint32]
        $NumberOfDisks
    )

    $upperDeviceID = $DeviceID + $NumberOfDisks - 1

    $Disks= Get-PhysicalDisk | Where-Object { ([int]$_.DeviceId -ge $DeviceID) -and ([int]$_.DeviceId -le $upperDeviceID) -and ($_.CanPool -eq $true)}

    return $Disks
}

function Verify-PartitionSize{
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $TimeOut
    )

   $timespan = new-timespan -Seconds $TimeOut

   $sw = [diagnostics.stopwatch]::StartNew()

    while ($sw.elapsed -lt $timespan){
        
        if ($OldPartitionSize.SizeMax -lt $NewPartitionSize.SizeMax){
            return $true
        }
    
        Get-disk | Update-Disk

        $NewPartitionSize = Get-PartitionSupportedSize -DriveLetter $DiskLetter

        start-sleep -seconds 3
    }
    
    Write-Error "No Size Change for Partition $($DiskLetter) after $($TimeOut)"
}

function Verify-StoragePoolSize{
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $TimeOut
    )

   $timespan = new-timespan -Seconds $TimeOut

   $sw = [diagnostics.stopwatch]::StartNew()

    while ($sw.elapsed -lt $timespan){
        
        if ($OldStoragePoolSize -lt $NewStoragePoolSize){
            return $true
        }
 
        start-sleep -seconds 1
    }
 
    Write-Error "No Size Change for Storage Pool $($StoragePoolName) after $($TimeOut)"
}

function Verify-NewStoragePool{
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $TimeOut
    )

   $timespan = new-timespan -Seconds $TimeOut

   $sw = [diagnostics.stopwatch]::StartNew()

    while ($sw.elapsed -lt $timespan){
        
    $StoragePool = Get-StoragePool -FriendlyName $StoragePoolName -ErrorAction SilentlyContinue

        if ($StoragePool){
            return $true
        }
 
        start-sleep -seconds 1
    }
 
    Write-Error "Unable to find Storage Pool $($StoragePoolName) after $($TimeOut)"
}


function Verify-VirtualDisk{
    param
    (
        [parameter(Mandatory = $true)]
        [System.Uint32]
        $TimeOut
    )

   $timespan = new-timespan -Seconds $TimeOut

   $sw = [diagnostics.stopwatch]::StartNew()

    while ($sw.elapsed -lt $timespan){
        
    $VirtualDisk = Get-VirtualDisk -FriendlyName $VirtualDiskName -ErrorAction SilentlyContinue

        if ($VirtualDisk){
            return $true
        }
 
        start-sleep -seconds 1
    }
    

    Write-Error "Unable to find Vitrual Disk $($VirtualDiskName) after $($TimeOut)"
}


Export-ModuleMember -Function *-TargetResource