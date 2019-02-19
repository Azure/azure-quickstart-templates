Param($DCIPAddress,$DomainFullName,$DomainAdminName,$Password)

$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
$logpath = $ProvisionToolPath+"\JoinDomainlog.txt"
$dnsset = Get-DnsClientServerAddress | %{$_ | ?{$_.InterfaceAlias.StartsWith("Ethernet") -and $_.AddressFamily -eq 2}}
if($DCIPaddress -eq "")
{

}
else
{
    "[$(Get-Date -format HH:mm:ss)] Set DNS to $DCIPaddress" | Out-File -Append $logpath
    Set-DnsClientServerAddress -InterfaceIndex $dnsset.InterfaceIndex -ServerAddresses $DCIPaddress
}
$DomainName = $DomainFullName.split('.')[0]
$DName = $DomainName + "\" + $DomainAdminName
#JoinDomain
$pwd = $Password | ConvertTo-SecureString -asPlainText -Force
        
$credential = New-Object System.Management.Automation.PSCredential($DName,$pwd)
        
"[$(Get-Date -format HH:mm:ss)] Start to join in to domain : $DomainFullName" | Out-File -Append $logpath
try
{
    Add-Computer -DomainName $DomainFullName -Credential $credential
    "[$(Get-Date -format HH:mm:ss)] Finished!" | Out-File -Append $logpath
}
catch
{
    "[$(Get-Date -format HH:mm:ss)] Failed to join domain with below error:" | Out-File -Append $logpath
    $ErrorMessage = $_.Exception.Message
    $ErrorMessage | Out-File -Append $logpath
}