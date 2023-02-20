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
        [Parameter(Mandatory)] [System.Object[]] $SharePointBits,
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
    Import-DscResource -ModuleName StorageDsc -ModuleVersion 5.0.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0

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
    [String] $DCSetupPath = "\\$DCServerName\C$\DSC Data"
    [String] $DscStatusFilePath = "$SetupPath\dsc-status-$ComputerName.log"
    [String] $SharePointBuildLabel = $SharePointVersion.Split("-")[1]
    [String] $SharePointBitsPath = Join-Path -Path $SetupPath -ChildPath "Binaries" #[environment]::GetEnvironmentVariable("temp","machine")
    [String] $SharePointIsoFullPath = Join-Path -Path $SharePointBitsPath -ChildPath "OfficeServer.iso"
    [String] $SharePointIsoDriveLetter = "S"
    [String] $AdfsDnsEntryName = "adfs"

    # SharePoint settings
    [String] $SPDBPrefix = "SPDSC_"
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

        # # xCredSSP is required for SharePointDsc resources SPUserProfileServiceApp and SPDistributedCacheService
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

        # Allow OneDrive NGSC to connect to SharePoint Subscription / 2019 - https://learn.microsoft.com/en-us/sharepoint/install/configure-syncing-with-the-onedrive-sync-app
        Registry SetOneDriveUrl { Key = "HKLM:\Software\Policies\Microsoft\OneDrive"; ValueName = "SharePointOnPremFrontDoorUrl"; ValueType = "String"; ValueData = "http://{0}" -f $MySiteHostAlias; Ensure = "Present" }
        Registry SetOneDriveName { Key = "HKLM:\Software\Policies\Microsoft\OneDrive"; ValueName = "SharePointOnPremTenantName"; ValueType = "String"; ValueData = "{0} - {1}" -f $DomainNetbiosName, $MySiteHostAlias; Ensure = "Present" }
        
        SqlAlias AddSqlAlias { Ensure = "Present"; Name = $SQLAlias; ServerName = $SQLServerName; Protocol = "TCP"; TcpPort= 1433 }
        
        Script EnableFileSharing
        {
            GetScript = { }
            TestScript = { return $null -ne (Get-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -ErrorAction SilentlyContinue | Where-Object{$_.Profile -eq "Domain"}) }
            SetScript = { Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Domain -Confirm:$false }
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
        # Download and install for SharePoint
        #**********************************************************
        Script DscStatus_DownloadSharePoint
        {
            SetScript =
            {
                "$(Get-Date -Format u)`t$($using:ComputerName)`tDownload SharePoint bits and install it..." | Out-File -FilePath $using:DscStatusFilePath -Append
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
        }

        xRemoteFile DownloadSharePoint
        {
            DestinationPath = $SharePointIsoFullPath
            Uri             = ($SharePointBits | Where-Object {$_.Label -eq "RTM"}).Packages[0].DownloadUrl
            ChecksumType    = ($SharePointBits | Where-Object {$_.Label -eq "RTM"}).Packages[0].ChecksumType
            Checksum        = ($SharePointBits | Where-Object {$_.Label -eq "RTM"}).Packages[0].Checksum
            MatchSource     = $false
        }
        
        MountImage MountSharePointImage
        {
            ImagePath   = $SharePointIsoFullPath
            DriveLetter = $SharePointIsoDriveLetter
            DependsOn   = "[xRemoteFile]DownloadSharePoint"
        }
          
        WaitForVolume WaitForSharePointImage
        {
            DriveLetter      = $SharePointIsoDriveLetter
            RetryIntervalSec = 5
            RetryCount       = 10
            DependsOn        = "[MountImage]MountSharePointImage"
        }

        SPInstallPrereqs InstallPrerequisites
        {
            IsSingleInstance  = "Yes"
            InstallerPath     = "$($SharePointIsoDriveLetter):\Prerequisiteinstaller.exe"
            OnlineMode        = $true
            DependsOn         = "[WaitForVolume]WaitForSharePointImage"
        }

        SPInstall InstallBinaries
        {
            IsSingleInstance = "Yes"
            BinaryDir        = "$($SharePointIsoDriveLetter):\"
            ProductKey       = "VW2FM-FN9FT-H22J4-WV9GT-H8VKF"
            DependsOn        = "[SPInstallPrereqs]InstallPrerequisites"
        }

        if ($SharePointBuildLabel -ne "RTM") {
            foreach ($package in ($SharePointBits | Where-Object {$_.Label -eq $SharePointBuildLabel}).Packages) {
                $packageUrl = [uri] $package.DownloadUrl
                $packageFilename = $packageUrl.Segments[$packageUrl.Segments.Count - 1]
                $packageFilePath = Join-Path -Path $SharePointBitsPath -ChildPath $packageFilename
                
                xRemoteFile "DownloadSharePointUpdate_$($SharePointBuildLabel)_$packageFilename"
                {
                    DestinationPath = $packageFilePath
                    Uri             = $packageUrl
                    ChecksumType    = if ($null -ne $package.ChecksumType) { $package.ChecksumType } else { "None" }
                    Checksum        = if ($null -ne $package.Checksum) { $package.Checksum } else { $null }
                    MatchSource     = $false
                }

                Script "InstallSharePointUpdate_$($SharePointBuildLabel)_$packageFilename"
                {
                    SetScript = {
                        $SharePointBuildLabel = $using:SharePointBuildLabel
                        $packageFilePath = $using:packageFilePath
                        $packageFile = Get-ChildItem -Path $packageFilePath
                        
                        $exitRebootCodes = @(3010, 17022)
                        $needReboot = $false
                        Write-Host "Starting installation of SharePoint update '$SharePointBuildLabel', file '$($packageFile.Name)'..."
                        Unblock-File -Path $packageFile -Confirm:$false
                        $process = Start-Process $packageFile.FullName -ArgumentList '/passive /quiet /norestart' -PassThru -Wait
                        if ($exitRebootCodes.Contains($process.ExitCode)) {
                            $needReboot = $true
                        }
                        Write-Host "Finished installation of SharePoint update '$($packageFile.Name)'. Exit code: $($process.ExitCode); needReboot: $needReboot"
                        New-Item -Path "HKLM:\SOFTWARE\DscScriptExecution\flag_spupdate_$($SharePointBuildLabel)_$($packageFile.Name)" -Force
                        Write-Host "Finished installation of SharePoint build '$SharePointBuildLabel'. needReboot: $needReboot"

                        if ($true -eq $needReboot) {
                            $global:DSCMachineStatus = 1
                        }
                    }
                    TestScript = {
                        $SharePointBuildLabel = $using:SharePointBuildLabel
                        $packageFilePath = $using:packageFilePath
                        $packageFile = Get-ChildItem -Path $packageFilePath
                        return (Test-Path "HKLM:\SOFTWARE\DscScriptExecution\flag_spupdate_$($SharePointBuildLabel)_$($packageFile.Name)")
                    }
                    GetScript = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                    DependsOn        = "[SPInstall]InstallBinaries"
                }

                PendingReboot "RebootOnSignalFromInstallSharePointUpdate_$($SharePointBuildLabel)_$packageFilename"
                {
                    Name             = "RebootOnSignalFromInstallSharePointUpdate_$($SharePointBuildLabel)_$packageFilename"
                    SkipCcmClientSDK = $true
                    DependsOn        = "[Script]InstallSharePointUpdate_$($SharePointBuildLabel)_$packageFilename"
                }
            }
        }

        # IIS cleanup cannot be executed earlier in SharePoint SE: It uses a base image of Windows Server without IIS (installed by SPInstallPrereqs)
        WebAppPool RemoveDotNet2Pool         { Name = ".NET v2.0";            Ensure = "Absent"; }
        WebAppPool RemoveDotNet2ClassicPool  { Name = ".NET v2.0 Classic";    Ensure = "Absent"; }
        WebAppPool RemoveDotNet45Pool        { Name = ".NET v4.5";            Ensure = "Absent"; }
        WebAppPool RemoveDotNet45ClassicPool { Name = ".NET v4.5 Classic";    Ensure = "Absent"; }
        WebAppPool RemoveClassicDotNetPool   { Name = "Classic .NET AppPool"; Ensure = "Absent"; }
        WebAppPool RemoveDefaultAppPool      { Name = "DefaultAppPool";       Ensure = "Absent"; }
        WebSite    RemoveDefaultWebSite      { Name = "Default Web Site";     Ensure = "Absent"; PhysicalPath = "C:\inetpub\wwwroot"; }

        #**********************************************************
        # Join AD forest
        #**********************************************************
        Script DscStatus_WaitForDCReady
        {
            SetScript =
            {
                "$(Get-Date -Format u)`t$($using:ComputerName)`tWait for AD DC to be ready..." | Out-File -FilePath $using:DscStatusFilePath -Append
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
        }

        # DNS record for ADFS is created only after the ADFS farm was created and DC restarted (required by ADFS setup)
        # This turns out to be a very reliable way to ensure that VM joins AD only when the DC is guaranteed to be ready
        # This totally eliminates the random errors that occured in WaitForADDomain with the previous logic (and no more need of WaitForADDomain)
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
        Script DscStatus_WaitForSPFarmReadyToJoin
        {
            SetScript =
            {
                "$(Get-Date -Format u)`t$($using:ComputerName)`tWait for the SharePoint farm to be ready to be joined..." | Out-File -FilePath $using:DscStatusFilePath -Append
            }
            GetScript            = { } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If the TestScript returns $false, DSC executes the SetScript to bring the node back to the desired state
        }

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

        Script SetFarmPropertiesForOIDC
        {
            SetScript = 
            {
                # Import OIDC-specific cookie certificate and set required permissions
                $spTrustedSitesName = $using:SharePointSitesAuthority
                $DCSetupPath = Join-Path -Path $using:DCSetupPath -ChildPath "Certificates"
                
                # Import OIDC-specific cookie certificate created in 1st SharePoint Server of the farm
                $cookieCertificateFileName = "SharePoint Cookie Cert.pfx"
                $cookieCertificateFilePath = Join-Path -Path $DCSetupPath -ChildPath $cookieCertificateFileName
                $cert = Import-PfxCertificate -FilePath $cookieCertificateFilePath -CertStoreLocation Cert:\localMachine\My -Exportable

                # Grant the application pool access to the private key of the cookie certificate
                $wa = Get-SPWebApplication "http://$spTrustedSitesName"
                $apppoolUserName = $wa.ApplicationPool.Username
                $rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
                $fileName = $rsaCert.key.UniqueName
                $path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\RSA\MachineKeys\$fileName"
                $permissions = Get-Acl -Path $path
                $access_rule = New-Object System.Security.AccessControl.FileSystemAccessRule($apppoolUserName, 'Read', 'None', 'None', 'Allow')
                $permissions.AddAccessRule($access_rule)
                Set-Acl -Path $path -AclObject $permissions
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                # Import-Module SharePointServer | Out-Null
                # $f = Get-SPFarm
                # if ($f.Farm.Properties.ContainsKey('SP-NonceCookieCertificateThumbprint') -eq $false) {
                if ((Get-ChildItem -Path "cert:\LocalMachine\My\"| Where-Object{$_.Subject -eq "CN=SharePoint Cookie Cert"}) -eq $null) {
                    return $false
                }
                else {
                    return $true
                }
            }
            DependsOn            = "[SPFarm]JoinSPFarm"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        Script CreateShortcuts
        {
            SetScript =
            {
                $WshShell = New-Object -comObject WScript.Shell
                # Shortcut to the setup folder
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Setup data.lnk")
                $Shortcut.TargetPath = $using:SetupPath
                $Shortcut.Save()

                # Shortcut for SharePoint Central Administration
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SharePoint Central Administration.lnk")
                $Shortcut.TargetPath = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\BIN\psconfigui.exe"
                $Shortcut.Arguments = "-cmd showcentraladmin"
                $Shortcut.Save()

                # Shortcut for SharePoint Products Configuration Wizard
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SharePoint Products Configuration Wizard.lnk")
                $Shortcut.TargetPath = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\BIN\psconfigui.exe"
                $Shortcut.Save()

                # Shortcut for SharePoint Management Shell
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SharePoint Management Shell.lnk")
                $Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe"
                $Shortcut.Arguments = " -NoExit -Command ""& 'C:\Program Files\WindowsPowerShell\Modules\SharePointServer\SharePoint.ps1'"
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
        #             $Shortcut.TargetPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\{0}\DSCWork\ConfigureFESE.0" -f $folderWithMaxVersionNumber
        #             $Shortcut.Save()
        #         }
        #         GetScript = { }
        #         DependsOn = "[cChocoPackageInstaller]InstallPython"
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
$SharePointVersion = "Subscription-Latest"
$SharePointSitesAuthority = "spsites"
$EnableAnalysis = $true
$SharePointBits = @(
    @{
        Label = "RTM"; 
        Packages = @(
            @{ DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2171943"; ChecksumType = "SHA256"; Checksum = "C576B847C573234B68FC602A0318F5794D7A61D8149EB6AE537AF04470B7FC05" }
        )
    },
    @{
        Label = "22H2"; 
        Packages = @(
            @{ DownloadUrl = "https://download.microsoft.com/download/8/d/f/8dfcb515-6e49-42e5-b20f-5ebdfd19d8e7/wssloc-subscription-kb5002270-fullfile-x64-glb.exe"; ChecksumType = "SHA256"; Checksum = "7E496530EB873146650A9E0653DE835CB2CAD9AF8D154CBD7387BB0F2297C9FC" },
            @{ DownloadUrl = "https://download.microsoft.com/download/3/f/5/3f5b1ee0-3336-45d7-b2f4-1e6af977d574/sts-subscription-kb5002271-fullfile-x64-glb.exe"; ChecksumType = "SHA256"; Checksum = "247011443AC573D4F03B1622065A7350B8B3DAE04D6A5A6DC64C8270A3BE7636" }
        )
    },
    @{
        Label = "Latest"; 
        Packages = @(
            @{ DownloadUrl = "https://download.microsoft.com/download/d/6/d/d6dcc9e7-744e-43e1-b4be-206a6acd4f88/sts-subscription-kb5002331-fullfile-x64-glb.exe" },
            @{ DownloadUrl = "https://download.microsoft.com/download/d/3/5/d354b6e2-fa16-48e0-b3f8-423f7ca279a0/wssloc-subscription-kb5002326-fullfile-x64-glb.exe" }
        )
    }
)

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.5\DSCWork\ConfigureFESE.0\ConfigureFEVM"
ConfigureFEVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DCServerName $DCServerName -SQLServerName $SQLServerName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -SharePointSitesAuthority $SharePointSitesAuthority -EnableAnalysis $EnableAnalysis -SharePointBits $SharePointBits -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.83.5
#>