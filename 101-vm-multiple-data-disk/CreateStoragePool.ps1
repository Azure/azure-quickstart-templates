$subsystem = Get-StorageSubSystem
$subsystemname = $subsystem[0].FriendlyName

$PhysicalDisks = (Get-PhysicalDisk -CanPool $True)

New-StoragePool -FriendlyName DataPool_01 -StorageSubSystemFriendlyName $subsystemname -PhysicalDisks $PhysicalDisks

$disk = New-VirtualDisk -StoragePoolFriendlyName DataPool_01 -FriendlyName DataDisk_01 -Size 2TB -ResiliencySettingName Parity -ProvisioningType Thin

Initialize-Disk -VirtualDisk $disk

$part = New-Partition -DiskId $disk.UniqueId -DriveLetter "G" -UseMaximumSize

Format-Volume -DriveLetter $part.DriveLetter -NewFileSystemLabel "Data01" -Confirm:$false

