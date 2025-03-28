Param($DomainFullName,$CM,$CMUser,$Role,$ProvisionToolPath,$LogFolder,$PSName,$PSRole)

$DName = $DomainFullName.Split(".")[0]
$PSComputerAccount = "$DName\$PSName$"
$SMSInstallDir="C:\Program Files\Microsoft Configuration Manager"

$logpath = $ProvisionToolPath+"\InstallSCCMlog.txt"
$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"
$Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

$Configuration.InstallSCCM.Status = 'Running'
$Configuration.InstallSCCM.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

$cmpath = "c:\$CM.exe"
$cmsourceextractpath = "c:\$CM"
if(!(Test-Path $cmpath))
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Copying SCCM installation source..." | Out-File -Append $logpath
    $cmurl = "https://go.microsoft.com/fwlink/?linkid=2093192"
    Invoke-WebRequest -Uri $cmurl -OutFile $cmpath
    if(!(Test-Path $cmsourceextractpath))
    {
        New-Item -ItemType Directory -Path $cmsourceextractpath
        Start-Process -WorkingDirectory ($cmsourceextractpath) -Filepath ($cmpath) -ArgumentList ('/s') -wait
    }
}

$cmsourcepath = (Get-ChildItem -Path $cmsourceextractpath | ?{$_.Name.ToLower().Contains("cd.")}).FullName
$CMINIPath = "$cmsourceextractpath\HierarchyCS.ini"
"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Check ini file." | Out-File -Append $logpath

$cmini = @'
[Identification]
Action=InstallCAS

[Options]
ProductID=EVAL
SiteCode=%Role%
SiteName=%Role%
SMSInstallDir=%InstallDir%
SDKServer=%MachineFQDN%
PrerequisiteComp=0
PrerequisitePath=%cmsourcepath%\REdist
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
$cmini = $cmini.Replace('%cmsourcepath%',$cmsourcepath)

