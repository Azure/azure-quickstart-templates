Configuration CreateRootDomain
{
    Param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [Array]$RDSParameters
    )

    $DomainName = $RDSParameters[0].DomainName
    $DNSServer = $RDSParameters[0].DNSServer
    $TimeZoneID = $RDSParameters[0].TimeZoneID
    $ExternalDnsDomain = $RDSParameters[0].ExternalDnsDomain
    $IntBrokerLBIP = $RDSParameters[0].IntBrokerLBIP
    $IntWebGWLBIP = $RDSParameters[0].IntWebGWLBIP
    $WebGWDNS = $RDSParameters[0].WebGWDNS
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xActiveDirectory,xNetworking,ComputerManagementDSC,xComputerManagement,xDnsServer,NetworkingDsc
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)",$Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $MyIP = ($Interface | Get-NetIPAddress -AddressFamily IPv4 | Select-Object -First 1).IPAddress
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }
                
        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        WindowsFeature AD-Domain-Services
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            DependsOn = "[WindowsFeature]DNS"
        }      

        WindowsFeature DnsTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }        

        WindowsFeature GPOTools
        {
            Ensure = "Present"
            Name = "GPMC"
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature DFSTools
        {
            Ensure = "Present"
            Name = "RSAT-DFS-Mgmt-Con"
            DependsOn = "[WindowsFeature]DNS"
        }        

        WindowsFeature RSAT-AD-Tools
        {
            Ensure = "Present"
            Name = "RSAT-AD-Tools"
            DependsOn = "[WindowsFeature]AD-Domain-Services"
            IncludeAllSubFeature = $True
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = $TimeZoneID
        }

        Firewall EnableSMBFwRule
        {
            Name = "FPS-SMB-In-TCP"
            Enabled = $True
            Ensure = "Present"
        }
        
        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        If ($MyIP -eq $DNSServer) {
            xADDomain RootDomain
            {
                DomainName = $DomainName
                DomainAdministratorCredential = $DomainCreds
                SafemodeAdministratorPassword = $DomainCreds
                DatabasePath = "$Env:windir\NTDS"
                LogPath = "$Env:windir\NTDS"
                SysvolPath = "$Env:windir\SYSVOL"
                DependsOn = @("[WindowsFeature]AD-Domain-Services", "[xDnsServerAddress]DnsServerAddress")
            }

            xDnsServerForwarder SetForwarders
            {
                IsSingleInstance = 'Yes'
                IPAddresses      = @('8.8.8.8', '8.8.4.4')
                UseRootHint      = $false
                DependsOn = @("[WindowsFeature]DNS", "[xADDomain]RootDomain")
            }
    
            Script AddExternalZone
            {
                SetScript = {
                    Add-DnsServerPrimaryZone -Name $Using:ExternalDnsDomain `
                        -ReplicationScope "Forest" `
                        -DynamicUpdate "Secure"
                }
    
                TestScript = {
                    If (Get-DnsServerZone -Name $Using:ExternalDnsDomain -ErrorAction SilentlyContinue) {
                        Return $True
                    } Else {
                        Return $False
                    }
                }
    
                GetScript = {
                    @{
                        Result = Get-DnsServerZone -Name $Using:ExternalDnsDomain -ErrorAction SilentlyContinue
                    }
                }
    
                DependsOn = "[xDnsServerForwarder]SetForwarders"
            }
    
            xDnsRecord AddIntLBBrokerIP
            {
                Name = "broker"
                Target = $IntBrokerLBIP
                Zone = $ExternalDnsDomain
                Type = "ARecord"
                Ensure = "Present"
                DependsOn = "[Script]AddExternalZone"
            }
    
            xDnsRecord AddIntLBWebGWIP
            {
                Name = $WebGWDNS
                Target = $IntWebGWLBIP
                Zone = $ExternalDnsDomain
                Type = "ARecord"
                Ensure = "Present"
                DependsOn = "[Script]AddExternalZone"
            }

            PendingReboot RebootAfterInstallingAD
            {
                Name = 'RebootAfterInstallingAD'
                DependsOn = @("[xADDomain]RootDomain","[xDnsServerForwarder]SetForwarders")
            }                       
        } Else {            
            xWaitForADDomain DscForestWait
            {
                DomainName = $DomainName
                DomainUserCredential= $DomainCreds
                RetryCount = 30
                RetryIntervalSec = 2400
                DependsOn = @("[WindowsFeature]AD-Domain-Services", "[xDnsServerAddress]DnsServerAddress")
            }
            
            xADDomainController NextDC
            {
                DomainName = $DomainName
                DomainAdministratorCredential = $DomainCreds
                SafemodeAdministratorPassword = $DomainCreds
                DatabasePath = "$Env:windir\NTDS"
                LogPath = "$Env:windir\NTDS"
                SysvolPath = "$Env:windir\SYSVOL"
                DependsOn = @("[xWaitForADDomain]DscForestWait","[WindowsFeature]AD-Domain-Services", "[xDnsServerAddress]DnsServerAddress")
            }

            xDnsServerForwarder SetForwarders
            {
                IsSingleInstance = 'Yes'
                IPAddresses      = @('8.8.8.8', '8.8.4.4')
                UseRootHint      = $false
                DependsOn = @("[WindowsFeature]DNS", "[xADDomainController]NextDC")
            }            

            PendingReboot RebootAfterInstallingAD
            {
                Name = 'RebootAfterInstallingAD'
                DependsOn = @("[xADDomainController]NextDC","[xDnsServerForwarder]SetForwarders")
            }            
        }        
    }
}

