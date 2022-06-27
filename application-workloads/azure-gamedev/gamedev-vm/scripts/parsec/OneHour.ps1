function OneHour {
Write-Output "Launched" | Out-File C:\ParsecTemp\Launched.txt
$Seconds = Get-Content $env:programdata\ParsecLoader\Time.txt
$Count = 0
do {
$Count++
Start-Sleep -s 1
$Count
}
Until($Count -ge $Seconds)


Start-Process powershell.exe -ArgumentList "-windowstyle hidden -executionpolicy bypass -file $env:programdata\ParsecLoader\ShowDialog.ps1"

} 

OneHour