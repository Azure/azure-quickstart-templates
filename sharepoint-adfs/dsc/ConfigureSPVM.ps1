configuration ConfigureSPVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServer,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [String]$DCName,
        [Parameter(Mandatory)] [String]$SQLName,
        [Parameter(Mandatory)] [String]$SQLAlias,
        [Parameter(Mandatory)] [String]$SharePointVersion,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPFarmCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSvcCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPAppPoolCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSuperUserCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSuperReaderCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc, StorageDsc, NetworkingDsc, xActiveDirectory, xCredSSP, xWebAdministration, SharePointDsc, xPSDesiredStateConfiguration, xDnsServer, CertificateDsc, SqlServerDsc

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [System.Management.Automation.PSCredential] $SPSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSvcCreds.UserName)", $SPSvcCreds.Password)
    [System.Management.Automation.PSCredential] $SPAppPoolCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPAppPoolCreds.UserName)", $SPAppPoolCreds.Password)
    [String] $SPDBPrefix = "SPDSC_"
    [String] $SPTrustedSitesName = "SPSites"
    [Int] $RetryCount = 30
    [Int] $RetryIntervalSec = 30
    [String] $ComputerName = Get-Content env:computername
    [String] $LdapcpLink = (Get-LatestGitHubRelease -Repo "Yvand/LDAPCP" -Artifact "LDAPCP.wsp")
    [String] $ServiceAppPoolName = "SharePoint Service Applications"
    [String] $UpaServiceName = "User Profile Service Application"
    [String] $AppDomainFQDN = (Get-AppDomain -DomainFQDN $DomainFQDN -Suffix "Apps")
    [String] $AppDomainIntranetFQDN = (Get-AppDomain -DomainFQDN $DomainFQDN -Suffix "Apps-Intranet")
    [String] $SetupPath = "C:\Setup"
    [String] $DCSetupPath = "\\$DCName\C$\Setup"
    [String] $MySiteHostAlias = "OhMy"
    [String] $HNSC1Alias = "HNSC1"
    [String] $AddinsSiteCName = "addins"

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        #**********************************************************
        # Initialization of VM
        #**********************************************************
        WindowsFeature ADTools  { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature ADPS     { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        WindowsFeature DnsTools { Name = "RSAT-DNS-Server";    Ensure = "Present"; }
        DnsServerAddress DnsServerAddress { Address = $DNSServer; InterfaceAlias = $InterfaceAlias; AddressFamily  = 'IPv4'; DependsOn ="[WindowsFeature]ADPS" }
        xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[DnsServerAddress]DnsServerAddress" }
        xCredSSP CredSSPClient { Ensure = "Present"; Role = "Client"; DelegateComputers = "*.$DomainFQDN", "localhost"; DependsOn = "[xCredSSP]CredSSPServer" }

        # Properly enable TLS 1.2 as documented in https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/application-proxy-add-on-premises-application
        # It's a best practice, and mandatory with Windows 2012 R2 (SharePoint 2013) to allow xRemoteFile to download releases from GitHub: https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/405           
        Registry EnableTLS12RegKey1
        {
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'DisabledByDefault'
            ValueType = 'Dword'
            ValueData =  '0'
            Ensure    = 'Present'
        }

        Registry EnableTLS12RegKey2
        {
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'Enabled'
            ValueType = 'Dword'
            ValueData =  '1'
            Ensure    = 'Present'
        }

        Registry EnableTLS12RegKey3
        {
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'DisabledByDefault'
            ValueType = 'Dword'
            ValueData =  '0'
            Ensure    = 'Present'
        }

        Registry EnableTLS12RegKey4
        {
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'Enabled'
            ValueType = 'Dword'
            ValueData =  '1'
            Ensure    = 'Present'
        }

        Registry SchUseStrongCrypto
        {
            Key       = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319'
            ValueName = 'SchUseStrongCrypto'
            ValueType = 'Dword'
            ValueData =  '1'
            Ensure    = 'Present'
        }

        <#Registry SchUseStrongCrypto64
        {
            Key                         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319'
            ValueName                   = 'SchUseStrongCrypto'
            ValueType                   = 'Dword'
            ValueData                   =  '1'
            Ensure                      = 'Present'
        }#>

        #**********************************************************
        # Join AD forest
        #**********************************************************
        xWaitForADDomain DscForestWait
        {
            DomainName           = $DomainFQDN
            RetryCount           = $RetryCount
            RetryIntervalSec     = $RetryIntervalSec
            DomainUserCredential = $DomainAdminCredsQualified
            DependsOn            = "[xCredSSP]CredSSPClient"
        }

        Computer DomainJoin
        {
            Name       = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainAdminCredsQualified
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xScript CreateWSManSPNsIfNeeded
        {
            SetScript =
            {
                # A few times, deployment failed because of this error:
                # "The WinRM client cannot process the request. A computer policy does not allow the delegation of the user credentials to the target computer because the computer is not trusted."
                # The root cause was that SPNs WSMAN/SP and WSMAN/sp.contoso.local were missing in computer account contoso\SP
                # Those SPNs are created by WSMan when it (re)starts
                # Restarting service causes an error, so creates SPNs manually instead
                # Restart-Service winrm

                # Create SPNs WSMAN/SP and WSMAN/sp.contoso.local
                $domainFQDN = $using:DomainFQDN
                $computerName = $using:ComputerName
                Write-Verbose -Message "Adding SPNs 'WSMAN/$computerName' and 'WSMAN/$computerName.$domainFQDN' to computer '$computerName'"
                setspn.exe -S "WSMAN/$computerName" "$computerName"
                setspn.exe -S "WSMAN/$computerName.$domainFQDN" "$computerName"
            }
            GetScript = { }
            # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            TestScript = 
            {
                $computerName = $using:ComputerName
                $samAccountName = "$computerName$"
                if ((Get-ADComputer -Filter {(SamAccountName -eq $samAccountName)} -Property serviceprincipalname | Select-Object serviceprincipalname | Where-Object {$_.ServicePrincipalName -like "WSMAN/$computerName"}) -ne $null) {
                    # SPN is present
                    return $true
                }
                else {
                    # SPN is missing and must be created
                    return $false
                }
            }
            DependsOn = "[Computer]DomainJoin"
        }

        #**********************************************************
        # Do some cleanup and preparation for SharePoint
        #**********************************************************
        Registry DisableLoopBackCheck
        {
            Key       = "HKLM:\System\CurrentControlSet\Control\Lsa"
            ValueName = "DisableLoopbackCheck"
            ValueData = "1"
            ValueType = "Dword"
            Ensure    = "Present"
            DependsOn ="[Computer]DomainJoin"
        }

        xDnsRecord AddTrustedSiteDNS
        {
            Name                 = $SPTrustedSitesName
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Computer]DomainJoin"
        }

        xDnsRecord AddMySiteHostDNS
        {
            Name                 = $MySiteHostAlias
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Computer]DomainJoin"
        }

        xDnsRecord AddHNSC1DNS
        {
            Name                 = $HNSC1Alias
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Computer]DomainJoin"
        }

        xWebAppPool RemoveDotNet2Pool         { Name = ".NET v2.0";            Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDotNet2ClassicPool  { Name = ".NET v2.0 Classic";    Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDotNet45Pool        { Name = ".NET v4.5";            Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDotNet45ClassicPool { Name = ".NET v4.5 Classic";    Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveClassicDotNetPool   { Name = "Classic .NET AppPool"; Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDefaultAppPool      { Name = "DefaultAppPool";       Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebSite    RemoveDefaultWebSite      { Name = "Default Web Site";     Ensure = "Absent"; PhysicalPath = "C:\inetpub\wwwroot"; DependsOn = "[Computer]DomainJoin"}

        #**********************************************************
        # Provision required accounts for SharePoint
        #**********************************************************
        xADUser CreateSPSetupAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSetupCreds.UserName
            Password                      = $SPSetupCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[Computer]DomainJoin"
        }        

        xADUser CreateSParmAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPFarmCreds.UserName
            Password                      = $SPFarmCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[Computer]DomainJoin"
        }

        Group AddSPSetupAccountToAdminGroup
        {
            GroupName            = "Administrators"
            Ensure               = "Present"
            MembersToInclude     = @("$($SPSetupCredsQualified.UserName)")
            Credential           = $DomainAdminCredsQualified
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xADUser]CreateSPSetupAccount", "[xADUser]CreateSParmAccount"
        }

        xADUser CreateSPSvcAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSvcCreds.UserName
            Password                      = $SPSvcCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[Computer]DomainJoin"
        }

        xADUser CreateSPAppPoolAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPAppPoolCreds.UserName
            Password                      = $SPAppPoolCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[Computer]DomainJoin"
        }

        xADUser CreateSPSuperUserAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSuperUserCreds.UserName
            Password                      = $SPSuperUserCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[Computer]DomainJoin"
        }

        xADUser CreateSPSuperReaderAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSuperReaderCreds.UserName
            Password                      = $SPSuperReaderCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[Computer]DomainJoin"
        }

        File AccountsProvisioned
        {
            DestinationPath      = "C:\Logs\DSC1.txt"
            Contents             = "AccountsProvisioned"
            Type                 = 'File'
            Force                = $true
            PsDscRunAsCredential = $SPSetupCredential
            DependsOn            = "[Group]AddSPSetupAccountToAdminGroup", "[xADUser]CreateSParmAccount", "[xADUser]CreateSPSvcAccount", "[xADUser]CreateSPAppPoolAccount", "[xADUser]CreateSPSuperUserAccount", "[xADUser]CreateSPSuperReaderAccount"
        }

        #****************************************************************
        # Copy solutions and certificates that will be used in SharePoint
        #****************************************************************
        File CopyCertificatesFromDC
        {
            Ensure          = "Present"
            Type            = "Directory"
            Recurse         = $true
            SourcePath      = "$DCSetupPath"
            DestinationPath = "$SetupPath\Certificates"
            Credential      = $DomainAdminCredsQualified
            DependsOn       = "[File]AccountsProvisioned"
        }

        xRemoteFile DownloadLdapcp
        {
            Uri             = $LdapcpLink
            DestinationPath = "$SetupPath\LDAPCP.wsp"
            DependsOn       = "[File]AccountsProvisioned"
        }

        SqlAlias AddSqlAlias
        {
            Ensure               = "Present"
            Name                 = $SQLAlias
            ServerName           = $SQLName
            Protocol             = "TCP"
            TcpPort              = 1433
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[File]AccountsProvisioned"
        }

        xScript WaitForSQL
        {
            SetScript =
            {
                $retrySleep = $using:RetryIntervalSec
                $server = $using:SQLAlias
                $db="master"
                $retry = $true
                while ($retry) {
                    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection "Data Source=$server;Initial Catalog=$db;Integrated Security=True;Enlist=False;Connect Timeout=3"
                    try {
                        $sqlConnection.Open()
                        Write-Verbose "Connection to SQL Server $server succeeded"
                        $sqlConnection.Close()
                        $retry = $false
                    }
                    catch {
                        Write-Verbose "SQL connection to $server failed, retry in $retrySleep secs..."
                        Start-Sleep -s $retrySleep
                    }
                }
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SqlAlias]AddSqlAlias"
        }

        #**********************************************************
        # Create SharePoint farm
        #**********************************************************
        SPFarm CreateSPFarm
        {
            DatabaseServer            = $SQLAlias
            FarmConfigDatabaseName    = $SPDBPrefix + "Config"
            Passphrase                = $SPPassphraseCreds
            FarmAccount               = $SPFarmCredsQualified
            PsDscRunAsCredential      = $SPSetupCredsQualified
            AdminContentDatabaseName  = $SPDBPrefix + "AdminContent"
            CentralAdministrationPort = 5000
            # If RunCentralAdmin is false and configdb does not exist, SPFarm checks during 30 mins if configdb got created and joins the farm
            RunCentralAdmin           = $true
            IsSingleInstance          = "Yes"
            Ensure                    = "Present"
            DependsOn                 = "[xScript]WaitForSQL"
        }

        xScript RestartSPTimer
        {
            SetScript =
            {
                # Restarting SPTimerV4 service before deploying solution makes deployment a lot more reliable
                Restart-Service SPTimerV4
            }
            GetScript            = { }
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPTrustedRootAuthority TrustRootCA
        {
            Name                 = "$DomainFQDN root CA"
            CertificateFilePath  = "$SetupPath\Certificates\ADFS Signing issuer.cer"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPFarmSolution InstallLdapcp
        {
            LiteralPath          = "$SetupPath\LDAPCP.wsp"
            Name                 = "LDAPCP.wsp"
            Deployed             = $true
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimer"
        }

        SPManagedAccount CreateSPSvcManagedAccount
        {
            AccountName          = $SPSvcCredsQualified.UserName
            Account              = $SPSvcCredsQualified
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPManagedAccount CreateSPAppPoolManagedAccount
        {
            AccountName          = $SPAppPoolCredsQualified.UserName
            Account              = $SPAppPoolCredsQualified
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPDiagnosticLoggingSettings ApplyDiagnosticLogSettings
        {
            LogPath              = "C:\ULS"
            LogSpaceInGB         = 20
            IsSingleInstance     = "Yes"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPStateServiceApp StateServiceApp
        {
            Name                 = "State Service Application"
            DatabaseName         = $SPDBPrefix + "StateService"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPDistributedCacheService EnableDistributedCache
        {
            Name                 = "AppFabricCachingService"
            CacheSizeInMB        = 2000
            CreateFirewallRules  = $true
            ServiceAccount       = $SPSvcCredsQualified.UserName
            InstallAccount       = $SPSetupCredsQualified
            Ensure               = "Present"
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        # Installing LDAPCP somehow updates SPClaimEncodingManager 
        # But in SharePoint 2019 (only), it causes an UpdatedConcurrencyException on SPClaimEncodingManager in SPTrustedIdentityTokenIssuer resource
        # The only solution I've found is to force a reboot in SharePoint 2019
        if ($SharePointVersion -eq "2019") {
            xScript ForceRebootBeforeCreatingSPTrust
            {
                # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
                TestScript = {
                    return (Test-Path HKLM:\SOFTWARE\SPDSCConfigForceRebootKey\RebootRequested)
                }
                SetScript = {
                    New-Item -Path HKLM:\SOFTWARE\SPDSCConfigForceRebootKey\RebootRequested -Force
                    $global:DSCMachineStatus = 1
                }
                GetScript = { }
                PsDscRunAsCredential = $SPSetupCredsQualified
                DependsOn = "[SPFarmSolution]InstallLdapcp"
            }

            PendingReboot RebootBeforeCreatingSPTrust
            {
                Name             = "BeforeCreatingSPTrust"
                SkipCcmClientSDK = $true
                DependsOn        = "[xScript]ForceRebootBeforeCreatingSPTrust"
            }
        }

        SPTrustedIdentityTokenIssuer CreateSPTrust
        {
            Name                         = $DomainFQDN
            Description                  = "Federation with $DomainFQDN"
            Realm                        = "https://$SPTrustedSitesName.$DomainFQDN"
            SignInUrl                    = "https://adfs.$DomainFQDN/adfs/ls/"
            IdentifierClaim              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
            ClaimsMappings               = @(
                MSFT_SPClaimTypeMapping{
                    Name = "Email"
                    IncomingClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
                }
                MSFT_SPClaimTypeMapping{
                    Name = "Role"
                    IncomingClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
                }
            )
            SigningCertificateFilePath   = "$SetupPath\Certificates\ADFS Signing.cer"
            ClaimProviderName            = "LDAPCP"
            #ProviderSignOutUri          = "https://adfs.$DomainFQDN/adfs/ls/"
            UseWReplyParameter           = $true
            Ensure                       = "Present"
            DependsOn                    = "[SPFarmSolution]InstallLdapcp"
            PsDscRunAsCredential         = $SPSetupCredsQualified
        }

        xScript ConfigureLDAPCP
        {
            SetScript = 
            {
                Add-Type -AssemblyName "ldapcp, Version=1.0.0.0, Culture=neutral, PublicKeyToken=80be731bc1a1a740"

				# Create LDAPCP configuration
				$config = [ldapcp.LDAPCPConfig]::CreateConfiguration([ldapcp.ClaimsProviderConstants]::CONFIG_ID, [ldapcp.ClaimsProviderConstants]::CONFIG_NAME, $using:DomainFQDN);

				# Remove unused claim types
				$config.ClaimTypes.Remove("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn")
				$config.ClaimTypes.Remove("http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname")
				$config.ClaimTypes.Remove("http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid")

				# Configure augmentation
				$config.EnableAugmentation = $true
				$config.MainGroupClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
                foreach ($connection in $config.LDAPConnectionsProp) {
                    $connection.EnableAugmentation = $true
                }

				# Save changes
				$config.Update()
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
				Add-Type -AssemblyName "ldapcp, Version=1.0.0.0, Culture=neutral, PublicKeyToken=80be731bc1a1a740"
				$config = [ldapcp.LDAPCPConfig]::GetConfiguration("LDAPCPConfig")
				if ($config -eq $null) {
					return $false
				}
				else {
					return $true
				}
            }
            DependsOn            = "[SPTrustedIdentityTokenIssuer]CreateSPTrust"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        #**********************************************************
        # Service instances are started at the beginning of the deployment to give some time between this and creation of service applications
        # This makes deployment a lot more reliable and avoids errors related to concurrency update of persisted objects, or service instance not found...
        #**********************************************************
        SPServiceAppPool MainServiceAppPool
        {
            Name                 = $ServiceAppPoolName
            ServiceAccount       = $SPSvcCredsQualified.UserName
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance UPAServiceInstance
        {
            Name                 = "User Profile Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance StartSubscriptionSettingsServiceInstance
        {
            Name                 = "Microsoft SharePoint Foundation Subscription Settings Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance StartAppManagementServiceInstance
        {
            Name                 = "App Management Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPWebApplication MainWebApp
        {
            Name                   = "SharePoint - 80"
            ApplicationPool        = "SharePoint - 80"
            ApplicationPoolAccount = $SPAppPoolCredsQualified.UserName
            AllowAnonymous         = $false
            DatabaseName           = $SPDBPrefix + "Content_80"
            WebAppUrl              = "http://$SPTrustedSitesName/"
            Port                   = 80
            Ensure                 = "Present"
            PsDscRunAsCredential   = $SPSetupCredsQualified
            DependsOn              = "[SPFarm]CreateSPFarm"
        }

        # Update GPO to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\" before issuing a certificate request, otherwise request would fail
        xScript UpdateGPOToTrustRootCACert
        {
            SetScript =
            {
                gpupdate.exe /force
            }
            GetScript            = { }
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            DependsOn            = "[Computer]DomainJoin"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        CertReq SPSSiteCert
        {
            CARootName             = "$DomainNetbiosName-$DCName-CA"
            CAServerFQDN           = "$DCName.$DomainFQDN"
            Subject                = "$SPTrustedSitesName.$DomainFQDN"
            SubjectAltName         = "dns=*.$DomainFQDN&dns=*.$AppDomainIntranetFQDN"
            KeyLength              = '2048'
            Exportable             = $true
            ProviderName           = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                    = '1.3.6.1.5.5.7.3.1'
            KeyUsage               = '0xa0'
            CertificateTemplate    = 'WebServer'
            AutoRenew              = $true
            Credential             = $DomainAdminCredsQualified
            DependsOn              = "[xScript]UpdateGPOToTrustRootCACert"
        }

        SPWebApplicationExtension ExtendWebApp
        {
            WebAppUrl              = "http://$SPTrustedSitesName/"
            Name                   = "SharePoint - 443"
            AllowAnonymous         = $false
            Url                    = "https://$SPTrustedSitesName.$DomainFQDN"
            Zone                   = "Intranet"
            UseSSL                 = $true
            Port                   = 443
            Ensure                 = "Present"
            PsDscRunAsCredential   = $SPSetupCredsQualified
            DependsOn              = "[CertReq]SPSSiteCert", "[SPWebApplication]MainWebApp"
        }

        SPWebAppAuthentication ConfigureWebAppAuthentication
        {
            WebAppUrl = "http://$SPTrustedSitesName/"
            Default = @(
                MSFT_SPWebAppAuthenticationMode {
                    AuthenticationMethod = "NTLM"
                }
            )
            Intranet = @(
                MSFT_SPWebAppAuthenticationMode {
                    AuthenticationMethod = "Federated"
                    AuthenticationProvider = $DomainFQDN
                }
            )
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplicationExtension]ExtendWebApp"
        }

        xWebsite SetHTTPSCertificate
        {
            Name                 = "SharePoint - 443"
            BindingInfo          = MSFT_xWebBindingInformation
            {
                Protocol             = "HTTPS"
                Port                 = 443
                CertificateStoreName = "My"
                CertificateSubject   = "$SPTrustedSitesName.$DomainFQDN"
            }
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPWebApplicationExtension]ExtendWebApp"
        }

        SPCacheAccounts SetCacheAccounts
        {
            WebAppUrl            = "http://$SPTrustedSitesName/"
            SuperUserAlias       = "$DomainNetbiosName\$($SPSuperUserCreds.UserName)"
            SuperReaderAlias     = "$DomainNetbiosName\$($SPSuperReaderCreds.UserName)"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]MainWebApp"
        }

        SPSite RootTeamSite
        {
            Url                  = "http://$SPTrustedSitesName/"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "Team site"
            Template             = "STS#0"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]MainWebApp"
        }

        #**********************************************************
        # Additional configuration
        #**********************************************************
        SPSite MySiteHost
        {
            Url                      = "http://$MySiteHostAlias/"
            HostHeaderWebApplication = "http://$SPTrustedSitesName/"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "MySite host"
            Template                 = "SPSMSITEHOST#0"
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[SPWebApplication]MainWebApp"
        }

        SPSiteUrl MySiteHostIntranetUrl
        {
            Url                  = "http://$MySiteHostAlias/"
            Intranet             = "https://$MySiteHostAlias.$DomainFQDN"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]MySiteHost"
        }

        SPManagedPath MySiteManagedPath
        {
            WebAppUrl            = "http://$SPTrustedSitesName/"
            RelativeUrl          = "personal"
            Explicit             = $false
            HostHeader           = $true
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]MySiteHost"
        }

        SPUserProfileServiceApp UserProfileServiceApp
        {
            Name                 = $UpaServiceName
            ApplicationPool      = $ServiceAppPoolName
            MySiteHostLocation   = "http://$MySiteHostAlias/"
            ProfileDBName        = $SPDBPrefix + "UPA_Profiles"
            SocialDBName         = $SPDBPrefix + "UPA_Social"
            SyncDBName           = $SPDBPrefix + "UPA_Sync"
            EnableNetBIOS        = $false
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]UPAServiceInstance", "[SPSite]MySiteHost"
        }

        SPSite DevSite
        {
            Url                  = "http://$SPTrustedSitesName/sites/dev"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "Developer site"
            Template             = "DEV#0"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]MainWebApp"
        }

        SPSite CreateHNSC1
        {
            Url                      = "http://$HNSC1Alias/"
            HostHeaderWebApplication = "http://$SPTrustedSitesName/"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "$HNSC1Alias site"
            Template                 = "STS#0"
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[SPWebApplication]MainWebApp"
        }

        SPSiteUrl HNSC1IntranetUrl
        {
            Url                  = "http://$HNSC1Alias/"
            Intranet             = "https://$HNSC1Alias.$DomainFQDN"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]CreateHNSC1"
        }

        <#xScript CreateDefaultGroupsInTeamSites
        {
            SetScript = {
                $argumentList = @(@{ "sitesToUpdate" = @("http://$using:SPTrustedSitesName", "http://$using:SPTrustedSitesName/sites/team");
                                     "owner1"        = "i:0#.w|$using:DomainNetbiosName\$($using:DomainAdminCreds.UserName)";
                                     "owner2"        = "i:05.t|$using:DomainFQDN|$($using:DomainAdminCreds.UserName)@$using:DomainFQDN" })
                Invoke-SPDscCommand -Arguments @argumentList -ScriptBlock {
                    # Create members/visitors/owners groups in team sites
                    $params = $args[0]
                    #$sitesToUpdate = Get-SPSite
                    $sitesToUpdate = $params.sitesToUpdate
                    $owner1 = $params.owner1
                    $owner2 = $params.owner2

                    foreach ($siteUrl in $sitesToUpdate) {
                        $spsite = Get-SPSite $siteUrl
                        $spsite| fl *| Out-File $SetupPath\test.txt
                        Write-Verbose -Message "site $($spsite.Title) has template $($spsite.RootWeb.WebTemplate)"
                        if ($spsite.RootWeb.WebTemplate -like "STS") {
                            Write-Verbose -Message "Updating site $siteUrl with $owner1 and $($spsite.Url)"
                            $spsite.RootWeb.CreateDefaultAssociatedGroups($owner1, $owner2, $spsite.RootWeb.Title);
                            $spsite.RootWeb.Update();
                        }
                    }
                }
            }
            GetScript = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn = "[SPSite]RootTeamSite", "[SPSite]TeamSite"
        }#>

        # Added that to avoid the update conflict error (UpdatedConcurrencyException) of the UserProfileApplication persisted object
        # Error message avoided: UpdatedConcurrencyException: The object UserProfileApplication Name=User Profile Service Application was updated by another user.  Determine if these changes will conflict, resolve any differences, and reapply the second change.  This error may also indicate a programming error caused by obtaining two copies of the same object in a single thread. Previous update information: User: CONTOSO\spfarm Process:wsmprovhost (8632) Machine:SP Time:October 17, 2017 11:25:01.0000 Stack trace (Thread [16] CorrelationId [2c50ced7-4721-0003-b7f3-502c2147d301]):  Current update information: User: CONTOSO\spsetup Process:wsmprovhost (696) Machine:SP Time:October 17, 2017 11:25:06.0252 Stack trace (Thread [62] CorrelationId [37bd239e-a854-f0e6-ee90-b0567bfec821]):
        <#xScript RefreshLocalConfigCache
        {
            SetScript =
            {
                $methodName = "get_Local"
                $assembly = [Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
                $SPConfigurationDBType = $assembly.GetType("Microsoft.SharePoint.Administration.SPConfigurationDatabase")

                $bindingFlags = [Reflection.BindingFlags] "Public, Static"
                $localProp = [System.Reflection.MethodInfo] $SPConfigurationDBType.GetMethod($methodName, $bindingFlags)
                $SPConfigurationDBObject = $localProp.Invoke($null, $null)

                $methodName = "FlushCache"  # method RefreshCache() does not fix the UpdatedConcurrencyException, so use FlushCache instead
                $bindingFlags = [Reflection.BindingFlags] "NonPublic, Instance"
                $localProp = [System.Reflection.MethodInfo] $SPConfigurationDBType.GetMethod($methodName, $bindingFlags)
                $localProp.Invoke($SPConfigurationDBObject, $null)
            }
            GetScript = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn = "[SPUserProfileServiceApp]UserProfileServiceApp"
        }#>

        # Grant spsvc full control to UPA to allow newsfeeds to work properly
        SPServiceAppSecurity UserProfileServiceSecurity
        {
            ServiceAppName       = $UpaServiceName
            SecurityType         = "SharingPermissions"
            MembersToInclude     =  @(
                MSFT_SPServiceAppSecurityEntry {
                    Username     = $SPSvcCredsQualified.UserName
                    AccessLevels = @("Full Control")
            })
            PsDscRunAsCredential = $SPSetupCredsQualified
            #DependsOn           = "[xScript]RefreshLocalConfigCache"
            DependsOn            = "[SPUserProfileServiceApp]UserProfileServiceApp"
        }

        SPSubscriptionSettingsServiceApp SubscriptionSettingsServiceApp
        {
            Name                 = "Subscription Settings Service Application"
            ApplicationPool      = $ServiceAppPoolName
            DatabaseName         = "$($SPDBPrefix)SubscriptionSettings"
            InstallAccount       = $DomainAdminCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]StartSubscriptionSettingsServiceInstance"
        }

        SPAppManagementServiceApp AppManagementServiceApp
        {
            Name                 = "App Management Service Application"
            ApplicationPool      = $ServiceAppPoolName
            DatabaseName         = "$($SPDBPrefix)AppManagement"
            InstallAccount       = $DomainAdminCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]StartAppManagementServiceInstance"
        }

        SPSite TeamSite
        {
            Url                  = "http://$SPTrustedSitesName/sites/team"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "Team site"
            Template             = "STS#0"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]MainWebApp"
        }

        xDnsRecord AddAddinDNSWildcard
        {
            Name                 = "*"
            Zone                 = $AppDomainFQDN
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            DnsServer            = "$DCName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        xDnsRecord AddAddinDNSWildcardInIntranetZone
        {
            Name                 = "*"
            Zone                 = $AppDomainIntranetFQDN
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            DnsServer            = "$DCName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPAppDomain ConfigureLocalFarmAppUrls
        {
            AppDomain            = $AppDomainFQDN
            Prefix               = "addin"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSubscriptionSettingsServiceApp]SubscriptionSettingsServiceApp", "[SPAppManagementServiceApp]AppManagementServiceApp"
        }

        SPSite AppCatalog
        {
            Url                  = "http://$SPTrustedSitesName/sites/AppCatalog"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "AppCatalog"
            Template             = "APPCATALOG#0"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]MainWebApp"
        }

        SPSecurityTokenServiceConfig ConfigureSTS
        {
            Name                  = "SecurityTokenServiceManager"
            UseSessionCookies     = $false
            AllowOAuthOverHttp    = $true
            AllowMetadataOverHttp = $true
            IsSingleInstance      = "Yes"
            PsDscRunAsCredential  = $SPSetupCredsQualified
            DependsOn             = "[SPFarm]CreateSPFarm"
        }

        Script ConfigureAppDomains
        {
            SetScript = {
                $argumentList = @(@{ "webAppUrl"             = "http://$using:SPTrustedSitesName";
                                     "AppDomainFQDN"         = "$using:AppDomainFQDN";
                                     "AppDomainIntranetFQDN" = "$using:AppDomainIntranetFQDN" })
                Invoke-SPDscCommand -Arguments @argumentList -ScriptBlock {
                    $params = $args[0]

                    # Configure the app domains in both zones of the web application
                    $webAppUrl = $params.webAppUrl
                    $appDomainDefaultZone = $params.AppDomainFQDN
                    $appDomainIntranetZone = $params.AppDomainIntranetFQDN

                    $defaultZoneConfig = Get-SPWebApplicationAppDomain -WebApplication $webAppUrl -Zone Default
                    if($defaultZoneConfig -eq $null) {
                        New-SPWebApplicationAppDomain -WebApplication $webAppUrl -Zone Default -AppDomain $appDomainDefaultZone -ErrorAction SilentlyContinue
                    }
                    elseif ($defaultZoneConfig.AppDomain -notlike $appDomainDefaultZone) {
                        $defaultZoneConfig| Remove-SPWebApplicationAppDomain -Confirm:$false
                        New-SPWebApplicationAppDomain -WebApplication $webAppUrl -Zone Default -AppDomain $appDomainDefaultZone -ErrorAction SilentlyContinue
                    }

                    $IntranetZoneConfig = Get-SPWebApplicationAppDomain -WebApplication $webAppUrl -Zone Intranet
                    if($IntranetZoneConfig -eq $null) {
                        New-SPWebApplicationAppDomain -WebApplication $webAppUrl -Zone Intranet -SecureSocketsLayer -AppDomain $appDomainIntranetZone -ErrorAction SilentlyContinue
                    }
                    elseif ($IntranetZoneConfig.AppDomain -notlike $appDomainIntranetZone) {
                        $IntranetZoneConfig| Remove-SPWebApplicationAppDomain -Confirm:$false
                        New-SPWebApplicationAppDomain -WebApplication $webAppUrl -Zone Intranet -SecureSocketsLayer -AppDomain $appDomainIntranetZone -ErrorAction SilentlyContinue
                    }
                }
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPAppDomain]ConfigureLocalFarmAppUrls"
        }

        # SPWebApplicationAppDomain ConfigureAppDomainDefaultZone
        # {
        #     WebAppUrl            ="http://$SPTrustedSitesName"
        #     Zone                 = "Default"
        #     Port                 = 80
        #     AppDomain            = $AppDomainFQDN
        #     PsDscRunAsCredential = $DomainAdminCredsQualified
        #     DependsOn            = "[SPAppDomain]ConfigureLocalFarmAppUrls"
        # }

        # SPWebApplicationAppDomain ConfigureAppDomainIntranetZone
        # {
        #     WebAppUrl            ="http://$SPTrustedSitesName"
        #     Zone                 = "Intranet"
        #     Port                 = 443
        #     AppDomain            = $AppDomainIntranetFQDN
        #     PsDscRunAsCredential = $DomainAdminCredsQualified
        #     DependsOn            = "[SPAppDomain]ConfigureLocalFarmAppUrls"
        # }

        SPAppCatalog SetAppCatalogUrl
        {
            SiteUrl              = "http://$SPTrustedSitesName/sites/AppCatalog"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPSite]AppCatalog"
        }

        xDnsRecord ProviderHostedAddinsAlias
        {
            Name                 = $AddinsSiteCName
            Zone                 = $DomainFQDN
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            DnsServer            = "$DCName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        CertReq AddinsSiteCert
        {
            CARootName             = "$DomainNetbiosName-$DCName-CA"
            CAServerFQDN           = "$DCName.$DomainFQDN"
            Subject                = "$AddinsSiteCName.$($DomainFQDN)"
            FriendlyName           = "Provider-hosted addins site certificate"
            SubjectAltName         = "dns=$AddinsSiteCName.$($DomainFQDN)"
            KeyLength              = '2048'
            Exportable             = $true
            ProviderName           = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                    = '1.3.6.1.5.5.7.3.1'
            KeyUsage               = '0xa0'
            CertificateTemplate    = 'WebServer'
            AutoRenew              = $true
            Credential             = $DomainAdminCredsQualified
        }

        File AddinsSiteDirectory
        {
            DestinationPath = "C:\inetpub\wwwroot\addins"
            Type            = "Directory"
            Ensure          = "Present"
        }

        xWebAppPool AddinsSiteApplicationPool
        {
            Name                  = "Provider-hosted addins"
            State                 = "Started"
            managedPipelineMode   = 'Integrated'
            managedRuntimeLoader  = 'webengine4.dll'
            managedRuntimeVersion = 'v4.0'
            identityType          = "SpecificUser"
            Credential            = $SPSvcCredsQualified
            Ensure                = "Present"
            PsDscRunAsCredential  = $DomainAdminCredsQualified
        }

        xWebsite AddinsSite
        {
            Name                 = "Provider-hosted addins"
            State                = "Started"
            PhysicalPath         = "C:\inetpub\wwwroot\addins"
            ApplicationPool      = "Provider-hosted addins"
            AuthenticationInfo   = MSFT_xWebAuthenticationInformation 
            {
                Anonymous                 = $true
                Windows                   = $true
            }
            BindingInfo          = @(
                MSFT_xWebBindingInformation
                {
                    Protocol              = "HTTP"
                    Port                  = 20080
                }
                MSFT_xWebBindingInformation
                {
                    Protocol              = "HTTPS"
                    Port                 = 20443
                    CertificateStoreName = "My"
                    CertificateSubject   = "$AddinsSiteCName.$($DomainFQDN)"
                }
            )
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[CertReq]AddinsSiteCert"
        }

        xScript CopyIISWelcomePageToAddinsSite
        {
            SetScript = 
            {
                Copy-Item -Path "C:\inetpub\wwwroot\*" -Filter "iisstart*" -Destination "C:\inetpub\wwwroot\addins"
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                if ( (Get-ChildItem -Path "C:\inetpub\wwwroot\addins" -Name "iisstart*") -eq $null)
                {
                    return $false
                }
                else
                {
                    return $true
                }
            }
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xWebsite]AddinsSite"
        }

        CertReq HighTrustAddinsCert
        {
            CARootName             = "$DomainNetbiosName-$DCName-CA"
            CAServerFQDN           = "$DCName.$DomainFQDN"
            Subject                = "HighTrustAddins"
            FriendlyName           = "Sign OAuth tokens of high-trust add-ins"
            KeyLength              = '2048'
            Exportable             = $true
            ProviderName           = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                    = '1.3.6.1.5.5.7.3.1'
            KeyUsage               = '0xa0'
            CertificateTemplate    = 'WebServer'
            AutoRenew              = $true
            Credential             = $DomainAdminCredsQualified
        }

        xScript ExportHighTrustAddinsCert
        {
            SetScript = 
            {
                $destinationPath = "$($using:SetupPath)\Certificates"
                $certSubject = "HighTrustAddins"
                $certName = "HighTrustAddins.cer"
                $certFullPath = [System.IO.Path]::Combine($destinationPath, $certName)
                Write-Verbose -Message "Exporting public key of certificate with subject $certSubject to $certFullPath..."
                New-Item $destinationPath -Type directory -ErrorAction SilentlyContinue
                $signingCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "$certSubject"
                $signingCert | Export-Certificate -FilePath $certFullPath
                Write-Verbose -Message "Public key of certificate with subject $certSubject successfully exported to $certFullPath."
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
               return $false
            }
            DependsOn = "[CertReq]HighTrustAddinsCert"
        }

        SPTrustedSecurityTokenIssuer HighTrustAddinsTrust
        {
            Name                           = "HighTrustAddins"
            Description                    = "Trust for Provider-hosted high-trust add-ins"
            RegisteredIssuerNameIdentifier = "22222222-2222-2222-2222-222222222222"
            IsTrustBroker                  = $true
            SigningCertificateFilePath     = "$SetupPath\Certificates\HighTrustAddins.cer"
            Ensure                         = "Present"
            DependsOn                      = "[xScript]ExportHighTrustAddinsCert"
            PsDscRunAsCredential           = $SPSetupCredsQualified
        }

        # DSC resource File throws an access denied when accessing a remote location, so use xScript instead
        xScript CreateDSCCompletionFile
        {
            SetScript =
            {
                $SetupPath = $using:DCSetupPath
                $ComputerName = $using:ComputerName
                $DestinationPath = "$SetupPath\SPDSCFinished.txt"
                $Contents = "DSC Configuration on $ComputerName finished successfully."
                # Do not overwrite and do not throw an exception if file already exists
                New-Item $DestinationPath -Type file -Value $Contents -ErrorAction SilentlyContinue
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPTrustedSecurityTokenIssuer]HighTrustAddinsTrust"
        }
    }
}

