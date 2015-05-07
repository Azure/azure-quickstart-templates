configuration DomainJoin 
{ 
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$adminCreds,

        [Int]$retryCount = 20,
        [Int]$retryIntervalSec = 30
    ) 
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($adminCreds.UserName)", $adminCreds.Password)
   
    Node localhost
    {
        WindowsFeature ADPowershell
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        } 

        xWaitForADDomain WaitForDomain 
        { 
            DomainName = $domainName 
            DomainUserCredential= $adminCreds
            RetryCount = $retryCount 
            RetryIntervalSec = $retryIntervalSec
            DependsOn = "[WindowsFeature]ADPowershell" 
        }

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $domainName
            Credential = $DomainCreds
            DependsOn = "[xWaitForADDomain]WaitForDomain" 
        }
   }
}


configuration RDSDeployment
{
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$adminCreds,

        [Int]$retryCount = 60,
        [Int]$retryIntervalSec = 30,

        # Connection Broker Node Name
        [String]$connectionBroker,
        
        # Web Access Node Name
        [String]$webAccessServer,
        
        # RDSH Name
        [String]$sessionHost,
        
        # Collection Name
        [String]$collectionName,

        # Connection Description
        [String]$collectionDescription

    ) 

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xRemoteDesktopSessionHost

   
    $localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

    $DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($adminCreds.UserName)", $adminCreds.Password)


    if (-not $connectionBroker)
    {
        $connectionBroker = $localhost
    }

    if (-not $webAccessServer) 
    { 
        $webAccessServer = $localhost 
    }

    if (-not $sessionHost)
    {
        $sessionHost = $localhost
    }

    if (-not $collectionName)
    {
        $collectionName = "Session Collection"
    }

    if (-not $collectionDescription)
    {
        $collectionDescription = "A sample Session collection up in Azure"
    }


    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature RDS-Licensing
        {
            Ensure = "Present"
            Name = "RDS-Licensing"
        }

        WindowsFeature ADDSTools
        {
            Name = "RSAT-ADDS-Tools"
        } 

        WindowsFeature ADPowershell
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        } 

        xWaitForADDomain WaitForDomain 
        { 
            DependsOn = "[WindowsFeature]ADPowershell" 

            DomainName = $domainName 
            DomainUserCredential= $adminCreds
            RetryCount = $retryCount 
            RetryIntervalSec = $retryIntervalSec
        }

        xComputer DomainJoin
        {
            DependsOn = "[xWaitForADDomain]WaitForDomain" 

            Name = $env:COMPUTERNAME
            DomainName = $domainName
            Credential = $DomainCreds
        }

        xRDSessionDeployment Deployment
        {
            DependsOn = "[xComputer]DomainJoin"

            ConnectionBroker = $connectionBroker
            WebAccessServer  = $webAccessServer

            SessionHost      = $sessionHost
        }

        xRDSessionCollection Collection
        {
            DependsOn = "[xRDSessionDeployment]Deployment"

            ConnectionBroker = $connectionBroker

            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            
            SessionHost = $sessionHost
        }

        xRDSessionCollectionConfiguration CollectionConfiguration
        {
            CollectionName = $collectionName
            
            TemporaryFoldersDeletedOnExit = $false
            SecurityLayer = "SSL"

            DependsOn = "[xRDSessionCollection]Collection"
        }
   }


<#
	LocalConfigurationManager 
        {
            ActionAfterReboot = 'StopConfiguration'
        }
#>
}