if(!(Test-Path $cmsourcepath\Redist))
{
    New-Item $cmsourcepath\Redist -ItemType directory | Out-Null
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

$Configuration.InstallSCCM.Status = 'Completed'
$Configuration.InstallSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

#Upgrade SCCM
$Configuration.UpgradeSCCM.Status = 'Running'
$Configuration.UpgradeSCCM.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

Start-Sleep -Seconds 120
$logpath = $ProvisionToolPath+"\UpgradeCMlog.txt"
$SiteCode =  Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\SMS\Identification' -Name 'Site Code'

$ProviderMachineName = $env:COMPUTERNAME+"."+$DomainFullName # SMS Provider machine name

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
"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Setting PS Drive..." | Out-File -Append $logpath
New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams

while((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Retry in 10s to set PS Drive. Please wait." | Out-File -Append $logpath
    Start-Sleep -Seconds 10
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#Add domain user as CM administrative user
"Setting $CMUser as CM administrative user." | Out-File -Append $logpath
New-CMAdministrativeUser -Name $CMUser -RoleName "Full Administrator" -SecurityScopeName "All","All Systems","All Users and User Groups"
"Done" | Out-File -Append $logpath

#Add PS computer account as CM administrative user
$ComputerAccount = $PSComputerAccount.Split('$')[0]
"Setting $ComputerAccount as CM administrative user." | Out-File -Append $logpath
New-CMAdministrativeUser -Name $ComputerAccount  -RoleName "Full Administrator" -SecurityScopeName "All","All Systems","All Users and User Groups"
"Done" | Out-File -Append $logpath

$upgradingfailed = $false
$originalbuildnumber = ""

#Wait for SMS_DMP_DOWNLOADER running
$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$subKey =  $key.OpenSubKey("SOFTWARE\Microsoft\SMS\Components\SMS_Executive\Threads\SMS_DMP_DOWNLOADER")
$DMPState = $subKey.GetValue("Current State")
while($DMPState -ne "Running")
{
    "Current SMS_DMP_DOWNLOADER state is : $DMPState , will try again 30 seconds later..." | Out-File -Append $logpath
    Start-Sleep -Seconds 30
    $DMPState = $subKey.GetValue("Current State")
}

"Current SMS_DMP_DOWNLOADER state is : $DMPState " | Out-File -Append $logpath

"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Trying to enable CAS EnableSCCMManagedCert." | Out-File -Append $logpath

#Configure CAS EnableSCCMManagedCert
$WmiObjectNameSpace = "root\SMS\site_$($SiteCode)"
#Get component
$wmiObject = Get-WmiObject -Namespace $WmiObjectNameSpace -class SMS_SCI_Component -Filter "ComponentName='SMS_SITE_COMPONENT_MANAGER'"| where-object {$_.SiteCode -eq $SiteCode}

#Get embeded property
$props = $wmiObject.Props
$index = 0
foreach($oProp in $props)
{
    if($oProp.PropertyName -eq 'IISSSLState')
    {
        $v = $oProp.Value
        "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] IISSSLState previous value is $v." | Out-File -Append $logpath
        $oProp.Value = '1216'
        $props[$index] = $oProp
    }
    $index++
}

$WmiObject.Props = $props
$wmiObject.Put()

"[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Set the IISSSLState 1216, you could check it manually" | Out-File -Append $logpath

#get the available update
function getupdate()
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Get CM update..." | Out-File -Append $logpath
    $CMPSSuppressFastNotUsedCheck = $true
    $updatepacklist= Get-CMSiteUpdate -Fast | ?{$_.State -ne 196612}
    $getupdateretrycount = 0
    while($updatepacklist.Count -eq 0)
    {
        if($getupdateretrycount -eq 3)
        {
            break
        }
        "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Not found any updates, retry to invoke update check." | Out-File -Append $logpath
        $getupdateretrycount++
        "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Invoke CM Site update check..." | Out-File -Append $logpath
        Invoke-CMSiteUpdateCheck -ErrorAction Ignore
        Start-Sleep 120

        $updatepacklist= Get-CMSiteUpdate | ?{$_.State -ne 196612}
    }

    $updatepack=""

    if($updatepacklist.Count -eq 0)
    {
    }
    elseif($updatepacklist.Count -eq 1)
    {
        $updatepack= $updatepacklist
    }
    else
    {
        $updatepack= ($updatepacklist | sort -Property fullversion)[-1] 
    }
    return $updatepack
}

#----------------------------------------------------
$state=@{
    0 = 'UNKNOWN'
    2 = 'ENABLED'
    #DMP DOWNLOAD
    262145 = 'DOWNLOAD_IN_PROGRESS'
    262146 = 'DOWNLOAD_SUCCESS'
    327679 = 'DOWNLOAD_FAILED'
    #APPLICABILITY
    327681 = 'APPLICABILITY_CHECKING'
    327682 = 'APPLICABILITY_SUCCESS'
    393213 ='APPLICABILITY_HIDE'
    393214 = 'APPLICABILITY_NA'
    393215 = 'APPLICABILITY_FAILED'
    #CONTENT
    65537 = 'CONTENT_REPLICATING'
    65538 = 'CONTENT_REPLICATION_SUCCESS'
    131071 = 'CONTENT_REPLICATION_FAILED'
    #PREREQ
    131073 = 'PREREQ_IN_PROGRESS'
    131074 = 'PREREQ_SUCCESS'
    131075 = 'PREREQ_WARNING'
    196607 = 'PREREQ_ERROR'
    #Apply changes
    196609 = 'INSTALL_IN_PROGRESS'
    196610 = 'INSTALL_WAITING_SERVICE_WINDOW'
    196611 = 'INSTALL_WAITING_PARENT'
    196612 = 'INSTALL_SUCCESS'
    196613 = 'INSTALL_PENDING_REBOOT'
    262143 = 'INSTALL_FAILED'
    #CMU SERVICE UPDATEI
    196614 = 'INSTALL_CMU_VALIDATING'
    196615 = 'INSTALL_CMU_STOPPED'
    196616 = 'INSTALL_CMU_INSTALLFILES'
    196617 = 'INSTALL_CMU_STARTED'
    196618 = 'INSTALL_CMU_SUCCESS'
    196619 = 'INSTALL_WAITING_CMU'
    262142 = 'INSTALL_CMU_FAILED'
    #DETAILED INSTALL STATUS
    196620 = 'INSTALL_INSTALLFILES'
    196621 = 'INSTALL_UPGRADESITECTRLIMAGE'
    196622 = 'INSTALL_CONFIGURESERVICEBROKER'
    196623 = 'INSTALL_INSTALLSYSTEM'
    196624 = 'INSTALL_CONSOLE'
    196625 = 'INSTALL_INSTALLBASESERVICES'
    196626 = 'INSTALL_UPDATE_SITES'
    196627 = 'INSTALL_SSB_ACTIVATION_ON'
    196628 = 'INSTALL_UPGRADEDATABASE'
    196629 = 'INSTALL_UPDATEADMINCONSOLE'
}
#----------------------------------------------------
$starttime= Get-Date
$sites= Get-CMSite
if($originalbuildnumber -eq "")
{
    if($sites.count -eq 1)
    {
        $originalbuildnumber = $sites.BuildNumber
    }
    else
    {
        $originalbuildnumber = $sites[0].BuildNumber
    }
}

#----------------------------------------------------
$retrytimes = 0
$updatepack = getupdate
if($updatepack -ne "")
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Update package is " + $updatepack.Name | Out-File -Append $logpath
}
else
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] No update package be found." | Out-File -Append $logpath
}
while($updatepack -ne "")
{
    if($retrytimes -eq 3)
    {
        $upgradingfailed = $true
        break
    }
    $updatepack = Get-CMSiteUpdate -Fast -Name $updatepack.Name 
    while($updatepack.State -eq 327682 -or $updatepack.State -eq 262145 -or $updatepack.State -eq 327679)
    {
        #package not downloaded
        if($updatepack.State -eq 327682)
        {
            Invoke-CMSiteUpdateDownload -Name $updatepack.Name -Force -WarningAction SilentlyContinue
            Start-Sleep 120
            $updatepack = Get-CMSiteUpdate -Name $updatepack.Name -Fast
            $downloadstarttime = get-date
            while($updatepack.State -eq 327682)
            {
                "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Waiting SCCM Upgrade package start to download, sleep 2 min..." | Out-File -Append $logpath
                Start-Sleep 120
                $updatepack = Get-CMSiteUpdate -Name $updatepack.Name -Fast
                $downloadspan = New-TimeSpan -Start $downloadstarttime -End (Get-Date)
                if($downloadspan.Hours -ge 1)
                {
                    Restart-Service -DisplayName "SMS_Executive"
                    Start-Sleep 120
                    $downloadstarttime = get-date
                }
            }
        }
        #waiting package downloaded
        $downloadstarttime = get-date
        while($updatepack.State -eq 262145)
        {
            "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Waiting SCCM Upgrade package download, sleep 2 min..." | Out-File -Append $logpath
            Start-Sleep 120
            $updatepack = Get-CMSiteUpdate -Name $updatepack.Name -Fast
            $downloadspan = New-TimeSpan -Start $downloadstarttime -End (Get-Date)
            if($downloadspan.Hours -ge 1)
            {
                Restart-Service -DisplayName "SMS_Executive"
                Start-Sleep 120
                $downloadstarttime = get-date
            }
        }

        #downloading failed
        if($updatepack.State -eq 327679)
        {
            $retrytimes++
            Start-Sleep 300
            continue
        }
    }
    #trigger prerequisites check after the package downloaded
    Invoke-CMSiteUpdatePrerequisiteCheck -Name $updatepack.Name
    while($updatepack.State -ne 196607 -and $updatepack.State -ne 131074 -and $updatepack.State -ne 131075)
    {
        ("[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Waiting checking prerequisites complete, current pack " + $updatepack.Name + " state is " + ($state.($updatepack.State)) + ", sleep 2 min...") | Out-File -Append $logpath
        Start-Sleep 120
        $updatepack = Get-CMSiteUpdate -Fast -Name $updatepack.Name 
    }
    if($updatepack.State -eq 196607)
    {
        $retrytimes++
        Start-Sleep 300
        continue
    }
    #trigger setup after the prerequisites check
    Install-CMSiteUpdate -Name $updatepack.Name -SkipPrerequisiteCheck -Force
    while($updatepack.State -ne 196607 -and $updatepack.State -ne 262143 -and $updatepack.State -ne 196612)
    {
        ("[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Waiting SCCM Upgrade Complete, current pack " + $updatepack.Name + " state is " + ($state.($updatepack.State)) + ", sleep 2 min...") | Out-File -Append $logpath
        Start-Sleep 120
        $updatepack = Get-CMSiteUpdate -Fast -Name $updatepack.Name 
    }
    if($updatepack.State -eq 196612)
    {
        ("[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] SCCM Upgrade Complete, current pack " + $updatepack.Name + " state is " + ($state.($updatepack.State)) ) | Out-File -Append $logpath
        #we need waiting the copying files finished if there is only one site
        $toplevelsite =  Get-CMSite |where {$_.ReportingSiteCode -eq ""}
        if((Get-CMSite).count -eq 1)
        {
            $path= Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\SMS\Setup' -Name 'Installation Directory'

            $fileversion=(Get-Item ($path+'\cd.latest\SMSSETUP\BIN\X64\setup.exe')).VersionInfo.FileVersion.split('.')[2]
            while($fileversion -ne $toplevelsite.BuildNumber)
            {
                Start-Sleep 120
                $fileversion=(Get-Item ($path+'\cd.latest\SMSSETUP\BIN\X64\setup.exe')).VersionInfo.FileVersion.split('.')[2]
            }
            #Wait for copying files finished
            Start-Sleep 600
        }
        #Get if there are any other updates need to be installed
        $updatepack = getupdate 
    }
    if($updatepack.State -eq 196607 -or $updatepack.State -eq 262143 )
    {
        if($retrytimes -le 3)
        {
            $upgradingfailed = $true
            Start-Sleep 300
            continue
        }
        $retrytimes = $retrytimes + 1
    }
}

