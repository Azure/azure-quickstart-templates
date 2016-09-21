
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
 
function GetServersByRole($roleName)
{
    $RemoteSqlOdbcconn = new-object System.Data.Odbc.OdbcConnection	
    $RemoteSqlOdbcconn.ConnectionString = $connStringToNewDbRdcms 
    $RemoteSqlOdbcconn.Open()
    
    $OdbcCmdStr = "SELECT s.Name FROM rds.Server s INNER JOIN rds." + $roleName + " cb ON s.Id = cb.ServerId"
    $RemoteSqlOdbccmd = new-object System.Data.Odbc.OdbcCommand
    $RemoteSqlOdbccmd.CommandText = $OdbcCmdStr
    $RemoteSqlOdbccmd.Connection = $RemoteSqlOdbcconn
    $SqlRdr = $RemoteSqlOdbccmd.ExecuteReader()    
    while ($SqlRdr.Read() -eq $true)
    {
        $ServerArr += @($SqlRdr.GetString(0).Split('.')[0])
    }
    
    $SqlRdr.Close()
    $RemoteSqlOdbccmd.Dispose()
    $RemoteSqlOdbcconn.Close()
    return $ServerArr
}

function GetIpAddress([string]$compName, [int]$ipType)
{
    $IPconfigset = Get-WmiObject -ComputerName $compName Win32_NetworkAdapterConfiguration    
    foreach ($IPConfig in $IPconfigset) 
    {  
        if (!$Ipconfig.IPaddress -or 
            ($Ipconfig.IPEnabled -eq $FALSE)) 
        {
           continue; 
        }
        	
        foreach ($addrStr in $Ipconfig.Ipaddress) 
        {
            $addr = [System.Net.IPAddress]::Parse($addrStr);
            if (($ipType -eq 4) -and 
                ($addr.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork))
            {                
                return $addr;
            }
            elseif (($ipType -eq 6) -and 
                    ($addr.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6) -and
                    (!$addrStr.StartsWith("fe80")))
            {                
                return $addr;
            }
        }
    }  
}

function AddDomainComputersToRDSMgmtServerGroup()
{
    $rdmsGroupName = "RDS Management Servers";
    $objOU = [ADSI]("WinNT://" + $env:computername)
    $objGroup = $objOU.psbase.children.find($rdmsGroupName)
    
    $machineAcc = "Domain Computers"
    $membershipExists = $objGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name",'GetProperty',$null,$_,$null)} | where {$_ -eq $machineAcc}
    if ( !($membershipExists.length -gt 1) ) 
    {
        $objGroup.Add("WinNT://" + $domainName + "/" + $machineAcc)
    }   
}
function SetupVMHA($compName)
{
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $compName);

    $regKey = $reg.OpenSubKey('SYSTEM\CurrentControlSet\Services\VMHostAgent\Parameters', 'ReadWriteSubTree', 'SetValue');
    $regKey.SetValue('tssdis',$brokerMachineList, 'string');
	
    AddDomainComputersToRDSMgmtServerGroup;
}

function SetupRDSH($compName)
{
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $compName);

    $regKey = $reg.OpenSubKey('SYSTEM\CurrentControlSet\Control\Terminal Server\ClusterSettings', 'ReadWriteSubTree', 'SetValue');
    $regKey.SetValue('SessionDirectoryLocation',$brokerMachineList, 'string');

    AddDomainComputersToRDSMgmtServerGroup;
}

function SetupRDWA($compName)
{
    $rdweb = Get-WmiObject -ComputerName $compName AppSettingssection -namespace root\webadministration -Authentication 6
    $appSection = $rdweb[0]
    $objAppSettings = $appSection.AppSettings

    foreach ($cfg in $objAppSettings)
    {
        if ($cfg.key.CompareTo("radcmserver") -eq 0)
        {
            Write-Host "Changing" $cfg.Value "to" $brokerMachineList
            $cfg.Value = $brokerMachineList
        }
    }
    $appSection.SetPropertyValue("AppSettings", $objAppSettings)
    $PutOptions = New-Object System.Management.PutOptions
    $PutOptions.Type = 1  # update only
    $appSection.Put($PutOptions)
    Write-Host "Successfully configured RDWeb's Broker name"
}

