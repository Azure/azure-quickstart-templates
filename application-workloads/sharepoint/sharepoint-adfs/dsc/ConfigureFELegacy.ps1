configuration ConfigureFEVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServerIP,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [String]$DCServerName,
        [Parameter(Mandatory)] [String]$SQLServerName,
        [Parameter(Mandatory)] [String]$SQLAlias,
        [Parameter(Mandatory)] [String]$SharePointVersion,
        [Parameter(Mandatory)] [String]$SharePointSitesAuthority,
        [Parameter(Mandatory)] [Boolean]$EnableAnalysis,
        [Parameter()] [System.Object[]] $SharePointBits,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPFarmCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.0.0
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.2.0
    Import-DscResource -ModuleName WebAdministrationDsc -ModuleVersion 4.1.0
    Import-DscResource -ModuleName SharePointDsc -ModuleVersion 5.3.0
    Import-DscResource -ModuleName DnsServerDsc -ModuleVersion 3.0.0
    Import-DscResource -ModuleName CertificateDsc -ModuleVersion 5.1.0
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 16.0.0
    Import-DscResource -ModuleName cChoco -ModuleVersion 2.5.0.0    # With custom changes to implement retry on package downloads

    # Init
    [String] $InterfaceAlias = (Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1).Name
    [String] $ComputerName = Get-Content env:computername
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)

    # Format credentials to be qualified by domain name: "domain\username"
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("$DomainNetbiosName\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("$DomainNetbiosName\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("$DomainNetbiosName\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)

    # Setup settings
    [String] $SetupPath = "C:\DSC Data"
    [String] $DscStatusFilePath = "$SetupPath\dsc-status-$ComputerName.log"
    [String] $AdfsDnsEntryName = "adfs"

    # SharePoint settings
    [String] $SPDBPrefix = "SPDSC_"
    [String] $AppDomainIntranetFQDN = "{0}{1}.{2}" -f $DomainFQDN.Split('.')[0], "Apps-Intranet", $DomainFQDN.Split('.')[1]
    [String] $MySiteHostAlias = "OhMy"
    [String] $HNSC1Alias = "HNSC1"

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        Script DscStatus_Start
        {
            SetScript =
            {
                $destinationFolder = $using:SetupPath
                if (!(Test-Path $destinationFolder -PathType Container)) {
                    New-Item -ItemType Directory -Force -Path $destinationFolder
                }
                "$(Get-Date -Format u)`t$($using:ComputerName)`tDSC Configuration starting..." | Out-File -FilePath $using:DscStatusFilePath -Append
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
        }

        #**********************************************************
        # Initialization of VM - Do as much work as possible before waiting on AD domain to be available
        #**********************************************************
        WindowsFeature AddADTools             { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature AddADPowerShell        { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        WindowsFeature AddDnsTools            { Name = "RSAT-DNS-Server";    Ensure = "Present"; }
        WindowsFeature AddADLDS               { Name = "RSAT-ADLDS";         Ensure = "Present"; }
        WindowsFeature AddADCSManagementTools { Name = "RSAT-ADCS-Mgmt";     Ensure = "Present"; }
        DnsServerAddress SetDNS { Address = $DNSServerIP; InterfaceAlias = $InterfaceAlias; AddressFamily  = 'IPv4' }

        # # xCredSSP is required forSharePointDsc resources SPUserProfileServiceApp and SPDistributedCacheService
        # xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[DnsServerAddress]SetDNS" }
        # xCredSSP CredSSPClient { Ensure = "Present"; Role = "Client"; DelegateComputers = "*.$DomainFQDN", "localhost"; DependsOn = "[xCredSSP]CredSSPServer" }

        # Allow NTLM on HTTPS sites when site host name is different than the machine name - https://docs.microsoft.com/en-US/troubleshoot/windows-server/networking/accessing-server-locally-with-fqdn-cname-alias-denied
        Registry DisableLoopBackCheck { Key = "HKLM:\System\CurrentControlSet\Control\Lsa"; ValueName = "DisableLoopbackCheck"; ValueData = "1"; ValueType = "Dword"; Ensure = "Present" }

        # Enable TLS 1.2 - https://learn.microsoft.com/en-us/azure/active-directory/app-proxy/application-proxy-add-on-premises-application#tls-requirements
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

        Registry DisableIESecurityRegKey1 { Key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'; ValueName = 'IsInstalled'; ValueType = 'Dword'; ValueData = '0'; Force = $true ; Ensure = 'Present' }
        Registry DisableIESecurityRegKey2 { Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main'; ValueName = 'DisableFirstRunCustomize'; ValueType = 'Dword'; ValueData = '1'; Force = $true ; Ensure = 'Present' }
        Registry DisableIESecurityRegKey3 { Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\TabbedBrowsing'; ValueName = 'NewTabPageShow'; ValueType = 'Dword'; ValueData = '0'; Force = $true ; Ensure = 'Present' }

        # From https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=powershell :
        # Starting in Windows 10, version 1607, MAX_PATH limitations have been removed from common Win32 file and directory functions. However, you must opt-in to the new behavior.
        Registry SetLongPathsEnabled { Key = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"; ValueName = "LongPathsEnabled"; ValueType = "DWORD"; ValueData = "1"; Force = $true; Ensure = "Present" }
        
        Registry ShowWindowsExplorerRibbon { Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; ValueName = "ExplorerRibbonStartsMinimized"; ValueType = "DWORD"; ValueData = "4"; Force = $true; Ensure = "Present" }

        if ($SharePointVersion -eq "2019") {
            # Allow OneDrive NGSC to connect to SharePoint Subscription / 2019 - https://learn.microsoft.com/en-us/sharepoint/install/configure-syncing-with-the-onedrive-sync-app
            Registry SetOneDriveUrl { Key = "HKLM:\Software\Policies\Microsoft\OneDrive"; ValueName = "SharePointOnPremFrontDoorUrl"; ValueType = "String"; ValueData = "http://{0}" -f $MySiteHostAlias; Ensure = "Present" }
            Registry SetOneDriveName { Key = "HKLM:\Software\Policies\Microsoft\OneDrive"; ValueName = "SharePointOnPremTenantName"; ValueType = "String"; ValueData = "{0} - {1}" -f $DomainNetbiosName, $MySiteHostAlias; Ensure = "Present" }
        }

        if ($SharePointVersion -eq "2013") {
            # Those 2 registry keys are required in SPS 2013 image to fix the psconfigui timeout error - https://support.microsoft.com/en-us/topic/some-document-conversion-services-in-sharepoint-server-are-not-secure-when-they-run-in-a-particular-environment-c39cd633-1e6a-18b1-9f2f-d0e7073a26bd
            Registry FixDocumentConversionKeyMissing  { Key = "HKLM:\SOFTWARE\Microsoft\Office Server\15.0\LauncherSettings";     ValueName = "AcknowledgedRunningOnAppServer"; ValueData = "1"; ValueType = "Dword"; Ensure = "Present" }
            Registry FixDocumentConversionKeyMissing2 { Key = "HKLM:\SOFTWARE\Microsoft\Office Server\15.0\LoadBalancerSettings"; ValueName = "AcknowledgedRunningOnAppServer"; ValueData = "1"; ValueType = "Dword"; Ensure = "Present" }
        }

        SqlAlias AddSqlAlias { Ensure = "Present"; Name = $SQLAlias; ServerName = $SQLServerName; Protocol = "TCP"; TcpPort= 1433 }

        Script EnableFileSharing
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

        # Create the rules in the firewall required for the distributed cache - https://learn.microsoft.com/en-us/sharepoint/administration/plan-for-feeds-and-the-distributed-cache-service#firewall
        Script CreateFirewallRulesForDistributedCache
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
        Script DscStatus_InstallApps
        {
            SetScript =
            {
                "$(Get-Date -Format u)`t$($using:ComputerName)`tInstall applications..." | Out-File -FilePath $using:DscStatusFilePath -Append
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
        }

        cChocoInstaller InstallChoco
        {
            InstallDir = "C:\Chocolatey"
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
        {   # Install takes about 30 secs
            Name                 = "vscode"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallAzureDataStudio
        {   # Install takes about 40 secs
            Name                 = "azure-data-studio"
            Ensure               = "Present"
            DependsOn            = "[cChocoInstaller]InstallChoco"
        }

        # if ($EnableAnalysis) {
        #     # This resource is only for analyzing dsc logs using a custom Python script
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
                        Write-Host "DNS record '$dnsRecordFQDN' not found yet: $_"
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
        #     DependsOn               = "[DnsServerAddress]SetDNS"
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
            DependsOn  = "[Script]WaitForADFSFarmReady"
        }

        PendingReboot RebootOnSignalFromJoinDomain
        {
            Name             = "RebootOnSignalFromJoinDomain"
            SkipCcmClientSDK = $true
            DependsOn        = "[Computer]JoinDomain"
        }

        Registry ShowFileExtensions { Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; ValueName = "HideFileExt"; ValueType = "DWORD"; ValueData = "0"; Force = $true; Ensure = "Present"; PsDscRunAsCredential = $DomainAdminCredsQualified }
        
        # This script is still needed
        Script CreateWSManSPNsIfNeeded
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
                Write-Host "Adding SPNs 'WSMAN/$computerName' and 'WSMAN/$computerName.$domainFQDN' to computer '$computerName'"
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

        # Fiddler must be installed as $DomainAdminCredsQualified because it's a per-user installation
        cChocoPackageInstaller InstallFiddler
        {
            Name                 = "fiddler"
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

        #********************************************************************
        # Wait for SharePoint app server to be ready
        #********************************************************************
        # The best test is to check the latest HTTP team site to be created, after all SharePoint services are provisioned.
        # If this server joins the farm while a SharePoint service is being created on the 1st server, it may block its creation forever.
        # Not testing HTTPS avoid potential issues with the root CA cert maybe not present in the machine store yet
        Script WaitForSPFarmReadyToJoin
        {
            SetScript =
            {
                $uri = "http://$($using:SharePointSitesAuthority)/sites/team"
                $sleepTime = 30
                $currentStatusCode = 0
                $expectedStatusCode = 200
                do {
                    try
                    {
                        Write-Host "Trying to connect to $uri..."
                        # -UseDefaultCredentials: Does NTLM authN
                        # -UseBasicParsing: Avoid exception because IE was not first launched yet
                        $Response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials -TimeoutSec 10 -ErrorAction Stop -UseBasicParsing
                        # When it will be actually ready, site will respond 401/302/200, and $Response.StatusCode will be 200
                        $currentStatusCode = $Response.StatusCode
                    }
                    catch [System.Net.WebException]
                    {
                        # We always expect a WebException until site is actually up. 
                        # Write-Host "Request failed with a WebException: $($_.Exception)"
                        if ($null -ne $_.Exception.Response) {
                            $currentStatusCode = $_.Exception.Response.StatusCode.value__
                        }
                    }
                    catch
                    {
                        Write-Host "Request failed with an unexpected exception: $($_.Exception)"
                    }

                    if ($currentStatusCode -ne $expectedStatusCode){
                        Write-Host "Connection to $uri... returned status code $currentStatusCode while $expectedStatusCode is expected, retrying in $sleepTime secs..."
                        Start-Sleep -Seconds $sleepTime
                    }
                    else {
                        Write-Host "Connection to $uri... returned expected status code $currentStatusCode, exiting..."
                    }
                } while ($currentStatusCode -ne $expectedStatusCode)
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Script]CreateWSManSPNsIfNeeded"
        }

        # Setup account is created by SP VM so it must be added to local admins group after the waiting script, to be sure it was created
        Group AddSPSetupAccountToAdminGroup
        {
            GroupName            = "Administrators"
            Ensure               = "Present"
            MembersToInclude     = @("$($SPSetupCredsQualified.UserName)")
            Credential           = $DomainAdminCredsQualified
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Script]WaitForSPFarmReadyToJoin"
        }

        # Update GPO to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\", otherwise certificate request will fail
        # At this point it is safe to assume that the DC finished provisioning AD CS
        Script UpdateGPOToTrustRootCACert
        {
            SetScript =
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
                } else {
                    return $true    # Root CA already present
                }
            }
            DependsOn            = "[Script]WaitForSPFarmReadyToJoin"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        # If multiple servers join the SharePoint farm at the same time, resource JoinSPFarm may fail on a server with this error:
        # "Scheduling DiagnosticsService timer job failed" (SharePoint event id aitap or aitaq)
        # This script uses the computer name (FE-0 FE-1) to sequence the time when servers join the farm
        Script WaitToAvoidServersJoiningFarmSimultaneously
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
                Write-Host "Computer $computerName is going to wait for $sleepTimeInSeconds seconds before joining the SharePoint farm, to avoid multiple servers joining it at the same time"
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
                # If RunCentralAdmin is false and configdb does not exist, SPFarm checks during 30 mins if configdb got created and joins the farm
                RunCentralAdmin           = $false
                IsSingleInstance          = "Yes"
                SkipRegisterAsDistributedCacheHost = $true
                Ensure                    = "Present"
                DependsOn                 = "[Script]WaitToAvoidServersJoiningFarmSimultaneously"
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
                # If RunCentralAdmin is false and configdb does not exist, SPFarm checks during 30 mins if configdb got created and joins the farm
                RunCentralAdmin           = $false
                IsSingleInstance          = "Yes"
                ServerRole                = "WebFrontEnd"
                SkipRegisterAsDistributedCacheHost = $true
                Ensure                    = "Present"
                DependsOn                 = "[Script]WaitToAvoidServersJoiningFarmSimultaneously"
            }
        }

        DnsRecordCname UpdateDNSAliasSPSites
        {
            Name                 = $SharePointSitesAuthority
            ZoneName             = $DomainFQDN
            DnsServer            = $DCServerName
            HostNameAlias        = "$ComputerName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        DnsRecordCname UpdateDNSAliasOhMy
        {
            Name                 = $MySiteHostAlias
            ZoneName             = $DomainFQDN
            DnsServer            = $DCServerName
            HostNameAlias        = "$ComputerName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        DnsRecordCname UpdateDNSAliasHNSC1
        {
            Name                 = $HNSC1Alias
            ZoneName             = $DomainFQDN
            DnsServer            = $DCServerName
            HostNameAlias        = "$ComputerName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        CertReq SPSSiteCert
        {
            CARootName             = "$DomainNetbiosName-$DCServerName-CA"
            CAServerFQDN           = "$DCServerName.$DomainFQDN"
            Subject                = "$SharePointSitesAuthority.$DomainFQDN"
            SubjectAltName         = "dns=*.$DomainFQDN&dns=*.$AppDomainIntranetFQDN"
            KeyLength              = '2048'
            Exportable             = $true
            ProviderName           = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                    = '1.3.6.1.5.5.7.3.1'
            KeyUsage               = '0xa0'
            CertificateTemplate    = 'WebServer'
            AutoRenew              = $true
            Credential             = $DomainAdminCredsQualified
            DependsOn              = "[Script]UpdateGPOToTrustRootCACert"
        }

        Website SetHTTPSCertificate
        {
            Name                 = "SharePoint - 443"
            BindingInfo          = DSC_WebBindingInformation
            {
                Protocol             = "HTTPS"
                Port                 = 443
                CertificateStoreName = "My"
                CertificateSubject   = "$SharePointSitesAuthority.$DomainFQDN"
            }
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[CertReq]SPSSiteCert", "[SPFarm]JoinSPFarm"
        }

        Script WarmupSites
        {
            SetScript =
            {
                $jobBlock = {
                    $uri = $args[0]
                    try {
                        Write-Host "Connecting to $uri..."
                        # -UseDefaultCredentials: Does NTLM authN
                        # -UseBasicParsing: Avoid exception because IE was not first launched yet
                        # Expected traffic is HTTP 401/302/200, and $Response.StatusCode is 200
                        Invoke-WebRequest -Uri $uri -UseDefaultCredentials -TimeoutSec 40 -UseBasicParsing -ErrorAction SilentlyContinue
                        Write-Host "Connected successfully to $uri"
                    }
                    catch [System.Exception] {
                        Write-Host "Unexpected error while connecting to '$uri': $_"
                    }
                    catch {
                        # It may typically be a System.Management.Automation.ErrorRecord, which does not inherit System.Exception
                        Write-Host "Unexpected error while connecting to '$uri'"
                    }
                }
                [System.Management.Automation.Job[]] $jobs = @()
                $spsite = "http://$($using:SharePointSitesAuthority)/"
                Write-Host "Warming up '$spsite'..."
                $jobs += Start-Job -ScriptBlock $jobBlock -ArgumentList @($spsite)

                # Must wait for the jobs to complete, otherwise they do not actually run
                Receive-Job -Job $jobs -AutoRemoveJob -Wait
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[DnsRecordCname]UpdateDNSAliasSPSites"
        }

        Script CreateShortcuts
        {
            SetScript =
            {
                $sharePointVersion = $using:SharePointVersion
                $directoryVersion = "16"
                if ($sharePointVersion -eq "2013") { $directoryVersion = "15" }
                $WshShell = New-Object -comObject WScript.Shell
                # Shortcut to the setup folder
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Setup data.lnk")
                $Shortcut.TargetPath = $using:SetupPath
                $Shortcut.Save()

                # Shortcut for SharePoint Central Administration
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SharePoint $sharePointVersion Central Administration.lnk")
                $Shortcut.TargetPath = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\$directoryVersion\BIN\psconfigui.exe"
                $Shortcut.Arguments = "-cmd showcentraladmin"
                $Shortcut.Save()

                # Shortcut for SharePoint Products Configuration Wizard
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SharePoint $sharePointVersion Products Configuration Wizard.lnk")
                $Shortcut.TargetPath = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\$directoryVersion\BIN\psconfigui.exe"
                $Shortcut.Save()

                # Shortcut for SharePoint Management Shell
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SharePoint $sharePointVersion Management Shell.lnk")
                $Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe"
                $Shortcut.Arguments = " -NoExit -Command ""& 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\$directoryVersion\CONFIG\POWERSHELL\Registration\SharePoint.ps1'"""
                $Shortcut.Save()
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        # if ($EnableAnalysis) {
        #     # This resource is for analysis of dsc logs only and totally optionnal
        #     Script parseDscLogs
        #     {
        #         TestScript = { return (Test-Path "$setupPath\parse-dsc-logs.py" -PathType Leaf) }
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
                    
        #             # Start python script
        #             Write-Host "Run python `"$localScriptPath`" `"$fullPathToDscLogs`"..."
        #             #Start-Process -FilePath "powershell" -ArgumentList "python `"$localScriptPath`" `"$fullPathToDscLogs`""
        #             #invoke-expression "cmd /c start powershell -Command { $localScriptPath $fullPathToDscLogs }"
        #             python "$localScriptPath" "$fullPathToDscLogs"

        #             # Create a shortcut to the DSC logs folder
        #             $WshShell = New-Object -comObject WScript.Shell
        #             $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\DSC logs.lnk")
        #             $Shortcut.TargetPath = $fullPathToDscLogs
        #             $Shortcut.Save()

        #             # Create shortcut to DSC configuration folder
        #             $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\DSC config.lnk")
        #             $Shortcut.TargetPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\{0}\DSCWork\ConfigureFELegacy.0" -f $folderWithMaxVersionNumber
        #             $Shortcut.Save()
        #         }
        #         GetScript = { }
        #         DependsOn            = "[cChocoPackageInstaller]InstallPython"
        #         PsDscRunAsCredential = $DomainAdminCredsQualified
        #     }
        # }

        Script DscStatus_Finished
        {
            SetScript =
            {
                "$(Get-Date -Format u)`t$($using:ComputerName)`tDSC Configuration on finished." | Out-File -FilePath $using:DscStatusFilePath -Append
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
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

function Get-SPDSCInstalledProductVersion
{
    $pathToSearch = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\*\ISAPI\Microsoft.SharePoint.dll"
    $fullPath = Get-Item $pathToSearch | Sort-Object { $_.Directory } -Descending | Select-Object -First 1
    return (Get-Command $fullPath).FileVersionInfo
}

<#
help ConfigureFEVM

$password = ConvertTo-SecureString -String "mytopsecurepassword" -AsPlainText -Force
$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$SPFarmCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spfarm", $password
$SPPassphraseCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Passphrase", $password
$DNSServerIP = "10.1.1.4"
$DomainFQDN = "contoso.local"
$DCServerName = "DC"
$SQLServerName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "2019"
$EnableAnalysis = $false
$SharePointBits = @()

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.5\DSCWork\ConfigureFELegacy.0\ConfigureFEVM"
ConfigureFEVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DCServerName $DCServerName -SQLServerName $SQLServerName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -EnableAnalysis $EnableAnalysis -SharePointBits $SharePointBits -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.83.5
#>