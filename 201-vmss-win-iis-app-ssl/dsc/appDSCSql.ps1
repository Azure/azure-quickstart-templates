Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration
Node $nodeName
  {
   <# This commented section represents an example configuration that can be updated as required.
    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature WebManagementConsole
    {
      Name = "Web-Mgmt-Console"
      Ensure = "Present"
    }
    WindowsFeature WebManagementService
    {
      Name = "Web-Mgmt-Service"
      Ensure = "Present"
    }
    WindowsFeature ASPNet45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }
    WindowsFeature HTTPRedirection
    {
      Name = "Web-Http-Redirect"
      Ensure = "Present"
    }
    WindowsFeature CustomLogging
    {
      Name = "Web-Custom-Logging"
      Ensure = "Present"
    }
    WindowsFeature LogginTools
    {
      Name = "Web-Log-Libraries"
      Ensure = "Present"
    }
    WindowsFeature RequestMonitor
    {
      Name = "Web-Request-Monitor"
      Ensure = "Present"
    }
    WindowsFeature Tracing
    {
      Name = "Web-Http-Tracing"
      Ensure = "Present"
    }
    WindowsFeature BasicAuthentication
    {
      Name = "Web-Basic-Auth"
      Ensure = "Present"
    }
    WindowsFeature WindowsAuthentication
    {
      Name = "Web-Windows-Auth"
      Ensure = "Present"
    }
    WindowsFeature ApplicationInitialization
    {
      Name = "Web-AppInit"
      Ensure = "Present"
    }
    Script DownloadWebDeploy
    {
        TestScript = {
            Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        }
        SetScript ={
            $source = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
            $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = {@{Result = "DownloadWebDeploy"}}
        DependsOn = "[WindowsFeature]WebServerRole"
    }
    Package InstallWebDeploy
    {
        Ensure = "Present"  
        Path  = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        Name = "Microsoft Web Deploy 3.6"
        ProductId = "{ED4CC1E5-043E-4157-8452-B5E533FE2BA1}"
        Arguments = "ADDLOCAL=ALL"
        DependsOn = "[Script]DownloadWebDeploy"
    }
    Service StartWebDeploy
    {                    
        Name = "WMSVC"
        StartupType = "Automatic"
        State = "Running"
        DependsOn = "[Package]InstallWebDeploy"
    } #>
	Script ConfigureSql
    {
        TestScript = {
            return $false
        }
        SetScript ={
		$disks = Get-Disk | Where partitionstyle -eq 'raw' 
		if($disks -ne $null)
		{
		# Create a new storage pool using all available disks 
		New-StoragePool –FriendlyName "VMStoragePool" `
				–StorageSubsystemFriendlyName "Storage Spaces*" `
				–PhysicalDisks (Get-PhysicalDisk –CanPool $True)

		# Return all disks in the new pool
		$disks = Get-StoragePool –FriendlyName "VMStoragePool" `
					-IsPrimordial $false | 
					Get-PhysicalDisk

		# Create a new virtual disk 
		New-VirtualDisk –FriendlyName "DataDisk" `
				-ResiliencySettingName Simple `
						–NumberOfColumns $disks.Count `
						–UseMaximumSize –Interleave 256KB `
						-StoragePoolFriendlyName "VMStoragePool" 

		# Format the disk using NTFS and mount it as the F: drive
		Get-Disk | 
			Where partitionstyle -eq 'raw' |
			Initialize-Disk -PartitionStyle MBR -PassThru |
			New-Partition -DriveLetter "F" -UseMaximumSize |
	Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk" -Confirm:$false

		Start-Sleep -Seconds 60

		$logs = "F:\Logs"
		$data = "F:\Data"
		$backups = "F:\Backup" 
		[system.io.directory]::CreateDirectory($logs)
		[system.io.directory]::CreateDirectory($data)
		[system.io.directory]::CreateDirectory($backups)
		[system.io.directory]::CreateDirectory("C:\SQDATA")

	# Setup the data, backup and log directories as well as mixed mode authentication
	Import-Module "sqlps" -DisableNameChecking
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
	$sqlesq = new-object ('Microsoft.SqlServer.Management.Smo.Server') Localhost
	$sqlesq.Settings.LoginMode = [Microsoft.SqlServer.Management.Smo.ServerLoginMode]::Mixed
	$sqlesq.Settings.DefaultFile = $data
	$sqlesq.Settings.DefaultLog = $logs
	$sqlesq.Settings.BackupDirectory = $backups
	$sqlesq.Alter() 

	# Restart the SQL Server service
	Restart-Service -Name "MSSQLSERVER" -Force
	# Re-enable the sa account and set a new password to enable login
	Invoke-Sqlcmd -ServerInstance Localhost -Database "master" -Query "ALTER LOGIN sa ENABLE"
	Invoke-Sqlcmd -ServerInstance Localhost -Database "master" -Query "ALTER LOGIN sa WITH PASSWORD = 'demo@pass1'"

	# Get the Adventure works database backup 
	$dbsource = "https://computeteststore.blob.core.windows.net/deploypackage/AdventureWorks2012.bak?sv=2015-04-05&ss=bfqt&srt=sco&sp=r&se=2099-10-16T02:03:39Z&st=2016-10-15T18:03:39Z&spr=https&sig=aSH6yNPEGPWXk6PxTPzS6fyEXMD1ZYIkI0j5E9Hu5%2Fk%3D"
	$dbdestination = "C:\SQDATA\AdventureWorks2012.bak"
	Invoke-WebRequest $dbsource -OutFile $dbdestination 

	$mdf = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("AdventureWorks2012_Data", "F:\Data\AdventureWorks2012.mdf")
	$ldf = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("AdventureWorks2012_Log", "F:\Logs\AdventureWorks2012.ldf")

	# Restore the database from the backup
	Restore-SqlDatabase -ServerInstance Localhost -Database AdventureWorks `
					-BackupFile $dbdestination -RelocateFile @($mdf,$ldf)  
	New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound –Protocol TCP –LocalPort 1433 -Action allow 

	}
  }
        GetScript = {@{Result = "ConfigureSql"}}
}

  }
}