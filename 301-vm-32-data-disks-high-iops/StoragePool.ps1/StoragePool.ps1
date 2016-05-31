Configuration StoragePool
{
  param ($MachineName,$adminCreds,$domainName)
  Write-Host $adminCreds.Username
  $domainCreds = New-Object System.Management.Automation.PSCredential ("$domainName\$($adminCreds.UserName)", $adminCreds.Password)
  
  Node $MachineName
  {
	 LocalConfigurationManager
        {
            ActionAfterreboot = "ContinueConfiguration"
            RebootNodeIfNeeded = $true
        }
    Script ConfigureStoragePool { 
		SetScript = { 
			$disks = Get-PhysicalDisk –CanPool $true
			New-StoragePool -FriendlyName "DataPool" -StorageSubsystemFriendlyName "Storage Spaces*" -PhysicalDisks $disks | New-VirtualDisk -FriendlyName "DataDisk" -UseMaximumSize -NumberOfColumns $disks.Count -ResiliencySettingName "Simple" -ProvisioningType Fixed -Interleave 65536 | Initialize-Disk -Confirm:$False -PassThru | New-Partition -DriveLetter H –UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$false			
		} 

		TestScript = { 
			Test-Path H:\ 
		} 
		GetScript = { <# This must return a hash table #> }          }   
   PsDscRunAsCredential = $domaincred
  }
} 