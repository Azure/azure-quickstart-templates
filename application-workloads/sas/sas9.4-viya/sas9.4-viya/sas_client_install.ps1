param (
    [string]$stg_acc_name,
    [string]$stg_key,
    [string]$file_share_name,
    [string]$depot_folder_name,
    [string]$clients_sid,
    [string]$app_name,
    [string]$mid_name,
    [string]$domain_name,
    [string]$artifact_loc,
    [string]$storageuri,
    $code = 99
)

Set-PSDebug -Trace 1;
$logdir = "C:\saslog"
$mid_fqdn = "${app_name}${mid_name}.${domain_name}"
New-Item -Path $logdir -ItemType directory

Copy-Item -Path "C:\WindowsAzure\client_install\*" -Destination ${logdir} -Recurse

(Get-Content -path ${logdir}\clients_install.properties -Raw) -replace 'client_sid', $clients_sid | Add-Content -Path ${logdir}\clients_install_new.properties
Remove-Item -Path ${logdir}\clients_install.properties
Move-Item -Path ${logdir}\clients_install_new.properties -Destination ${logdir}\clients_install.properties
(Get-Content -path ${logdir}\clients_install.properties -Raw) -replace 'depot_folder', $depot_folder_name | Add-Content -Path ${logdir}\clients_install_new.properties
Remove-Item -Path ${logdir}\clients_install.properties
Move-Item -Path ${logdir}\clients_install_new.properties -Destination ${logdir}\clients_install.properties
(Get-Content -path ${logdir}\clients_install.properties -Raw) -replace 'mid_fqdn', $mid_fqdn | Add-Content -Path ${logdir}\clients_install_new.properties
Remove-Item -Path ${logdir}\clients_install.properties
Move-Item -Path ${logdir}\clients_install_new.properties -Destination ${logdir}\clients_install.properties
$connectTestResult = Test-NetConnection -ComputerName "${storageuri}" -Port 445

if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    Set-PSDebug -Trace 1;
    cmd.exe /C "cmdkey /add:`"${storageuri}`" /user:`"Azure\${stg_acc_name}`" /pass:`"${stg_key}`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\${storageuri}\${file_share_name}" -Persist
}
else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
Set-Location "Z:\${depot_folder_name}"
.\setup.exe -lang en -deploy -datalocation C:\saslog -responsefile ${logdir}\clients_install.properties -quiet 

Start-Sleep -Seconds 1800
$latest = Get-ChildItem -Path ${logdir}\deployw* | Sort-Object LastAccessTime -Descending | Select-Object -First 1
$latest.name
Set-Location $logdir
$sort_string = Select-String -Path $latest.name -Pattern "ExitInstance="
$status = $sort_string.Line.split() | ForEach-Object { $_.substring($_.length - 1) } | Select-Object -first 1 -skip 1 
if ($status -ne 0) { 
    Write-Host "Install Is Failed"
    exit $code
}
else {
    Write-Host "Install Is Sucess"
}
$Path = $env:TEMP; $Installer = "chrome_installer.exe"; Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer; Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; Remove-Item $Path\$Installer
