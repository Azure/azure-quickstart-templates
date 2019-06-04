configuration Configuration
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,
        [Parameter(Mandatory)]
        [String]$DCName,
        [Parameter(Mandatory)]
        [String]$DPMPName,
        [Parameter(Mandatory)]
        [String]$ClientName,
        [Parameter(Mandatory)]
        [String]$PSName,
        [Parameter(Mandatory)]
        [String]$DNSIPAddress,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds
    )
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName TemplateHelpDSC
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName ComputerManagementDsc

    $LogFolder = "TempLog"
    $LogPath = "c:\$LogFolder"
    $DName = $DomainName.Split(".")[0]
    $DCComputerAccount = "$DName\$DCName$"
    $PSComputerAccount = "$DName\$PSName$"

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    $PrimarySiteName = $PSName.split(".")[0] + "$"

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        SetDNS DnsServerAddress
        {
            DNSIPAddress = $DNSIPAddress
            Ensure = "Present"
        }

        WaitForDomainReady WaitForDomain
        {
            Ensure = "Present"
            DCName = $DCName
            DependsOn = "[SetDNS]DnsServerAddress"
        }

        WindowsFeature Rdc
        {             
            Ensure = "Present"             
            Name = "Rdc"             
        }

        Firewall EnableBuiltInFirewallRule
        {
            Name = 'Windows Management Instrumentation (WMI)'
            Ensure = 'Present'
            Enabled = 'True'
            DependsOn = "[Computer]JoinDomain"
        }

        Firewall EnableBuiltInFirewallRule1
        {
            Name = 'File and Printer Sharing'
            Ensure = 'Present'
            Enabled = 'True'
            DependsOn = "[Computer]JoinDomain"
        }


        Computer JoinDomain
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds # Credential to join to domain
            DependsOn = "[WaitForDomainReady]WaitForDomain"
        }

        WaitForConfigurationFile WaitForPSJoinDomain
        {
            Role = "DC"
            MachineName = $DCName
            LogFolder = $LogFolder
            ReadNode = "PSJoinDomain"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

        File ShareFolder
        {            
            DestinationPath = $LogPath     
            Type = 'Directory'            
            Ensure = 'Present'
            DependsOn = "[WaitForConfigurationFile]WaitForPSJoinDomain"
        }

        xSmbShare DomainSMBShare
        {
            Ensure = "Present"
            Name   = $LogFolder
            Path = $LogPath
            ReadAccess = @($DCComputerAccount,$PSComputerAccount)
            Description = "This is a test SMB Share"
            DependsOn = "[File]ShareFolder"
        }

        Firewall TCPInbound
        { 
            Name = 'TCPInboundInbound' 
            DisplayName = 'TCPInbound Inbound' 
            Group = 'For SCCM Client' 
            Ensure = 'Present' 
            Enabled = 'True' 
            Profile = ('Domain', 'Private') 
            Direction = 'Inbound' 
            LocalPort = ('2701') 
            Protocol = 'TCP' 
            Description = 'TCPInbound Inbound'
            DependsOn = "[Computer]JoinDomain"
        }

        Firewall TCPOutbound
        { 
            Name = 'TCPOutbound' 
            DisplayName = 'TCP Outbound' 
            Group = 'For SCCM Client' 
            Ensure = 'Present' 
            Enabled = 'True' 
            Profile = ('Domain', 'Private') 
            Direction = 'Outbound' 
            LocalPort = ('80','443','2701','8530','8531','10123') 
            Protocol = 'TCP' 
            Description = 'TCP Inbound'
            DependsOn = "[Computer]JoinDomain"
        }

        Firewall UDPOutbound
        { 
            Name = 'UDPOutbound' 
            DisplayName = 'UDP Outbound' 
            Group = 'For SCCM Client' 
            Ensure = 'Present' 
            Enabled = 'True' 
            Profile = ('Domain', 'Private') 
            Direction = 'Outbound' 
            LocalPort = ('9','25536') 
            Protocol = 'UDP' 
            Description = 'HTTP(S) Inbound'
            DependsOn = "[Computer]JoinDomain"
        }

        Group AddADUserToLocalAdminGroup {
            GroupName='Administrators'
            Ensure= 'Present'
            MembersToInclude= @("${DomainName}\$($Admincreds.UserName)","${DomainName}\$PrimarySiteName")
            DependsOn = "[xSmbShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteClientFinished
        {
            Role = "Client"
            LogPath = $LogPath
            WriteNode = "ClientFinished"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[Group]AddADUserToLocalAdminGroup"
        }
    }
}