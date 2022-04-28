
$CountSinceStart = 0
Function CountSinceStart {$MinutesSinceStart = [int]3240 - $($(get-date) - $(Get-EventLog -LogName System -InstanceId 12 -Newest 1).TimeGenerated).TotalSeconds
If ($MinutesSinceStart -lt 0) {
$MinutesSinceStart = 0}
Else{}

Do {
$CountSinceStart++
Start-Sleep -s 1
}
Until 
(
$CountSinceStart -ge $MinutesSinceStart
)
Start-Process powershell.exe -ArgumentList "-windowstyle hidden -executionpolicy bypass -file $env:programdata\ParsecLoader\ShowDialog.ps1"
}


CountSinceStart




