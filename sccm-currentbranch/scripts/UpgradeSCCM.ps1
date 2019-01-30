Param($DomainFullName)

$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
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
"[$(Get-Date -format HH:mm:ss)] Setting PS Drive..." | Out-File -Append $logpath
New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams

while((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
{
    "[$(Get-Date -format HH:mm:ss)] Retry in 10s to set PS Drive. Please wait." | Out-File -Append $logpath
    Start-Sleep -Seconds 10
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$upgradingfailed = $false
$originalbuildnumber = ""

#get the available update
function getupdate()
{
    "[$(Get-Date -format HH:mm:ss)] Get CM update..." | Out-File -Append $logpath
    $CMPSSuppressFastNotUsedCheck = $true
    $updatepacklist= Get-CMSiteUpdate | ?{$_.State -ne 196612}
    $getupdateretrycount = 0
    while($updatepacklist.Count -eq 0)
    {
        if($getupdateretrycount -eq 3)
        {
            break
        }
        "[$(Get-Date -format HH:mm:ss)] Not found any updates, retry to invoke update check." | Out-File -Append $logpath
        $getupdateretrycount++
        "[$(Get-Date -format HH:mm:ss)] Invoke CM Site update check..." | Out-File -Append $logpath
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
    "[$(Get-Date -format HH:mm:ss)] Update package is " + $updatepack.Name | Out-File -Append $logpath
}
else
{
    "[$(Get-Date -format HH:mm:ss)] No update package be found." | Out-File -Append $logpath
}
while($updatepack -ne "")
{
    if($retrytimes -eq 3)
    {
        $upgradingfailed = $true
        break;
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
                "[$(Get-Date -format HH:mm:ss)] Waiting SCCM Upgrade package start to download, sleep 2 min..." | Out-File -Append $logpath
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
            "[$(Get-Date -format HH:mm:ss)] Waiting SCCM Upgrade package download, sleep 2 min..." | Out-File -Append $logpath
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
            $retrytimes++;
            Start-Sleep 300
            continue;
        }
    }
    #trigger prerequisites check after the package downloaded
    Invoke-CMSiteUpdatePrerequisiteCheck -Name $updatepack.Name
    while($updatepack.State -ne 196607 -and $updatepack.State -ne 131074 -and $updatepack.State -ne 131075)
    {
        ("[$(Get-Date -format HH:mm:ss)] Waiting checking prerequisites complete, current pack " + $updatepack.Name + " state is " + ($state.($updatepack.State)) + ", sleep 2 min...") | Out-File -Append $logpath
        Start-Sleep 120
        $updatepack = Get-CMSiteUpdate -Fast -Name $updatepack.Name 
    }
    if($updatepack.State -eq 196607)
    {
        $retrytimes++;
        Start-Sleep 300
        continue;
    }
    #trigger setup after the prerequisites check
    Install-CMSiteUpdate -Name $updatepack.Name -SkipPrerequisiteCheck -Force
    while($updatepack.State -ne 196607 -and $updatepack.State -ne 262143 -and $updatepack.State -ne 196612)
    {
        ("[$(Get-Date -format HH:mm:ss)] Waiting SCCM Upgrade Complete, current pack " + $updatepack.Name + " state is " + ($state.($updatepack.State)) + ", sleep 2 min...") | Out-File -Append $logpath
        Start-Sleep 120
        $updatepack = Get-CMSiteUpdate -Fast -Name $updatepack.Name 
    }
    if($updatepack.State -eq 196612)
    {
        ("[$(Get-Date -format HH:mm:ss)] SCCM Upgrade Complete, current pack " + $updatepack.Name + " state is " + ($state.($updatepack.State)) ) | Out-File -Append $logpath
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
            continue;
        }
        $retrytimes = $retrytimes + 1;
    }
}

if($upgradingfailed -eq $true)
{
    ("[$(Get-Date -format HH:mm:ss)] Upgrade " + $updatepack.Name + " failed") | Out-File -Append $logpath
    throw
}