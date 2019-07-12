configuration ConfigureSqlServer 
{ 
    param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    ) 
    
    Import-DscResource -ModuleName xSqlServer, xNetworking
    [System.Management.Automation.PSCredential] $DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    $ComputerName = Get-Content env:computername

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainName)

    Node localhost
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        xFirewall DatabaseEngineFirewallRule {
            Direction   = "Inbound"
            Name        = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group       = "SQL Server"
            Enabled     = "True"
            Action      = "Allow"
            Protocol    = "TCP"
            LocalPort   = "1433"
            Ensure      = "Present"
        }

        xSqlServerLogin CreateDomainAdminLogin {
            Name            = "${DomainNetbiosName}\$($Admincreds.UserName)"
            Ensure          = "Present"
            LoginType       = "WindowsUser"
            SQLServer       = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
        }

        xSQLServerRole GrantDomainAdminSysadmin {
            ServerRoleName   = "sysadmin"
            MembersToInclude = "${DomainNetbiosName}\$($Admincreds.UserName)"
            Ensure           = "Present"
            SQLServer        = $ComputerName
            SQLInstanceName  = "MSSQLSERVER"
            DependsOn        = "[xSQLServerLogin]CreateDomainAdminLogin"
        }
    }
} 

function Get-NetBIOSName {
    [OutputType([string])]
    param(
        [string]$DomainFQDN
    )

    if ($DomainFQDN.Contains('.')) {
        $length = $DomainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length = 15
        }

        return $DomainFQDN.Substring(0, $length)
    }
    else {
        if ($DomainFQDN.Length -gt 15) {
            return $DomainFQDN.Substring(0, 15)
        }
        else {
            return $DomainFQDN
        }
    }
}