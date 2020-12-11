configuration ConfigureDCVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$Admincreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$AdfsSvcCreds,
        [Parameter(Mandatory)] [String]$PrivateIP
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc, NetworkingDsc, xPSDesiredStateConfiguration, ActiveDirectoryCSDsc, CertificateDsc, cADFS, xDnsServer, ComputerManagementDsc
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    [System.Management.Automation.PSCredential] $DomainCredsNetbios = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential] $AdfsSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($AdfsSvcCreds.UserName)", $AdfsSvcCreds.Password)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    $ComputerName = Get-Content env:computername
    [String] $SPTrustedSitesName = "SPSites"
    [String] $ADFSSiteName = "ADFS"
    [String] $AppDomainFQDN = (Get-AppDomain -DomainFQDN $DomainFQDN -Suffix "Apps")
    [String] $AppDomainIntranetFQDN = (Get-AppDomain -DomainFQDN $DomainFQDN -Suffix "Apps-Intranet")

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        #**********************************************************
        # Create AD domain
        #**********************************************************
        WindowsFeature AddADDS { Name = "AD-Domain-Services"; Ensure = "Present" }
        WindowsFeature AddDNS  { Name = "DNS";                Ensure = "Present" }
        DnsServerAddress SetDNS { Address = '127.0.0.1' ; InterfaceAlias = $InterfaceAlias; AddressFamily  = 'IPv4' }

        ADDomain CreateADForest
        {
            DomainName                    = $DomainFQDN
            Credential                    = $DomainCredsNetbios
            SafemodeAdministratorPassword = $DomainCredsNetbios
            DatabasePath                  = "C:\NTDS"
            LogPath                       = "C:\NTDS"
            SysvolPath                    = "C:\SYSVOL"
            DependsOn                     = "[DnsServerAddress]SetDNS", "[WindowsFeature]AddADDS"
        }

        PendingReboot RebootOnSignalFromCreateADForest
        {
            Name      = "RebootOnSignalFromCreateADForest"
            DependsOn = "[ADDomain]CreateADForest"
        }

        WaitForADDomain WaitForDCReady
        {
            DomainName              = $DomainFQDN
            WaitTimeout             = 300
            RestartCount            = 3
            Credential              = $DomainCredsNetbios
            WaitForValidCredentials = $true
            DependsOn               = "[PendingReboot]RebootOnSignalFromCreateADForest"
        }
        
        #**********************************************************
        # Configuration needed by SharePoint farm
        #**********************************************************
        xDnsServerPrimaryZone CreateAppsDnsZone
        {
            Name      = $AppDomainFQDN
            Ensure    = "Present"
            DependsOn = "[WaitForADDomain]WaitForDCReady"
        }

        xDnsServerPrimaryZone CreateAppsIntranetDnsZone
        {
            Name      = $AppDomainIntranetFQDN
            Ensure    = "Present"
            DependsOn = "[WaitForADDomain]WaitForDCReady"
        }

        ADUser SetEmailOfDomainAdmin
        {
            DomainName           = $DomainFQDN
            UserName             = $Admincreds.UserName
            EmailAddress         = "$($Admincreds.UserName)@$DomainFQDN"
            PasswordNeverExpires = $true
            Ensure               = "Present"
            DependsOn            = "[WaitForADDomain]WaitForDCReady"
        }

        #**********************************************************
        # Configure AD CS
        #**********************************************************
        WindowsFeature AddADCSFeature { Name = "ADCS-Cert-Authority"; Ensure = "Present"; DependsOn = "[WaitForADDomain]WaitForDCReady" }
        
        ADCSCertificationAuthority CreateADCSAuthority
        {
            IsSingleInstance = "Yes"
            CAType           = "EnterpriseRootCA"
            Ensure           = "Present"
            Credential       = $DomainCredsNetbios
            DependsOn        = "[WindowsFeature]AddADCSFeature"
        }

        WaitForCertificateServices WaitAfterADCSProvisioning
        {
            CAServerFQDN         = "$ComputerName.$DomainFQDN"
            CARootName           = "$DomainNetbiosName-$ComputerName-CA"
            DependsOn            = '[ADCSCertificationAuthority]CreateADCSAuthority'
            PsDscRunAsCredential = $DomainCredsNetbios
        }

        #**********************************************************
        # Configure AD FS
        #**********************************************************
        CertReq GenerateADFSSiteCertificate
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "$ADFSSiteName.$DomainFQDN"
            FriendlyName              = "$ADFSSiteName.$DomainFQDN site certificate"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
            SubjectAltName            = "dns=certauth.$ADFSSiteName.$DomainFQDN&dns=$ADFSSiteName.$DomainFQDN&dns=enterpriseregistration.$DomainFQDN"
            Credential                = $DomainCredsNetbios
            DependsOn                 = '[WaitForCertificateServices]WaitAfterADCSProvisioning'
        }

        CertReq GenerateADFSSigningCertificate
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "$ADFSSiteName.Signing"
            FriendlyName              = "$ADFSSiteName Signing"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
            Credential                = $DomainCredsNetbios
            DependsOn                 = '[WaitForCertificateServices]WaitAfterADCSProvisioning'
        }

        CertReq GenerateADFSDecryptionCertificate
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "$ADFSSiteName.Decryption"
            FriendlyName              = "$ADFSSiteName Decryption"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
            Credential                = $DomainCredsNetbios
            DependsOn                 = '[WaitForCertificateServices]WaitAfterADCSProvisioning'
        }

        xScript ExportCertificates
        {
            SetScript = 
            {
                $destinationPath = "C:\Setup"
                $adfsSigningCertName = "ADFS Signing.cer"
                $adfsSigningIssuerCertName = "ADFS Signing issuer.cer"
                Write-Verbose -Message "Exporting public key of ADFS signing / signing issuer certificates..."
                New-Item $destinationPath -Type directory -ErrorAction SilentlyContinue
                $signingCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "$using:ADFSSiteName.Signing"
                $signingCert| Export-Certificate -FilePath ([System.IO.Path]::Combine($destinationPath, $adfsSigningCertName))
                Get-ChildItem -Path "cert:\LocalMachine\Root\"| Where-Object{$_.Subject -eq  $signingCert.Issuer}| Select-Object -First 1| Export-Certificate -FilePath ([System.IO.Path]::Combine($destinationPath, $adfsSigningIssuerCertName))
                Write-Verbose -Message "Public key of ADFS signing / signing issuer certificates successfully exported"
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
            DependsOn = "[CertReq]GenerateADFSSiteCertificate", "[CertReq]GenerateADFSSigningCertificate", "[CertReq]GenerateADFSDecryptionCertificate"
        }

        ADUser CreateAdfsSvcAccount
        {
            DomainName             = $DomainFQDN
            UserName               = $AdfsSvcCreds.UserName
            Password               = $AdfsSvcCreds
            PasswordAuthentication = 'Negotiate'
            PasswordNeverExpires   = $true
            Ensure                 = "Present"
            DependsOn              = "[CertReq]GenerateADFSSiteCertificate", "[CertReq]GenerateADFSSigningCertificate", "[CertReq]GenerateADFSDecryptionCertificate"
        }

        WindowsFeature AddADFS { Name = "ADFS-Federation"; Ensure = "Present"; DependsOn = "[ADUser]CreateAdfsSvcAccount" }

        xDnsRecord AddADFSHostDNS {
            Name = $ADFSSiteName
            Zone = $DomainFQDN
            Target = $PrivateIP
            Type = "ARecord"
            Ensure = "Present"
            DependsOn = "[WaitForADDomain]WaitForDCReady"
        }

        # https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/deployment/configure-corporate-dns-for-the-federation-service-and-drs
        xDnsRecord AddADFSDevideRegistrationAlias {
            Name = "enterpriseregistration"
            Zone = $DomainFQDN
            Target = "$ComputerName.$DomainFQDN"
            Type = "CName"
            Ensure = "Present"
            DependsOn = "[WaitForADDomain]WaitForDCReady"
        }

        # Since 2019-10, DSC regularly fails at cADFSFarm CreateADFSFarm with error below, but I don't know why or how to fix it.
        # Machine restart message is present even when there is no error and PendingReboot before cADFSFarm detects no pending reboot
        # VERBOSE: [2019-10-04 11:14:42Z] [VERBOSE] [DC]: [[cADFSFarm]CreateADFSFarm] Entering function InstallADFSFarm
        # VERBOSE: [2019-10-04 11:14:42Z] [WARNING] [DC]: [[cADFSFarm]CreateADFSFarm] A machine restart is required to complete ADFS service configuration. For more information, see: http://go.microsoft.com/fwlink/?LinkId=798725
        # VERBOSE: [2019-10-04 11:19:14Z] [ERROR] ADMIN0121: An attempt to update service settings failed because the data set that was used for updating was stale. Refresh the data in your session or console view, and then try the update again.
        cADFSFarm CreateADFSFarm
        {
            ServiceCredential = $AdfsSvcCredsQualified
            InstallCredential = $DomainCredsNetbios
            #CertificateThumbprint = $siteCert
            DisplayName = "$ADFSSiteName.$DomainFQDN"
            ServiceName = "$ADFSSiteName.$DomainFQDN"
            #SigningCertificateThumbprint = $signingCert
            #DecryptionCertificateThumbprint = $decryptionCert
            CertificateName = "$ADFSSiteName.$DomainFQDN"
            SigningCertificateName = "$ADFSSiteName.Signing"
            DecryptionCertificateName = "$ADFSSiteName.Decryption"
            Ensure= 'Present'
            PsDscRunAsCredential = $DomainCredsNetbios
            DependsOn = "[WindowsFeature]AddADFS"
        }

        cADFSRelyingPartyTrust CreateADFSRelyingParty
        {
            Name = $SPTrustedSitesName
            Identifier = "https://$SPTrustedSitesName.$DomainFQDN"
            ClaimsProviderName = @("Active Directory")
            WsFederationEndpoint = "https://$SPTrustedSitesName.$DomainFQDN/_trust/"
            AdditionalWSFedEndpoint = @("https://*.$DomainFQDN/")
            IssuanceAuthorizationRules = '=> issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", value = "true");'
            IssuanceTransformRules = @"
@RuleTemplate = "LdapClaims"
@RuleName = "AD"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
=> issue(
store = "Active Directory", 
types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress", "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"), 
query = ";mail,tokenGroups(longDomainQualifiedName);{0}", 
param = c.Value);
"@
            ProtocolProfile = "WsFed-SAML"
            Ensure= 'Present'
            PsDscRunAsCredential = $DomainCredsNetbios
            DependsOn = "[cADFSFarm]CreateADFSFarm"
        }

        WindowsFeature AddADTools             { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature AddADPowerShell        { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        WindowsFeature AddDnsTools            { Name = "RSAT-DNS-Server";    Ensure = "Present"; }
        WindowsFeature AddADLDS               { Name = "RSAT-ADLDS";         Ensure = "Present"; }
        WindowsFeature AddADCSManagementTools { Name = "RSAT-ADCS-Mgmt";     Ensure = "Present"; }
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

<#
# Azure DSC extension logging: C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.80.0.0
# Azure DSC extension configuration: C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name xAdcsDeployment
Install-Module -Name xCertificate
Install-Module -Name xPSDesiredStateConfiguration
Install-Module -Name xCredSSP
Install-Module -Name xWebAdministration
Install-Module -Name xDisk
Install-Module -Name xNetworking

help ConfigureDCVM

$Admincreds = Get-Credential -Credential "yvand"
$AdfsSvcCreds = Get-Credential -Credential "adfssvc"
$DomainFQDN = "contoso.local"
$PrivateIP = "10.1.1.4"

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.3\DSCWork\ConfigureDCVM.0\ConfigureDCVM"
ConfigureDCVM -Admincreds $Admincreds -AdfsSvcCreds $AdfsSvcCreds -DomainFQDN $DomainFQDN -PrivateIP $PrivateIP -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

https://github.com/PowerShell/xActiveDirectory/issues/27
Uninstall-WindowsFeature "ADFS-Federation"
https://msdn.microsoft.com/library/mt238290.aspx
\\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query
#>