Configuration RDWebGateway
{
    Param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [Array]$RDSParameters
    )

    $DomainName = $RDSParameters[0].DomainName
    $DNSServer = $RDSParameters[0].DNSServer
    $TimeZoneID = $RDSParameters[0].TimeZoneID
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xNetworking,ActiveDirectoryDsc,ComputerManagementDSC,xComputerManagement,xWebAdministration,NetworkingDsc
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)",$Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {    
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        WindowsFeature RDS-Gateway
        {
            Ensure = "Present"
            Name = "RDS-Gateway"
        }

        WindowsFeature RDS-Web-Access
        {
            Ensure = "Present"
            Name = "RDS-Web-Access"
        }

        WindowsFeature RSAT-AD-PowerShell
        {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = $TimeZoneID
        }

        Firewall EnableSMBFwRule
        {
            Name = "FPS-SMB-In-TCP"
            Enabled = $True
            Ensure = "Present"
        }        
        
        xIISMimeTypeMapping ConfigureMIME
        {
            Extension = "."
            MimeType = "text/plain"
            ConfigurationPath = "IIS:\sites\Default Web Site"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]RDS-Web-Access"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
        }

        WaitForADDomain WaitADDomain
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            WaitTimeout = 2400
            RestartCount = 30
            WaitForValidCredentials = $True
            DependsOn = @("[xDnsServerAddress]DnsServerAddress","[WindowsFeature]RSAT-AD-PowerShell")
        }

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[WaitForADDomain]WaitADDomain" 
        }
    }
}

Configuration RDSessionHost
{
    Param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [Array]$RDSParameters
    )

    $DomainName = $RDSParameters[0].DomainName
    $DNSServer = $RDSParameters[0].DNSServer
    $TimeZoneID = $RDSParameters[0].TimeZoneID
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xNetworking,ActiveDirectoryDsc,ComputerManagementDSC,xComputerManagement,NetworkingDsc
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)",$Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }

        WindowsFeature RSAT-AD-PowerShell
        {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = $TimeZoneID
        }
        
        Firewall EnableSMBFwRule
        {
            Name = "FPS-SMB-In-TCP"
            Enabled = $True
            Ensure = "Present"
        }        

        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
        }

        WaitForADDomain WaitADDomain
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            WaitTimeout = 2400
            RestartCount = 30
            WaitForValidCredentials = $True
            DependsOn = @("[xDnsServerAddress]DnsServerAddress","[WindowsFeature]RSAT-AD-PowerShell")
        }

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[WaitForADDomain]WaitADDomain" 
        }        
    }    
}

Configuration RDLicenseServer
{
    Param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [Array]$RDSParameters
    )

    $DomainName = $RDSParameters[0].DomainName
    $DNSServer = $RDSParameters[0].DNSServer
    $TimeZoneID = $RDSParameters[0].TimeZoneID
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xNetworking,ActiveDirectoryDsc,ComputerManagementDSC,xComputerManagement,NetworkingDsc
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)",$Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        WindowsFeature RDS-Licensing
        {
            Ensure = "Present"
            Name = "RDS-Licensing"
        }

        WindowsFeature RSAT-AD-PowerShell
        {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = $TimeZoneID
        }

        Firewall EnableSMBFwRule
        {
            Name = "FPS-SMB-In-TCP"
            Enabled = $True
            Ensure = "Present"
        }        

        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
        }

        WaitForADDomain WaitADDomain
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            WaitTimeout = 2400
            RestartCount = 30
            WaitForValidCredentials = $True
            DependsOn = @("[xDnsServerAddress]DnsServerAddress","[WindowsFeature]RSAT-AD-PowerShell")
        }

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[WaitForADDomain]WaitADDomain" 
        }        
    }    
}

