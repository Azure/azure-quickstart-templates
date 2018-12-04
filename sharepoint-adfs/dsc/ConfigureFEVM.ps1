configuration ConfigureFEVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServer,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [String]$DCName,
        [Parameter(Mandatory)] [String]$SQLName,
        [Parameter(Mandatory)] [String]$SQLAlias,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPFarmCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSvcCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPPassphraseCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc, StorageDsc, NetworkingDsc, xActiveDirectory, xCredSSP, xWebAdministration, SharePointDsc, xPSDesiredStateConfiguration, xDnsServer, CertificateDsc, SqlServerDsc

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [System.Management.Automation.PSCredential] $DomainAdminCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [System.Management.Automation.PSCredential] $SPSetupCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [System.Management.Automation.PSCredential] $SPFarmCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPFarmCreds.UserName)", $SPFarmCreds.Password)
    [System.Management.Automation.PSCredential] $SPSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SPSvcCreds.UserName)", $SPSvcCreds.Password)
    [String] $SPDBPrefix = "SPDSC_"
    [String] $SPTrustedSitesName = "SPSites"
    [Int] $RetryCount = 30
    [Int] $RetryIntervalSec = 30
    [String] $ComputerName = Get-Content env:computername
    [String] $AppDomainIntranetFQDN = (Get-AppDomain -DomainFQDN $DomainFQDN -Suffix "Apps-Intranet")
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
        # Initialization of VM
        #**********************************************************
        WaitforDisk WaitForDataDisk   { DiskId = 2; RetryIntervalSec = $RetryIntervalSec; RetryCount = $RetryCount }
        Disk PrepareDataDisk          { DiskId = 2; DriveLetter = "F"; DependsOn = "[WaitforDisk]WaitForDataDisk" }
        WindowsFeature ADTools  { Name = "RSAT-AD-Tools";      Ensure = "Present"; DependsOn = "[Disk]PrepareDataDisk" }
        WindowsFeature ADPS     { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; DependsOn = "[Disk]PrepareDataDisk" }
        WindowsFeature DnsTools { Name = "RSAT-DNS-Server";    Ensure = "Present"; DependsOn = "[Disk]PrepareDataDisk" }
        DnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn      ="[WindowsFeature]ADPS"
        }

        xCredSSP CredSSPServer { Ensure = "Present"; Role = "Server"; DependsOn = "[DnsServerAddress]DnsServerAddress" }
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
            DependsOn="[Computer]DomainJoin"
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

        xWebAppPool RemoveDotNet2Pool         { Name = ".NET v2.0";            Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDotNet2ClassicPool  { Name = ".NET v2.0 Classic";    Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDotNet45Pool        { Name = ".NET v4.5";            Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDotNet45ClassicPool { Name = ".NET v4.5 Classic";    Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveClassicDotNetPool   { Name = "Classic .NET AppPool"; Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebAppPool RemoveDefaultAppPool      { Name = "DefaultAppPool";       Ensure = "Absent"; DependsOn = "[Computer]DomainJoin"}
        xWebSite    RemoveDefaultWebSite      { Name = "Default Web Site";     Ensure = "Absent"; PhysicalPath = "C:\inetpub\wwwroot"; DependsOn = "[Computer]DomainJoin"}

        Group AddSPSetupAccountToAdminGroup
        {
            GroupName            = 'Administrators'
            Ensure               = 'Present'
            MembersToInclude     = $SPSetupCredsQualified.UserName
            Credential           = $DomainAdminCredsQualified
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Computer]DomainJoin"
        }

        SqlAlias AddSqlAlias
        {
            Ensure               = "Present"
            Name                 = $SQLAlias
            ServerName           = $SQLName
            Protocol             = "TCP"
            TcpPort              = 1433
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[Computer]DomainJoin"
        }

        #********************************************************************
        # Wait for SQL Server and first SharePoint server to be ready
        #********************************************************************
        xScript WaitForWebAppContentDatabase
        {
            SetScript =
            {
                $retrySleep = $using:RetryIntervalSec
                $server = $using:SQLAlias
                $db= $using:SPDBPrefix + "Content_80"
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
            DependsOn            = "[Computer]DomainJoin"
        }

        <# Should not join farm before Intranet zone is created on first server, otherwise web application may not provision correctly in FE
        xScript WaitForHTTPSSite
        {
            SetScript =
            {
                $retrySleep = $using:RetryIntervalSec
                $url = "https://$($using:SPTrustedSitesName).$($using:DomainFQDN)"
                $retry = $true
                while ($retry) {
                    try {
                        Invoke-WebRequest -Uri $url -UseBasicParsing
                        $retry = $false
                    }
                    catch {
                        Write-Verbose "Connection to $url failed, retry in $retrySleep secs..."
                        Start-Sleep -s $retrySleep
                    }
                }
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xScript]WaitForWebAppContentDatabase"
        }#>

        xScript WaitForAppServer
        {
            SetScript =
            {
                $retry = $true
                $retrySleep = $using:RetryIntervalSec
                $serverName = $using:DCName
                $fileName = "SPDSCFinished.txt"
                $fullPath = "\\$serverName\C$\Setup\$fileName"
                while ($retry) {
                    if ((Get-Item $fullPath -ErrorAction SilentlyContinue) -ne $null){   
                        $retry = $false
                    }
                    Write-Verbose "File '$fullPath' not found on server '$serverName', retry in $retrySleep secs..."
                    Start-Sleep -s $retrySleep
                }
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false } # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xScript]WaitForWebAppContentDatabase"
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
            Ensure                    = "Present"
            DependsOn                 = "[Group]AddSPSetupAccountToAdminGroup"
        }

        SPDistributedCacheService EnableDistributedCache
        {
            Name                 = "AppFabricCachingService"
            CacheSizeInMB        = 2000
            CreateFirewallRules  = $true
            ServiceAccount       = $SPSvcCredsQualified.UserName
            InstallAccount       = $SPSetupCredsQualified
            Ensure               = "Present"
            DependsOn            = "[SPFarm]JoinSPFarm"
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

        # Update GPO to ensure the root certificate of the CA is present in "cert:\LocalMachine\Root\" before issuing a certificate request, otherwise request would fail
        xScript UpdateGPOToTrustRootCACert
        {
            SetScript =
            {
                gpupdate.exe /force
            }
            GetScript            = { return @{ "Result" = "false" } } # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
            TestScript           = { return $false }
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
            DependsOn              = "[SPFarm]JoinSPFarm", "[xScript]UpdateGPOToTrustRootCACert"
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
            DependsOn            = "[CertReq]SPSSiteCert"
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
help ConfigureFEVM

$DomainAdminCreds = Get-Credential -Credential "yvand"
$SPSetupCreds = Get-Credential -Credential "spsetup"
$SPFarmCreds = Get-Credential -Credential "spfarm"
$SPSvcCreds = Get-Credential -Credential "spsvc"
$SPPassphraseCreds = Get-Credential -Credential "Passphrase"
$SPSuperUserCreds = Get-Credential -Credential "spSuperUser"
$SPSuperReaderCreds = Get-Credential -Credential "spSuperReader"
$DNSServer = "10.0.1.4"
$DomainFQDN = "contoso.local"
$DCName = "DC"
$SQLName = "SQL"
$SQLAlias = "SQLAlias"

ConfigureFEVM -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DCName $DCName -SQLName $SQLName -SQLAlias $SQLAlias -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.77.0.0\DSCWork\ConfigureFEVM.0\ConfigureFEVM"
Set-DscLocalConfigurationManager -Path "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.77.0.0\DSCWork\ConfigureFEVM.0\ConfigureFEVM"
Start-DscConfiguration -Path "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.77.0.0\DSCWork\ConfigureFEVM.0\ConfigureFEVM" -Wait -Verbose -Force

#>