if($upgradingfailed -eq $true)
{
    ("[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Upgrade " + $updatepack.Name + " failed") | Out-File -Append $logpath
    throw
}

#Set permission
$Acl = Get-Acl $SMSInstallDir
$NewAccessRule = New-Object system.security.accesscontrol.filesystemaccessrule($PSComputerAccount,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
$Acl.SetAccessRule($NewAccessRule)
Set-Acl $SMSInstallDir $Acl

$Configuration.UpgradeSCCM.Status = 'Completed'
$Configuration.UpgradeSCCM.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

Copy-Item $ConfigurationFile -Destination "c:\$LogFolder" -Force

#Waiting for PS ready to use
$Configuration.PSReadyToUse.Status = 'Running'
$Configuration.PSReadyToUse.StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

$PSSystemServer = Get-CMSiteSystemServer -SiteCode $PSRole
while(!$PSSystemServer)
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Wait for PS finished installing, will try 60 seconds later..." | Out-File -Append $logpath
    Start-Sleep -Seconds 60
    $PSSystemServer = Get-CMSiteSystemServer -SiteCode $PSRole
}

#Wait for replication ready
$replicationStatus = Get-CMDatabaseReplicationStatus

while($replicationStatus.LinkStatus -ne 2 -or $replicationStatus.Site1ToSite2GlobalState -ne 2 -or $replicationStatus.Site2ToSite1GlobalState -ne 2 -or $replicationStatus.Site2ToSite1SiteState -ne 2 )
{
    "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] Wait for PS ready for use, will try 60 seconds later..." | Out-File -Append $logpath
    Start-Sleep -Seconds 60
    $replicationStatus = Get-CMDatabaseReplicationStatus
}

$Configuration.PSReadyToUse.Status = 'Completed'
$Configuration.PSReadyToUse.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
$Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force

Copy-Item $ConfigurationFile -Destination "c:\$LogFolder" -Force

