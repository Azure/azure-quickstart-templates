param(
    $dcpassword = $(throw "password is required"),
    $domainname = "apprenda.local",
    $netbiosname = "apprendadc"
)
Start-Transcript -path "c:\users\domainAdmin\domaincontrollerlog.txt"
#install features 
$featureLogPath = "c:\users\domainAdmin\featurelog.txt" 
New-Item $featureLogPath -ItemType file -Force 
$addsTools = "RSAT-AD-Tools" 
Add-WindowsFeature $addsTools 
start-job -Name addFeature -ScriptBlock { 
Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools } 
Wait-Job -Name addFeature 
Get-WindowsFeature | Where installed >>$featureLogPath
# Add Domain Controller 
$secpw = ConvertTo-SecureString $dcpassword -AsPlainText -Force 
Import-Module ADDSDeployment
Install-ADDSDomainController -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainName $domainname -InstallDns -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SafeModeAdministratorPassword $secpw -SysvolPath "C:\Windows\SYSVOL" -Force:$true
Stop-Transcript

# New ADDSForest
Start-Transcript -Path "C:\transcripts\adforest.txt"
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012" -DomainName $domainname -DomainNetbiosName $netbiosName -ForestMode "Win2012R2" -InstallDns -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SafeModeAdministratorPassword $secpw -SysvolPath "C:\Windows\SYSVOL" -Force:$true
Stop-Transcript