function Get-LatestGitHubRelease
{
    [OutputType([string])]
    param(
        [string] $Repo,
        [string] $Artifact
    )
    # Force protocol TLS 1.2 in Invoke-WebRequest to fix TLS/SSL connection error with GitHub in Windows Server 2012 R2, as documented in https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-update-1802
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # Found in https://blog.markvincze.com/download-artifacts-from-a-latest-github-release-in-sh-and-powershell/
    $latestRelease = Invoke-WebRequest https://github.com/$Repo/releases/latest -Headers @{"Accept"="application/json"} -UseBasicParsing
    $json = $latestRelease.Content | ConvertFrom-Json
    $latestVersion = $json.tag_name
    $url = "https://github.com/$Repo/releases/download/$latestVersion/$Artifact"
    return $url
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

function Get-AppDomain
{
    [OutputType([string])]
    param(
        [string]$DomainFQDN,
        [string]$Suffix
    )

    $appDomain = [String]::Empty
    if ($DomainFQDN.Contains('.')) {
        $domainParts = $DomainFQDN.Split('.')
        $appDomain = $domainParts[0]
        $appDomain += "$Suffix."
        $appDomain += $domainParts[1]
    }
    return $appDomain
}

function Get-SPDSCInstalledProductVersion
{
    $pathToSearch = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\*\ISAPI\Microsoft.SharePoint.dll"
    $fullPath = Get-Item $pathToSearch | Sort-Object { $_.Directory } -Descending | Select-Object -First 1
    return (Get-Command $fullPath).FileVersionInfo
}

<#
# Azure DSC extension logging: C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.21.0.0
# Azure DSC extension configuration: C:\Packages\Plugins\Microsoft.Powershell.DSC\2.21.0.0\DSCWork

Install-Module -Name PendingReboot
help ConfigureSPVM

$DomainAdminCreds = Get-Credential -Credential "yvand"
$SPSetupCreds = Get-Credential -Credential "spsetup"
$SPFarmCreds = Get-Credential -Credential "spfarm"
$SPSvcCreds = Get-Credential -Credential "spsvc"
$SPAppPoolCreds = Get-Credential -Credential "spapppool"
$SPPassphraseCreds = Get-Credential -Credential "Passphrase"
$SPSuperUserCreds = Get-Credential -Credential "spSuperUser"
$SPSuperReaderCreds = Get-Credential -Credential "spSuperReader"
$DNSServer = "10.0.1.4"
$DomainFQDN = "contoso.local"
$DCName = "DC"
$SQLName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = 2019

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.77.0.0\DSCWork\ConfigureSPVM.0\ConfigureSPVM"
ConfigureSPVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPAppPoolCreds $SPAppPoolCreds -SPPassphraseCreds $SPPassphraseCreds -SPSuperUserCreds $SPSuperUserCreds -SPSuperReaderCreds $SPSuperReaderCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>
