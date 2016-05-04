
param 
    ( 
        
        [String]$WebGwServer,
        [String]$BrokerServer,
        [String]$WebURL,
        [String]$Domainname,
        [String]$DoaminNetbios,
        [String]$username,
        [String]$password

    
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
    
    $DomainNetbios = $domainName.Split('.') | select -First 1
    $username = $adminCreds.UserName -split '\\' | select -last 1
    $domainCreds = New-Object System.Management.Automation.PSCredential ("$DomainNetbios\$username", $adminCreds.Password)

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

            PsDscRunAsCredential = $domainCreds
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
    
    $DomainNetbios = $domainName.Split('.') | select -First 1
    $username = $adminCreds.UserName -split '\\' | select -last 1
    $domainCreds = New-Object System.Management.Automation.PSCredential ("$DomainNetbios\$username", $adminCreds.Password)

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

            PsDscRunAsCredential = $domainCreds
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







