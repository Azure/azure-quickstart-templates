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
Import-Module $modulePath
$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$subKey =  $key.OpenSubKey("SOFTWARE\Microsoft\SMS\Identification")
$SiteCode =  $subKey.GetValue("Site Code")
$MachineName = $DPMPName + "." + $DomainFullName
$initParams = @{}
Set-Location "$($SiteCode):\" @initParams

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