configuration ConfigureSPVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServer,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [String]$DCName,
        [Parameter(Mandatory)] [String]$SQLName,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPFarmCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSvcCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPAppPoolCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSuperUserCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSuperReaderCreds
    )

    Import-DscResource -ModuleName xComputerManagement, xDisk, cDisk, xNetworking, xActiveDirectory, xCredSSP, xWebAdministration, SharePointDsc, xPSDesiredStateConfiguration, xDnsServer, xCertificate

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [System.Management.Automation.PSCredential] $SPSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSvcCreds.UserName)", $SPSvcCreds.Password)
    [System.Management.Automation.PSCredential] $SPAppPoolCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPAppPoolCreds.UserName)", $SPAppPoolCreds.Password)
    [System.Management.Automation.PSCredential] $SPSuperUserCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSuperUserCreds.UserName)", $SPSuperUserCreds.Password)
    [System.Management.Automation.PSCredential] $SPSuperReaderCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSuperReaderCreds.UserName)", $SPSuperReaderCreds.Password)
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
    [String] $SetupPath = "F:\Setup"
    [String] $DCSetupPath = "\\$DCName\C$\Setup"

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
        xWaitforDisk WaitForDataDisk   { DiskNumber = 2; RetryIntervalSec = $RetryIntervalSec; RetryCount = $RetryCount }
        cDiskNoRestart PrepareDataDisk { DiskNumber = 2; DriveLetter = "F" ; DependsOn   = "[xWaitforDisk]WaitForDataDisk" }
        WindowsFeature ADPS     { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; DependsOn = "[cDiskNoRestart]PrepareDataDisk" }
        WindowsFeature DnsTools { Name = "RSAT-DNS-Server";    Ensure = "Present"; DependsOn = "[cDiskNoRestart]PrepareDataDisk"  }
        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn      ="[WindowsFeature]ADPS"
        }

        xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[xDnsServerAddress]DnsServerAddress" }
        xCredSSP CredSSPClient { Ensure = "Present"; Role = "Client"; DelegateComputers = "*.$DomainFQDN", "localhost"; DependsOn = "[xCredSSP]CredSSPServer" }

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

        xComputer DomainJoin
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
            GetScript = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
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
            DependsOn="[xComputer]DomainJoin"
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
            DependsOn ="[xComputer]DomainJoin"
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
            DependsOn            = "[xComputer]DomainJoin"
        }

        xWebAppPool RemoveDotNet2Pool         { Name = ".NET v2.0";            Ensure = "Absent"; DependsOn = "[xComputer]DomainJoin"}
        xWebAppPool RemoveDotNet2ClassicPool  { Name = ".NET v2.0 Classic";    Ensure = "Absent"; DependsOn = "[xComputer]DomainJoin"}
        xWebAppPool RemoveDotNet45Pool        { Name = ".NET v4.5";            Ensure = "Absent"; DependsOn = "[xComputer]DomainJoin"}
        xWebAppPool RemoveDotNet45ClassicPool { Name = ".NET v4.5 Classic";    Ensure = "Absent"; DependsOn = "[xComputer]DomainJoin"}
        xWebAppPool RemoveClassicDotNetPool   { Name = "Classic .NET AppPool"; Ensure = "Absent"; DependsOn = "[xComputer]DomainJoin"}
        xWebAppPool RemoveDefaultAppPool      { Name = "DefaultAppPool";       Ensure = "Absent"; DependsOn = "[xComputer]DomainJoin"}
        xWebSite    RemoveDefaultWebSite      { Name = "Default Web Site";     Ensure = "Absent"; PhysicalPath = "C:\inetpub\wwwroot"; DependsOn = "[xComputer]DomainJoin"}

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
            DependsOn                     = "[xComputer]DomainJoin"
        }        

        xADUser CreateSParmAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPFarmCreds.UserName
            Password                      = $SPFarmCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[xComputer]DomainJoin"
        }

        <# Temporarily add farm account to admin group to deal with bug in SPUserProfileServiceApp introduced in SharePointDsc 2.0 - https://github.com/PowerShell/SharePointDsc/issues/709 #>
        Group AddSPSetupAccountToAdminGroup
        {
            GroupName            ='Administrators'
            Ensure               = 'Present'
            MembersToInclude     = @("$($SPSetupCredsQualified.UserName)", "$($SPFarmCredsQualified.UserName)")
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
            DependsOn                     = "[xComputer]DomainJoin"
        }

        xADUser CreateSPAppPoolAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPAppPoolCreds.UserName
            Password                      = $SPAppPoolCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[xComputer]DomainJoin"
        }

        xADUser CreateSPSuperUserAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSuperUserCreds.UserName
            Password                      = $SPSuperUserCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[xComputer]DomainJoin"
        }

        xADUser CreateSPSuperReaderAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSuperReaderCreds.UserName
            Password                      = $SPSuperReaderCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DependsOn                     = "[xComputer]DomainJoin"
        }

        File AccountsProvisioned
        {
            DestinationPath      = "F:\Logs\DSC1.txt"
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

        <#
        xRemoteFile Download201612CU
        {
            Uri             = "https://download.microsoft.com/download/D/0/4/D04FD356-E140-433E-94F6-472CF45FD591/sts2016-kb3128014-fullfile-x64-glb.exe"
            DestinationPath = "$SetupPath\sts2016-kb3128014-fullfile-x64-glb.exe"
            MatchSource = $false
            DependsOn = "[File]AccountsProvisioned"
        }

        xScript Install201612CU
        {
            SetScript =
            {
                $cuBuildNUmber = "16.0.4471.1000"
                $updateLocation = "$SetupPath\sts2016-kb3128014-fullfile-x64-glb.exe"
                $cuInstallLogPath = "$SetupPath\sts2016-kb3128014-fullfile-x64-glb.exe.install.log"
                $setup = Start-Process -FilePath $updateLocation -ArgumentList "/log:`"$CuInstallLogPath`" /quiet /passive /norestart" -Wait -PassThru

                if ($setup.ExitCode -eq 0) {
                    Write-Verbose -Message "SharePoint cumulative update $cuBuildNUmber installation complete"
                }
                else
                {
                    Write-Verbose -Message "SharePoint cumulative update install failed, exit code was $($setup.ExitCode)"
                    throw "SharePoint cumulative update install failed, exit code was $($setup.ExitCode)"
                }
            }
            GetScript =
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                $cuBuildNUmber = "16.0.4471.1000"
                $result = "false"
                Write-Verbose -Message 'Getting Sharepoint buildnumber'

                try
                {
                    $spInstall = Get-SPDSCInstalledProductVersion
                    $build = $spInstall.ProductVersion
                    if ($build -eq $cuBuildNUmber) {
                        $result = "true"
                    }
                }
                catch
                {
                    Write-Verbose -Message 'Sharepoint not installed, CU installation is going to fail if attempted'
                }

                return @{ "Result" = $result }
            }
            TestScript =
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                $cuBuildNUmber = "16.0.4471.1000"
                $result = $false
                try
                {
                    Write-Verbose -Message "Getting Sharepoint build number"
                    $spInstall = Get-SPDSCInstalledProductVersion
                    $build = $spInstall.ProductVersion
                    Write-Verbose -Message "Current Sharepoint build number is $build and expected build number is $cuBuildNUmber"
                    if ($build -eq $cuBuildNUmber) {
                        $result = $true
                    }
                }
                catch
                {
                    Write-Verbose -Message "Sharepoint is not installed, abort installation of CU or it will fail otherwise"
                    $result = $true
                }
                return $result
            }
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn = "[xRemoteFile]Download201612CU"
        }

        xPendingReboot RebootAfterInstall201612CU
        {
            Name = 'RebootAfterInstall201612CU'
            DependsOn = "[xScript]Install201612CU"
        }

        xPackage Install201612CU
        {
            Ensure = "Present"
            Name = "Update for Microsoft SharePoint Enterprise Server 2016 (KB3128014) 64-Bit Edition"
            ProductId = "{ECE043F3-EEF8-4070-AF9B-D805C42A8ED4}"
            InstalledCheckRegHive = "LocalMachine"
            InstalledCheckRegKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{90160000-1014-0000-1000-0000000FF1CE}_Office16.OSERVER_{ECE043F3-EEF8-4070-AF9B-D805C42A8ED4}"
            InstalledCheckRegValueName = "DisplayName"
            InstalledCheckRegValueData = "Update for Microsoft SharePoint Enterprise Server 2016 (KB3128014) 64-Bit Edition"
            Path = "$SetupPath\sts2016-kb3128014-fullfile-x64-glb.exe"
            Arguments = "/q"
            RunAsCredential = $DomainAdminCredsQualified
            ReturnCode = @( 0, 1641, 3010, 17025 )
            DependsOn = "[xPendingReboot]RebootAfterInstall201612CU"
        }
        #>

        xScript WaitForSQL
        {
            SetScript =
            {
                $retrySleep = $using:RetryIntervalSec
                $server = $using:SQLName
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
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xRemoteFile]DownloadLdapcp"
        }

        #**********************************************************
        # Create SharePoint farm
        #**********************************************************
        SPFarm CreateSPFarm
        {
            DatabaseServer            = $SQLName
            FarmConfigDatabaseName    = $SPDBPrefix + "Config"
            Passphrase                = $SPPassphraseCreds
            FarmAccount               = $SPFarmCredsQualified
            PsDscRunAsCredential      = $SPSetupCredsQualified
            AdminContentDatabaseName  = $SPDBPrefix + "AdminContent"
            CentralAdministrationPort = 5000
            # If RunCentralAdmin is false and configdb does not exist, SPFarm checks during 30 mins if configdb got created and joins the farm
            RunCentralAdmin           = $true
            Ensure                    = "Present"
            DependsOn                 = "[xScript]WaitForSQL"
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
            LogPath              = "F:\ULS"
            LogSpaceInGB         = 20
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

        xScript RestartSPTimer
        {
            SetScript =
            {
                # Restarting SPTimerV4 service before deploying solution makes deployment a lot more reliable
                Restart-Service SPTimerV4
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPDistributedCacheService]EnableDistributedCache"
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
            Ensure                       = "Present"
            DependsOn                    = "[SPFarmSolution]InstallLdapcp"
            PsDscRunAsCredential         = $SPSetupCredsQualified
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
            Url                    = "http://$SPTrustedSitesName/"
            Port                   = 80
            Ensure                 = "Present"
            PsDscRunAsCredential   = $SPSetupCredsQualified
            DependsOn              = "[SPFarm]CreateSPFarm"
        }

        xScript TrustCACertAsTrustedRootAuthority
        {
            SetScript =
            {
                # CA root cert must be added to trusted root authorities, otherwise xCertReq resource may fail to generate HTTPS site certificate with this error:
                # Certificate Request Processor: A certificate chain processed, but terminated in a root certificate which is not trusted by the trust provider. 0x800b0109
                try {
                    $file = ( Get-ChildItem -Path "$($using:SetupPath)\Certificates\ADFS Signing issuer.cer" )
                    $file | Import-Certificate -CertStoreLocation "cert:\LocalMachine\Root" -ErrorAction SilentlyContinue
                } catch {
                    # It may fail with following error: System.InvalidOperationException: The set script threw an error. ---> System.UnauthorizedAccessException: Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))
                    # But the certificate is successfully added anyway
                }
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = '[SPWebApplication]MainWebApp'
        }

        xCertReq SPSSiteCert
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
            DependsOn              = '[xScript]TrustCACertAsTrustedRootAuthority'
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
            DependsOn              = '[xCertReq]SPSSiteCert'
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

        xScript SetHTTPSCertificate
        {
            SetScript =
            {
                $siteCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "*.$using:DomainFQDN"

                $website = Get-WebConfiguration -Filter '/system.applicationHost/sites/site' |
                    Where-Object -FilterScript {$_.Name -eq "SharePoint - 443"}

                $properties = @{
                    protocol = "https"
                    bindingInformation = ":443:"
                    certificateStoreName = "MY"
                    certificateHash = $siteCert.Thumbprint
                }

                Clear-WebConfiguration -Filter "$($website.ItemXPath)/bindings" -Force -ErrorAction Stop
                Add-WebConfiguration -Filter "$($website.ItemXPath)/bindings" -Value @{
                    protocol = $properties.protocol
                    bindingInformation = $properties.bindingInformation
                    certificateStoreName = $properties.certificateStoreName
                    certificateHash = $properties.certificateHash
                } -Force -ErrorAction Stop

                if (!(Get-Item IIS:\SslBindings\*!443)) {
                    New-Item IIS:\SslBindings\*!443 -value $siteCert
                }

                <# To implement only when the TestScript will be implemented and will determine that current config must be overwritten
                # Otherwise, assume the right certificate is already used and binding doesn't need to be recreated
                if ((Get-Item IIS:\SslBindings\*!443)) {
                    Remove-Item IIS:\SslBindings\*!443 -Confirm:$false
                }
                New-Item IIS:\SslBindings\*!443 -value $siteCert
                #>
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPWebAppAuthentication]ConfigureWebAppAuthentication"
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
            Url                  = "http://$SPTrustedSitesName/sites/my"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "MySite host"
            Template             = "SPSMSITEHOST#0"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]MainWebApp"
        }

        SPUserProfileServiceApp UserProfileServiceApp
        {
            Name                 = $UpaServiceName
            ApplicationPool      = $ServiceAppPoolName
            MySiteHostLocation   = "http://$SPTrustedSitesName/sites/my"
            ProfileDBName        = $SPDBPrefix + "UPA_Profiles"
            SocialDBName         = $SPDBPrefix + "UPA_Social"
            SyncDBName           = $SPDBPrefix + "UPA_Sync"
            EnableNetBIOS        = $false
            PsDscRunAsCredential = $SPFarmCredsQualified
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
                            $spsite.RootWeb.CreateDefaultAssociatedGroups($owner1, $owner2, $spsite.Title);
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
                    Username    = $SPSvcCredsQualified.UserName
                    AccessLevel = "Full Control"
            })
            PsDscRunAsCredential = $SPSetupCredsQualified
            #DependsOn           = "[xScript]RefreshLocalConfigCache"
            DependsOn            = "[SPUserProfileServiceApp]UserProfileServiceApp"
        }

        SPSubscriptionSettingsServiceApp CreateSubscriptionSettingsServiceApp
        {
            Name                 = "Subscription Settings Service Application"
            ApplicationPool      = $ServiceAppPoolName
            DatabaseName         = "$($SPDBPrefix)SubscriptionSettings"
            InstallAccount       = $DomainAdminCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]StartSubscriptionSettingsServiceInstance"
        }

        SPAppManagementServiceApp CreateAppManagementServiceApp
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
            DependsOn            = "[SPSubscriptionSettingsServiceApp]CreateSubscriptionSettingsServiceApp", "[SPAppManagementServiceApp]CreateAppManagementServiceApp"
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

        Script ConfigureSTSAndMultipleZones
        {
            SetScript = {
                $argumentList = @(@{ "webAppUrl"             = "http://$using:SPTrustedSitesName";
                                     "AppDomainFQDN"         = "$using:AppDomainFQDN";
                                     "AppDomainIntranetFQDN" = "$using:AppDomainIntranetFQDN" })
                Invoke-SPDscCommand -Arguments @argumentList -ScriptBlock {
                    $params = $args[0]

                    # Configure STS
                    $serviceConfig = Get-SPSecurityTokenServiceConfig
                    $serviceConfig.AllowOAuthOverHttp = $true
                    $serviceConfig.Update()

                    # Configure app domains in zones of the web application
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

                    # Configure app catalog
                    # Deactivated because it throws "Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))"
                    #Update-SPAppCatalogConfiguration -Site "$webAppUrl/sites/AppCatalog" -Confirm:$false
                }
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPAppDomain]ConfigureLocalFarmAppUrls"
        }

        # Deactivated because it throws "Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))"
        <#SPAppCatalog MainAppCatalog
        {
            SiteUrl              = "http://$SPTrustedSitesName/sites/AppCatalog"
            InstallAccount       = $SPSetupCredsQualified
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPSite]AppCatalog"
        }#>

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
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Script]ConfigureSTSAndMultipleZones"
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

Install-Module -Name xPendingReboot
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

ConfigureSPVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPAppPoolCreds $SPAppPoolCreds -SPPassphraseCreds $SPPassphraseCreds -SPSuperUserCreds $SPSuperUserCreds -SPSuperReaderCreds $SPSuperReaderCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.74.0.0\DSCWork\ConfigureSPVM.0\ConfigureSPVM"
Set-DscLocalConfigurationManager -Path "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.74.0.0\DSCWork\ConfigureSPVM.0\ConfigureSPVM"
Start-DscConfiguration -Path "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.74.0.0\DSCWork\ConfigureSPVM.0\ConfigureSPVM" -Wait -Verbose -Force

#>
