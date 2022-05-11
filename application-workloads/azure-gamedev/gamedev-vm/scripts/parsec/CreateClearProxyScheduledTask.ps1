# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

function Setup {
#requests user approve potential cloud run time charges for using the tool
Write-Output "This creates a scheduled task that 
automatically disables Windows Proxies and re-enables
and installs the GPU driver if a user accidentally deletes
it. Both of these stop Parsec working. Runs on Startup.

If the user does uninstall the driver, the machine may 
reboot automatically.  No warranty given or implied."
$ReadHost = Read-Host "Install the scheduled task? (Y/N)"
    Switch ($ReadHost) 
       {
       Y {
       Write-output "Creating Task"
       CreateScheduledTask | Out-Null
       Write-output "Done"
       Pause
       Exit
       }
       N{
       Write-Output "The upgrade script will now exit"
       Pause
       Exit}
       }
}

Function CreateScheduledTask {

try {Get-ScheduledTask -TaskName "Recover GPU Driver and Remove Proxy" -ErrorAction Stop | Out-Null
Unregister-ScheduledTask -TaskName "Recover GPU Driver and Remove Proxy" -Confirm:$false
}
catch {}

$action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-file %programdata%\ParsecLoader\clear-proxy.ps1'

$trigger =  New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME 

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Recover GPU Driver and Remove Proxy" -Description "This task reinstalls or re-enables the GPU and clears any Windows Proxies" -RunLevel Highest
}

setup