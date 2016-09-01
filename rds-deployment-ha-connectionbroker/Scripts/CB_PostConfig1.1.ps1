
param 
    ( 
     [String]$BrokerServer,
     [String]$PrimaryDBConString,
     [String]$SecondaryDBConString,
     [String]$username,
     [String]$password,
     [string]$cbDNSName,
     [string]$downloadClientURL,
     [string]$DomainNetbios,
     [string]$DNSServer,
     [string]$adDomainName
    ) 

$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
$username = $DomainNetbios + "\" + $Username
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
} # End of Config Data
$installPath = "$env:temp\Install-$(Get-Date -format 'yyyy-dd hh-mm-ss').msi"

if(!(Split-Path -parent $installPath) -or !(Test-Path -PathType Container (Split-Path -parent $installPath))) {
   $installPath = Join-Path $pwd (Split-Path -leaf $path)
}

$client = New-Object System.Net.WebClient
$client.DownloadFile($downloadClientURL, $installPath)

$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installPath /passive IACCEPTSQLINCLILICENSETERMS=YES APPGUID={OCC618CE-F36A-415E-84b4-FB1BFF6967E1}" -Wait -PassThru).ExitCode
"Result from installing client: $result"

Invoke-Command -ComputerName $BrokerServer -ScriptBlock {
$installPath = "$env:temp\Install-$(Get-Date -format 'yyyy-dd hh-mm-ss').msi"

if(!(Split-Path -parent $installPath) -or !(Test-Path -PathType Container (Split-Path -parent $installPath))) {
   $installPath = Join-Path $pwd (Split-Path -leaf $path)
}

$client = New-Object System.Net.WebClient
$client.DownloadFile($downloadClientURL, $installPath)

$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installPath /passive IACCEPTSQLINCLILICENSETERMS=YES APPGUID={OCC618CE-F36A-415E-84b4-FB1BFF6967E1}" -Wait -PassThru).ExitCode
"Result from installing client: $result"
}

$res = Get-RDConnectionBrokerHighAvailability $BrokerServer
if ($null -eq $res )
{
    if ($null -eq $SecondaryDBConString -or "" -eq $SecondaryDBConString )
    {
        $SecondaryDBConString = "-DatabaseSecondaryConnectionString $SecondaryDBConString"
    }
    else
    {
       $SecondaryDBConString = ""
    }

    "Set-RDConnectionBrokerHighAvailability -ConnectionBroker $BrokerServer -DatabaseConnectionString $PrimaryDBConString $secConnString -ClientAccessName $cbDNSName"
    Set-RDConnectionBrokerHighAvailability -ConnectionBroker $BrokerServer -DatabaseConnectionString $PrimaryDBConString $secConnString -ClientAccessName $cbDNSName

    $res = Get-RDConnectionBrokerHighAvailability $BrokerServer
    if ( $null -eq $res )
    {
       Write-Host "Failed to set the connection broker as high availability"
    }
}

$res = get-rdserver -ConnectionBroker $BrokerServer -Role RDS-CONNECTION-BROKER | select Server
if ( $res.Server.ToLower().StartsWith($localhost.ToLower()) )
{
   Write-Host "$localhost is already added as a server"
}
"Add-RdServer -Server $localhost -Role RDS-CONNECTION-BROKER -ConnectionBroker $BrokerServer"
Add-RdServer -Server $localhost -Role RDS-CONNECTION-BROKER -ConnectionBroker $BrokerServer

$cb1IP = (Resolve-DnsName -Name $BrokerServer -Type A).IPAddress
$cb2IP = (Resolve-DnsName -Name $localhost -Type A).IPAddress

Invoke-Command -ComputerName $DNSServer -ScriptBlock {
$result = (Start-Process -FilePath "dnscmd.exe" -ArgumentList "$DNSServer /RecordAdd $adDomainName $cbDNSName A $cb1IP" -Wait -PassThru).ExitCode
"Result from adding  DNS entry: $result"

$result = (Start-Process -FilePath "dnscmd.exe" -ArgumentList "$DNSServer /RecordAdd $adDomainName $cbDNSName A $cb2IP" -Wait -PassThru).ExitCode
"Result from adding  DNS entry: $result"
}


