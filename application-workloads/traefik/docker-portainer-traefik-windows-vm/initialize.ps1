param (
    $mail,
    $publicdnsname,
    $adminPwd,
    $publicSshKey
)

$ProgressPreference = 'SilentlyContinue'  
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V, Containers -All -NoRestart
. .\InstallOrUpdateDockerEngine.ps1 -Force -envScope "Machine"

$setupScript = Join-Path (Get-Location) "setup.ps1"

$startupAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy UnRestricted -File $setupScript -mail $mail -publicdnsname $publicdnsname -adminPwd $adminPwd -basepath $(Get-Location) -publicSshKey `"$publicSshKey`""
$startupTrigger = New-ScheduledTaskTrigger -AtStartup
$startupTrigger.Delay = "PT1M"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
Register-ScheduledTask -TaskName "SetupStart" `
                       -Action $startupAction `
                       -Trigger $startupTrigger `
                       -Settings $settings `
                       -RunLevel "Highest" `
                       -User "NT AUTHORITY\SYSTEM" | Out-Null

Restart-Computer -Force