Configuration RDSDeployment
{
    Param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [Array]$RDSParameters
    )

    $DomainName = $RDSParameters[0].DomainName
    $DNSServer = $RDSParameters[0].DNSServer
    $TimeZoneID = $RDSParameters[0].TimeZoneID
    $MainConnectionBroker = $($RDSParameters[0].MainConnectionBroker + "." + $DomainName)
    $WebAccessServer = $($RDSParameters[0].WebAccessServer + "." + $DomainName)
    $SessionHost = $($RDSParameters[0].SessionHost + "." + $DomainName)
    $LicenseServer = $($RDSParameters[0].LicenseServer + "." + $DomainName)
    $ExternalFqdn = $RDSParameters[0].ExternalFqdn

    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xNetworking,ActiveDirectoryDsc,ComputerManagementDSC,xComputerManagement,xRemoteDesktopSessionHost,NetworkingDsc
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)",$Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    if (-not $collectionName)         { $collectionName = "RemoteApps" }
    if (-not $collectionDescription)  { $collectionDescription = "Remote Desktop Services Apps" }

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        WindowsFeature RSAT-RDS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Tools"
            IncludeAllSubFeature = $true
        }        

        WindowsFeature RSAT-AD-PowerShell
        {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }

        WindowsFeature RDS-Connection-Broker
        {
            Ensure = "Present"
            Name = "RDS-Connection-Broker"
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = $TimeZoneID
        }        

        Firewall EnableSMBFwRule
        {
            Name = "FPS-SMB-In-TCP"
            Enabled = $True
            Ensure = "Present"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
        }

        WaitForADDomain WaitADDomain
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            WaitTimeout = 2400
            RestartCount = 30
            WaitForValidCredentials = $True
            DependsOn = @("[xDnsServerAddress]DnsServerAddress","[WindowsFeature]RSAT-AD-PowerShell")
        }

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[WaitForADDomain]WaitADDomain" 
        }

        Registry RdmsEnableUILog
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDMS"
            ValueName = "EnableUILog"
            ValueType = "Dword"
            ValueData = "1"
        }
 
        Registry EnableDeploymentUILog
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDMS"
            ValueName = "EnableDeploymentUILog"
            ValueType = "Dword"
            ValueData = "1"
        }
 
        Registry EnableTraceLog
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDMS"
            ValueName = "EnableTraceLog"
            ValueType = "Dword"
            ValueData = "1"
        }
 
        Registry EnableTraceToFile
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDMS"
            ValueName = "EnableTraceToFile"
            ValueType = "Dword"
            ValueData = "1"
        }

        If ($($Env:COMPUTERNAME) -eq $($RDSParameters[0].MainConnectionBroker)) {
            xRDSessionDeployment Deployment
            {
                ConnectionBroker = $MainConnectionBroker
                WebAccessServer = $WebAccessServer
                SessionHost = $SessionHost
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xComputer]DomainJoin"
            }

            xRDServer AddLicenseServer
            {
                Role = 'RDS-Licensing'
                Server = $LicenseServer
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xRDSessionDeployment]Deployment"
            }
            
            xRDLicenseConfiguration LicenseConfiguration
            {
                ConnectionBroker = $MainConnectionBroker
                LicenseServer = $LicenseServer
                LicenseMode = 'PerUser'
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xRDServer]AddLicenseServer"
            }
                
            xRDServer AddGatewayServer
            {
                Role = 'RDS-Gateway'
                Server = $WebAccessServer
                GatewayExternalFqdn = $ExternalFqdn
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xRDLicenseConfiguration]LicenseConfiguration"
            }

            xRDGatewayConfiguration GatewayConfiguration
            {
                ConnectionBroker = $MainConnectionBroker
                GatewayServer = $WebAccessServer
                ExternalFqdn = $ExternalFqdn
                GatewayMode = 'Custom'
                LogonMethod = 'Password'
                UseCachedCredentials = $true
                BypassLocal = $false
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xRDServer]AddGatewayServer"
            }
            
            xRDSessionCollection Collection
            {
                ConnectionBroker = $MainConnectionBroker
                CollectionName = $CollectionName
                CollectionDescription = $CollectionDescription
                SessionHost = $SessionHost
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xRDGatewayConfiguration]GatewayConfiguration"
            }
        }
    }
}
