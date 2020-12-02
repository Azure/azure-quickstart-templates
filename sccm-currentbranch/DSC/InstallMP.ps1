Param($DomainFullName,$DPMPName,$Role,$ProvisionToolPath)

$logpath = $ProvisionToolPath+"\InstallMPlog.txt"
$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"
$Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

#Install MP
$Configuration.InstallMP.Status = 'Running'
$Configuration.InstallMP.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Start running add management point script." | Out-File -Append $logpath
$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
$subKey =  $key.OpenSubKey("SOFTWARE\Microsoft\ConfigMgr10\Setup")
$uiInstallPath = $subKey.GetValue("UI Installation Directory")
$modulePath = $uiInstallPath+"bin\ConfigurationManager.psd1"
# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module $modulePath
}
$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$subKey =  $key.OpenSubKey("SOFTWARE\Microsoft\SMS\Identification")
$SiteCode =  $subKey.GetValue("Site Code")
$MachineName = $DPMPName + "." + $DomainFullName
$initParams = @{}

$ProviderMachineName = $env:COMPUTERNAME+"."+$DomainFullName # SMS Provider machine name
# Connect to the site's drive if it is not already present
"[$(Get-Date -format HH:mm:ss)] Setting PS Drive..." | Out-File -Append $logpath
New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams

while((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
{
    "[$(Get-Date -format HH:mm:ss)] Retry in 10s to set PS Drive. Please wait." | Out-File -Append $logpath
    Start-Sleep -Seconds 10
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

Set-Location "$($SiteCode):\" @initParams

#Get Database name
$DatabaseValue='Database Name'
$DatabaseName=(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\SMS\SQL Server' -Name 'Database Name').$DatabaseValue
#Get Instance Name
$InstanceValue='Service Name'
$InstanceName=(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\SMS\SQL Server' -Name 'Service Name').$InstanceValue

$SystemServer = Get-CMSiteSystemServer -SiteSystemServerName $MachineName
if(!$SystemServer)
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Creating cm site system server..." | Out-File -Append $logpath
    New-CMSiteSystemServer -SiteSystemServerName $MachineName | Out-File -Append $logpath
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Finished creating cm site system server." | Out-File -Append $logpath
    $Date = [DateTime]::Now.AddYears(30)
    $SystemServer = Get-CMSiteSystemServer -SiteSystemServerName $MachineName
}

if((Get-CMManagementPoint -SiteSystemServerName $MachineName).count -ne 1)
{
    #Install MP
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Adding management point on $MachineName ..." | Out-File -Append $logpath
    Add-CMManagementPoint -InputObject $SystemServer -CommunicationType Http | Out-File -Append $logpath
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Finished adding management point on $MachineName ..." | Out-File -Append $logpath
    
    $connectionString = "Data Source=.; Integrated Security=SSPI; Initial Catalog=$DatabaseName"
    if($InstanceName.ToUpper() -ne 'MSSQLSERVER')
    {
        $connectionString = "Data Source=.\$InstanceName; Integrated Security=SSPI; Initial Catalog=$DatabaseName"
    }
    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $sqlCommand = "INSERT INTO [Feature_EC] (FeatureID,Exposed) values (N'49E3EF35-718B-4D93-A427-E743228F4855',0)"
    $connection.Open() | Out-Null
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $command.ExecuteNonQuery() | Out-Null

    if((Get-CMManagementPoint -SiteSystemServerName $MachineName).count -eq 1)
    {
        "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Finished running the script." | Out-File -Append $logpath
        $Configuration.InstallMP.Status = 'Completed'
        $Configuration.InstallMP.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
    }
    else
    {
        "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Failed to run the script." | Out-File -Append $logpath
        $Configuration.InstallMP.Status = 'Failed'
        $Configuration.InstallMP.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
    }
}
else
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] $MachineName is already a management point , skip running this script." | Out-File -Append $logpath
}