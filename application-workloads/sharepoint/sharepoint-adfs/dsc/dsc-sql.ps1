configuration ConfigSql
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServerIP,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [String]$SPSetupUserName,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SqlSvcCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 10.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.1.0
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.7.1
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 17.5.1 # Custom workaround on SqlSecureConnection
    Import-DscResource -ModuleName CertificateDsc -ModuleVersion 6.0.0

    WaitForSqlSetup
    [String] $InterfaceAlias = (Get-NetAdapter | Where-Object InterfaceDescription -Like "Microsoft Hyper-V Network Adapter*" | Select-Object -First 1).Name
    [String] $ComputerName = Get-Content env:computername
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    [String] $DomainLDAPPath = "DC=$($DomainFQDN.Split(".")[0]),DC=$($DomainFQDN.Split(".")[1])"
    [String] $DCServerName = "DC"
    [String] $AdfsDnsEntryName = "adfs"
    
    # Format username as user@contoso.local to workaround issue https://github.com/dsccommunity/ComputerManagementDsc/issues/413
    [System.Management.Automation.PSCredential] $DomainAdminCredsToJoinDomain = New-Object System.Management.Automation.PSCredential ("$($DomainAdminCreds.UserName)@$($DomainFQDN)", $DomainAdminCreds.Password)
    # Format credentials to be qualified by domain name: "domain\username"
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("$($DomainNetbiosName)\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SQLCredsQualified = New-Object PSCredential ("$($DomainNetbiosName)\$($SqlSvcCreds.UserName)", $SqlSvcCreds.Password)
    [String] $SqlSvcUserNameQualified = "$($DomainNetbiosName)\$($SqlSvcCreds.UserName)"
    [String] $SPSetupUserNameQualified = "$($DomainNetbiosName)\$SPSetupUserName"

    Node localhost
    {
        LocalConfigurationManager {
            ConfigurationMode  = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        #**********************************************************
        # Initialization of VM - Do as much work as possible before waiting on AD domain to be available
        #**********************************************************
        DnsServerAddress SetDNS { Address = $DNSServerIP; InterfaceAlias = $InterfaceAlias; AddressFamily = 'IPv4' }

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
        # This totally eliminates the random errors that occured in WaitForADDomain with the previous logic (and no more need of WaitForADDomain)
        Script WaitForADFSFarmReady {
            SetScript  =
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
                } while (-not $dnsRecordFound)
            }
            GetScript  = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript = { try { [Net.DNS]::GetHostEntry("$($using:AdfsDnsEntryName).$($using:DomainFQDN)"); return $true } catch { return $false } }
            DependsOn  = "[DnsServerAddress]SetDNS"
        }

        Computer JoinDomain {
            Name       = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainAdminCredsToJoinDomain
            DependsOn  = "[Script]WaitForADFSFarmReady"
        }

        PendingReboot RebootOnSignalFromJoinDomain {
            Name             = "RebootOnSignalFromJoinDomain"
            SkipCcmClientSDK = $true
            DependsOn        = "[Computer]JoinDomain"
        }

        #**********************************************************
        # Create accounts and configure SQL Server
        #**********************************************************
        # By default, SPNs MSSQLSvc/SQL.contoso.local:1433 and MSSQLSvc/SQL.contoso.local are set on the machine account
        # They need to be removed before they can be set on the SQL service account
        Script RemoveSQLSpnOnSQLMachine {
            GetScript            = { return @{ "Result" = "false" } }
            TestScript           = 
            {
                return $false
                # $spn = "MSSQLSvc/$($using:ComputerName).$($using:DomainFQDN)"
                # $computerAccount = Get-ADComputer -Identity $using:ComputerName -Properties ServicePrincipalName -ErrorAction SilentlyContinue
                # if ([bool]($computerAccount.ServicePrincipalName -contains $Spn) -or [bool]($computerAccount.ServicePrincipalName -contains "$($spn):1433")) {
                #     return $false   # SPN still exists on machine account, need to run SetScript to remove it
                # }
                # else {
                #     return $true    # SPN already removed from machine account
                # }
            }
            SetScript            = 
            {
                $computerName = $using:ComputerName
                $spn = "MSSQLSvc/$($using:ComputerName).$($using:DomainFQDN)"
                Write-Verbose -Verbose -Message "Removing SPNs '$spn' and '$($spn):1433' from computer $computerName..."
                setspn -D "$spn" "$computerName"
                setspn -D "$($spn):1433" "$computerName"

                $targetObject = "$($using:SqlSvcUserNameQualified)"
                Write-Verbose -Verbose -Message "Adding SPNs '$spn' and '$($spn):1433' to '$targetObject'..."
                setspn -U -S "$spn" "$targetObject"
                setspn -U -S "$($spn):1433" "$targetObject"
            }
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        # Allow SQL Server to automatically register the SPN when its service starts
        # Doc: https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/register-a-service-principal-name-for-kerberos-connections?view=sql-server-ver17#automatic-spn-registration
        Script GrantWriteSpnPermissionToSqlSvcOnSQLMachine {
            SetScript            =
            {
                Function Set-SpnPermission {
                    param(
                        [ADSI]$TargetObject,
                        [Security.Principal.IdentityReference]$Identity
                    )
    
                    Write-Verbose -Verbose -Message "Granting delegated permission 'Validated write to service principal name' to '$Identity' on '$($TargetObject.Name)'"
                    # GUID for "Validated write to service principal name"
                    $validateWriteSPNGuid = "f3a64788-5306-11d1-a9c5-0000f80367c1"
                    $activeDirectoryRights = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::Self
                    # Create the ACE (Access Control Entry)
                    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                        $Identity,
                        $activeDirectoryRights,
                        [System.Security.AccessControl.AccessControlType]::Allow,
                        [guid]$validateWriteSPNGuid,
                        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
                    )
                    # Get the AD object and apply the ACE
                    $TargetObject.psBase.ObjectSecurity.AddAccessRule($ace)
                    $TargetObject.psBase.CommitChanges()
                }
                $targetObject = "LDAP://CN=$($using:ComputerName),CN=Computers,$($using:DomainLDAPPath)"
                $identity = [System.Security.Principal.NTAccount] "$($using:SqlSvcUserNameQualified)"
                Set-SpnPermission -TargetObject $targetObject -Identity $identity
            }
            GetScript            = { }
            TestScript           = {
                Function Test-SpnPermission {
                    param(
                        [ADSI]$TargetObject,
                        [Security.Principal.IdentityReference]$Identity
                    )
                        
                    Write-Verbose -Verbose -Message "Checking if delegated permission 'Validated write to service principal name' exists for '$Identity' on '$($TargetObject.Name)'"
                    # GUID for "Validated write to service principal name"
                    $validateWriteSPNGuid = [guid]"f3a64788-5306-11d1-a9c5-0000f80367c1"
                    $expectedRights = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::Self
                    
                    # Get the current ACL
                    $acl = $TargetObject.psBase.ObjectSecurity
                    $accessRules = $acl.GetAccessRules($true, $false, [System.Security.Principal.NTAccount])
                    
                    # Check if the permission already exists
                    foreach ($rule in $accessRules) {
                        if ($rule.IdentityReference -eq $Identity -and
                            ($rule.ActiveDirectoryRights -band $expectedRights) -eq $expectedRights -and
                            $rule.ObjectType -eq $validateWriteSPNGuid -and
                            $rule.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow) {
                            Write-Verbose -Verbose -Message "Permission already exists"
                            return $true
                        }
                    }
                    
                    Write-Verbose -Verbose -Message "Permission does not exist"
                    return $false
                }
                $targetObject = "LDAP://CN=$($using:ComputerName),CN=Computers,$($using:DomainLDAPPath)"
                $identity = [System.Security.Principal.NTAccount] "$($using:SqlSvcUserNameQualified)"
                return Test-SpnPermission -TargetObject $targetObject -Identity $identity
            }
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        SqlServiceAccount SetSqlInstanceServiceAccount {
            ServerName     = $ComputerName
            InstanceName   = "MSSQLSERVER"
            ServiceType    = "DatabaseEngine"
            ServiceAccount = $SQLCredsQualified
            RestartService = $true
            DependsOn      = "[Script]GrantWriteSpnPermissionToSqlSvcOnSQLMachine"
        }

        SqlMaxDop ConfigureMaxDOP {
            ServerName = $ComputerName; InstanceName = "MSSQLSERVER"; MaxDop = 1; DependsOn = "[SqlServiceAccount]SetSqlInstanceServiceAccount" 
        }

        SqlLogin AddDomainAdminLogin {
            Name         = "${DomainNetbiosName}\$($DomainAdminCreds.UserName)"
            Ensure       = "Present"
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            LoginType    = "WindowsUser"
            DependsOn    = "[SqlServiceAccount]SetSqlInstanceServiceAccount" 
        }

        SqlLogin AddSPSetupLogin {
            Name         = $SPSetupUserNameQualified
            Ensure       = "Present"
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            LoginType    = "WindowsUser"
            DependsOn    = "[SqlServiceAccount]SetSqlInstanceServiceAccount" 
        }

        SqlRole GrantSQLRoleSysadmin {
            ServerRoleName   = "sysadmin"
            MembersToInclude = @("${DomainNetbiosName}\$($DomainAdminCreds.UserName)")
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddDomainAdminLogin"
        }

        SqlRole GrantSQLRoleSecurityAdmin {
            ServerRoleName   = "securityadmin"
            MembersToInclude = @($SPSetupUserNameQualified)
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddSPSetupLogin"
        }

        SqlRole GrantSQLRoleDBCreator {
            ServerRoleName   = "dbcreator"
            MembersToInclude = @($SPSetupUserNameQualified)
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddSPSetupLogin"
        }

        # Since SharePointDsc 4.4.0, SPFarm "Switched from creating a Lock database to a Lock table in the TempDB. This to allow the use of precreated databases."
        # But for this to work, the SPSetup account needs specific permissions on both the tempdb and the dbo schema
        SqlDatabaseUser AddSPSetupUserToTempdb {
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            DatabaseName = "tempdb"
            UserType     = 'Login'
            Name         = $SPSetupUserNameQualified
            LoginName    = $SPSetupUserNameQualified
            DependsOn    = "[SqlLogin]AddSPSetupLogin"
        }

        # Reference: https://learn.microsoft.com/en-us/sql/t-sql/statements/grant-schema-permissions-transact-sql?view=sql-server-ver16
        SqlDatabasePermission GrantPermissionssToTempdb {
            Name         = $SPSetupUserNameQualified
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            DatabaseName = "tempdb"
            Permission   = @(
                DatabasePermission {
                    State      = 'Grant'
                    Permission = @('Select', 'CreateTable', 'Execute', 'DELETE', 'INSERT', 'UPDATE')
                }
                DatabasePermission {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                DatabasePermission {
                    State      = 'Deny'
                    Permission = @()
                }
            )
            DependsOn    = "[SqlDatabaseUser]AddSPSetupUserToTempdb"
        }

        SqlDatabaseObjectPermission GrantPermissionssToDboSchema {
            Name         = $SPSetupUserNameQualified
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            DatabaseName = "tempdb"
            SchemaName   = "dbo"
            ObjectName   = ""
            ObjectType   = "Schema"
            Permission   = @(
                DSC_DatabaseObjectPermission {
                    State      = "Grant"
                    Permission = "Select"
                }
                DSC_DatabaseObjectPermission {
                    State      = "Grant"
                    Permission = "Update"
                }
                DSC_DatabaseObjectPermission {
                    State      = "Grant"
                    Permission = "Insert"
                }
                DSC_DatabaseObjectPermission {
                    State      = "Grant"
                    Permission = "Execute"
                }
                DSC_DatabaseObjectPermission {
                    State      = "Grant"
                    Permission = "Control"
                }
                DSC_DatabaseObjectPermission {
                    State      = "Grant"
                    Permission = "References"
                }
            )
            DependsOn    = "[SqlDatabaseUser]AddSPSetupUserToTempdb"
        }

        # SqlDatabaseRole 'GrantPermissionsToTempdb'
        # {
        #     ServerName           = $ComputerName
        #     InstanceName         = "MSSQLSERVER"
        #     DatabaseName         = "tempdb"
        #     Name                 = "db_owner"
        #     Ensure               = "Present"
        #     MembersToInclude     = @($SPSetupUserNameQualified)
        #     PsDscRunAsCredential = $SqlAdministratorCredential
        #     DependsOn            = "[SqlLogin]AddSPSetupLogin"
        # }

        # Update GPOs to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\", otherwise certificate request will fail
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

        Script GrantSqlsvcFullControlToPrivateKey {
            SetScript            = 
            {
                $subjectName = "CN=$($using:ComputerName).$($using:DomainFQDN)"
                $sqlSvcUserNameQualified = $using:SqlSvcUserNameQualified

                # Grant access to the certificate private key.
                $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq $subjectName }
                $rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
                $fileName = $rsaCert.key.UniqueName
                $path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\RSA\MachineKeys\$fileName"
                $permissions = Get-Acl -Path $path
                $access_rule = New-Object System.Security.AccessControl.FileSystemAccessRule($sqlSvcUserNameQualified, 'FullControl', 'None', 'None', 'Allow')
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
        SqlSecureConnection EnableSecureConnection {
            InstanceName    = 'MSSQLSERVER'
            Thumbprint      = "CN=$ComputerName.$DomainFQDN"
            ForceEncryption = $false
            Ensure          = 'Present'
            ServiceAccount  = $SqlSvcCreds.UserName
            ServerName      = "$ComputerName.$DomainFQDN"
            DependsOn       = '[Script]GrantSqlsvcFullControlToPrivateKey'
        }

        # Open port on the firewall only when everything is ready, as SharePoint DSC is testing it to start creating the farm
        Firewall AddDatabaseEngineFirewallRule {
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

function WaitForSqlSetup {
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true) {
        try {
            $taskResult = Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Write-Verbose -Verbose -Message "ScheduledTaskInfo results: LastRunTime: $($taskResult.LastRunTime); LastTaskResult: $($taskResult.LastTaskResult); NextRunTime: $($taskResult.NextRunTime); NumberOfMissedRuns: $($taskResult.NumberOfMissedRuns);"
            Start-Sleep -Seconds 5
        }
        catch {
            break
        }
    }
}

<#
$password = ConvertTo-SecureString -String "mytopsecurepassword" -AsPlainText -Force
$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$DNSServerIP = "10.1.1.100"
$DomainFQDN = "contoso.local"
$SPSetupUserName = "spsetup"

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.5\DSCWork\dsc-sql.0\ConfigSql"
ConfigSql -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DomainAdminCreds $DomainAdminCreds -SqlSvcCreds $SqlSvcCreds -SPSetupUserName $SPSetupUserName -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>
