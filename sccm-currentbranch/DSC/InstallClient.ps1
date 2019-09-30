Param($DomainFullName,$CMUser,$ClientName,$DPMPName,$Role,$ProvisionToolPath)

$logpath = $ProvisionToolPath+"\InstallClientLog.txt"
$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"
$Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

$Configuration.InstallClient.Status = 'Running'
$Configuration.InstallClient.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

$DomainUserName = $CMUser
$SiteCode = $Role

$ProviderMachineName = $env:COMPUTERNAME+"."+$DomainFullName # SMS Provider machine name
$DPMPMachineName = $DPMPName +"." + $DomainFullName

# Customizations
$initParams = @{}
if($ENV:SMS_ADMIN_UI_PATH -eq $null)
{
    $ENV:SMS_ADMIN_UI_PATH = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386"
}

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
}

# Connect to the site's drive if it is not already present
"[$(Get-Date -format HH:mm:ss)] Setting PS Drive..." | Out-File -Append $logpath

New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
while((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
{
    "[$(Get-Date -format HH:mm:ss)] Failed ,retry in 10s. Please wait." | Out-File -Append $logpath
    Start-Sleep -Seconds 10
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

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

#Get Client IP
$clientIP= (Test-Connection $ClientName -count 1 | select @{Name="Computername";Expression={$_.Address}},Ipv4Address).IpV4Address.IPAddressToString

"[$(Get-Date -format HH:mm:ss)] Client IP is $clientIP." | Out-File -Append $logpath
$boundaryrange = $clientIP+"-"+$clientIP

"[$(Get-Date -format HH:mm:ss)] Create boundary and boundary group..." | Out-File -Append $logpath
New-CMBoundary -Type IPRange -Name Client -Value $boundaryrange

New-CMBoundaryGroup -Name $SiteCode -DefaultSiteCode $SiteCode -AddSiteSystemServerName $DPMPMachineName

Add-CMBoundaryToGroup -BoundaryName Client -BoundaryGroupName $SiteCode

#Wait collection
$machinelist = (get-cmdevice -CollectionName "all systems").Name
while($machinelist -notcontains $ClientName)
{
    "[$(Get-Date -format HH:mm:ss)] Waiting for client appear in all systems collection." | Out-File -Append $logpath
    Start-Sleep -Seconds 20
    $machinelist = (get-cmdevice -CollectionName "all systems").Name
}
"[$(Get-Date -format HH:mm:ss)]Push Client..." | Out-File -Append $logpath
Install-CMClient -DeviceName $ClientName -SiteCode $SiteCode -AlwaysInstallClient $true
"[$(Get-Date -format HH:mm:ss)]Done." | Out-File -Append $logpath

$Configuration.InstallClient.Status = 'Completed'
$Configuration.InstallClient.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
