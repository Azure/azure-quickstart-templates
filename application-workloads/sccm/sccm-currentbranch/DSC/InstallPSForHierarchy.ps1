Param($DomainFullName,$CM,$CMUser,$Role,$ProvisionToolPath,$CSName,$CSRole,$LogFolder)

$SMSInstallDir="C:\Program Files\Microsoft Configuration Manager"

$logpath = $ProvisionToolPath+"\InstallSCCMlog.txt"
$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"
$Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

$Configuration.WaitingForCASFinsihedInstall.Status = 'Running'
$Configuration.WaitingForCASFinsihedInstall.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force


$_Role = $CSRole
$_FilePath = "\\$CSName\$LogFolder"
$CSConfigurationFile = Join-Path -Path $_FilePath -ChildPath "$_Role.json"

while(!(Test-Path $CSConfigurationFile))
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Wait for configuration file exist on $CSName, will try 60 seconds later..." | Out-File -Append $logpath
    Start-Sleep -Seconds 60
    $CSConfigurationFile = Join-Path -Path $_FilePath -ChildPath "$_Role.json"
}
$CSConfiguration = Get-Content -Path $CSConfigurationFile -ErrorAction Ignore | ConvertFrom-Json
while($CSConfiguration.$("UpgradeSCCM").Status -ne "Completed")
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Wait for step : [UpgradeSCCM] finished running on $CSName, will try 60 seconds later..." | Out-File -Append $logpath
    Start-Sleep -Seconds 60
    $CSConfiguration = Get-Content -Path $CSConfigurationFile | ConvertFrom-Json
}

$Configuration.WaitingForCASFinsihedInstall.Status = 'Completed'
$Configuration.WaitingForCASFinsihedInstall.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

$cmsourcepath = "\\$CSName\SMS_$CSRole\cd.latest"

$CMINIPath = "c:\HierarchyPS.ini"
"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Check ini file." | Out-File -Append $logpath

$cmini = @'
[Identification]
Action=InstallPrimarySite
CDLatest=1

[Options]
ProductID=EVAL
SiteCode=%Role%
SiteName=%Role%
SMSInstallDir=%InstallDir%
SDKServer=%MachineFQDN%
RoleCommunicationProtocol=HTTPorHTTPS
ClientsUsePKICertificate=0
PrerequisiteComp=1
PrerequisitePath=%REdistPath%
MobileDeviceLanguage=0
AdminConsole=1
JoinCEIP=0

[SQLConfigOptions]
SQLServerName=%SQLMachineFQDN%
DatabaseName=%SQLInstance%CM_%Role%
SQLSSBPort=4022
SQLDataFilePath=%SQLDataFilePath%
SQLLogFilePath=%SQLLogFilePath%

[CloudConnectorOptions]
CloudConnector=0
CloudConnectorServer=
UseProxy=0
ProxyName=
ProxyPort=

[SystemCenterOptions]
SysCenterId=

[HierarchyExpansionOption]
CCARSiteServer=%CASMachineFQDN%

'@
$inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances[0]
$p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$inst

$sqlinfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\$inst"

"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] ini file exist." | Out-File -Append $logpath
$cmini = $cmini.Replace('%InstallDir%',$SMSInstallDir)
$cmini = $cmini.Replace('%MachineFQDN%',"$env:computername.$DomainFullName")
$cmini = $cmini.Replace('%SQLMachineFQDN%',"$env:computername.$DomainFullName")
$cmini = $cmini.Replace('%Role%',$Role)
$cmini = $cmini.Replace('%SQLDataFilePath%',$sqlinfo.DefaultData)
$cmini = $cmini.Replace('%SQLLogFilePath%',$sqlinfo.DefaultLog)
$cmini = $cmini.Replace('%CM%',$CM)
$cmini = $cmini.Replace('%CASMachineFQDN%',"$CSName.$DomainFullName")
$cmini = $cmini.Replace('%REdistPath%',"$cmsourcepath\REdist")

if(!(Test-Path C:\$CM\Redist))
{
    New-Item C:\$CM\Redist -ItemType directory | Out-Null
}
    
if($inst.ToUpper() -eq "MSSQLSERVER")
{
    $cmini = $cmini.Replace('%SQLInstance%',"")
}
else
{
    $tinstance = $inst.ToUpper() + "\"
    $cmini = $cmini.Replace('%SQLInstance%',$tinstance)
}
$CMInstallationFile = "$cmsourcepath\SMSSETUP\BIN\X64\Setup.exe"
$cmini > $CMINIPath 
"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Installing.." | Out-File -Append $logpath
Start-Process -Filepath ($CMInstallationFile) -ArgumentList ('/NOUSERINPUT /script "' + $CMINIPath + '"') -wait

"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Finished installing CM." | Out-File -Append $logpath

Remove-Item $CMINIPath

#Waiting for Site ready
$CSConfiguration = Get-Content -Path $CSConfigurationFile -ErrorAction Ignore | ConvertFrom-Json
while($CSConfiguration.$("PSReadytoUse").Status -ne "Completed")
{
    Write-Verbose "Wait for step : [PSReadytoUse] finished running on $CSName, will try 60 seconds later..."
    Start-Sleep -Seconds 60
    $CSConfiguration = Get-Content -Path $CSConfigurationFile | ConvertFrom-Json
}

$Configuration.InstallSCCM.Status = 'Completed'
$Configuration.InstallSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
