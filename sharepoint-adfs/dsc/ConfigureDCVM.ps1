configuration ConfigureDCVM
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainFQDN,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdfsSvcCreds,

        [Parameter(Mandatory)]
        [String]$PrivateIP,

        [Int] $RetryCount = 20,
        [Int] $RetryIntervalSec = 30,
        [String] $SPTrustedSitesName = "SPSites",
        [String] $ADFSSiteName = "ADFS"
    )

    Import-DscResource -ModuleName xActiveDirectory, xDisk, xNetworking, cDisk, xPSDesiredStateConfiguration, xAdcsDeployment, xCertificate, xPendingReboot, cADFS, xDnsServer
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    [System.Management.Automation.PSCredential] $DomainCredsNetbios = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential] $AdfsSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($AdfsSvcCreds.UserName)", $AdfsSvcCreds.Password)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    $ComputerName = Get-Content env:computername

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WindowsFeature ADDS { Name = "AD-Domain-Services"; Ensure = "Present" }
        WindowsFeature DNS  { Name = "DNS"; Ensure = "Present" }

        Script script1
        {
            SetScript =  {
                Set-DnsServerDiagnostics -All $true
                Write-Verbose -Verbose "Enabling DNS client diagnostics" 
            }
            GetScript =  { @{} }
            TestScript = { $false }
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature DnsTools { Name = "RSAT-DNS-Server"; Ensure = "Present" }

        xDnsServerAddress DnsServerAddress 
        {
            Address        = '127.0.0.1' 
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }

        cDiskNoRestart ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
        }

        xADDomain FirstDS
        {
            DomainName = $DomainFQDN
            DomainAdministratorCredential = $DomainCredsNetbios
            SafemodeAdministratorPassword = $DomainCredsNetbios
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
            DependsOn = "[cDiskNoRestart]ADDataDisk"
        }

        xPendingReboot Reboot1
        {
            Name = "RebootServer"
            DependsOn = "[xADDomain]FirstDS"
        }

        #**********************************************************
        # Misc: Set email of AD domain admin and add remote AD tools
        #**********************************************************
        xADUser SetEmailOfDomainAdmin
        {
            DomainAdministratorCredential = $DomainCredsNetbios
            DomainName = $DomainFQDN
            UserName = $Admincreds.UserName
            Password = $Admincreds
            EmailAddress = $Admincreds.UserName + "@" + $DomainFQDN
            PasswordAuthentication = 'Negotiate'
            Ensure = "Present"
            PasswordNeverExpires = $true
            DependsOn = "[xPendingReboot]Reboot1"
        }
        WindowsFeature AddADFeature1    { Name = "RSAT-ADLDS";          Ensure = "Present"; DependsOn = "[xPendingReboot]Reboot1" }
        WindowsFeature AddADFeature2    { Name = "RSAT-ADDS-Tools";     Ensure = "Present"; DependsOn = "[xPendingReboot]Reboot1" }

        #**********************************************************
        # Configure AD CS
        #**********************************************************
        WindowsFeature AddCertAuthority       { Name = "ADCS-Cert-Authority"; Ensure = "Present"; DependsOn = "[xPendingReboot]Reboot1" }
        WindowsFeature AddADCSManagementTools { Name = "RSAT-ADCS-Mgmt";      Ensure = "Present"; DependsOn = "[xPendingReboot]Reboot1" }
        xADCSCertificationAuthority ADCS
        {
            Ensure = "Present"
            Credential = $DomainCredsNetbios
            CAType = "EnterpriseRootCA"
            DependsOn = "[WindowsFeature]AddCertAuthority"
        }

        #**********************************************************
        # Configure AD FS
        #**********************************************************
        xWaitForCertificateServices WaitAfterADCSProvisioning
        {
            CAServerFQDN = "$ComputerName.$DomainFQDN"
            CARootName = "$DomainNetbiosName-$ComputerName-CA"
            DependsOn = '[xADCSCertificationAuthority]ADCS'
            PsDscRunAsCredential = $DomainCredsNetbios
        }
        <#xScript WaitAfterADCSProvisioning
        {
            SetScript = 
            {
                # Add a timer to mitigate issue https://github.com/PowerShell/xCertificate/issues/73
                Start-Sleep -s 30
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
            DependsOn = '[xADCSCertificationAuthority]ADCS'
        }#>

        xCertReq ADFSSiteCert
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
            #SubjectAltName            = "certauth.$ADFSSiteName.$DomainFQDN"
            Credential                = $DomainCredsNetbios
            DependsOn = '[xWaitForCertificateServices]WaitAfterADCSProvisioning'
        }

        xCertReq ADFSSigningCert
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
            DependsOn = '[xWaitForCertificateServices]WaitAfterADCSProvisioning'
        }

        xCertReq ADFSDecryptionCert
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
            DependsOn = '[xWaitForCertificateServices]WaitAfterADCSProvisioning'
        }

        xADUser CreateAdfsSvcAccount
        {
            DomainAdministratorCredential = $DomainCredsNetbios
            DomainName = $DomainFQDN
            UserName = $AdfsSvcCreds.UserName
            Password = $AdfsSvcCreds
            Ensure = "Present"
            PasswordAuthentication = 'Negotiate'
            PasswordNeverExpires = $true
            DependsOn = "[xCertReq]ADFSSiteCert", "[xCertReq]ADFSSigningCert", "[xCertReq]ADFSDecryptionCert"
        }

        Group AddAdfsSvcAccountToDomainAdminsGroup
        {
            GroupName='Administrators'   
            Ensure= 'Present'             
            MembersToInclude= $AdfsSvcCredsQualified.UserName
            Credential = $DomainCredsNetbios    
            PsDscRunAsCredential = $DomainCredsNetbios
            DependsOn = "[xADUser]CreateAdfsSvcAccount"
        }

        WindowsFeature AddADFS          { Name = "ADFS-Federation"; Ensure = "Present"; DependsOn = "[Group]AddAdfsSvcAccountToDomainAdminsGroup" }

        xDnsRecord AddADFSHostDNS {
            Name = $ADFSSiteName
            Zone = $DomainFQDN
            Target = $PrivateIP
            Type = "ARecord"
            Ensure = "Present"
            DependsOn = "[xPendingReboot]Reboot1"
        }

        xScript ExportCertificates
        {
            SetScript = 
            {
                Write-Verbose -Message "Exporting public key of certificates..."
                New-Item F:\Setup -Type directory -ErrorAction SilentlyContinue
                $signingCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "$using:ADFSSiteName.Signing"
                $signingCert| Export-Certificate -FilePath "F:\Setup\ADFS Signing.cer"
                Get-ChildItem -Path "cert:\LocalMachine\Root\" | Where-Object{$_.Subject -eq  $signingCert.Issuer}| Select-Object -First 1| Export-Certificate -FilePath "F:\Setup\ADFS Signing issuer.cer"
                Write-Verbose -Message "Public key of certificates successfully exported"
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
            DependsOn = "[WindowsFeature]AddADFS"
        }

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
            IssuanceAuthorizationRules = '=> issue (Type = "http://schemas.microsoft.com/authorization/claims/permit", value = "true");'
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
# Azure DSC extension logging: C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.21.0.0
# Azure DSC extension configuration: C:\Packages\Plugins\Microsoft.Powershell.DSC\2.21.0.0\DSCWork

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
$PrivateIP = "10.0.1.4"

ConfigureDCVM -Admincreds $Admincreds -AdfsSvcCreds $AdfsSvcCreds -DomainFQDN $DomainFQDN -PrivateIP $PrivateIP -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath "C:\Data\\output"
Set-DscLocalConfigurationManager -Path "C:\Data\output\"
Start-DscConfiguration -Path "C:\Data\output" -Wait -Verbose -Force

https://github.com/PowerShell/xActiveDirectory/issues/27
Uninstall-WindowsFeature "ADFS-Federation"
https://msdn.microsoft.com/library/mt238290.aspx
\\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query
#>