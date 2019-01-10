$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
$logpath = $ProvisionToolPath+"\InstallADKLog.txt"

#ADK 1809 (17763)
$adkurl = "https://go.microsoft.com/fwlink/?linkid=2026036"
$adkpath = "c:\adksetup.exe"
Invoke-WebRequest -Uri $adkurl -OutFile $adkpath

$cmd = "c:\adksetup.exe"
$arg1  = "/Features"
$arg2 = "OptionId.DeploymentTools"
$arg3 = "OptionId.UserStateMigrationTool"
$arg4 = "/q"

try
{
	"[$(Get-Date -format HH:mm:ss)] Installing ADK..." | Out-File -Append $logpath
	& $cmd $arg1 $arg2 $arg3 $arg4 | out-null
	"[$(Get-Date -format HH:mm:ss)] ADK Installed Successfully!" | Out-File -Append $logpath
}
catch
{
	"[$(Get-Date -format HH:mm:ss)] Failed to install ADK with below error:" | Out-File -Append $logpath
	$ErrorMessage = $_.Exception.Message
	$ErrorMessage | Out-File -Append $logpath
}

#ADK add-on (17763)
$adkurl = "https://go.microsoft.com/fwlink/?linkid=2022233"
$adkpath = "c:\adkwinpesetup.exe"
Invoke-WebRequest -Uri $adkurl -OutFile $adkpath

$cmd = "c:\adkwinpesetup.exe"
$arg1  = "/Features"
$arg2 = "OptionId.WindowsPreinstallationEnvironment"
$arg3 = "/q"

try
{
	"[$(Get-Date -format HH:mm:ss)] Installing add-on for ADK..." | Out-File -Append $logpath
	& $cmd $arg1 $arg2 $arg3 | out-null
	"[$(Get-Date -format HH:mm:ss)] Add-on for ADK Installed Successfully!" | Out-File -Append $logpath
}
catch
{
	"[$(Get-Date -format HH:mm:ss)] Failed to install Add-on for ADK with below error:" | Out-File -Append $logpath
	$ErrorMessage = $_.Exception.Message
	$ErrorMessage | Out-File -Append $logpath
}