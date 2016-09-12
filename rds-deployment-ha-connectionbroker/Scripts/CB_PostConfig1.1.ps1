
param 
    ( 
     [String]$BrokerServer,
     [String]$PrimaryDBConString,
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

$Logfile = ".\CB_PostConfig1.1_{0}.log" -f (get-date -Format "yyyyMMddhhmmss")
 
Function WriteLog
{
   Param ([string]$logstring)
 
   Add-content $Logfile -value $logstring
   Write-Host $logstring
}

WriteLog("Starting PostConfig")

$installPath = "$env:temp\Install-$(Get-Date -format 'yyyy-dd hh-mm-ss').msi"

if(!(Split-Path -parent $installPath) -or !(Test-Path -PathType Container (Split-Path -parent $installPath))) {
   $installPath = Join-Path $pwd (Split-Path -leaf $path)
}
WriteLog("Install Path of Client: $($installPath), starting download from $($downloadClientURL)")
Invoke-WebRequest -Uri $downloadClientURL -OutFile $installPath -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
WriteLog("Completed Download")

WriteLog("Starting install of client on localhost")
try{
$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ""$installPath"" /passive IACCEPTSQLINCLILICENSETERMS=YES" -Wait -PassThru).ExitCode
}
catch [Exception] {
    WriteLog("Exception installing the client on the localhost: $($_.Exception.Message)")
    throw
 }
WriteLog("Result from installing client: $result")

WriteLog("Starting Install of client on broker: $($BrokerServer)")
try
{
	Invoke-Command -ComputerName $BrokerServer -ScriptBlock {
		$installPath = "$env:temp\Install-$(Get-Date -format 'yyyy-dd hh-mm-ss').msi"

		if(!(Split-Path -parent $installPath) -or !(Test-Path -PathType Container (Split-Path -parent $installPath))) {
		   $installPath = Join-Path $pwd (Split-Path -leaf $path)
		}

		Write-Output("Downloading new client from: $($installPath)")
        Invoke-WebRequest -Uri $downloadClientURL -OutFile $installPath -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
		Write-Output("FinishedDownloading Client and starting install")
		$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ""$installPath"" /passive IACCEPTSQLINCLILICENSETERMS=YES" -Wait -PassThru).ExitCode
		Write-Output("Result from installing client: $($result)")
	} | Out-File -Append $Logfile
}
catch [Exception] {
    WriteLog("Exception installing the client on the localhost: $($_.Exception.Message)")
    throw
 } 


WriteLog("Getting Connection broker high availability")
$res = Get-RDConnectionBrokerHighAvailability $BrokerServer
WriteLog("Result from Broker high availability: $($res)")

if ($null -eq $res )
{
    WriteLog("Set-RDConnectionBrokerHighAvailability -ConnectionBroker $($BrokerServer) -DatabaseConnectionString $($PrimaryDBConString) -ClientAccessName $($cbDNSName)")
    Set-RDConnectionBrokerHighAvailability -ConnectionBroker $BrokerServer -DatabaseConnectionString $PrimaryDBConString -ClientAccessName $cbDNSName
	WriteLog("Returning from Set-RDConnectionBroker, checking high availability")
    $res = Get-RDConnectionBrokerHighAvailability $BrokerServer
    if ( $null -eq $res )
    {
       WriteLog "Unable to set the connection broker as high availability"
    }
	WriteLog("Result from Get-RDConnectionBrokerHighAvailability: $($res)")
}

WriteLog("Getting Connection broker to see if $($server) is added as a connection broker")
$res = get-rdserver -ConnectionBroker $BrokerServer -Role RDS-CONNECTION-BROKER | select Server
if ( $res.Server.ToLower().StartsWith($localhost.ToLower()) )
{
   WriteLog( "$($localhost) is already added as a server")
}
else
{
	WriteLog("Add-RdServer -Server $($localhost) -Role RDS-CONNECTION-BROKER -ConnectionBroker $($BrokerServer)")
	Add-RdServer -Server $localhost -Role RDS-CONNECTION-BROKER -ConnectionBroker $BrokerServer
}

$cb1IP = (Resolve-DnsName -Name $BrokerServer -Type A).IPAddress
$cb2IP = (Resolve-DnsName -Name $localhost -Type A).IPAddress

Invoke-Command -ComputerName $DNSServer  -ScriptBlock {
	Write-Output("Adding DNS for IP $($cb1IP)")
	$rec = Add-DnsServerResourceRecordA -ZoneNmae ""$($adDomainName)"" -AllowUpdateAny -Ipv4Address ""$($cb1IP)"" -PassThru -TimeToLive 00:00:30
	if ($rec -eq $null) 
	{
		throw "Unable to add Dns record for ip address $($cb1IP)"
	}
	Write-Output("Successfully added ip address")
    Write-Output("Adding DNS for IP $($cb2IP)")
	$rec = Add-DnsServerResourceRecordA -ZoneNmae ""$($adDomainName)"" -AllowUpdateAny -Ipv4Address ""$($cb2IP)"" -PassThru -TimeToLive 00:00:30
	if ($rec -eq $null) 
	{
		throw "Unable to add Dns record for ip address $($cb2IP)"
	}
	Write-Output("Succesfully added ip address")
	} | Out-File -Append $Logfile
    WriteLog("Completed setup")

