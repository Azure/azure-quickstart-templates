Param($DomainFullName,$CMUser,$ClientName,$DPMPName,$Role,$ProvisionToolPath)

$logpath = $ProvisionToolPath+"\InstallClientLog.txt"
$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"
$Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

#Install Client
$Configuration.InstallClient.Status = 'Running'
$Configuration.InstallClient.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Start running install client script." | Out-File -Append $logpath
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
$DPMPMachineName = $DPMPName +"." + $DomainFullName
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

Get-CMManagementPoint -SiteSystemServerName $DPMPMachineName

"[$(Get-Date -format HH:mm:ss)] Setting system descovery..." | Out-File -Append $logpath
$DomainName = $DomainFullName.split('.')[0]
$lastdomainname = $DomainFullName.Split(".")[-1]
while(((Get-CMDiscoveryMethod | ?{$_.ItemName -eq "SMS_AD_SYSTEM_DISCOVERY_AGENT|SMS Site Server"}).Props | ?{$_.PropertyName -eq "Settings"}).value1.ToLower() -ne "active")
{
    start-sleep -Seconds 20
    Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode $SiteCode -Enabled $true -AddActiveDirectoryContainer "LDAP://DC=$DomainName,DC=$lastdomainname" -Recursive
}
"[$(Get-Date -format HH:mm:ss)] Invoke system descovery..." | Out-File -Append $logpath
Invoke-CMSystemDiscovery 

#Create Boundry Group
"[$(Get-Date -format HH:mm:ss)] Create boundary group." | Out-File -Append $logpath
New-CMBoundaryGroup -Name $SiteCode -DefaultSiteCode $SiteCode -AddSiteSystemServerName $DPMPMachineName

#Get Client IP
$ClientNameList = $ClientName.split(",")
foreach($client in $ClientNameList)
{
    $clientIP= (Test-Connection $client -count 1 | select @{Name="Computername";Expression={$_.Address}},Ipv4Address).IpV4Address.IPAddressToString
    
    "[$(Get-Date -format HH:mm:ss)] $client IP is $clientIP." | Out-File -Append $logpath
    $boundaryrange = $clientIP+"-"+$clientIP
    
    "[$(Get-Date -format HH:mm:ss)] Create boundary..." | Out-File -Append $logpath
    New-CMBoundary -Type IPRange -Name $client -Value $boundaryrange
    
    "[$(Get-Date -format HH:mm:ss)] Add $client IP to Boundry Group..." | Out-File -Append $logpath
    Add-CMBoundaryToGroup -BoundaryName $client -BoundaryGroupName $SiteCode
}

#Wait collection
$machinelist = (get-cmdevice -CollectionName "all systems").Name

foreach($client in $ClientNameList)
{
    while($machinelist -notcontains $client)
    {
        Invoke-CMDeviceCollectionUpdate -Name "all systems"
        "[$(Get-Date -format HH:mm:ss)] Waiting for " + $client + " appear in all systems collection." | Out-File -Append $logpath
        Start-Sleep -Seconds 20
        $machinelist = (get-cmdevice -CollectionName "all systems").Name
    }
    "[$(Get-Date -format HH:mm:ss)] " + $client + "push Client..." | Out-File -Append $logpath
    Install-CMClient -DeviceName $client -SiteCode $SiteCode -AlwaysInstallClient $true
    "[$(Get-Date -format HH:mm:ss)] " + $client + "push Client Done." | Out-File -Append $logpath
}

$Configuration.InstallClient.Status = 'Completed'
$Configuration.InstallClient.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
