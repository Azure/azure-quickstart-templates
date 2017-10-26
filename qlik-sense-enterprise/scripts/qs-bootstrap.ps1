#
# QsBootstrap.ps1
#
$adminUser = $Args[0]
$adminPassword = $Args[1]
$scriptUrl = $($Args[6])
$script = $($scriptUrl)+'/scripts/qs-install.ps1'
$password =  ConvertTo-SecureString $($adminPassword) -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $env:computername\$adminUser, $password
New-Item -ItemType directory -Path C:\installation
(New-Object System.Net.WebClient).DownloadFile($($script), "c:\installation\qs-install.ps1")
Enable-PSRemoting -Force
Invoke-Command -ScriptBlock { & c:\installation\qs-install.ps1 $Args[0] $Args[1] $Args[2] $Args[3] $Args[4] $($Args[5]) } -ArgumentList ($Args[0], $Args[1], $Args[2], $Args[3], $Args[4], $($Args[5])) -Credential $credential -ComputerName $env:COMPUTERNAME
Disable-PSRemoting -Force
