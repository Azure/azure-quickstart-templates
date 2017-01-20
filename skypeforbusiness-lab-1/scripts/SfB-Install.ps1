#
# SfB_install.ps1
#
<# Custom Script for Windows #>
Param (		
		[Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [string]$Username,

	    [Parameter(Mandatory)]
        [string]$Password,

		[Parameter(Mandatory)]
        [string]$Share,

		[Parameter(Mandatory)]
        [string]$sasToken

       )

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
[PSCredential ]$DomainCreds = New-Object PSCredential ("$DomainName\$Username", $SecurePassword)
$scriptDir = (Get-Location).path
$User=$Share
$Share="\\"+$Share+".file.core.windows.net\skype"

# Enabling remote powershell + CredSSP as the Skype AD commands need a Cred SSP session to process
Enable-PSRemoting
Enable-WSManCredSSP -Role client -DelegateComputer * -force
Enable-WSManCredSSP -Role server -force

#Somtimes PSRemoting needs some time before first connection. in the meanwhile we will install lync prrequisite with default NTSystem account
#region Lync Prerequisite

Write-Verbose "Installing SfB pre-requisites @ $(Get-Date)"
#connect to file share on storage account
net use G: $Share /u:$User $sasToken

start-sleep -Seconds 10
#install Visual C++
Start-Process -FilePath cmd -ArgumentList /c, "G:\SfBServer2015\Setup\amd64\vcredist_x64.exe", /q -Wait
#install Lync core
Start-Process -FilePath msiexec -ArgumentList /i, "G:\SfBServer2015\Setup\amd64\setup\ocscore.msi", /passive -Wait
#install SQL express
Start-Process -FilePath msiexec -ArgumentList /i, "G:\SfBServer2015\Setup\amd64\SQLSysClrTypes.msi", /quiet -Wait
#install SMO
Start-Process -FilePath msiexec -ArgumentList /i, "G:\SfBServer2015\Setup\amd64\SharedManagementObjects.msi", /quiet -Wait
#install Lync admin tools
Start-Process -FilePath msiexec -ArgumentList /i, "G:\SfBServer2015\Setup\amd64\setup\admintools.msi", /passive -Wait
#install SilverLight
Start-Process -FilePath cmd -ArgumentList /c, "G:\Silverlight_x64.exe", /q -Wait

#install KB updates needed for SfB
Start-Process -FilePath wusa -ArgumentList "G:\Windows8.1-KB2919442-x64.msu", /quiet -Wait -verbose
Start-Process -FilePath wusa -ArgumentList "G:\Windows8.1-KB2919355-x64.msu", /quiet -Wait -verbose
Start-Process -FilePath wusa -ArgumentList "G:\Windows8.1-KB2982006-x64.msu", /quiet, /norestart -Wait -verbose


net use G: /d
#endregion Lync Prerequisite


Invoke-Command  -Credential $DomainCreds -Authentication CredSSP -ComputerName $env:COMPUTERNAME -ScriptBlock {
 
param (
        $workingDir,
        $_Share,
        $_User,
        $_sasToken
    )
    # Working variables

#connect to file share on storage account
net use G: $_Share /u:$_User $_sasToken


## Module Imports ##

Import-Module "C:\Program Files\Common Files\Skype for Business Server 2015\Modules\SkypeForBusiness\SkypeForBusiness.psd1"
Import-Module ActiveDirectory


## Variables ##

$Domain = Get-ADDomain
$DomainDNSName = $Domain.DNSRoot
$Computer = $env:computername + '.'+$Domain.DNSRoot
$DC = Get-ADDomainController
$Sbase = "CN=Configuration,"+$Domain.DistinguishedName
$fileshareName = "LyncShare"
$filesharepath = "F:\"+$fileshareName
$Databasespaths= "F:\SQLLogs","F:\SQLData"
$Logfilespath = "G:\Logs\"
$NewTopologypath="F:\"+$domain.DNSRoot+"Topology.xml"

## Prepare the AD Forest
Install-CSAdServerSchema -Confirm:$false -Verbose -Report $Logfilespath"Install-CSAdServerSchema.html"
Enable-CSAdForest  -Verbose -Confirm:$false -Report $Logfilespath"Enable-CSAdForest.html"
Enable-CSAdDomain -Verbose -Confirm:$false -Report $Logfilespath"Enable-CSAdDomain.html"
Add-ADGroupMember -Identity CSAdministrator -Members "Domain Admins"
Add-ADGroupMember -Identity RTCUniversalServerAdmins -Members "Domain Admins"

## Install SQL RTC database with updateEnabled=0 because internet access is denied trough the script extention
#Start-Process  -FilePath G:\SfBServer2015\Setup\amd64\SQLEXPR_x64.exe  -ArgumentList '/UpdateEnabled=0 /Q /IACCEPTSQLSERVERLICENSETERMS /HIDECONSOLE /ACTION=Install /FEATURES=SQLEngine,Tools /INSTANCENAME=RTC /TCPENABLED=1 /SQLSVCACCOUNT="NT AUTHORITY\NetworkService" /SQLSYSADMINACCOUNTS="Builtin\Administrators" /BROWSERSVCSTARTUPTYPE="Automatic" /AGTSVCACCOUNT="NT AUTHORITY\NetworkService" /SQLSVCSTARTUPTYPE=Automatic' -Wait -NoNewWindow
# here the boot strap do the same thing but with updateenabled and it do not hace network access
& 'C:\Program Files\Skype for Business Server 2015\Deployment\bootstrapper.exe' /BootstrapSqlExpress /SourceDirectory:"G:\SfBServer2015\Setup\amd64"

## Install Central Management Store databases within RTC

Install-CsDatabase -CentralManagementDatabase -SqlServerFqdn $Computer -SqlInstanceName rtc -DatabasePaths $Databasespaths -Report $Logfilespath'InstallCMSDatabases.html'
#Set-CsConfigurationStoreLocation -SqlServerFqdn $Computer -SqlInstanceName rtc -Report $Logfilespath'Set-CsConfigurationStoreLocation.html' 
Start-Process  -FilePath powershell.exe -ArgumentList "Set-CsConfigurationStoreLocation -force -SqlServerFqdn $Computer -SqlInstanceName rtc -Report $Logfilespath'Set-CsConfigurationStoreLocation.html'"
start-sleep -Seconds 10

## Create File Share used to share the CMS
New-Item $filesharepath -type directory
New-SmbShare -Name $fileshareName $filesharepath
Get-smbshare -name $fileshareName | Grant-SmbShareAccess -AccessRight Full -AccountName Everyone -Force

## Build and Publish Lync Topology
$defaultTopology= $workingDir+"\DefaultTopology_Skype.xml"
$xml = New-Object XML
$xml.Load($defaultTopology)
$xml.Topology.InternalDomains.DefaultDomain = $domain.DNSRoot
$xml.Topology.InternalDomains.InternalDomain.name = $domain.DNSRoot
$xml.Topology.Clusters.cluster.fqdn = $Computer
$xml.Topology.Clusters.cluster.machine.Fqdn = $Computer
$xml.Topology.Clusters.cluster.machine.FaultDomain = $Computer
$xml.Topology.Clusters.cluster.machine.UpgradeDomain = $Computer
$xml.Topology.Services.Service.Webservice.externalsettings.host = $Computer
$xml.Topology.Services.Service[3].FileStoreService.ShareName = $fileshareName
$xml.Save($NewTopologypath)

Publish-CSTopology -Filename $NewTopologypath -Force -Report $Logfilespath'Publish-CSTopology.html'
Enable-CSTopology -Report $Logfilespath'Enable-CsTopology.html'

## Install SQL RTCLOCAL and LYNCLOCAL databases with non default parameters : updateEnabled=0
Write-Verbose "Installing local configuration store @ $(Get-Date)"
#Start-Process  -FilePath G:\SfBServer2015\Setup\amd64\SQLEXPR_x64.exe  -ArgumentList '/UpdateEnabled=0 /QUIET /IACCEPTSQLSERVERLICENSETERMS /HIDECONSOLE /ACTION=Install /FEATURES=SQLEngine,Tools /INSTANCENAME=RTCLOCAL /TCPENABLED=1 /SQLSVCACCOUNT="NT AUTHORITY\NetworkService" /SQLSYSADMINACCOUNTS="Builtin\Administrators" /BROWSERSVCSTARTUPTYPE="Automatic" /AGTSVCACCOUNT="NT AUTHORITY\NetworkService" /SQLSVCSTARTUPTYPE=Automatic' -Wait -NoNewWindow
#Start-Process  -FilePath G:\SfBServer2015\Setup\amd64\SQLEXPR_x64.exe  -ArgumentList '/UpdateEnabled=0 /QUIET /IACCEPTSQLSERVERLICENSETERMS /HIDECONSOLE /ACTION=Install /FEATURES=SQLEngine,Tools /INSTANCENAME=LYNCLOCAL /TCPENABLED=1 /SQLSVCACCOUNT="NT AUTHORITY\NetworkService" /SQLSYSADMINACCOUNTS="Builtin\Administrators" /BROWSERSVCSTARTUPTYPE="Automatic" /AGTSVCACCOUNT="NT AUTHORITY\NetworkService" /SQLSVCSTARTUPTYPE=Automatic' -Wait -NoNewWindow

##do the same thing for RTCLOCAL
& 'C:\Program Files\Skype for Business Server 2015\Deployment\bootstrapper.exe' /Bootstraplocalmgmt /SourceDirectory:"G:\SfBServer2015\Setup\amd64"

## Install Local configuration Store (replica of CMS) within RTCLOCAL
Install-CSDatabase -ConfiguredDatabases -SqlServerFqdn $Computer -DatabasePaths $Databasespaths -Report $Logfilespath'InstallLocalstoreDatabases.html'

## Filling the local configuration store RTClocal and enabling Replica
$CSConfigExp = Export-csconfiguration -asbytes
Import-CsConfiguration -Byteinput $CSConfigExp -Localstore
Enable-CsReplica -Report $Logfilespath'Enable-CsReplica.html'
Start-CSwindowsService Replica -Report $Logfilespath'Start-CSwindowsService-Replica.html'

## Install Lync Component (LYNCLOCAL is normally done here) 
& 'C:\Program Files\Skype for Business Server 2015\Deployment\Bootstrapper.exe' /SourceDirectory:"G:\SfBServer2015\Setup\amd64"

## DNS Records ##

$lyncIP = Get-NetAdapter | Get-NetIPAddress -AddressFamily IPv4
Add-DnsServerResourceRecordA -IPv4Address $lyncIP.IPv4Address -Name sip -ZoneName $DomainDNSName -ComputerName $DC.HostName
Add-DnsServerResourceRecordA -IPv4Address $lyncIP.IPv4Address -Name meet -ZoneName $DomainDNSName -ComputerName $DC.HostName
Add-DnsServerResourceRecordA -IPv4Address $lyncIP.IPv4Address -Name admin -ZoneName $DomainDNSName -ComputerName $DC.HostName
Add-DnsServerResourceRecordA -IPv4Address $lyncIP.IPv4Address -Name dialin -ZoneName $DomainDNSName -ComputerName $DC.HostName

$urlEntry1 = New-CsSimpleUrlEntry -Url "https://dialin.$DomainDNSName"
$simpleUrl1 = New-CsSimpleUrl -Component "dialin" -Domain "*" -SimpleUrlEntry $urlEntry1 -ActiveUrl "https://dialin.$DomainDNSName"
$urlEntry2 = New-CsSimpleUrlEntry -Url "https://meet.$DomainDNSName"
$simpleUrl2 = New-CsSimpleUrl -Component "meet" -Domain "$DomainDNSName" -SimpleUrlEntry $urlEntry2 -ActiveUrl "https://meet.$DomainDNSName"
$urlEntry3 = New-CsSimpleUrlEntry -Url "https://admin.$DomainDNSName"
$simpleUrl3 = New-CsSimpleUrl -Component "Cscp" -Domain "*" -SimpleUrlEntry $urlEntry3 -ActiveUrl "https://admin.$DomainDNSName"

Remove-CsSimpleUrlConfiguration -Identity "Global"     
set-CsSimpleUrlConfiguration -Identity "Global" -SimpleUrl @{Add=$simpleUrl1,$simpleUrl2,$simpleUrl3}
Enable-CsComputer -Report $Logfilespath'Enable-CsComputer.html'


## Request and Install Certificates ##

$CA = Get-Adobject -LDAPFilter "(&(objectClass=pKIEnrollmentService)(cn=*))" -SearchBase $Sbase
$CAName = $DC.Hostname + "\" + $CA.Name
$certServer = Request-CsCertificate -New -Type Default,WebServicesInternal,WebServicesExternal -ComputerFqdn $Computer -CA $CAName  -FriendlyName "Standard Edition Certficate" -PrivateKeyExportable $True -DomainName "sip.$DomainDNSName" -allsipdomain -Report $Logfilespath'Request-CsCertificate-Webserver.html'
$certOAuth = Request-CsCertificate -New -Type OAuthTokenIssuer -ComputerFqdn $Computer -CA $CAName -FriendlyName "OathCert" -PrivateKeyExportable $True -DomainName $Computer -Report $Logfilespath'Request-CsCertificate-Oauth.html'
Set-CsCertificate -Reference $certServer -Type Default,WebservicesInternal,WebServicesExternal -Report $Logfilespath'Set-CsCertificate-Webserver.html'
Set-CsCertificate -Reference $certOAuth -Type OAuthTokenIssuer -Report $Logfilespath'Set-CsCertificate-OAuth.html'

## Start Skype services ##
Start-CSWindowsService -NoWait -Report $Logfilespath'Start-CSwindowsService.html'

#Pin shortcuts to tskbar
$sa = new-object -c shell.application
$pn = $sa.namespace("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools").parsename('Windows PowerShell ISE.lnk')
$pn.invokeverb('taskbarpin')
$pn = $sa.namespace("$env:CommonProgramFiles\Skype for Business Server 2015").parsename('AdminUIHost.exe')
$pn.invokeverb('taskbarpin')
$pn = $sa.namespace("$env:ProgramFiles\Skype for Business Server 2015\Administrative Tools").parsename('Microsoft.Rtc.Management.TopologyBuilder.exe')
$pn.invokeverb('taskbarpin')
$pn = $sa.namespace("c:\ProgramData\Microsoft\Windows\Start Menu\Programs\Skype for Business Server 2015").parsename('Skype for Business Server Management Shell.lnk')
$pn.invokeverb('taskbarpin')
$pn = $sa.namespace("$env:ProgramFiles\Skype for Business Server 2015\Deployment").parsename('Deploy.exe')
$pn.invokeverb('taskbarpin')

#in order to start skype control pannel withouth a security a prompt
Write-Verbose "Adding *.$DomainDNSName to local intranet zone @ $(Get-Date)"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$DomainDNSName"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$DomainDNSName" -Name * -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" -Name IEHarden -Value 0 -Type DWord

#Remove installation file Drive
net use G: /d

##Enable users
#cd $scriptDir
#Import-Csv .\New-ADUsers.csv | ForEach-Object {
#    Enable-CsUser -Identity $_.Name -SipAddressType SamAccountName  -SipDomain  $DomainDNSName -RegistrarPool $Computer
#    Set-CsUser -Identity $_.Name -EnterpriseVoiceEnabled $True
#}
#Enable users
cd $workingDir
.\Enable-CsUsers.ps1 -SipDomain $DomainDNSName

} -ArgumentList $PSScriptRoot, $Share, $User, $sasToken
Disable-PSRemoting
Disable-WSManCredSSP -role client
Disable-WSManCredSSP -role server

#The registery key modified earlier need a computer restart
Restart-Computer