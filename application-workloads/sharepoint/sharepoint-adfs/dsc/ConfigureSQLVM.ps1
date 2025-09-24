configuration ConfigureSQLVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServerIP,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SqlSvcCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 10.0.0 # Custom
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.0.0
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.6.2
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 17.0.0 # Custom workaround on SqlSecureConnection
    Import-DscResource -ModuleName CertificateDsc -ModuleVersion 6.0.0

    WaitForSqlSetup
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object InterfaceDescription -Like "Microsoft Hyper-V Network Adapter*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    
    # Format credentials to be qualified by domain name: "domain\username"
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("$DomainNetbiosName\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SQLCredsQualified = New-Object PSCredential ("${DomainNetbiosName}\$($SqlSvcCreds.UserName)", $SqlSvcCreds.Password)
    [String] $ComputerName = Get-Content env:computername
    [String] $AdfsDnsEntryName = "adfs"

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        #**********************************************************
        # Initialization of VM - Do as much work as possible before waiting on AD domain to be available
        #**********************************************************
        WindowsFeature AddADTools      { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature AddADPowerShell { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        
        DnsServerAddress SetDNS { Address = $DNSServerIP; InterfaceAlias = $InterfaceAlias; AddressFamily  = 'IPv4' }
        

        Script EnableFileSharing {
            GetScript  = { }
            TestScript = { return $null -ne (Get-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -ErrorAction SilentlyContinue | Where-Object { $_.Profile -eq "Domain" }) }
            SetScript  = { Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Domain }
        }

        Script EnableRemoteEventViewerConnection {
            GetScript  = { }
            TestScript = { return $null -ne (Get-NetFirewallRule -DisplayGroup "Remote Event Log Management" -Enabled True -ErrorAction SilentlyContinue | Where-Object { $_.Profile -eq "Domain" }) }
            SetScript  = { Set-NetFirewallRule -DisplayGroup "Remote Event Log Management" -Enabled True -Profile Domain }
        }

        #**********************************************************
        # Join AD forest
        #**********************************************************
        # DNS record for ADFS is created only after the ADFS farm was created and DC restarted (required by ADFS setup)
        # This turns out to be a very reliable way to ensure that VM joins AD only when the DC is guaranteed to be ready
        # This totally eliminates the random errors that occurred in WaitForADDomain with the previous logic (and no more need of WaitForADDomain)
        Script WaitForADFSFarmReady
        {
            SetScript =
            {
                $dnsRecordFQDN = "$($using:AdfsDnsEntryName).$($using:DomainFQDN)"
                $dnsRecordFound = $false
                $sleepTime = 15
                do {
                    try {
                        [Net.DNS]::GetHostEntry($dnsRecordFQDN)
                        $dnsRecordFound = $true
                    }
                    catch [System.Net.Sockets.SocketException] {
                        # GetHostEntry() throws SocketException "No such host is known" if DNS entry is not found
                        Write-Verbose -Verbose -Message "DNS record '$dnsRecordFQDN' not found yet: $_"
                        Start-Sleep -Seconds $sleepTime
                    }
                } while ($false -eq $dnsRecordFound)
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { try { [Net.DNS]::GetHostEntry("$($using:AdfsDnsEntryName).$($using:DomainFQDN)"); return $true } catch { return $false } }
            DependsOn            = "[DnsServerAddress]SetDNS"
        }

        # # If WaitForADDomain does not find the domain whtin "WaitTimeout" secs, it will signar a restart to DSC engine "RestartCount" times
        # WaitForADDomain WaitForDCReady
        # {
        #     DomainName              = $DomainFQDN
        #     WaitTimeout             = 1800
        #     RestartCount            = 2
        #     WaitForValidCredentials = $True
        #     Credential              = $DomainAdminCredsQualified
        #     DependsOn               = "[Script]WaitForADFSFarmReady"
        # }

        # # WaitForADDomain sets reboot signal only if WaitForADDomain did not find domain within "WaitTimeout" secs
        # PendingReboot RebootOnSignalFromWaitForDCReady
        # {
        #     Name             = "RebootOnSignalFromWaitForDCReady"
        #     SkipCcmClientSDK = $true
        #     DependsOn        = "[WaitForADDomain]WaitForDCReady"
        # }

        Computer JoinDomain
        {
            Name       = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainAdminCredsQualified
            # DependsOn  = "[PendingReboot]RebootOnSignalFromWaitForDCReady"
            DependsOn  = "[Script]WaitForADFSFarmReady"
        }

        PendingReboot RebootOnSignalFromJoinDomain
        {
            Name             = "RebootOnSignalFromJoinDomain"
            SkipCcmClientSDK = $true
            DependsOn        = "[Computer]JoinDomain"
        }

        #**********************************************************
        # Create accounts and configure SQL Server
        #**********************************************************
        # By default, SPNs MSSQLSvc/SQL.contoso.local:1433 and MSSQLSvc/SQL.contoso.local are set on the machine account
        # They need to be removed before they can be set on the SQL service account
        Script RemoveSQLSpnOnSQLMachine
        {
            GetScript = { }
            TestScript = { return $false }
            SetScript = 
            {
                $hostname = $using:ComputerName
                $domainFQDN = $using:DomainFQDN
                setspn -D "MSSQLSvc/$hostname.$($domainFQDN)" "$hostname"
                setspn -D "MSSQLSvc/$hostname.$($domainFQDN):1433" "$hostname"
            }
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        ADUser CreateSqlSvcAccount
        {
            DomainName           = $DomainFQDN
            UserName             = $SqlSvcCreds.UserName
            UserPrincipalName    = "$($SqlSvcCreds.UserName)@$DomainFQDN"
            Password             = $SQLCredsQualified
            PasswordNeverExpires = $true
            ServicePrincipalNames = @("MSSQLSvc/$ComputerName.$($DomainFQDN):1433", "MSSQLSvc/$ComputerName.$DomainFQDN", "MSSQLSvc/$($ComputerName):1433", "MSSQLSvc/$ComputerName")
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Script]RemoveSQLSpnOnSQLMachine"
        }

        Script EnsureSQLServiceStarted
        {
            GetScript = { }
            TestScript = { return (Get-Service -Name "MSSQLSERVER").Status -like 'Running' }
            SetScript = { Start-Service -Name "MSSQLSERVER" }
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        SqlMaxDop ConfigureMaxDOP { ServerName = $ComputerName; InstanceName = "MSSQLSERVER"; MaxDop = 1; DependsOn = "[Script]EnsureSQLServiceStarted" }

        # Script WorkaroundErrorInSqlServiceAccountResource
        # {
        #     GetScript = { }
        #     TestScript = { return $false }
        #     SetScript = { 
        #         [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
        #         $mc = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
        #     }
        #     DependsOn      = "[Script]EnsureSQLServiceStarted", "[ADUser]CreateSqlSvcAccount"
        #     PsDscRunAsCredential = $DomainAdminCredsQualified
        # }

        SqlServiceAccount SetSqlInstanceServiceAccount
        {
            ServerName     = $ComputerName
            InstanceName   = "MSSQLSERVER"
            ServiceType    = "DatabaseEngine"
            ServiceAccount = $SQLCredsQualified
            RestartService = $true
            DependsOn      = "[Script]EnsureSQLServiceStarted", "[ADUser]CreateSqlSvcAccount"
            # DependsOn      = "[Script]WorkaroundErrorInSqlServiceAccountResource"
        }

        SqlLogin AddDomainAdminLogin
        {
            Name         = "${DomainNetbiosName}\$($DomainAdminCreds.UserName)"
            Ensure       = "Present"
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            LoginType    = "WindowsUser"
            DependsOn    = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        ADUser CreateSPSetupAccount
        {   # Both SQL and SharePoint DSCs run this SPSetupAccount AD account creation
            DomainName           = $DomainFQDN
            UserName             = $SPSetupCreds.UserName
            UserPrincipalName    = "$($SPSetupCreds.UserName)@$DomainFQDN"
            Password             = $SPSetupCreds
            PasswordNeverExpires = $true
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        SqlLogin AddSPSetupLogin
        {
            Name         = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            Ensure       = "Present"
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            LoginType    = "WindowsUser"
            DependsOn    = "[ADUser]CreateSPSetupAccount"
        }

        SqlRole GrantSQLRoleSysadmin
        {
            ServerRoleName   = "sysadmin"
            MembersToInclude = @("${DomainNetbiosName}\$($DomainAdminCreds.UserName)")
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddDomainAdminLogin"
        }

        SqlRole GrantSQLRoleSecurityAdmin
        {
            ServerRoleName   = "securityadmin"
            MembersToInclude = @("${DomainNetbiosName}\$($SPSetupCreds.UserName)")
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddSPSetupLogin"
        }

        SqlRole GrantSQLRoleDBCreator
        {
            ServerRoleName   = "dbcreator"
            MembersToInclude = @("${DomainNetbiosName}\$($SPSetupCreds.UserName)")
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddSPSetupLogin"
        }

        # Since SharePointDsc 4.4.0, SPFarm "Switched from creating a Lock database to a Lock table in the TempDB. This to allow the use of precreated databases."
        # But for this to work, the SPSetup account needs specific permissions on both the tempdb and the dbo schema
        SqlDatabaseUser AddSPSetupUserToTempdb
        {
            ServerName           = $ComputerName
            InstanceName         = "MSSQLSERVER"
            DatabaseName         = "tempdb"
            UserType             = 'Login'
            Name                 = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            LoginName            = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            DependsOn            = "[SqlLogin]AddSPSetupLogin"
        }

        # Reference: https://learn.microsoft.com/en-us/sql/t-sql/statements/grant-schema-permissions-transact-sql?view=sql-server-ver16
        SqlDatabasePermission GrantPermissionssToTempdb
        {
            Name                 = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            ServerName           =  $ComputerName
            InstanceName         = "MSSQLSERVER"
            DatabaseName         = "tempdb"
            Permission   = @(
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @('Select', 'CreateTable', 'Execute', 'DELETE', 'INSERT', 'UPDATE')
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
            )
            DependsOn            = "[SqlDatabaseUser]AddSPSetupUserToTempdb"
        }

        SqlDatabaseObjectPermission GrantPermissionssToDboSchema
        {
            Name                 = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            ServerName           = $ComputerName
            InstanceName         = "MSSQLSERVER"
            DatabaseName         = "tempdb"
            SchemaName           = "dbo"
            ObjectName           = ""
            ObjectType           = "Schema"
            Permission           = @(
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = "Select"
                }
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = "Update"
                }
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = "Insert"
                }
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = "Execute"
                }
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = "Control"
                }
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = "References"
                }
            )
            DependsOn            = "[SqlDatabaseUser]AddSPSetupUserToTempdb"
        }

        # SqlDatabaseRole 'GrantPermissionsToTempdb'
        # {
        #     ServerName           = $ComputerName
        #     InstanceName         = "MSSQLSERVER"
        #     DatabaseName         = "tempdb"
        #     Name                 = "db_owner"
        #     Ensure               = "Present"
        #     MembersToInclude     = @("${DomainNetbiosName}\$($SPSetupCreds.UserName)")
        #     PsDscRunAsCredential = $SqlAdministratorCredential
        #     DependsOn            = "[SqlLogin]AddSPSetupLogin"
        # }

        # Update GPO to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\", otherwise certificate request will fail
        # $DCServerName = Get-ADDomainController | Select-Object -First 1 -Expand Name
        $DCServerName = "DC"
        Script UpdateGPOToTrustRootCACert {
            SetScript            =
            {
                gpupdate.exe /force
            }
            GetScript            = { }
            TestScript           = 
            {
                $domainNetbiosName = $using:DomainNetbiosName
                $dcName = $using:DCServerName
                $rootCAName = "$domainNetbiosName-$dcName-CA"
                $cert = Get-ChildItem -Path "cert:\LocalMachine\Root\" -DnsName "$rootCAName"
                
                if ($null -eq $cert) {
                    return $false   # Run SetScript
                }
                else {
                    return $true    # Root CA already present
                }
            }
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        CertReq GenerateSQLServerCertificate {
            CARootName          = "$DomainNetbiosName-$DCServerName-CA"
            CAServerFQDN        = "$DCServerName.$DomainFQDN"
            Subject             = "$ComputerName.$DomainFQDN"
            FriendlyName        = "SQL Server Certificate"
            KeyLength           = '2048'
            Exportable          = $true
            SubjectAltName      = "dns=$ComputerName.$DomainFQDN&dns=$ComputerName"
            ProviderName        = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                 = '1.3.6.1.5.5.7.3.1'
            KeyUsage            = 'CERT_KEY_ENCIPHERMENT_KEY_USAGE | CERT_DIGITAL_SIGNATURE_KEY_USAGE'
            CertificateTemplate = 'WebServer'
            AutoRenew           = $true
            Credential          = $DomainAdminCredsQualified
            DependsOn           = '[Script]UpdateGPOToTrustRootCACert'
        }

        $sqlsvcUserName = $SQLCredsQualified.UserName
        Script GrantSqlsvcFullControlToPrivateKey {
            SetScript            = 
            {
                $subjectName = "CN=$($using:ComputerName).$($using:DomainFQDN)"
                $sqlsvcUserName = $using:sqlsvcUserName

                # Grant access to the certificate private key.
                $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq $subjectName }
                $rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
                $fileName = $rsaCert.key.UniqueName
                $path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\RSA\MachineKeys\$fileName"
                $permissions = Get-Acl -Path $path
                $access_rule = New-Object System.Security.AccessControl.FileSystemAccessRule($sqlsvcUserName, 'FullControl', 'None', 'None', 'Allow')
                $permissions.AddAccessRule($access_rule)
                Set-Acl -Path $path -AclObject $permissions
            }
            GetScript            =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript           = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                return $false
            }
            DependsOn            = "[CertReq]GenerateSQLServerCertificate"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        # $subjectName = "CN=SQL.contoso.local"
        # $sqlServerEncryptionCertThumbprint = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=$ComputerName.$DomainFQDN" } | Select-Object -Expand Thumbprint
        SqlSecureConnection EnableSecureConnection
        {
            InstanceName    = 'MSSQLSERVER'
            Thumbprint      = "CN=SQL.contoso.local"
            ForceEncryption = $false
            Ensure          = 'Present'
            ServiceAccount  = $SqlSvcCreds.UserName
            ServerName      = "$ComputerName.$DomainFQDN"
            DependsOn       = '[Script]GrantSqlsvcFullControlToPrivateKey'
        }

        # Open port on the firewall only when everything is ready, as SharePoint DSC is testing it to start creating the farm
        Firewall AddDatabaseEngineFirewallRule
        {
            Direction   = "Inbound"
            Name        = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group       = "SQL Server"
            Enabled     = "True"
            Protocol    = "TCP"
            LocalPort   = "1433"
            Ensure      = "Present"
        }
    }
}

function Get-NetBIOSName
{
    [OutputType([string])]
    param(
        [string]$DomainFQDN
    )

    if ($DomainFQDN.Contains('.')) {
        $length=$DomainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainFQDN.Substring(0,$length)
    }
    else {
        if ($DomainFQDN.Length -gt 15) {
            return $DomainFQDN.Substring(0,15)
        }
        else {
            return $DomainFQDN
        }
    }
}

function WaitForSqlSetup
{
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true)
    {
        try
        {
            Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Start-Sleep -Seconds 5
        }
        catch
        {
            break
        }
    }
}



<#
$password = ConvertTo-SecureString -String "mytopsecurepassword" -AsPlainText -Force
$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$DNSServerIP = "10.1.1.4"
$DomainFQDN = "contoso.local"

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.5\DSCWork\ConfigureSQLVM.0\ConfigureSQLVM"
ConfigureSQLVM -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DomainAdminCreds $DomainAdminCreds -SqlSvcCreds $SqlSvcCreds -SPSetupCreds $SPSetupCreds -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>
