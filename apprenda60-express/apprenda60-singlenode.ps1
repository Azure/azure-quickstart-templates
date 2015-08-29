#First, let's satisfy all of the requirements for the platform node.

param(
    $platformAdminFirstName = @(throw "platformAdminFirstNameIsRequired"),
    $platformAdminLastName = @(throw "platformAdminLastNameIsRequired"),
    $platformAdminEmailAddress = @(throw "platformAdminEmailAddressIsRequired"),
    $platformAdminPassword = "@ppm5205"
)

# start transcript for the install
Start-Transcript -Path .\InstallOutput.txt

# sourced from GetCurrentDirectory.ps1
$directoryPath = Get-Locationd
Set-Variable -name currentpath -Value $directoryPath.path

# use the same webclient for all downloads
$webclient = New-Object System.Net.WebClient

# set hostname for later use
$hostname = $env:COMPUTERNAME

try
{
#download required files
$remoteApprendaLocalXml = "http://apprendaconfigfiles.blob.core.windows.net/configurationfiles/apprenda.local.xml"
$remoteSqlUnattendInstallFile = "http://apprendaconfigfiles.blob.core.windows.net/configurationfiles/SQL2012ExpressUnAttendedInstallConfigurationFile.ini"
$apprendaLocalXml = "$currentpath\apprenda.local.xml"
$sqlUnattendInstallFile = "$currentpath\SQL2012ExpressUnAttendedInstallConfigurationFile.ini"
$webclient.DownloadFile($remoteApprendaLocalXml, $apprendaLocalXml)
$webclient.DownloadFile($remoteSqlUnattendInstallFile, $sqlUnattendInstallFile)


# prepare installation
[xml] $installConfig = Get-Content $apprendaLocalXml 
$computername = Get-ChildItem Env:Computername
$installConfig.ApprendaGridDefinitions.ApprendaGrid.repositoryHost = $computername.Value
$installConfig.ApprendaGridDefinitions.ApprendaGrid.Clouds.cloud.Servers.Server.hostname = $computername.Value
$installConfig.ApprendaGridDefinitions.ApprendaGrid.Clouds.cloud.DatabaseServerInstances.DatabaseServerInstance.name = $computername.value
$installConfig.ApprendaGridDefinitions.ApprendaGrid.Clouds.cloud.DatabaseServerInstances.DatabaseServerInstance.fqdn = $computername.value
$installConfig.ApprendaGridDefinitions.ApprendaGrid.WindowsServiceConfig.AdminUserAccount.UserAccount.domain = $computername.value
$installConfig.ApprendaGridDefinitions.ApprendaGrid.WindowsServiceConfig.SystemUserAccount.UserAccount.domain = $computername.value
$installConfig.ApprendaGridDefinitions.ApprendaGrid.CompanyInfo.adminFirstName = [string] $platformAdminFirstName
$installConfig.ApprendaGridDefinitions.ApprendaGrid.CompanyInfo.adminLastName = [string] $platformAdminLastName
$installConfig.ApprendaGridDefinitions.ApprendaGrid.CompanyInfo.adminEmail = [string] $platformAdminEmailAddress
$installConfig.ApprendaGridDefinitions.ApprendaGrid.CompanyInfo.adminPassword = [string] $platformAdminPassword
$installConfig.Save($apprendaLocalXml)

# Download Files
# -----------------------------------------------------------------
$directoryPath = Get-Location
Set-Variable -name currentpath -Value $directoryPath.path

# Download Apprenda 6.0

$url = "http://docs.apprenda.com/sites/default/files/apprenda-6.0.0.zip"
$apprendazip = "$currentpath\apprenda-6.0.0.zip"
$webclient.DownloadFile($url, $apprendazip)
$installDir = "$currentpath\apprendainstall"
mkdir $installDir

# Download 7zip
$7zipurl = "http://www.7-zip.org/a/7z938-x64.msi"
$7ziplocalfile = "$currentpath\7z938-x64.msi"
$webclient.DownloadFile($7zipurl, $7ziplocalfile)
Start-Process $7ziplocalfile /qn -Wait
$7zipexe = "C:\Program Files\7-Zip\7z.exe"
#unzip apprenda
& $7zipexe x -o"C:\Install" $apprendazip

# Download SqlServer2012 R2 Express and C++ redist
$webclient.DownloadFile("http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLEXPR_x64_ENU.exe", $currentpath + "\SQLEXPR_x64_ENU.exe")
$webclient.DownloadFile("http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe", $currentpath + "\vcredist_x64.exe")

# download and install iisnode
$webclient = New-Object System.Net.WebClient
$url = "https://github.com/azure/iisnode/releases/download/v0.2.16/iisnode-full-v0.2.16-x64.msi"
$iisnodemsi = "$currentpath\iisnode-full-v0.2.16-x64.msi"
$webclient.DownloadFile($url, $iisnodemsi)
Start-Process $iisnodemsi /qn -Wait

# Install WebPI
$webpifile = “C:\WebPlatformInstaller_amd64_en-US.msi”
$webplatformdownload = “http://download.microsoft.com/download/7/0/4/704CEB4C-9F42-4962-A2B0-5C84B0682C7A/WebPlatformInstaller_amd64_en-US.msi"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($webplatformdownload, $webpifile)
Start-Process $webpifile /qn -Wait

# now use it to install ARRv3_0 and its dependencies
& 'C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd.exe' /Install /Products:ARRv3_0 /accepteula /suppressreboot

# Next, install Windows Features. First, Web Server configuration
install-windowsfeature web-webserver -IncludeManagementTools
install-WindowsFeature web-dyn-compression -IncludeManagementTools
install-WindowsFeature Web-Basic-Auth -IncludeManagementTools
install-WindowsFeature Web-Windows-Auth -IncludeManagementTools
install-WindowsFeature Web-App-Dev -IncludeManagementTools
install-WindowsFeature Web-Net-Ext45 -IncludeManagementTools
install-WindowsFeature Web-AppInit -IncludeManagementTools
install-WindowsFeature Web-ASP -IncludeManagementTools
install-WindowsFeature Web-Asp-Net -IncludeManagementTools
install-WindowsFeature Web-Asp-Net45 -IncludeManagementTools
install-WindowsFeature Web-Includes -IncludeManagementTools
install-WindowsFeature Web-WebSockets -IncludeManagementTools
install-WindowsFeature Web-Scripting-Tools -IncludeManagementTools
install-WindowsFeature NET-WCF-HTTP-Activation45 -IncludeManagementTools

# Now, Application Server configuration
install-WindowsFeature Application-Server -IncludeManagementTools
install-WindowsFeature AS-Dist-Transaction -IncludeManagementTools
install-WindowsFeature AS-Incoming-Trans -IncludeManagementTools
install-WindowsFeature AS-Outgoing-Trans -IncludeManagementTools
install-WindowsFeature AS-TCP-Port-Sharing -IncludeManagementTools
install-WindowsFeature AS-Web-Support -IncludeManagementTools
install-WindowsFeature AS-TCP-Port-Sharing -IncludeManagementTools
install-WindowsFeature AS-HTTP-Activation  -IncludeManagementTools

# Disable windows firewall for good measure. We'll turn back on afterwards.
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

## INSTALL TIME!

# Install SQLServer2012 Express
Start-Process -Wait .\SQLEXPR_x64_ENU.exe /ConfigurationFile=$sqlUnattendInstallFile

# Configure hosts file
$hostsFilePath = "$env:windir\System32\drivers\etc\hosts"
[System.Net.Dns]::GetHostAddresses($hostname) | foreach { "`n" + $_.IPAddressToString + "`tapps.apprenda.$hostname" | Out-File $hostsFilePath -encoding ASCII -append}

& C:\Install\Installer\Apprenda.Wizard.exe Install -autorepair -inputFile $apprendaLocalXml
start http://apps.apprenda.$env:COMPUTERNAME/SOC
start http://apps.apprenda.$env:COMPUTERNAME/Developer

$WshShell = New-Object -comObject WScript.Shell

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\ApprendaOperatorPortal.lnk")
$Shortcut.TargetPath = "http://apps.apprenda.$env:COMPUTERNAME/SOC"
$Shortcut.Save()

$Shortcut2 = $WshShell.CreateShortcut("$Home\Desktop\ApprendaDeveloperPortal.lnk")
$Shortcut2.TargetPath = "http://apps.apprenda.$env:COMPUTERNAME/Developer"
$Shortcut2.Save()
}
catch [Exception]
{
    throw
}
finally
{
    Stop-Transcript
}