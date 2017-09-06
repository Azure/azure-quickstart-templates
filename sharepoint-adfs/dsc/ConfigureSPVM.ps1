configuration ConfigureSPVM
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DNSServer,

        [Parameter(Mandatory)]
        [String]$DomainFQDN,

        [Parameter(Mandatory)]
        [String]$DCName,

        [Parameter(Mandatory)]
        [String]$SQLName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$DomainAdminCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SPSetupCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SPFarmCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SPSvcCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SPAppPoolCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SPPassphraseCreds,

        [String] $SPTrustedSitesName = "SPSites"
    )

    Import-DscResource -ModuleName xComputerManagement, xDisk, cDisk, xNetworking, xActiveDirectory, xCredSSP, xWebAdministration, SharePointDsc, xPSDesiredStateConfiguration, xDnsServer, xCertificate

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface=Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias=$($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [System.Management.Automation.PSCredential] $SPSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSvcCreds.UserName)", $SPSvcCreds.Password)
    [System.Management.Automation.PSCredential] $SPAppPoolCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPAppPoolCreds.UserName)", $SPAppPoolCreds.Password)
    [String] $SPDBPrefix = "SP16DSC_"
    [Int] $RetryCount = 30
    [Int] $RetryIntervalSec = 30
    $ComputerName = Get-Content env:computername
    $LdapcpLink = (Get-LatestGitHubRelease -repo "Yvand/LDAPCP" -artifact "LDAPCP.wsp")

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

        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec = $RetryIntervalSec
            RetryCount = $RetryCount
        }
        cDiskNoRestart SPDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitforDisk]Disk2"
        }
        WindowsFeature ADPS     { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; DependsOn = "[cDiskNoRestart]SPDataDisk" }
        WindowsFeature DnsTools { Name = "RSAT-DNS-Server";    Ensure = "Present"; DependsOn = "[cDiskNoRestart]SPDataDisk"  }
        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn="[WindowsFeature]ADPS"
        }

        xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[xDnsServerAddress]DnsServerAddress" } 
        xCredSSP CredSSPClient { Ensure = "Present"; Role = "Client"; DelegateComputers = "*.$DomainFQDN", "localhost"; DependsOn = "[xCredSSP]CredSSPServer" }

        #**********************************************************
        # Join AD forest
        #**********************************************************
        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainFQDN
            DomainUserCredential= $DomainAdminCredsQualified
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn="[xCredSSP]CredSSPClient"
        }

        xComputer DomainJoin
        {
            Name = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainAdminCredsQualified
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        #**********************************************************
        # Do some cleanup and preparation for SharePoint
        #**********************************************************
        Registry DisableLoopBackCheck {
            Ensure = "Present"
            Key = "HKLM:\System\CurrentControlSet\Control\Lsa"
            ValueName = "DisableLoopbackCheck"
            ValueData = "1"
            ValueType = "Dword"
            DependsOn = "[xComputer]DomainJoin"
        }
        
        xDnsRecord AddTrustedSiteDNS 
        {
            Name = $SPTrustedSitesName
            Zone = $DomainFQDN
            DnsServer = $DCName
            Target = "$ComputerName.$DomainFQDN"
            Type = "CName"
            Ensure = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn = "[xComputer]DomainJoin"
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
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DomainName = $DomainFQDN
            UserName = $SPSetupCreds.UserName
            Password = $SPSetupCreds
            PasswordNeverExpires = $true
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        Group AddSPSetupAccountToAdminGroup
        {
            GroupName='Administrators'   
            Ensure= 'Present'             
            MembersToInclude= $SPSetupCredsQualified.UserName
            Credential = $DomainAdminCredsQualified    
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn = "[xADUser]CreateSPSetupAccount"
        }

        xADUser CreateSParmAccount
        {
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DomainName = $DomainFQDN
            UserName = $SPFarmCreds.UserName
            Password = $SPFarmCreds
            PasswordNeverExpires = $true
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        xADUser CreateSPSvcAccount
        {
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DomainName = $DomainFQDN
            UserName = $SPSvcCreds.UserName
            Password = $SPSvcCreds
            PasswordNeverExpires = $true
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        xADUser CreateSPAppPoolAccount
        {
            DomainAdministratorCredential = $DomainAdminCredsQualified
            DomainName = $DomainFQDN
            UserName = $SPAppPoolCreds.UserName
            Password = $SPAppPoolCreds
            PasswordNeverExpires = $true
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        File AccountsProvisioned
        {
            DestinationPath = "F:\Logs\DSC1.txt"
            PsDscRunAsCredential = $SPSetupCredential
            Contents = "AccountsProvisioned"
            Type = 'File'
            Force = $true
            DependsOn = "[Group]AddSPSetupAccountToAdminGroup", "[xADUser]CreateSParmAccount", "[xADUser]CreateSPSvcAccount", "[xADUser]CreateSPAppPoolAccount"
        }

        
        #**********************************************************
        # Download binaries and install SharePoint CU
        #**********************************************************
        File CopyCertificatesFromDC
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = "\\$DCName\F$\Setup"
            DestinationPath = "F:\Setup\Certificates"
            Credential = $DomainAdminCredsQualified
            DependsOn = "[File]AccountsProvisioned"
        }

        xRemoteFile DownloadLdapcp
        {  
            Uri             = $LdapcpLink
            DestinationPath = "F:\Setup\LDAPCP.wsp"
            DependsOn = "[File]AccountsProvisioned"
        }        

        <#
        xRemoteFile Download201612CU
        {  
            Uri             = "https://download.microsoft.com/download/D/0/4/D04FD356-E140-433E-94F6-472CF45FD591/sts2016-kb3128014-fullfile-x64-glb.exe"
            DestinationPath = "F:\Setup\sts2016-kb3128014-fullfile-x64-glb.exe"
            MatchSource = $false
            DependsOn = "[File]AccountsProvisioned"
        }

        xScript Install201612CU
        {
            SetScript = 
            {
                $cuBuildNUmber = "16.0.4471.1000"
                $updateLocation = "F:\setup\sts2016-kb3128014-fullfile-x64-glb.exe"
                $cuInstallLogPath = "F:\setup\sts2016-kb3128014-fullfile-x64-glb.exe.install.log"
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
            Path = "F:\setup\sts2016-kb3128014-fullfile-x64-glb.exe"
            Arguments = "/q"
            RunAsCredential = $DomainAdminCredsQualified
            ReturnCode = @( 0, 1641, 3010, 17025 )
            DependsOn = "[xPendingReboot]RebootAfterInstall201612CU"
        }

        # TODO: implement stupid workaround documented in https://technet.microsoft.com/en-us/library/mt723354(v=office.16).aspx until SP2016 image is fixed
        #>

        xScript WaitForSQL
        {
            SetScript = 
            {
                $retryCount = $using:RetryIntervalSec
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
                        Write-Verbose "SQL connection to $server failed, retry in $retryCount secs..."
                        Start-Sleep -s $retryCount
                    }
                }
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
            PsDscRunAsCredential     = $DomainAdminCredsQualified
            DependsOn = "[xRemoteFile]DownloadLdapcp"
        }

        #**********************************************************
        # SharePoint configuration
        #**********************************************************
        SPFarm CreateSPFarm
        {
            DatabaseServer           = $SQLName
            FarmConfigDatabaseName   = $SPDBPrefix+"Config"
            Passphrase               = $SPPassphraseCreds
            FarmAccount              = $SPFarmCredsQualified
            PsDscRunAsCredential     = $SPSetupCredsQualified
            AdminContentDatabaseName = $SPDBPrefix+"AdminContent"
            CentralAdministrationPort = 5000
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
            CacheSizeInMB        = 8192
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
                # The deployment of the solution is made in owstimer.exe tends to fail very often, so restart the service before to mitigate this risk
                Restart-Service SPTimerV4
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
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn = "[SPDistributedCacheService]EnableDistributedCache"
        }

        SPFarmSolution InstallLdapcp 
        {
            LiteralPath = "F:\Setup\LDAPCP.wsp"
            Name = "LDAPCP.wsp"
            Deployed = $true
            Ensure = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn = "[xScript]RestartSPTimer"
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
            SigningCertificateFilePath = "F:\Setup\Certificates\ADFS Signing.cer"
            ClaimProviderName            = "LDAPCP"
            #ProviderSignOutUri           = "https://adfs.$DomainFQDN/adfs/ls/"
            Ensure                       = "Present"
            DependsOn = "[SPFarmSolution]InstallLdapcp"
            PsDscRunAsCredential         = $SPSetupCredsQualified
        }
        
        SPWebApplication MainWebApp
        {
            Name                   = "SharePoint - 80"
            ApplicationPool        = "SharePoint - 80"
            ApplicationPoolAccount = $SPAppPoolCredsQualified.UserName
            AllowAnonymous         = $false
            AuthenticationMethod   = "NTLM"
            DatabaseName           = $SPDBPrefix + "Content_80"
            Url                    = "http://$SPTrustedSitesName/"
            Port                   = 80
            Ensure                 = "Present"
            PsDscRunAsCredential   = $SPSetupCredsQualified
            DependsOn              = "[SPTrustedIdentityTokenIssuer]CreateSPTrust"
        }

        <#xScript ExtendWebApp
        {
            SetScript = 
            {
                $ComputerName = $using:ComputerName
                $SPTrustedSitesName = $using:SPTrustedSitesName
                $DomainFQDN = $using:DomainFQDN

                $result = Invoke-SPDSCCommand -Credential $using:SPSetupCredsQualified -ScriptBlock {
                    Get-SPWebApplication "http://$ComputerName/" | New-SPWebApplicationExtension -Name "SharePoint - 443" -SecureSocketsLayer -Zone "Intranet" -URL "https://$SPTrustedSitesName.$DomainFQDN" -Port 443
                    $winAp = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication
                    $trust = Get-SPTrustedIdentityTokenIssuer $DomainFQDN
                    Get-SPWebApplication "http://$ComputerName/" | Set-SPWebApplication -Zone Intranet -AuthenticationProvider $trust, $winAp 
                                     
                    return "success"
                }
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                $result = "false"
                return @{ "Result" = $result }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                return $false
            }
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn = '[SPWebApplication]MainWebApp'
        }#>

        xCertReq SPSSiteCert
        {
            CARootName                = "$DomainNetbiosName-$DCName-CA"
            CAServerFQDN              = "$DCName.$DomainFQDN"
            Subject                   = "$SPTrustedSitesName.$DomainFQDN"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
            Credential                = $DomainAdminCredsQualified
            DependsOn = '[SPWebApplication]MainWebApp'
        }

        SPWebApplicationExtension ExtendWebApp
        {
            WebAppUrl              = "http://$SPTrustedSitesName/"
            Name                   = "SharePoint - 443"
            AllowAnonymous         = $false
            AuthenticationMethod   = "Claims"
            AuthenticationProvider = $DomainFQDN
            Url                    = "https://$SPTrustedSitesName.$DomainFQDN"
            Zone                   = "Intranet"
            UseSSL                 = $true
            Port                   = 443
            Ensure                 = "Present"
            PsDscRunAsCredential   = $SPSetupCredsQualified
            DependsOn = '[xCertReq]SPSSiteCert'
        }
        
        xScript SetHTTPSCertificate
        {
            SetScript = 
            {
                $siteCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "$using:SPTrustedSitesName.$using:DomainFQDN"

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
            PsDscRunAsCredential     = $DomainAdminCredsQualified
            DependsOn                = "[SPWebApplicationExtension]ExtendWebApp"
        }

        SPSite DevSite
        {
            Url                      = "http://$SPTrustedSitesName/"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "Developer site"
            Template                 = "DEV#0"
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[xScript]SetHTTPSCertificate"
        }

        SPSite TeamSite
        {
            Url                      = "http://$SPTrustedSitesName/sites/team"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "Team site"
            Template                 = "STS#0"
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[xScript]SetHTTPSCertificate"
        }

        SPSite MySiteHost
        {
            Url                      = "http://$SPTrustedSitesName/sites/my"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:05.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "MySite host"
            Template                 = "SPSMSITEHOST#0"
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[xScript]SetHTTPSCertificate"
        }

        $serviceAppPoolName = "SharePoint Service Applications"
        SPServiceAppPool MainServiceAppPool
        {
            Name                 = $serviceAppPoolName
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

        $upaServiceName = "User Profile Service Application"
        SPUserProfileServiceApp UserProfileServiceApp
        {
            Name                 = $upaServiceName
            ApplicationPool      = $serviceAppPoolName
            MySiteHostLocation   = "http://$SPTrustedSitesName/sites/my"
            ProfileDBName        = $SPDBPrefix + "UPA_Profiles"
            SocialDBName         = $SPDBPrefix + "UPA_Social"
            SyncDBName           = $SPDBPrefix + "UPA_Sync"
            EnableNetBIOS        = $false
            FarmAccount          = $SPFarmCredsQualified
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn = "[SPServiceAppPool]MainServiceAppPool", "[SPSite]MySiteHost"
        }

        xScript WaitAfterUPAProvisioning
        {
            SetScript = 
            {
                # Add a timer to avoid update conflict error (UpdatedConcurrencyException) of the UserProfileApplication persisted object
                Start-Sleep -s 10
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
            DependsOn = "[SPUserProfileServiceApp]UserProfileServiceApp"
        }

        # Grant spsvc full control to UPA to allow newsfeeds to work properly
        $upaAdminToInclude = @( 
            MSFT_SPServiceAppSecurityEntry {
                Username    = $SPSvcCredsQualified.UserName
                AccessLevel = "Full Control"
            } )
        SPServiceAppSecurity UserProfileServiceSecurity
        {
            ServiceAppName       = $upaServiceName
            SecurityType         = "SharingPermissions"
            MembersToInclude     = $upaAdminToInclude
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn = "[xScript]WaitAfterUPAProvisioning"
        }
    }
}

function Get-LatestGitHubRelease
{
    [OutputType([string])]
    param(
        [string]$repo,
        [string]$artifact
    )
    # Found in https://blog.markvincze.com/download-artifacts-from-a-latest-github-release-in-sh-and-powershell/
    $latestRelease = Invoke-WebRequest https://github.com/$repo/releases/latest -Headers @{"Accept"="application/json"} -UseBasicParsing
    $json = $latestRelease.Content | ConvertFrom-Json
    $latestVersion = $json.tag_name
    $url = "https://github.com/$repo/releases/download/$latestVersion/$artifact"
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
$DNSServer = "10.0.1.4"
$DomainFQDN = "contoso.local"
$DCName = "DC"
$SQLName = "SQL"

ConfigureSPVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPAppPoolCreds $SPAppPoolCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath "C:\Data\\output"
Set-DscLocalConfigurationManager -Path "C:\Data\output\"
Start-DscConfiguration -Path "C:\Data\output" -Wait -Verbose -Force

#>
