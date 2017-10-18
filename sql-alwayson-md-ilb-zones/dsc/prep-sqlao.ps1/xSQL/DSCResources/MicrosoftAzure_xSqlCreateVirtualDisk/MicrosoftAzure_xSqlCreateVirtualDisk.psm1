#
# xSqlCreateVirtualDisk: DSC resource to create a virtual disk from a storage pool
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
 
        [parameter(Mandatory = $true)]
        [System.UInt64]
        $DriveSize,
 
        [parameter(Mandatory = $true)]
        [System.UInt32]
        $NumberOfColumns,

        [parameter(Mandatory = $true)]
        [UInt64]$BytesPerDisk,
        
        [parameter(Mandatory = $true)]
        [System.String]$OptimizationType,

        [ValidateNotNullOrEmpty()]
        [Bool]$RebootVirtualMachine = $false 
    )
    
    $bConfigured = Test-TargetResource -DriveSize $DriveSize -NumberOfColumns $NumberOfColumns -BytesPerDisk $BytesPerDisk

    $retVal = @{
        DriveSize = $DriveSize
        NumberOfColumns = $NumberOfColumns
        BytesPerDisk = $BytesPerDisk
        Configured = $bConfigured
    }

    $retVal
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [System.UInt64]
        $DriveSize,
 
        [parameter(Mandatory = $true)]
        [System.UInt32]
        $NumberOfColumns,

        [parameter(Mandatory = $true)]
        [UInt64]$BytesPerDisk,

        [parameter(Mandatory = $true)]
        [System.String]$OptimizationType,

        [ValidateNotNullOrEmpty()]
        [Bool]$RebootVirtualMachine = $false 
    )

    $allocationSizeInByte = 262144

    if ($RebootVirtualMachine -eq $true)
    {
        $global:DSCMachineStatus = 1
    }

    if($OptimizationType.ToUpper().CompareTo("OLTP") -eq 0)
    {
       $allocationSizeInByte = 65536
    }

    if ($NumberOfColumns -eq 1)
    {
        
        $disk = get-disk | ? PartitionStyle -eq 'RAW' | Select-Object -First 1 
            
        if ($disk.IsOffline -eq $true)
        {
            Write-Verbose 'Setting disk Online'
            $disk | Set-Disk -IsOffline $false
        }
        else
        {
            Write-Verbose 'Disk is Online'
        }
            
        if ($disk.IsReadOnly -eq $true)
        {
            Write-Verbose 'Setting disk to not ReadOnly'
            $disk | Set-Disk -IsReadOnly $false
        }
        else
        {
            Write-Verbose 'Setting is not ReadOnly'
        }

        $diskNumber = $disk.Number
            
        if ($disk.PartitionStyle -eq "RAW")
        {
            Write-Verbose -Message "Initializing disk number '$($DiskNumber)' for drive letter 'F'... "

            $disk | Initialize-Disk -PartitionStyle GPT -PassThru
                
            $partition = $disk | New-Partition -DriveLetter F -UseMaximumSize

            # Sometimes the disk will still be read-only after the call to New-Partition returns.
            Start-Sleep -Seconds 10

            $partition | Format-Volume -FileSystem NTFS -Confirm:$false 

            Write-Verbose -Message "Successfully initialized disk number '$($DiskNumber)'."

            return $true
        }
    }
    else 
    {
            $DiskSizeInByte = $BytesPerDisk*$DriveSize
            
            Write-Verbose 'Creating Storage Pool'
         
            New-StoragePool -FriendlyName 'SqlVMStoragePool' -StorageSubSystemUniqueId (Get-StorageSubSystem)[0].uniqueID -PhysicalDisks (Get-PhysicalDisk -CanPool $true)
         
            Write-Verbose 'Creating Virtual Disk'
         
            New-VirtualDisk -FriendlyName 'SqlVMDataDisk' -StoragePoolFriendlyName 'SqlVMStoragePool' -Size $DiskSizeInByte -Interleave $allocationSizeInByte -NumberOfColumns $NumberOfColumns -ProvisioningType Thin -ResiliencySettingName Simple
         
            Start-Sleep -Seconds 20
         
            Write-Verbose 'Initializing Disk'
         
            Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName 'SqlVMDataDisk')
          
            Start-Sleep -Seconds 20
         
            $diskNumber = ((Get-VirtualDisk -FriendlyName 'SqlVMDataDisk' | Get-Disk).Number)
          
            Write-Verbose 'Creating Partition'
         
            New-Partition -DiskNumber $diskNumber -UseMaximumSize -DriveLetter F
             
            Start-Sleep -Seconds 20
         
            Write-Verbose 'Formatting Volume and Assigning Drive Letter'
             
            Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false -Force

            return $true
    }

    return $false
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
 
        [parameter(Mandatory = $true)]
        [System.UInt64]
        $DriveSize,
 
        [parameter(Mandatory = $true)]
        [System.UInt32]
        $NumberOfColumns,

        [parameter(Mandatory = $true)]
        [UInt64]$BytesPerDisk,

        [parameter(Mandatory = $true)]
        [System.String]$OptimizationType,

        [ValidateNotNullOrEmpty()]
        [Bool]$RebootVirtualMachine = $false 
    )
    
        $result = [System.Boolean]
    Try 
    {
        if (Test-Path F:\) 
        {
            Write-Verbose 'F:/ exists on target.'

            $result = $true
        }
        else
        {
            Write-Verbose "F:/ can't be found."
            $result = $false
        }
    }
    Catch 
    {
        throw "An error occured getting the F:/ drive informations. Error: $($_.Exception.Message)"
    }

    $result    
}


Export-ModuleMember -Function *-TargetResource
