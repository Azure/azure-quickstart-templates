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
        [Parameter(Mandatory)] $SharePointBits,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPFarmCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.0.0
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.2.0
    Import-DscResource -ModuleName WebAdministrationDsc -ModuleVersion 4.0.0
    Import-DscResource -ModuleName SharePointDsc -ModuleVersion 5.3.0
    Import-DscResource -ModuleName DnsServerDsc -ModuleVersion 3.0.0
    Import-DscResource -ModuleName CertificateDsc -ModuleVersion 5.1.0
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 16.0.0
    Import-DscResource -ModuleName cChoco -ModuleVersion 2.5.0.0    # With custom changes to implement retry on package downloads
    Import-DscResource -ModuleName StorageDsc -ModuleVersion 5.0.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [String] $SPDBPrefix = "SPDSC_"
    [String] $SPTrustedSitesName = "spsites"
    [String] $ComputerName = Get-Content env:computername
    [String] $SetupPath = "C:\Setup"
    [String] $DCSetupPath = "\\$DCName\C$\Setup"
    [String] $MySiteHostAlias = "OhMy"
    [String] $HNSC1Alias = "HNSC1"
    [String] $SharePointBuildLabel = $SharePointVersion.Split("-")[1]
    [String] $spIsoFolder = [environment]::GetEnvironmentVariable("temp","machine")
    [String] $spIsoPath = Join-Path -Path $spIsoFolder -ChildPath "OfficeServer.iso"
    [String] $spIsoDriverLetter = "S"
    [String] $spInstallFolder = "${spIsoDriverLetter}:\"
    [String] $spPrereqPath = "${spIsoDriverLetter}:\Prerequisiteinstaller.exe"

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

        SqlAlias AddSqlAlias { Ensure = "Present"; Name = $SQLAlias; ServerName = $SQLName; Protocol = "TCP"; TcpPort= 1433 }

        Script DisableIESecurity
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
        # Download and install for SharePoint
        #**********************************************************
        xRemoteFile DownloadSharePoint
        {
            DestinationPath = $spIsoPath
            Uri             = ($SharePointBits | Where-Object {$_.Label -eq "RTM"}).Packages[0].DownloadUrl
            ChecksumType    = ($SharePointBits | Where-Object {$_.Label -eq "RTM"}).Packages[0].ChecksumType
            Checksum        = ($SharePointBits | Where-Object {$_.Label -eq "RTM"}).Packages[0].Checksum
            MatchSource     = $false
        }
        
        MountImage MountSharePointImage
        {
            ImagePath   = $spIsoPath
            DriveLetter = $spIsoDriverLetter
            DependsOn   = "[xRemoteFile]DownloadSharePoint"
        }
          
        WaitForVolume WaitForSharePointImage
        {
            DriveLetter      = $spIsoDriverLetter
            RetryIntervalSec = 5
            RetryCount       = 10
            DependsOn        = "[MountImage]MountSharePointImage"
        }

        SPInstallPrereqs InstallPrerequisites
        {
            IsSingleInstance  = "Yes"
            InstallerPath     = $spPrereqPath
            OnlineMode        = $true
            DependsOn         = "[WaitForVolume]WaitForSharePointImage"
        }

        SPInstall InstallBinaries
        {
            IsSingleInstance = "Yes"
            BinaryDir        = $spInstallFolder
            ProductKey       = "VW2FM-FN9FT-H22J4-WV9GT-H8VKF"
            DependsOn        = "[SPInstallPrereqs]InstallPrerequisites"
        }

        if ($SharePointBuildLabel -ne "RTM") {
            foreach ($package in ($SharePointBits | Where-Object {$_.Label -eq $SharePointBuildLabel}).Packages) {
                $packageUrl = [uri] $package.DownloadUrl
                $packageFilename = $packageUrl.Segments[$packageUrl.Segments.Count - 1]
                $packageFilePath = Join-Path -Path ([environment]::GetEnvironmentVariable("temp","machine").ToString()) -ChildPath $packageFilename
                
                xRemoteFile "DownloadSharePointUpdate_$($SharePointBuildLabel)_$packageFilename"
                {
                    DestinationPath = $packageFilePath
                    Uri             = $packageUrl
                    ChecksumType    = $package.ChecksumType
                    Checksum        = $package.Checksum
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
                        Write-Verbose -Message "Starting installation of SharePoint update '$SharePointBuildLabel', file '$($packageFile.Name)'..."
                        Unblock-File -Path $packageFile -Confirm:$false
                        $process = Start-Process $packageFile.FullName -ArgumentList '/passive /quiet /norestart' -PassThru -Wait
                        if ($exitRebootCodes.Contains($process.ExitCode)) {
                            $needReboot = $true
                        }
                        Write-Verbose -Message "Finished installation of SharePoint update '$($packageFile.Name)'. Exit code: $($process.ExitCode); needReboot: $needReboot"
                        New-Item -Path "HKLM:\SOFTWARE\DscScriptExecution\flag_spupdate_$($SharePointBuildLabel)_$($packageFile.Name)" -Force
                        Write-Verbose -Message "Finished installation of SharePoint build '$SharePointBuildLabel'. needReboot: $needReboot"

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
                $dcName = $using:DCName
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
            DependsOn                 = "[Script]WaitToAvoidServersJoiningFarmSimultaneously"
        }

        DnsRecordCname UpdateDNSAliasSPSites
        {
            Name                 = $SPTrustedSitesName
            ZoneName             = $DomainFQDN
            DnsServer            = $DCName
            HostNameAlias        = "$ComputerName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        DnsRecordCname UpdateDNSAliasOhMy
        {
            Name                 = $MySiteHostAlias
            ZoneName             = $DomainFQDN
            DnsServer            = $DCName
            HostNameAlias        = "$ComputerName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        DnsRecordCname UpdateDNSAliasHNSC1
        {
            Name                 = $HNSC1Alias
            ZoneName             = $DomainFQDN
            DnsServer            = $DCName
            HostNameAlias        = "$ComputerName.$DomainFQDN"
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[SPFarm]JoinSPFarm"
        }

        Script WarmupSites
        {
            SetScript =
            {
                $warmupJobBlock = {
                    $uri = $args[0]
                    try {
                        Write-Verbose "Connecting to $uri..."
                        # -UseDefaultCredentials: Does NTLM authN
                        # -UseBasicParsing: Avoid exception because IE was not first launched yet
                        # Expected traffic is HTTP 401/302/200, and $Response.StatusCode is 200
                        $Response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials -TimeoutSec 40 -UseBasicParsing -ErrorAction SilentlyContinue
                        Write-Verbose "Connected successfully to $uri"
                    }
                    catch {
                    }
                }
                $spsite = "http://$($using:SPTrustedSitesName)/"
                Write-Verbose "Warming up '$spsite'..."
                $job = Start-Job -ScriptBlock $warmupJobBlock -ArgumentList @($spsite)
                
                # Must wait for the jobs to complete, otherwise they do not actually run
                Receive-Job -Job $job -AutoRemoveJob -Wait
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
                $spTrustedSitesName = $using:SPTrustedSitesName
                $dcSetupPath = $using:DCSetupPath
                
                # Import OIDC-specific cookie certificate created in 1st SharePoint Server of the farm
                $cookieCertificateName = "SharePoint Cookie Cert"
                $cookieCertificateFilePath = Join-Path -Path $dcSetupPath -ChildPath "$cookieCertificateName"
                $cert = Import-PfxCertificate -FilePath "$cookieCertificateFilePath.pfx" -CertStoreLocation Cert:\localMachine\My -Exportable

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

        # if ($EnableAnalysis) {
        #     # This resource is for analysis of dsc logs only and totally optionnal
        #     Script parseDscLogs
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
                    
        #             # Start python in a new process to ensure python.exe is in the path
        #             Write-Verbose -Message "Run python $localScriptPath `"$fullPathToDscLogs`" in a new PowerShell process..."
        #             Start-Process -FilePath "powershell" -ArgumentList "python $localScriptPath `"$fullPathToDscLogs`""
        #         }
        #         GetScript = { }
        #         DependsOn = "[cChocoPackageInstaller]InstallPython"
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

<#
help ConfigureFEVM

$password = ConvertTo-SecureString -String "mytopsecurepassword" -AsPlainText -Force
$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$SPFarmCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spfarm", $password
$SPPassphraseCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Passphrase", $password
$DNSServer = "10.1.1.4"
$DomainFQDN = "contoso.local"
$DCName = "DC"
$SQLName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "SE"
$EnableAnalysis = $false

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.2.0\DSCWork\ConfigureFEVM.0\ConfigureFEVM"
ConfigureFEVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -EnableAnalysis $EnableAnalysis -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>