function SetupCB($compName, $activeBroker)
{
	WriteLog("Starting Install of client on broker: $($compName)")
	try
	{
		Invoke-Command -ComputerName $compName -ScriptBlock {
			$installPath = "$env:temp\Install-$(Get-Date -format 'yyyy-dd hh-mm-ss').msi"

			if(!(Split-Path -parent $installPath) -or !(Test-Path -PathType Container (Split-Path -parent $installPath))) {
			   $installPath = Join-Path $pwd (Split-Path -leaf $path)
			}

			Write-Output("Downloading new client from: $($installPath)")
			Invoke-WebRequest -Uri $downloadClientURL -OutFile $installPath -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
			Write-Output("FinishedDownloading Client and starting install")
			$result = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ""$installPath"" /passive IACCEPTSQLINCLILICENSETERMS=YES" -Wait -PassThru).ExitCode
			Write-Output("Result from installing client: $($result)")

			if ( $activeBroker )
			{
				    #
					# Make CMS aware of all active brokers, by setting the DNS RR Name
					$rdmsenv = gwmi -namesp root\cimv2\rdms -class win32_rdmsenvironment -list
					$rdmsenv.SetActiveServer()
					$rdmsenv.SetClientAccessName( $cbDNSName )
			}

			#
			# Add Domain Computers to RDS Endpoint Servers group
			$rdsServersGroupName = "RDS Endpoint Servers"
			$objOU = [ADSI]("WinNT://" + $env:computername)
			$objGroup = $objOU.psbase.children.find($rdsServersGroupName)
			$machineAcc = "Domain Computers"
			$membershipExists = $objGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name",'GetProperty',$null,$_,$null)} | where {$_ -eq $machineAcc}
			if ( !($membershipExists.length -gt 1) ) 
			{
				$objGroup.Add("WinNT://" + $domainName + "/" + $machineAcc)
			}    
		} | Out-File -Append $Logfile
	}
	catch [Exception] {
    WriteLog("Exception installing the client on the localhost: $($_.Exception.Message)")
    throw
 } 
}

Function WriteLog
{
   Param ([string]$logstring)
 
   Add-content $Logfile -value $logstring
   Write-Host $logstring
}

WriteLog("Starting PostConfig")

SetupCB($localhost, $false);
Setup($BrokerServer, $true);

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
	$rec = Add-DnsServerResourceRecordA -ZoneName ""$($adDomainName)"" -AllowUpdateAny -Ipv4Address ""$($cb2IP)"" -PassThru -TimeToLive 00:00:30
	if ($rec -eq $null) 
	{
		throw "Unable to add Dns record for ip address $($cb2IP)"
	}
	Write-Output("Succesfully added ip address")
	} | Out-File -Append $Logfile
    

$brokerMachines = GetServersByRole "RoleRdcb"
$rdwaMachines = GetServersByRole "RoleRdwa"
$rdshMachines = GetServersByRole "RoleRdsh"
$rdvhMachines = GetServersByRole "RoleRdvh"

$brokerCount = 1;
$brokerMachineList = "";
foreach ($broker in $brokerMachines)
{
    $brokerMachineList = $brokerMachineList + $broker + "." + $env:USERDNSDOMAIN;
    if ($brokerCount -lt $brokerMachines.Count)
    {
        $brokerMachineList = $brokerMachineList + ";"
    }
    $brokerCount++;
}

foreach ($broker in $brokerMachines)
{
    Write-Host "Setting up Redirector machine : " + $broker
    SetupRDSH $broker;
}

foreach ($rdvh in $rdvhMachines)
{
    Write-Host "Setting up RDVH machine : " + $rdvh
    SetupVMHA $rdvh;
}

foreach ($rdsh in $rdshMachines)
{
    Write-Host "Setting up RDSH machine : " + $rdsh
    SetupRDSH $rdsh;
}

foreach ($rdwa in $rdwaMachines)
{
    Write-Host "Setting up RDWA machine : " + $rdwa
    SetupRDWA $rdwa
}

WriteLog("Completed setup")


