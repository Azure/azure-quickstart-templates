new-item c:\programy -itemtype directory
Install-WindowsFeature RSAT-ADDS-Tools,Telnet-Client,RSAT-DNS-Server,RSAT-AD-PowerShell,GPMC
$domain = "adarmtest.com"
$password = "Pa##w0rd" | ConvertTo-SecureString -asPlainText -Force
$username = "$domain\adAdministrator" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -Credential $credential
Start-BitsTransfer -Source "https://skrypty.blob.core.windows.net/skrypty/SQLEXPRADV_x64_ENU.exe" -Destination c:\programy\SQLEXPRADV_x64_ENU.exe  
New-ADUser -Name "adSQL" -AccountPassword (ConvertTo-SecureString Pa##w0rd -AsPlainText -Force) -DisplayName "adSQL" -Enabled $True -server 10.0.0.4 -Credential $credential
Install-WindowsFeature NET-Framework-Core
Enable-WSManCredSSP -Role Server -Force
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force
setspn -S WSMAN/ADSQL.adarmtest.com ADSQL
setspn -S WSMAN/ADSQL ADSQL
gpupdate /force
Invoke-Command -Computername AdSQL -Credential $credential -Authentication CredSSP -ScriptBlock { start-process -wait -Verb RunAs -ArgumentList '/Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=install /FEATURES=SQL,Tools /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="adarmtest\adSQL" /SQLSVCPASSWORD="Pa##w0rd" /SQLSYSADMINACCOUNTS="adarmtest\adAdministrator" /UpdateEnabled=0' C:\programy\SQLEXPRADV_x64_ENU.exe}