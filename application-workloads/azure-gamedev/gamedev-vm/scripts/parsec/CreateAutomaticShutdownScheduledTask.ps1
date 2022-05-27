# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

Write-Host "This sets your machine to shutdown if Windows detects it as idle for X minutes.
This is intended to save you money if you ever forget to shut your machine down.
You will get a warning message pop up 10 minutes before shutdown"

Do {[int]$read = read-host "How much time should the system idle for before shutting down? Time in Minutes - Minimum 20"}
while ($read -lt "20")
$read | Out-File $env:Programdata\ParsecLoader\Autoshutdown.txt
$readfile = Get-Content -Path $env:Programdata\ParsecLoader\Autoshutdown.txt
$time = $readfile - 10
$span = new-timespan -minutes $time

try {Get-ScheduledTask -TaskName "Automatically Shutdown on Idle" -ErrorAction Stop | Out-Null
Unregister-ScheduledTask -TaskName "Automatically Shutdown on Idle" -Confirm:$false
}
catch {}

$action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-executionpolicy bypass -windowstyle hidden -file %programdata%\ParsecLoader\automatic-shutdown.ps1'

$trigger =  New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME 

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Automatically Shutdown on Idle" -Description "This script runs at startup and monitors for idle" -RunLevel Highest

Write-Output "Successfully Created"

pause
