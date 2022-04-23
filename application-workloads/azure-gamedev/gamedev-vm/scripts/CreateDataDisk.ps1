#$size = (Get-PartitionSupportedSize -DriveLetter 'C')
#Resize-Partition -DriveLetter 'C' -Size $size.SizeMax

If ((Get-PhysicalDisk).Count -lt 3) { Exit }

New-StoragePool –FriendlyName LUN-0 –StorageSubsystemFriendlyName 'Windows Storage*' –PhysicalDisks (Get-PhysicalDisk -FriendlyName 'Msft Virtual Disk')

New-VirtualDisk -FriendlyName DataDisk1 -StoragePoolFriendlyName LUN-0 -UseMaximumSize -ResiliencySettingName Simple
Start-Sleep -Seconds 20

Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName DataDisk1)
Start-Sleep -Seconds 20

$diskNumber = ((Get-VirtualDisk -FriendlyName DataDisk1 | Get-Disk).Number)
New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
Start-Sleep -Seconds 20


Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel Data -Confirm:$false -Force
