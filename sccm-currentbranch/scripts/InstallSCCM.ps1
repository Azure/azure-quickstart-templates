Param($DomainFullName,$Username,$Password,$CM,$SQLVMName,$SQLInstanceName,$SQLDataFilePath,$SQLLogFilePath)

if($DomainFullName)
{
    $NetBIOSName = $DomainFullName.split('.')[0]
    $Username = $NetBIOSName + '\' + $Username
}
$DomainPassword = $Password
$DomainUserName = $Username
$CMInstallMode = 'standalone'
$Role = "PS1"
$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
$logpath = $ProvisionToolPath+"\InstallSCCMLog.txt"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}

$cmpath = "c:\"+$CM+".exe"
$cmsourcepath = "c:\$CM"
if(Test-Path $cmpath)
{
    Remove-Item $cmpath
}

"[$(Get-Date -format HH:mm:ss)] Copying SCCM installation source..." | Out-File -Append $logpath
$cmurl = "http://download.microsoft.com/download/F/C/E/FCEC70F4-168A-4D68-8B52-30913C402D5F/SC_Configmgr_SCEP_1802.exe"
Invoke-WebRequest -Uri $cmurl -OutFile $cmpath

if(Test-Path $cmsourcepath)
{
    Remove-Item $cmsourcepath -Recurse -Force
}
Start-Process -Filepath ($cmpath) -ArgumentList ('/Auto "' + $cmsourcepath + '"') -wait

"[$(Get-Date -format HH:mm:ss)] Finished." | Out-File -Append $logpath
"[$(Get-Date -format HH:mm:ss)] Start installing CM." | Out-File -Append $logpath
"[$(Get-Date -format HH:mm:ss)] Current Install mode is $CMInstallMode." | Out-File -Append $logpath

if($CMInstallMode -eq "standalone")
{
    $CMINIPath = "c:\" +$CM+ "\" + $CMInstallMode + ".ini"
    "[$(Get-Date -format HH:mm:ss)] Check ini file." | Out-File -Append $logpath

    $cmini = @'
[Identification]
Action=InstallPrimarySite

[Options]
ProductID=EVAL
SiteCode=%Role%
SiteName=%Role%
SMSInstallDir=C:\Program Files\Microsoft Configuration Manager
SDKServer=%MachineFQDN%
RoleCommunicationProtocol=HTTPorHTTPS
ClientsUsePKICertificate=0
PrerequisiteComp=0
PrerequisitePath=C:\%CM%\REdist
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
CloudConnector=1
CloudConnectorServer=%MachineFQDN%
UseProxy=0
ProxyName=
ProxyPort=

[SystemCenterOptions]
SysCenterId=

[HierarchyExpansionOption]

'@

    "[$(Get-Date -format HH:mm:ss)] ini file exist." | Out-File -Append $logpath
    $cmini = $cmini.Replace('%MachineFQDN%',"$env:computername.$env:userdnsdomain")
    $cmini = $cmini.Replace('%SQLMachineFQDN%',"$SQLVMName.$env:userdnsdomain")
    $cmini = $cmini.Replace('%Role%',$Role)
    $cmini = $cmini.Replace('%SQLDataFilePath%',$SQLDataFilePath)
    $cmini = $cmini.Replace('%SQLLogFilePath%',$SQLLogFilePath)
    $cmini = $cmini.Replace('%CM%',$CM)

    if(!(Test-Path C:\$CM\REdist))
    {
        New-Item C:\$CM\REdist -ItemType directory | Out-Null
    }

    if($SQLInstanceName.ToUpper() -eq "MSSQLSERVER")
    {
        $cmini = $cmini.Replace('%SQLInstance%',"")
    }
    else
    {
        $tinstance = $SQLInstanceName.ToUpper() + "\"
        $cmini = $cmini.Replace('%SQLInstance%',$tinstance)
    }
    $CMInstallationFile = "c:\" + $CM + "\SMSSETUP\BIN\X64\Setup.exe"
    $cmini > $CMINIPath 
    "[$(Get-Date -format HH:mm:ss)] Installing.." | Out-File -Append $logpath
    Start-Process -Filepath ($CMInstallationFile) -ArgumentList ('/NOUSERINPUT /script "' + $CMINIPath + '"') -wait

    "[$(Get-Date -format HH:mm:ss)] Finished installing CM." | Out-File -Append $logpath

    Remove-Item $CMINIPath
}