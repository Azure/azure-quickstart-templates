configuration ConfigureFEVM
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
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc, NetworkingDsc, ActiveDirectoryDsc, xWebAdministration, SharePointDsc, xPSDesiredStateConfiguration, xDnsServer, CertificateDsc, SqlServerDsc, cChoco

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [String] $SPDBPrefix = "SPDSC_"
    [String] $SPTrustedSitesName = "spsites"
    [String] $ComputerName = Get-Content env:computername
    [String] $AppDomainIntranetFQDN = (Get-AppDomain -DomainFQDN $DomainFQDN -Suffix "Apps-Intranet")
    [String] $SetupPath = "C:\Setup"
    [String] $MySiteHostAlias = "OhMy"
    [String] $HNSC1Alias = "HNSC1"

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

        # # xCredSSP is required forSharePointDsc resources SPUserProfileServiceApp and SPDistributedCacheService
        # xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[DnsServerAddress]SetDNS" }
        # xCredSSP CredSSPClient { Ensure = "Present"; Role = "Client"; DelegateComputers = "*.$DomainFQDN", "localhost"; DependsOn = "[xCredSSP]CredSSPServer" }

        # IIS cleanup
        xWebAppPool RemoveDotNet2Pool         { Name = ".NET v2.0";            Ensure = "Absent"; }
        xWebAppPool RemoveDotNet2ClassicPool  { Name = ".NET v2.0 Classic";    Ensure = "Absent"; }
        xWebAppPool RemoveDotNet45Pool        { Name = ".NET v4.5";            Ensure = "Absent"; }
        xWebAppPool RemoveDotNet45ClassicPool { Name = ".NET v4.5 Classic";    Ensure = "Absent"; }
        xWebAppPool RemoveClassicDotNetPool   { Name = "Classic .NET AppPool"; Ensure = "Absent"; }
        xWebAppPool RemoveDefaultAppPool      { Name = "DefaultAppPool";       Ensure = "Absent"; }
        xWebSite    RemoveDefaultWebSite      { Name = "Default Web Site";     Ensure = "Absent"; PhysicalPath = "C:\inetpub\wwwroot"; }

        # Allow sign-in on HTTPS sites when site host name is different than the machine name: https://support.microsoft.com/en-us/help/926642
        Registry DisableLoopBackCheck
        {
            Key       = "HKLM:\System\CurrentControlSet\Control\Lsa"
            ValueName = "DisableLoopbackCheck"
            ValueData = "1"
            ValueType = "Dword"
            Ensure    = "Present"
        }

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

        SqlAlias AddSqlAlias
        {
            Ensure               = "Present"
            Name                 = $SQLAlias
            ServerName           = $SQLName
            Protocol             = "TCP"
            TcpPort              = 1433
        }

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

        cChocoPackageInstaller InstallChrome
        {
            Name                 = "GoogleChrome"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallEverything
        {
            Name                 = "everything"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallILSpy
        {
            Name                 = "ilspy"
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
            DependsOn            = "[cChocoInstaller]InstallChoco", "[PendingReboot]RebootOnSignalFromJoinDomain"
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

        #********************************************************************
        # Wait for SharePoint app server to be ready
        #********************************************************************
        # The best test is to check the latest HTTP team site to be created, after all SharePoint services are provisioned.
        # If this server joins the farm while a SharePoint service is being created on the 1st server, it may block its creation forever.
        # Not testing HTTPS avoid potential issues with the root CA cert maybe not present in the machine store yet
        xScript WaitForSPFarmReadyToJoin
        {
            SetScript =
            {
                $uri = "http://$($using:SPTrustedSitesName)/sites/team"
                $sleepTime = 30
                $currentStatusCode = 0
                $expectedStatusCode = 200
                do {
                    try
                    {
                        Write-Verbose "Trying to connect to $uri..."
                        # -UseDefaultCredentials: Does NTLM authN
                        # -UseBasicParsing: Avoid exception because IE was not first launched yet
                        $Response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials -TimeoutSec 10 -ErrorAction Stop -UseBasicParsing
                        # When it will be actually ready, site will respond 401/302/200, and $Response.StatusCode will be 200
                        $currentStatusCode = $Response.StatusCode
                    }
                    catch [System.Net.WebException]
                    {
                        # We always expect a WebException until site is actually up. 
                        # Write-Verbose "Request failed with a WebException: $($_.Exception)"
                        if ($null -ne $_.Exception.Response) {
                            $currentStatusCode = $_.Exception.Response.StatusCode.value__
                        }
                    }
                    catch
                    {
                        Write-Verbose "Request failed with an unexpected exception: $($_.Exception)"
                    }

                    if ($currentStatusCode -ne $expectedStatusCode){
                        Write-Verbose "Connection to $uri... returned status code $currentStatusCode while $expectedStatusCode is expected, retrying in $sleepTime secs..."
                        Start-Sleep -Seconds $sleepTime
                    }
                    else {
                        Write-Verbose "Connection to $uri... returned expected status code $currentStatusCode, exiting..."
                    }
                } while ($currentStatusCode -ne $expectedStatusCode)
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xScript]CreateWSManSPNsIfNeeded"
        }

        # Setup account is created by SP VM so it must be added to local admins group after the waiting script, to be sure it was created
        Group AddSPSetupAccountToAdminGroup
        {
            GroupName            = "Administrators"
            Ensure               = "Present"
            MembersToInclude     = @("$($SPSetupCredsQualified.UserName)")
            Credential           = $DomainAdminCredsQualified
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xScript]WaitForSPFarmReadyToJoin"
        }

        # Update GPO to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\", otherwise certificate request will fail
        # At this point it is safe to assume that the DC finished provisioning AD CS
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
            DependsOn            = "[xScript]WaitForSPFarmReadyToJoin"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        # If multiple servers join the SharePoint farm at the same time, resource JoinSPFarm may fail on a server with this error:
        # "Scheduling DiagnosticsService timer job failed" (SharePoint event id aitap or aitaq)
        # This script uses the computer name (FE-0 FE-1) to sequence the time when servers join the farm
        xScript WaitToAvoidServersJoiningFarmSimultaneously
        {
            SetScript =
            {                
                $computerName = $env:computerName
                $digitFound = $computerName -match '\d+'
                if ($digitFound) {
                    $computerNumber = [Convert]::ToInt16($matches[0])
                }
                else {
                    $computerNumber = 0
                }
                $sleepTimeInSeconds = $computerNumber * 90  # Add a delay of 90 secs between each server
                Write-Verbose "Computer $computerName is going to wait for $sleepTimeInSeconds seconds before joining the SharePoint farm, to avoid multiple servers joining it at the same time"
                Start-Sleep -Seconds $sleepTimeInSeconds
                New-Item -Path HKLM:\SOFTWARE\DscScriptExecution\Flag_WaitToAvoidServersJoiningFarmSimultaneously -Force
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = {    # Make sure this script resource runs only 1 time (and not at each reboot)
                return (Test-Path HKLM:\SOFTWARE\DscScriptExecution\Flag_WaitToAvoidServersJoiningFarmSimultaneously)
            }
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Group]AddSPSetupAccountToAdminGroup"
        }

        #**********************************************************
        # Join SharePoint farm
        #**********************************************************
        if ($SharePointVersion -eq "2013") {
            # Do not set property ServerRole as it is not supported in SharePoint 2013
            SPFarm JoinSPFarm
            {
                DatabaseServer            = $SQLAlias
                FarmConfigDatabaseName    = $SPDBPrefix + "Config"
                Passphrase                = $SPPassphraseCreds
                FarmAccount               = $SPFarmCredsQualified
                PsDscRunAsCredential      = $SPSetupCredsQualified
                AdminContentDatabaseName  = $SPDBPrefix + "AdminContent"
                CentralAdministrationPort = 5000
                # If RunCentralAdmin is false and configdb does not exist, SPFarm checks during 30 mins if configdb got created and joins the farm
                RunCentralAdmin           = $false
                IsSingleInstance          = "Yes"
                SkipRegisterAsDistributedCacheHost = $true
                Ensure                    = "Present"
                DependsOn                 = "[xScript]WaitToAvoidServersJoiningFarmSimultaneously"
            }
        } else {
            # Set property ServerRole in all SharePoint versions that support it
            SPFarm JoinSPFarm
            {
                DatabaseServer            = $SQLAlias
                FarmConfigDatabaseName    = $SPDBPrefix + "Config"
                Passphrase                = $SPPassphraseCreds
                FarmAccount               = $SPFarmCredsQualified
                PsDscRunAsCredential      = $SPSetupCredsQualified
                AdminContentDatabaseName  = $SPDBPrefix + "AdminContent"
                CentralAdministrationPort = 5000
                # If RunCentralAdmin is false and configdb does not exist, SPFarm checks during 30 mins if configdb got created and joins the farm
                RunCentralAdmin           = $false
                IsSingleInstance          = "Yes"
                ServerRole                = "WebFrontEnd"
                SkipRegisterAsDistributedCacheHost = $true
                Ensure                    = "Present"
                DependsOn                 = "[xScript]WaitToAvoidServersJoiningFarmSimultaneously"
            }
        }

        xDnsRecord UpdateDNSAliasSPSites
        {
            Name                 = $SPTrustedSitesName
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        xDnsRecord UpdateDNSAliasOhMy
        {
            Name                 = $MySiteHostAlias
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        xDnsRecord UpdateDNSAliasHNSC1
        {
            Name                 = $HNSC1Alias
            Zone                 = $DomainFQDN
            DnsServer            = $DCName
            Target               = "$ComputerName.$DomainFQDN"
            Type                 = "CName"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
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
            DependsOn            = "[CertReq]SPSSiteCert", "[SPFarm]JoinSPFarm"
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

Install-Module -Name xPendingReboot
help ConfigureFEVM

$DomainAdminCreds = Get-Credential -Credential "yvand"
$SPSetupCreds = Get-Credential -Credential "spsetup"
$SPFarmCreds = Get-Credential -Credential "spfarm"
$SPPassphraseCreds = Get-Credential -Credential "Passphrase"
$SPSuperUserCreds = Get-Credential -Credential "spSuperUser"
$SPSuperReaderCreds = Get-Credential -Credential "spSuperReader"
$DNSServer = "10.0.1.4"
$DomainFQDN = "contoso.local"
$DCName = "DC"
$SQLName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = 2019

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.1.0\DSCWork\ConfigureFEVM.0\ConfigureFEVM"
ConfigureFEVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>
