param([Parameter(Mandatory=$true)][string]$chocoPackages)

cls
# Grab the choco installation script
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Get username/password & machine name
$userName = "artifactInstaller"
[Reflection.Assembly]::LoadWithPartialName("System.Web") 
$password = $([System.Web.Security.Membership]::GeneratePassword(12,4))
$cn = [ADSI]"WinNT://$env:ComputerName"

# Create new user
$user = $cn.Create("User", $userName)
$user.SetPassword($password)
$user.SetInfo()
$user.description = "Choco artifact installer"
$user.SetInfo()

# Add user to the Administrators group
$group = [ADSI]"WinNT://$env:ComputerName/Administrators,group"
$group.add("WinNT://$env:ComputerName/$userName")

$secPassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("$env:COMPUTERNAME\$($username)", $secPassword)

# Create installation command for the passed in packages
$command = "cinst " + $chocoPackages + " -y -force"
$sb = [scriptblock]::Create("$command")

# Run Chocolatey as the artifactInstaller user
Enable-PSRemoting -Force -SkipNetworkProfileCheck

# Ensure that current process can run scripts. 
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force 

Invoke-Command -ScriptBlock $sb -ComputerName $env:COMPUTERNAME -Credential $credential
Disable-PSRemoting -Force

# Delete the artifactInstaller user
$cn.Delete("User", $userName)

# Delete the artifactInstaller user profile
gwmi win32_userprofile | where { $_.LocalPath -like "*$userName*" } | foreach { $_.Delete() }
