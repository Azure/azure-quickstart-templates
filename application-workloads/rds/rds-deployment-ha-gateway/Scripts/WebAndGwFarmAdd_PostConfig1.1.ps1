
param 
    ( 
        
     [String]$WebGwServer,
     [String]$BrokerServer,
     [String]$WebURL,
     [String]$Domainname,
     [String]$DomainNetbios,
     [String]$username,
     [String]$password,
     [string]$ServerName = "gateway",
     [int]$numberofwebServers,
     $validationKey64,
     $decryptionKey24
    
    ) 

$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
$username = $DomainNetbios + "\" + $Username
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))

configuration RDWebAccessdeployment
{

    param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds,

        # Connection Broker Node name
        [String]$connectionBroker,
        
        # Web Access Node name
        [String]$webAccessServer,

        # Gateway external FQDN
        [String]$externalFqdn
        
      ) 


    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, xRemoteDesktopSessionHost
   
    $localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
    
    if (-not $connectionBroker)   { $connectionBroker = $localhost }
    if (-not $webAccessServer)    { $webAccessServer  = $localhost }

    if (-not $collectionName)         { $collectionName = "Desktop Collection" }
    if (-not $collectionDescription)  { $collectionDescription = "A sample RD Session collection up in cloud." }

    Node localhost
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        xRDServer AddWebAccessServer
        {
            Role    = 'RDS-Web-Access'
            Server  = $webAccessServer
            GatewayExternalFqdn = $externalFqdn
            ConnectionBroker = $BrokerServer

            PsDscRunAsCredential = $adminCreds
        }
    
    }



}#End of Configuration RDWebAccessdeployment 

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
} # End of Config Data

# calling the configuration
RDWebAccessdeployment -adminCreds $cred -connectionBroker $BrokerServer -webAccessServer $localhost -externalFqdn $WebURL -domainName $Domainname -ConfigurationData $ConfigData -Verbose
Start-DscConfiguration -Wait -Force -Path .\RDWebAccessdeployment -Verbose


configuration RDGatewaydeployment
{

    param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds,

        # Connection Broker Node name
        [String]$connectionBroker,
        
        # Web Access Node name
        [String]$webAccessServer,

        # Gateway external FQDN
        [String]$externalFqdn,
        
        # RD Session Host count and naming prefix
        [Int]$numberOfRdshInstances = 1,
        [String]$sessionHostNamingPrefix = "SessionHost-",

        # Collection Name
        [String]$collectionName,

        # Connection Description
        [String]$collectionDescription

      ) 


    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, xRemoteDesktopSessionHost
   
    $localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
 
    if (-not $connectionBroker)   { $connectionBroker = $localhost }
    if (-not $webAccessServer)    { $webAccessServer  = $localhost }

    if (-not $collectionName)         { $collectionName = "Desktop Collection" }
    if (-not $collectionDescription)  { $collectionDescription = "A sample RD Session collection up in cloud." }

    Node localhost
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        xRDServer AddGatewayServer
        {
            Role    = 'RDS-Gateway'
            Server  = $webAccessServer
            GatewayExternalFqdn = $externalFqdn
            ConnectionBroker = $BrokerServer

            PsDscRunAsCredential = $adminCreds
        }
    
    }



}#End of Configuration RDGatewaydeployment 

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
} # End of Config Data

RDGatewaydeployment -adminCreds $cred -connectionBroker $BrokerServer -webAccessServer $localhost -externalFqdn $WebURL -domainName $Domainname -ConfigurationData $ConfigData -Verbose
Start-DscConfiguration -Wait -Force -Path .\RDGatewaydeployment -Verbose


#--Post Configuration for IIS RD web for Machine keys

Write-Host "Username : $($username),   Password: $($password)"
#$username = $DomainNetbios + "\" + $username
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$webServernameArray = New-Object System.Collections.ArrayList

for ($i = 0; $i -le $numberofwebServers; $i++)
{ 
    if ($i -eq 0)
    {
        $webServername = "Gateway"
        #Write-Host "For i = 0, srvername = $($webServername)"
    }
    else{
    $servercount = $i - 1
    $webServername = "gateway" + $servercount.ToString()
    #Write-Host "For $($i), servername = $($webServername)"
        }
    $webServernameArray.Add($webServername) | Out-Null
}

Write-Host "web server Array value $($webServernameArray)"

# genrate 64 and 24 char keys:
[int]$keylen = 64
       $buff = new-object "System.Byte[]" $keylen
       $rnd = new-object System.Security.Cryptography.RNGCryptoServiceProvider
       $rnd.GetBytes($buff)
       $result =""
       for($i=0; $i -lt $keylen; $i++)  {
             $result += [System.String]::Format("{0:X2}",$buff[$i])
       }
       $validationkey64 = $result
       # Write-Host $validationkey64
       # end of Validation Key code

       $keylen = 24
       $buff1 = new-object "System.Byte[]" $keylen
       $rnd1 = new-object System.Security.Cryptography.RNGCryptoServiceProvider
       $rnd1.GetBytes($buff1)
       $result =""
       for($i=0; $i -lt $keylen; $i++)  {
             $result += [System.String]::Format("{0:X2}",$buff[$i])
       }
       $decryptionKey24 = $result
       # Write-Host $decryptionKey24

# logic end for 64 and 24 char keys

foreach ($item in $webServernameArray)
{
    $WebServer = $item + "." + $DomainName
    Write-Host "Starting working on webserver name : $($WebServer)"
    try{
    $session = New-PSSession -ComputerName $WebServer -Credential $cred 
    }
    catch{
    Write-Host $Error
    }


Invoke-Command -session $session -ScriptBlock {param($validationkey64,$decryptionKey24)


function ValidateWindowsFeature
{
    $localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
    $RdsWindowsFeature = Get-WindowsFeature -ComputerName $localhost -Name RDS-Web-Access     
    if ($RdsWindowsFeature.InstallState -eq "Installed")
    {
        Return $true
    }
    else
    {
        Return $false
    }

}
$Validationheck = $False
$Validationheck = ValidateWindowsFeature
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
if($Validationheck -eq $true)
{
    Write-Host "Windows feature RDS-Web_access present on $($localhost)"
    $machineConfig = "C:\Windows\Web\RDWeb\Web.config"
       if (Test-Path $machineConfig) 
       {
        Write-Host "editing machine config file : $($machineConfig) on server $($localhost) "
        
        try{
        $xml = [xml](get-content $machineConfig)
        $xml.Save($machineConfig + "_")
        
        $root = $xml.get_DocumentElement()
        $system_web = $root."system.web"
        if ($system_web.machineKey -eq $null) 
             { 
             $machineKey = $xml.CreateElement("machineKey") 
             $a = $system_web.AppendChild($machineKey)
             }
        $system_web.SelectSingleNode("machineKey").SetAttribute("validationKey","$validationKey64")
        $system_web.SelectSingleNode("machineKey").SetAttribute("decryptionKey","$decryptionKey24")
        $a = $xml.Save($machineConfig)
        
        }
        Catch{
        Write-Host $Error
        }
        
        } # end of If test-path

} # End of If($ValidationCheck -eq $True)
else
{
    Write-Host "Windows feature RDS-Web_access is not present on $($localhost)"
}

               
      
} -ArgumentList $validationKey64,$decryptionKey24 # end of Script Block 

Remove-PSSession -Session $session



} # end of foreach $item in $webServername








