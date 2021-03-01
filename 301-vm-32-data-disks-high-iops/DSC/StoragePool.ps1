Configuration StoragePool
{
  param ($MachineName)

  Node $MachineName
  {
	Script ConfigureStoragePool { 
		SetScript = { 
			$disks = Get-PhysicalDisk –CanPool $true
			New-StoragePool -FriendlyName "DataPool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $disks | New-VirtualDisk -FriendlyName "DataDisk" -UseMaximumSize -NumberOfColumns $disks.Count -ResiliencySettingName "Simple" -ProvisioningType Fixed -Interleave 65536 | Initialize-Disk -Confirm:$False -PassThru | New-Partition -DriveLetter H –UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$false			
		} 

		TestScript = { 
			Test-Path H:\ 
		} 
		GetScript = { <# This must return a hash table #> }          }   
  }
}
