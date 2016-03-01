param
(
    [String] $DBDataLUNS = "0,1,2",	
    [String] $DBLogLUNS = "3",
    [string] $DBDataDrive = "S:",
    [string] $DBLogDrive = "L:",
	[string] $DBDataName = "dbdata",
    [string] $DBLogName = "dblog"
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

function Create-Pool
{
    param
    (
        $arraystring,
        $name,
        $path
    )

    Log ("Creating volume for " + $arraystring);
    $luns = $arraystring.Split(",");
    if ($luns.Length -gt 1)
    {
        $count = 0;
        $disks = @();
        foreach ($lun in $luns)
        {
	    Log ("Preparing LUN " + $lun);
            $disk = Get-WmiObject Win32_DiskDrive | where InterfaceType -eq SCSI | where SCSILogicalUnit -eq $lun | % { Get-Disk -Number $_.Index } | select -First 1;
            $disk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue;
            $disks += Get-PhysicalDisk -UniqueId $disk.UniqueId;
            $count++;
        }
        $subsystem = Get-StorageSubSystem;
        Log "Creating Pool";
        $pool = New-StoragePool -FriendlyName $name -StorageSubsystemFriendlyName $subsystem.FriendlyName -PhysicalDisks $disks -ResiliencySettingNameDefault Simple -ProvisioningTypeDefault Fixed;
        Log "Creating disk";
        $disk = New-VirtualDisk -StoragePoolUniqueId $pool.UniqueId -FriendlyName $name -UseMaximumSize
        Initialize-Disk -PartitionStyle GPT -UniqueId $disk.UniqueId
        $partition = New-Partition -UseMaximumSize -DiskId $disk.UniqueId -DriveLetter $path.Substring(0,1)
        $partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $name -Confirm:$false;
    }
    elseif ($luns.Length -eq 1)
    {		
        $lun = $luns[0];
		Log ("Creating volume for disk " + $lun);
        $disk = Get-WmiObject Win32_DiskDrive | where InterfaceType -eq SCSI | where SCSILogicalUnit -eq $lun | % { Get-Disk -Number $_.Index } | select -First 1;
        $partition = $disk | Initialize-Disk -PartitionStyle GPT -ErrorAction SilentlyContinue -PassThru | New-Partition -DriveLetter $path.Substring(0,1) -UseMaximumSize;
		sleep 10;
		$partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $name -Confirm:$false;
    }
}

Create-Pool -arraystring $DBDataLUNS -name $DBDataName -path $DBDataDrive 
Create-Pool -arraystring $DBLogLUNS -name $DBLogName -path $DBLogDrive
