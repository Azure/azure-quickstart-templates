
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
WriteLog("Install Path of Client: $($installPath)")

$client = New-Object System.Net.WebClient
$client.DownloadFile($downloadClientURL, $installPath)

WriteLog("Starting install of client on localhost")
try{
$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installPath /passive IACCEPTSQLINCLILICENSETERMS=YES APPGUID={OCC618CE-F36A-415E-84b4-FB1BFF6967E1}" -Wait -PassThru).ExitCode
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
		$client = New-Object System.Net.WebClient
		$client.DownloadFile($downloadClientURL, $installPath)
		Write-Output("FinishedDownloading Client and starting install")
		$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installPath /passive IACCEPTSQLINCLILICENSETERMS=YES APPGUID={OCC618CE-F36A-415E-84b4-FB1BFF6967E1}" -Wait -PassThru).ExitCode
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
    if ($null -eq $SecondaryDBConString -or "" -eq $SecondaryDBConString )
    {
        $SecondaryDBConString = "-DatabaseSecondaryConnectionString $SecondaryDBConString"
    }
    else
    {
       $SecondaryDBConString = ""
    }


    WriteLog("Set-RDConnectionBrokerHighAvailability -ConnectionBroker $($BrokerServer) -DatabaseConnectionString $($PrimaryDBConString) $($secConnString) -ClientAccessName $($cbDNSName)")
    Set-RDConnectionBrokerHighAvailability -ConnectionBroker $BrokerServer -DatabaseConnectionString $PrimaryDBConString -DatabaseSecondaryConnectionString $secConnString -ClientAccessName $cbDNSName
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

WriteLog("Adding DNS Command: Start-Process -FilePath ""dnscmd.exe"" -ArgumentList ""$($DNSServer) /RecordAdd $($adDomainName) $($cbDNSName) A $($cb1IP)"" -Wait -PassThru")
Invoke-Command -ComputerName $DNSServer -ScriptBlock {
$result = (Start-Process -FilePath "dnscmd.exe" -ArgumentList "$DNSServer /RecordAdd $adDomainName $cbDNSName A $cb1IP" -Wait -PassThru).ExitCode
Write-Output("Result from adding  DNS entry: $($result)")

$result = (Start-Process -FilePath "dnscmd.exe" -ArgumentList "$DNSServer /RecordAdd $adDomainName $cbDNSName A $cb2IP" -Wait -PassThru).ExitCode
Write-Output("Result from adding  DNS entry: $($result)")
} | Out-File -Append $Logfile


