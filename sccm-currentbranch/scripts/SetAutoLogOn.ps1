Param([Parameter(Mandatory = $false)][AllowEmptyString()]$DomainFullName,$Username,$password)

$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
$logpath = $ProvisionToolPath+"\SetAutoLogOn.txt"
$isdomain = $false
$NetBIOSName = ""
if($DomainFullName)
{
    $isdomain = $true
    $NetBIOSName = $DomainFullName.split('.')[0]
    $Username = $NetBIOSName + '\' + $Username
}
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

"[$(Get-Date -format HH:mm:ss)] Start setting auto logon for $Username." | Out-File -Append $logpath
while((Get-ItemProperty $RegPath).AutoAdminLogon -ne 1)
{
    "[$(Get-Date -format HH:mm:ss)] Setting AutoAdminLogon to 1." | Out-File -Append $logpath
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String  
}

while((Get-ItemProperty $RegPath).DefaultUsername -ne $Username)
{
    "[$(Get-Date -format HH:mm:ss)] Setting DefaultUsername to $Username." | Out-File -Append $logpath
    Set-ItemProperty $RegPath "DefaultUsername" -Value "$Username" -type String  
}

while((Get-ItemProperty $RegPath).DefaultPassword -ne $password)
{
    "[$(Get-Date -format HH:mm:ss)] Setting Password..." | Out-File -Append $logpath
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$password" -type String
}

while((Get-ItemProperty $RegPath).AutoLogonCount -ne 1)
{
    "[$(Get-Date -format HH:mm:ss)] Setting Logon count to 1." | Out-File -Append $logpath
    Set-ItemProperty $RegPath "AutoLogonCount" -Value 1 -type DWord
}

if($isdomain)
{
    while((Get-ItemProperty $RegPath).DefaultDomainName -ne $NetBIOSName)
    {
        "[$(Get-Date -format HH:mm:ss)] Setting DefaultDomainName to $NetBIOSName." | Out-File -Append $logpath
        Set-ItemProperty $RegPath "DefaultDomainName" -Value $NetBIOSName -type String
    }
}

"[$(Get-Date -format HH:mm:ss)] Finished." | Out-File -Append $logpath