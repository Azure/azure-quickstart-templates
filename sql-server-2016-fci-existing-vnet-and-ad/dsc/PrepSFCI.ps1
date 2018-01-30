configuration PrepSFCI
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$svcCreds,
        
        [String]$DomainNetbiosName = (Get-NetBIOSName -DomainName $DomainName),

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    )

    Import-DscResource -ModuleName xComputerManagement, xActiveDirectory, xSQLServer, xPendingReboot, xNetworking

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    
    [System.Management.Automation.PSCredential]$ServiceCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($svcCreds.UserName)", $svcCreds.Password)
    [System.Management.Automation.PSCredential]$ServiceFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($svcCreds.UserName)", $svcCreds.Password)
    
    Node localhost
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager {
            DebugMode          = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }

        WindowsFeature FC {
            Name   = "Failover-Clustering"
            Ensure = "Present"
        }

        WindowsFeature FCPS {
            Name   = "RSAT-Clustering-PowerShell"
            Ensure = "Present"
        }

        WindowsFeature ADPS {
            Name   = "RSAT-AD-PowerShell"
            Ensure = "Present"
        }

        WindowsFeature FS {
            Name   = "FS-FileServer"
            Ensure = "Present"
        }

        xWaitForADDomain DscForestWait
        { 
            DomainName       = $DomainName 
            DomainUserCredential= $DomainCreds
            RetryCount       = $RetryCount 
            RetryIntervalSec = $RetryIntervalSec 
            DependsOn        = "[WindowsFeature]ADPS"
        }

        xComputer DomainJoin
        {
            Name       = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn  = "[xWaitForADDomain]DscForestWait"
        }

        Script CleanSQL {
            SetScript  = 'C:\SQLServerFull\Setup.exe /Action=Uninstall /FEATURES=SQL,AS,IS,RS /INSTANCENAME=MSSQLSERVER /Q'
            TestScript = '(test-path -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\master.mdf") -eq $false'
            GetScript  = '@{Ensure = if ((test-path -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\master.mdf") -eq $false) {"Present"} Else {"Absent"}}'
            DependsOn  = "[xComputer]DomainJoin"
        }

        xPendingReboot Reboot1
        { 
            Name      = "Reboot1"
            DependsOn = "[Script]CleanSQL"
        }

        xSQLServerFailoverClusterSetup PrepareMSSQLSERVER
        {
            DependsOn                  = "[xPendingReboot]Reboot1"
            Action                     = "Prepare"
            SourcePath                 = "C:\"
            SourceFolder               = "SQLServerFull"
            UpdateSource               = ""
            SetupCredential            = $DomainCreds
            Features                   = "SQLENGINE,AS"
            InstanceName               = "MSSQLSERVER"
            FailoverClusterNetworkName = "SQLFCI"
            SQLSvcAccount              = $ServiceCreds
        }

        xFirewall SQLFirewall
        {
            Name        = "SQL Firewall Rule"
            DisplayName = "SQL Firewall Rule"
            Ensure      = "Present"
            Enabled     = "True"
            Profile     = ("Domain", "Private", "Public")
            Direction   = "Inbound"
            RemotePort  = "Any"
            LocalPort   = ("445", "1433", "37000", "37001")
            Protocol    = "TCP"
            Description = "Firewall Rule for SQL"
            DependsOn   = "[xSQLServerFailoverClusterSetup]PrepareMSSQLSERVER"
        }

        xPendingReboot Reboot2
        { 
            Name      = 'Reboot2'
            DependsOn = "[xFirewall]SQLFirewall"
        }

    }
}

function Get-NetBIOSName { 
    [OutputType([string])]
    param(
        [string]$DomainName
    )

    if ($DomainName.Contains('.')) {
        $length = $DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length = 15
        }
        return $DomainName.Substring(0, $length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            return $DomainName.Substring(0, 15)
        }
        else {
            return $DomainName
        }
    }
} 