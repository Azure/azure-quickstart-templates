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
        [Parameter(Mandatory)] [Boolean]$EnableAnalysis,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPFarmCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSvcCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPAppPoolCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSuperUserCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSuperReaderCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc, NetworkingDsc, ActiveDirectoryDsc, xCredSSP, xWebAdministration, SharePointDsc, xPSDesiredStateConfiguration, xDnsServer, CertificateDsc, SqlServerDsc, cChoco

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [System.Management.Automation.PSCredential] $SPSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSvcCreds.UserName)", $SPSvcCreds.Password)
    [System.Management.Automation.PSCredential] $SPAppPoolCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPAppPoolCreds.UserName)", $SPAppPoolCreds.Password)
    [String] $SPDBPrefix = "SPDSC_"
    [String] $SPTrustedSitesName = "spsites"
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
    [String] $AddinsSiteDNSAlias = "addins"
    [String] $AddinsSiteName = "Provider-hosted addins"
    [String] $TrustedIdChar = "e"
    [String] $SPTeamSiteTemplate = "STS#3"
    if ([String]::Equals($SharePointVersion, "2013") -or [String]::Equals($SharePointVersion, "2016")) {
        $SPTeamSiteTemplate = "STS#0"
    }

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
        WindowsFeature AddADTools             { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature AddADPowerShell        { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        WindowsFeature AddDnsTools            { Name = "RSAT-DNS-Server";    Ensure = "Present"; }
        WindowsFeature AddADLDS               { Name = "RSAT-ADLDS";         Ensure = "Present"; }
        WindowsFeature AddADCSManagementTools { Name = "RSAT-ADCS-Mgmt";     Ensure = "Present"; }
        DnsServerAddress SetDNS { Address = $DNSServer; InterfaceAlias = $InterfaceAlias; AddressFamily  = 'IPv4' }

        # xCredSSP is required forSharePointDsc resources SPUserProfileServiceApp and SPDistributedCacheService
        xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[DnsServerAddress]SetDNS" }
        xCredSSP CredSSPClient { Ensure = "Present"; Role = "Client"; DelegateComputers = "*.$DomainFQDN", "localhost"; DependsOn = "[xCredSSP]CredSSPServer" }

        # IIS cleanup
        xWebAppPool RemoveDotNet2Pool         { Name = ".NET v2.0";            Ensure = "Absent"; }
        xWebAppPool RemoveDotNet2ClassicPool  { Name = ".NET v2.0 Classic";    Ensure = "Absent"; }
        xWebAppPool RemoveDotNet45Pool        { Name = ".NET v4.5";            Ensure = "Absent"; }
        xWebAppPool RemoveDotNet45ClassicPool { Name = ".NET v4.5 Classic";    Ensure = "Absent"; }
        xWebAppPool RemoveClassicDotNetPool   { Name = "Classic .NET AppPool"; Ensure = "Absent"; }
        xWebAppPool RemoveDefaultAppPool      { Name = "DefaultAppPool";       Ensure = "Absent"; }
        xWebSite    RemoveDefaultWebSite      { Name = "Default Web Site";     Ensure = "Absent"; PhysicalPath = "C:\inetpub\wwwroot"; }

        # Allow NTLM on HTTPS sites when site host name is different than the machine name - https://docs.microsoft.com/en-US/troubleshoot/windows-server/networking/accessing-server-locally-with-fqdn-cname-alias-denied
        Registry DisableLoopBackCheck { Key = "HKLM:\System\CurrentControlSet\Control\Lsa"; ValueName = "DisableLoopbackCheck"; ValueData = "1"; ValueType = "Dword"; Ensure = "Present" }

        # Enable TLS 1.2 - https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/application-proxy-add-on-premises-application#tls-requirements
        # It's a best practice, and mandatory with Windows 2012 R2 (SharePoint 2013) to allow xRemoteFile to download releases from GitHub: https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/405           
        Registry EnableTLS12RegKey1 { Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'; ValueName = 'DisabledByDefault'; ValueType = 'Dword'; ValueData = '0'; Ensure = 'Present' }
        Registry EnableTLS12RegKey2 { Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'; ValueName = 'Enabled';           ValueType = 'Dword'; ValueData = '1'; Ensure = 'Present' }
        Registry EnableTLS12RegKey3 { Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'; ValueName = 'DisabledByDefault'; ValueType = 'Dword'; ValueData = '0'; Ensure = 'Present' }
        Registry EnableTLS12RegKey4 { Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'; ValueName = 'Enabled';           ValueType = 'Dword'; ValueData = '1'; Ensure = 'Present' }

        # Enable strong crypto by default for .NET Framework 4 applications - https://docs.microsoft.com/en-us/dotnet/framework/network-programming/tls#configuring-security-via-the-windows-registry
        Registry SchUseStrongCrypto         { Key = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319';             ValueName = 'SchUseStrongCrypto';       ValueType = 'Dword'; ValueData = '1'; Ensure = 'Present' }
        Registry SchUseStrongCrypto32       { Key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319'; ValueName = 'SchUseStrongCrypto';       ValueType = 'Dword'; ValueData = '1'; Ensure = 'Present' }
        Registry SystemDefaultTlsVersions   { Key = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319';             ValueName = 'SystemDefaultTlsVersions'; ValueType = 'Dword'; ValueData = '1'; Ensure = 'Present' }
        Registry SystemDefaultTlsVersions32 { Key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319'; ValueName = 'SystemDefaultTlsVersions'; ValueType = 'Dword'; ValueData = '1'; Ensure = 'Present' }

        xRemoteFile DownloadLdapcp { Uri = $LdapcpLink; DestinationPath = "$SetupPath\LDAPCP.wsp" }

        SqlAlias AddSqlAlias { Ensure = "Present"; Name = $SQLAlias; ServerName = $SQLName; Protocol = "TCP"; TcpPort= 1433 }

        xScript DisableIESecurity
        {
            TestScript = {
                return $false   # If TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            }
            SetScript = {
                # Source: https://stackoverflow.com/questions/9368305/disable-ie-security-on-windows-server-via-powershell
                $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
                #$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
                Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
                #Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

                if ($false -eq (Test-Path -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer")) {
                    New-Item -Path "HKLM:\Software\Policies\Microsoft" -Name "Internet Explorer"
                }

                # Disable the first run wizard of IE
                $ieFirstRunKey = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
                if ($false -eq (Test-Path -Path $ieFirstRunKey)) {
                    New-Item -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer" -Name "Main"
                }
                Set-ItemProperty -Path $ieFirstRunKey -Name "DisableFirstRunCustomize" -Value 1
                
                # Set new tabs to open "about:blank" in IE
                $ieNewTabKey = "HKLM:\Software\Policies\Microsoft\Internet Explorer\TabbedBrowsing"
                if ($false -eq (Test-Path -Path $ieNewTabKey)) {
                    New-Item -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer" -Name "TabbedBrowsing"
                }
                Set-ItemProperty -Path $ieNewTabKey -Name "NewTabPageShow" -Value 0
            }
            GetScript = { }
        }

        xScript EnableFileSharing
        {
            TestScript = {
                # Test if firewall rules for file sharing already exist
                $rulesSet = Get-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -ErrorAction SilentlyContinue | Where-Object{$_.Profile -eq "Domain"}
                if ($null -eq $rulesSet) {
                    return $false   # Run SetScript
                } else {
                    return $true    # Rules already set
                }
            }
            SetScript = {
                Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Domain -Confirm:$false
            }
            GetScript = { }
        }

        # Create the rules in the firewall required for the distributed cache
        xScript CreateFirewallRulesForDistributedCache
        {
            TestScript = {
                # Test if firewall rules already exist
                $icmpRuleName = "File and Printer Sharing (Echo Request - ICMPv4-In)"
                $icmpFirewallRule = Get-NetFirewallRule -DisplayName $icmpRuleName -ErrorAction SilentlyContinue
                $spRuleName = "SharePoint Distributed Cache"
                $firewallRule = Get-NetFirewallRule -DisplayName $spRuleName -ErrorAction SilentlyContinue
                if ($null -eq $icmpFirewallRule -or $null -eq $firewallRule) {
                    return $false   # Run SetScript
                } else {
                    return $true    # Rules already set
                }
            }
            SetScript = {
                $icmpRuleName = "File and Printer Sharing (Echo Request - ICMPv4-In)"
                $icmpFirewallRule = Get-NetFirewallRule -DisplayName $icmpRuleName -ErrorAction SilentlyContinue
                if ($null -eq $icmpFirewallRule) {
                    New-NetFirewallRule -Name Allow_Ping -DisplayName $icmpRuleName `
                        -Description "Allow ICMPv4 ping" `
                        -Protocol ICMPv4 `
                        -IcmpType 8 `
                        -Enabled True `
                        -Profile Any `
                        -Action Allow
                }
                Enable-NetFirewallRule -DisplayName $icmpRuleName

                $spRuleName = "SharePoint Distributed Cache"
                $firewallRule = Get-NetFirewallRule -DisplayName $spRuleName -ErrorAction SilentlyContinue
                if ($null -eq $firewallRule) {
                    New-NetFirewallRule -Name "SPDistCache" `
                        -DisplayName $spRuleName `
                        -Protocol TCP `
                        -LocalPort 22233-22236 `
                        -Group "SharePoint"
                }                
                Enable-NetFirewallRule -DisplayName $spRuleName
            }
            GetScript = { }
        }

        #**********************************************************
        # Install applications using Chocolatey
        #**********************************************************
        cChocoInstaller InstallChoco
        {
            InstallDir = "C:\Choco"
        }

        cChocoPackageInstaller InstallEdge
        {
            Name                 = "microsoft-edge"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallNotepadpp
        {
            Name                 = "notepadplusplus.install"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller Install7zip
        {
            Name                 = "7zip.install"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallVscode
        {
            Name                 = "vscode.portable"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        # if ($EnableAnalysis) {
        #     # This resource is for  of dsc logs only and totally optionnal
        #     cChocoPackageInstaller InstallPython
        #     {
        #         Name                 = "python"
        #         Ensure               = "Present"
        #         DependsOn            = "[cChocoInstaller]InstallChoco"
        #     }
        # }

        #**********************************************************
        # Join AD forest
        #**********************************************************
        # If WaitForADDomain does not find the domain whtin "WaitTimeout" secs, it will signar a restart to DSC engine "RestartCount" times
        WaitForADDomain WaitForDCReady
        {
            DomainName              = $DomainFQDN
            WaitTimeout             = 1800
            RestartCount            = 2
            WaitForValidCredentials = $True
            Credential              = $DomainAdminCredsQualified
            DependsOn               = "[DnsServerAddress]SetDNS"
        }

        # WaitForADDomain sets reboot signal only if WaitForADDomain did not find domain within "WaitTimeout" secs
        PendingReboot RebootOnSignalFromWaitForDCReady
        {
            Name             = "RebootOnSignalFromWaitForDCReady"
            SkipCcmClientSDK = $true
            DependsOn        = "[WaitForADDomain]WaitForDCReady"
        }

        Computer JoinDomain
        {
            Name       = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainAdminCredsQualified
            DependsOn  = "[PendingReboot]RebootOnSignalFromWaitForDCReady"
        }

        PendingReboot RebootOnSignalFromJoinDomain
        {
            Name             = "RebootOnSignalFromJoinDomain"
            SkipCcmClientSDK = $true
            DependsOn        = "[Computer]JoinDomain"
        }

        # This script is still needed
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
            DependsOn = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        #**********************************************************
        # Do SharePoint pre-reqs that require membership in AD domain
        #**********************************************************
        # Create DNS entries used by SharePoint
        xDnsRecord AddTrustedSiteDNS
        {
            Name                 = $SPTrustedSitesName
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
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
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
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
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
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
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
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
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        xDnsRecord ProviderHostedAddinsAlias
        {
            Name                 = $AddinsSiteDNSAlias
            Zone                 = $DomainFQDN
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            DnsServer            = "$DCName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        #**********************************************************
        # Provision required accounts for SharePoint
        #**********************************************************
        ADUser CreateSPSetupAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSetupCreds.UserName
            Password                      = $SPSetupCreds
            UserPrincipalName             = "$($SPSetupCreds.UserName)@$DomainFQDN"
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn                     = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }        

        ADUser CreateSParmAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPFarmCreds.UserName
            UserPrincipalName             = "$($SPFarmCreds.UserName)@$DomainFQDN"
            Password                      = $SPFarmCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn                     = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        Group AddSPSetupAccountToAdminGroup
        {
            GroupName            = "Administrators"
            Ensure               = "Present"
            MembersToInclude     = @("$($SPSetupCredsQualified.UserName)")
            Credential           = $DomainAdminCredsQualified
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[ADUser]CreateSPSetupAccount"
        }

        ADUser CreateSPSvcAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSvcCreds.UserName
            UserPrincipalName             = "$($SPSvcCreds.UserName)@$DomainFQDN"
            Password                      = $SPSvcCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn                     = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        ADUser CreateSPAppPoolAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPAppPoolCreds.UserName
            UserPrincipalName             = "$($SPAppPoolCreds.UserName)@$DomainFQDN"
            Password                      = $SPAppPoolCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            ServicePrincipalNames         = @("HTTP/$SPTrustedSitesName.$($DomainFQDN)", "HTTP/$MySiteHostAlias.$($DomainFQDN)", "HTTP/$HNSC1Alias.$($DomainFQDN)", "HTTP/$SPTrustedSitesName", "HTTP/$MySiteHostAlias", "HTTP/$HNSC1Alias")
            PsDscRunAsCredential          = $DomainAdminCredsQualified
            DependsOn                     = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        ADUser CreateSPSuperUserAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSuperUserCreds.UserName
            UserPrincipalName             = "$($SPSuperUserCreds.UserName)@$DomainFQDN"
            Password                      = $SPSuperUserCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn                     = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        ADUser CreateSPSuperReaderAccount
        {
            DomainName                    = $DomainFQDN
            UserName                      = $SPSuperReaderCreds.UserName
            UserPrincipalName             = "$($SPSuperReaderCreds.UserName)@$DomainFQDN"
            Password                      = $SPSuperReaderCreds
            PasswordNeverExpires          = $true
            Ensure                        = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn                     = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        File AccountsProvisioned
        {
            DestinationPath      = "C:\Logs\DSC1.txt"
            Contents             = "AccountsProvisioned"
            Type                 = "File"
            Force                = $true
            PsDscRunAsCredential = $SPSetupCredential
            DependsOn            = "[Group]AddSPSetupAccountToAdminGroup", "[ADUser]CreateSParmAccount", "[ADUser]CreateSPSvcAccount", "[ADUser]CreateSPAppPoolAccount", "[ADUser]CreateSPSuperUserAccount", "[ADUser]CreateSPSuperReaderAccount", "[xScript]CreateWSManSPNsIfNeeded"
        }
        
        # Fiddler must be installed as $DomainAdminCredsQualified because it's a per-user installation
        cChocoPackageInstaller InstallFiddler
        {
            Name                 = "fiddler"
            Version              =  5.0.20204.45441
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[cChocoInstaller]InstallChoco", "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        # Install ULSViewer as $DomainAdminCredsQualified to ensure that the shortcut is visible on the desktop
        cChocoPackageInstaller InstallUlsViewer
        {
            Name                 = "ulsviewer"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        xScript WaitForSQL
        {
            SetScript =
            {
                $retrySleep = 30
                $server = $using:SQLAlias
                $db = "master"
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
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SqlAlias]AddSqlAlias", "[File]AccountsProvisioned"
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
            SkipRegisterAsDistributedCacheHost = $false
            Ensure                    = "Present"
            DependsOn                 = "[xScript]WaitForSQL"
        }

        xScript RestartSPTimerAfterCreateSPFarm
        {
            SetScript =
            {
                # Restarting SPTimerV4 service before deploying solution makes deployment a lot more reliable
                Restart-Service SPTimerV4
                # 2021-09: In SharePoint 2013, solution deployment failed multiple times with error "Admin SVC must be running in order to create deployment timer job."
                # So ensure that SPAdminV4 is started
                Restart-Service SPAdminV4
            }
            GetScript            = { }
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        # Delay this operation significantly, so that DC has time to generate and copy the certificates
        File CopyCertificatesFromDC
        {
            Ensure          = "Present"
            Type            = "Directory"
            Recurse         = $true
            SourcePath      = "$DCSetupPath"
            DestinationPath = "$SetupPath\Certificates"
            Credential      = $DomainAdminCredsQualified
            DependsOn       = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPTrustedRootAuthority TrustRootCA
        {
            Name                 = "$DomainFQDN root CA"
            CertificateFilePath  = "$SetupPath\Certificates\ADFS Signing issuer.cer"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[File]CopyCertificatesFromDC"
        }

        SPFarmSolution InstallLdapcp
        {
            LiteralPath          = "$SetupPath\LDAPCP.wsp"
            Name                 = "LDAPCP.wsp"
            Deployed             = $true
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPManagedAccount CreateSPSvcManagedAccount
        {
            AccountName          = $SPSvcCredsQualified.UserName
            Account              = $SPSvcCredsQualified
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPManagedAccount CreateSPAppPoolManagedAccount
        {
            AccountName          = $SPAppPoolCredsQualified.UserName
            Account              = $SPAppPoolCredsQualified
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPStateServiceApp StateServiceApp
        {
            Name                 = "State Service Application"
            DatabaseName         = $SPDBPrefix + "StateService"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        # Distributed Cache is now enabled directly by the SPFarm resource
        # SPDistributedCacheService EnableDistributedCache
        # {
        #     Name                 = "AppFabricCachingService"
        #     CacheSizeInMB        = 1000 # Default size is 819MB on a server with 16GB of RAM (5%)
        #     CreateFirewallRules  = $true
        #     ServiceAccount       = $SPFarmCredsQualified.UserName
        #     InstallAccount       = $SPSetupCredsQualified
        #     Ensure               = "Present"
        #     DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        # }

        #**********************************************************
        # Service instances are started at the beginning of the deployment to give some time between this and creation of service applications
        # This makes deployment a lot more reliable and avoids errors related to concurrency update of persisted objects, or service instance not found...
        #**********************************************************
        SPServiceInstance UPAServiceInstance
        {
            Name                 = "User Profile Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPServiceInstance StartSubscriptionSettingsServiceInstance
        {
            Name                 = "Microsoft SharePoint Foundation Subscription Settings Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPServiceInstance StartAppManagementServiceInstance
        {
            Name                 = "App Management Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        SPServiceAppPool MainServiceAppPool
        {
            Name                 = $ServiceAppPoolName
            ServiceAccount       = $SPSvcCredsQualified.UserName
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPManagedAccount]CreateSPSvcManagedAccount"
        }

        SPWebApplication CreateMainWebApp
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
            DependsOn              = "[xScript]RestartSPTimerAfterCreateSPFarm"
        }

        # Update GPO to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\", otherwise certificate request will fail
        xScript UpdateGPOToTrustRootCACert
        {
            SetScript =
            {
                gpupdate.exe /force
            }
            GetScript            = { }
            TestScript           = 
            {
                $domainNetbiosName = $using:DomainNetbiosName
                $dcName = $using:DCName
                $rootCAName = "$domainNetbiosName-$dcName-CA"
                $cert = Get-ChildItem -Path "cert:\LocalMachine\Root\" -DnsName "$rootCAName"
                
                if ($null -eq $cert) {
                    return $false   # Run SetScript
                } else {
                    return $true    # Root CA already present
                }
            }
            DependsOn            = "[xScript]RestartSPTimerAfterCreateSPFarm"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        CertReq GenerateMainWebAppCertificate
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

        # Installing LDAPCP somehow updates SPClaimEncodingManager 
        # But in SharePoint 2019 (only), it causes an UpdatedConcurrencyException on SPClaimEncodingManager in SPTrustedIdentityTokenIssuer resource
        # The only solution I've found is to force a reboot in SharePoint 2019
        if ($SharePointVersion -eq "2019") {
            xScript ForceRebootBeforeCreatingSPTrust
            {
                # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
                TestScript = {
                    return (Test-Path HKLM:\SOFTWARE\DscScriptExecution\flag_ForceRebootBeforeCreatingSPTrust)
                }
                SetScript = {
                    New-Item -Path HKLM:\SOFTWARE\DscScriptExecution\flag_ForceRebootBeforeCreatingSPTrust -Force
                    $global:DSCMachineStatus = 1
                }
                GetScript = { }
                PsDscRunAsCredential = $DomainAdminCredsQualified
                DependsOn = "[SPFarmSolution]InstallLdapcp"
            }

            PendingReboot RebootOnSignalFromForceRebootBeforeCreatingSPTrust
            {
                Name             = "RebootOnSignalFromForceRebootBeforeCreatingSPTrust"
                SkipCcmClientSDK = $true
                DependsOn        = "[xScript]ForceRebootBeforeCreatingSPTrust"
            }
        }

        SPTrustedIdentityTokenIssuer CreateSPTrust
        {
            Name                         = $DomainFQDN
            Description                  = "Federation with $DomainFQDN"
            Realm                        = "urn:sharepoint:$($SPTrustedSitesName)"
            SignInUrl                    = "https://adfs.$DomainFQDN/adfs/ls/"
            IdentifierClaim              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"
            ClaimsMappings               = @(
                MSFT_SPClaimTypeMapping{
                    Name = "upn"
                    IncomingClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"
                }
                MSFT_SPClaimTypeMapping{
                    Name = "role"
                    IncomingClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
                }
            )
            SigningCertificateFilePath   = "$SetupPath\Certificates\ADFS Signing.cer"
            ClaimProviderName            = "LDAPCP"
            ProviderSignOutUri          = "https://adfs.$DomainFQDN/adfs/ls/"
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
				$config.ClaimTypes.Remove("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress")
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

        # ExtendMainWebApp might fail with error: "The web.config could not be saved on this IIS Web Site: C:\\inetpub\\wwwroot\\wss\\VirtualDirectories\\80\\web.config.\r\nThe process cannot access the file 'C:\\inetpub\\wwwroot\\wss\\VirtualDirectories\\80\\web.config' because it is being used by another process."
        # So I added resources between it and CreateMainWebApp to avoid it
        SPWebApplicationExtension ExtendMainWebApp
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
            DependsOn              = "[CertReq]GenerateMainWebAppCertificate", "[SPWebApplication]CreateMainWebApp", "[xScript]ConfigureLDAPCP"
        }

        SPWebAppAuthentication ConfigureMainWebAppAuthentication
        {
            WebAppUrl = "http://$SPTrustedSitesName/"
            Default = @(
                MSFT_SPWebAppAuthenticationMode {
                    AuthenticationMethod = "WindowsAuthentication"
                    WindowsAuthMethod    = "NTLM"
                }
            )
            Intranet = @(
                MSFT_SPWebAppAuthenticationMode {
                    AuthenticationMethod = "Federated"
                    AuthenticationProvider = $DomainFQDN
                }
            )
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplicationExtension]ExtendMainWebApp", "[SPTrustedIdentityTokenIssuer]CreateSPTrust"
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
            DependsOn            = "[SPWebApplicationExtension]ExtendMainWebApp"
        }

        SPCacheAccounts SetCacheAccounts
        {
            WebAppUrl            = "http://$SPTrustedSitesName/"
            SuperUserAlias       = "$DomainNetbiosName\$($SPSuperUserCreds.UserName)"
            SuperReaderAlias     = "$DomainNetbiosName\$($SPSuperReaderCreds.UserName)"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebApplication]CreateMainWebApp"
        }

        SPSite CreateRootSite
        {
            Url                  = "http://$SPTrustedSitesName/"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:0$TrustedIdChar.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "Team site"
            Template             = $SPTeamSiteTemplate
            CreateDefaultGroups  = $true
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebAppAuthentication]ConfigureMainWebAppAuthentication"
        }

        # Create this site early, otherwise [SPAppCatalog]SetAppCatalogUrl may throw error "Cannot find an SPSite object with Id or Url: http://SPSites/sites/AppCatalog"
        SPSite CreateAppCatalog
        {
            Url                  = "http://$SPTrustedSitesName/sites/AppCatalog"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:0$TrustedIdChar.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "AppCatalog"
            Template             = "APPCATALOG#0"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebAppAuthentication]ConfigureMainWebAppAuthentication"
        }

        #**********************************************************
        # Additional configuration
        #**********************************************************
        SPSite CreateMySiteHost
        {
            Url                      = "http://$MySiteHostAlias/"
            HostHeaderWebApplication = "http://$SPTrustedSitesName/"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:0$TrustedIdChar.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "MySite host"
            Template                 = "SPSMSITEHOST#0"
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[SPWebAppAuthentication]ConfigureMainWebAppAuthentication"
        }

        SPSiteUrl SetMySiteHostIntranetUrl
        {
            Url                  = "http://$MySiteHostAlias/"
            Intranet             = "https://$MySiteHostAlias.$DomainFQDN"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]CreateMySiteHost"
        }

        SPManagedPath CreateMySiteManagedPath
        {
            WebAppUrl            = "http://$SPTrustedSitesName/"
            RelativeUrl          = "personal"
            Explicit             = $false
            HostHeader           = $true
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]CreateMySiteHost"
        }

        SPUserProfileServiceApp CreateUserProfileServiceApp
        {
            Name                 = $UpaServiceName
            ApplicationPool      = $ServiceAppPoolName
            MySiteHostLocation   = "http://$MySiteHostAlias/"
            ProfileDBName        = $SPDBPrefix + "UPA_Profiles"
            SocialDBName         = $SPDBPrefix + "UPA_Social"
            SyncDBName           = $SPDBPrefix + "UPA_Sync"
            EnableNetBIOS        = $false
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]UPAServiceInstance", "[SPSite]CreateMySiteHost"
        }

        # Creating this site takes about 1 min but it is not so useful, skip it
        # SPSite CreateDevSite
        # {
        #     Url                  = "http://$SPTrustedSitesName/sites/dev"
        #     OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
        #     SecondaryOwnerAlias  = "i:0$TrustedIdChar.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
        #     Name                 = "Developer site"
        #     Template             = "DEV#0"
        #     PsDscRunAsCredential = $SPSetupCredsQualified
        #     DependsOn            = "[SPWebAppAuthentication]ConfigureMainWebAppAuthentication"
        # }

        SPSite CreateHNSC1
        {
            Url                      = "http://$HNSC1Alias/"
            HostHeaderWebApplication = "http://$SPTrustedSitesName/"
            OwnerAlias               = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias      = "i:0$TrustedIdChar.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                     = "$HNSC1Alias site"
            Template                 = $SPTeamSiteTemplate
            CreateDefaultGroups      = $true
            PsDscRunAsCredential     = $SPSetupCredsQualified
            DependsOn                = "[SPWebAppAuthentication]ConfigureMainWebAppAuthentication"
        }

        SPSiteUrl SetHNSC1IntranetUrl
        {
            Url                  = "http://$HNSC1Alias/"
            Intranet             = "https://$HNSC1Alias.$DomainFQDN"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]CreateHNSC1"
        }

        SPSubscriptionSettingsServiceApp CreateSubscriptionServiceApp
        {
            Name                 = "Subscription Settings Service Application"
            ApplicationPool      = $ServiceAppPoolName
            DatabaseName         = "$($SPDBPrefix)SubscriptionSettings"
            InstallAccount       = $SPSetupCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]StartSubscriptionSettingsServiceInstance", "[xScript]ConfigureLDAPCP"
        }

        SPAppManagementServiceApp CreateAppManagementServiceApp
        {
            Name                 = "App Management Service Application"
            ApplicationPool      = $ServiceAppPoolName
            DatabaseName         = "$($SPDBPrefix)AppManagement"
            InstallAccount       = $SPSetupCredsQualified
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool", "[SPServiceInstance]StartAppManagementServiceInstance"
        }

        # Grant spsvc full control to UPA to allow newsfeeds to work properly
        SPServiceAppSecurity SetUserProfileServiceSecurity
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
            DependsOn            = "[SPUserProfileServiceApp]CreateUserProfileServiceApp"
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

        # Execute this action some time after CreateAppManagementServiceApp to avoid this error: An update conflict has occurred, and you must re-try this action. The object AppManagementService was updated by CONTOSO\\spsetup, in the wsmprovhost (5136) process, on machine SP
        SPAppDomain ConfigureLocalFarmAppUrls
        {
            AppDomain            = $AppDomainFQDN
            Prefix               = "addin"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSubscriptionSettingsServiceApp]CreateSubscriptionServiceApp", "[SPAppManagementServiceApp]CreateAppManagementServiceApp"
        }        

        SPWebApplicationAppDomain ConfigureAppDomainDefaultZone
        {
            WebAppUrl            = "http://$SPTrustedSitesName"
            AppDomain            = $AppDomainFQDN
            Zone                 = "Default"
            Port                 = 80
            SSL                  = $false
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPAppDomain]ConfigureLocalFarmAppUrls"
        }

        SPWebApplicationAppDomain ConfigureAppDomainIntranetZone
        {
            WebAppUrl            = "http://$SPTrustedSitesName"
            AppDomain            = $AppDomainIntranetFQDN
            Zone                 = "Intranet"
            Port                 = 443
            SSL                  = $true
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPAppDomain]ConfigureLocalFarmAppUrls"
        }

        SPAppCatalog SetAppCatalogUrl
        {
            SiteUrl              = "http://$SPTrustedSitesName/sites/AppCatalog"
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPSite]CreateAppCatalog","[SPAppManagementServiceApp]CreateAppManagementServiceApp"
        }
        
        # This team site is tested by VM FE to wait before joining the farm, so it acts as a milestone and it should be created only when all SharePoint services are created
        # If VM FE joins the farm while a SharePoint service is creating here, it may block its creation forever.
        SPSite CreateTeamSite
        {
            Url                  = "http://$SPTrustedSitesName/sites/team"
            OwnerAlias           = "i:0#.w|$DomainNetbiosName\$($DomainAdminCreds.UserName)"
            SecondaryOwnerAlias  = "i:0$TrustedIdChar.t|$DomainFQDN|$($DomainAdminCreds.UserName)@$DomainFQDN"
            Name                 = "Team site"
            Template             = $SPTeamSiteTemplate
            CreateDefaultGroups  = $true
            PsDscRunAsCredential = $SPSetupCredsQualified
            DependsOn            = "[SPWebAppAuthentication]ConfigureMainWebAppAuthentication", "[SPWebApplicationAppDomain]ConfigureAppDomainDefaultZone", "[SPWebApplicationAppDomain]ConfigureAppDomainIntranetZone", "[SPAppCatalog]SetAppCatalogUrl"
        }

        CertReq GenerateAddinsSiteCertificate
        {
            CARootName             = "$DomainNetbiosName-$DCName-CA"
            CAServerFQDN           = "$DCName.$DomainFQDN"
            Subject                = "$AddinsSiteDNSAlias.$($DomainFQDN)"
            FriendlyName           = "Provider-hosted addins site certificate"
            SubjectAltName         = "dns=$AddinsSiteDNSAlias.$($DomainFQDN)"
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

        File CreateAddinsSiteDirectory
        {
            DestinationPath = "C:\inetpub\wwwroot\addins"
            Type            = "Directory"
            Ensure          = "Present"
            DependsOn       = "[SPFarm]CreateSPFarm", "[xScript]ConfigureLDAPCP"
        }

        xWebAppPool CreateAddinsSiteApplicationPool
        {
            Name                  = $AddinsSiteName
            State                 = "Started"
            managedPipelineMode   = 'Integrated'
            managedRuntimeLoader  = 'webengine4.dll'
            managedRuntimeVersion = 'v4.0'
            identityType          = "SpecificUser"
            Credential            = $SPSvcCredsQualified
            Ensure                = "Present"
            PsDscRunAsCredential  = $DomainAdminCredsQualified
            DependsOn             = "[SPFarm]CreateSPFarm"
        }

        xWebsite CreateAddinsSite
        {
            Name                 = $AddinsSiteName
            State                = "Started"
            PhysicalPath         = "C:\inetpub\wwwroot\addins"
            ApplicationPool      = $AddinsSiteName
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
                    CertificateSubject   = "$AddinsSiteDNSAlias.$($DomainFQDN)"
                }
            )
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[CertReq]GenerateAddinsSiteCertificate", "[File]CreateAddinsSiteDirectory", "[xWebAppPool]CreateAddinsSiteApplicationPool"
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
            DependsOn            = "[xWebsite]CreateAddinsSite"
        }

        CertReq GenerateHighTrustAddinsCert
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
            DependsOn              = "[xScript]UpdateGPOToTrustRootCACert"
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
            DependsOn = "[CertReq]GenerateHighTrustAddinsCert"
        }

        SPTrustedSecurityTokenIssuer CreateHighTrustAddinsTrustedIssuer
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
                $SetupPath = $using:SetupPath
                $ComputerName = $using:ComputerName
                $DestinationPath = "$SetupPath\SPDSCFinished.txt"
                $Contents = "DSC Configuration on $ComputerName finished successfully."
                # Do not overwrite and do not throw an exception if file already exists
                New-Item $DestinationPath -Type file -Value $Contents -ErrorAction SilentlyContinue
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPTrustedSecurityTokenIssuer]CreateHighTrustAddinsTrustedIssuer"
        }

        # if ($EnableAnalysis) {
        #     # This resource is for analysis of dsc logs only and totally optionnal
        #     xScript parseDscLogs
        #     {
        #         TestScript = { return $false }
        #         SetScript = {
        #             $setupPath = $using:SetupPath
        #             $localScriptPath = "$setupPath\parse-dsc-logs.py"
        #             New-Item -ItemType Directory -Force -Path $setupPath

        #             $url = "https://gist.githubusercontent.com/Yvand/777a2e97c5d07198b926d7bb4f12ab04/raw/parse-dsc-logs.py"
        #             $downloader = New-Object -TypeName System.Net.WebClient
        #             $downloader.DownloadFile($url, $localScriptPath)

        #             $dscExtensionPath = "C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC"
        #             $folderWithMaxVersionNumber = Get-ChildItem -Directory -Path $dscExtensionPath | Where-Object { $_.Name -match "^[\d\.]+$"} | Sort-Object -Descending -Property Name | Select-Object -First 1
        #             $fullPathToDscLogs = [System.IO.Path]::Combine($dscExtensionPath, $folderWithMaxVersionNumber)
                    
        #             python $localScriptPath "$fullPathToDscLogs"
        #         }
        #         GetScript = { }
        #         DependsOn            = "[cChocoPackageInstaller]InstallPython"
        #         PsDscRunAsCredential = $DomainAdminCredsQualified
        #     }
        # }
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
# Azure DSC extension logging: C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.83.1.0
# Azure DSC extension configuration: C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.1.0\DSCWork

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

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.1.0\DSCWork\ConfigureSPVM.0\ConfigureSPVM"
ConfigureSPVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPAppPoolCreds $SPAppPoolCreds -SPPassphraseCreds $SPPassphraseCreds -SPSuperUserCreds $SPSuperUserCreds -SPSuperReaderCreds $SPSuperReaderCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>
