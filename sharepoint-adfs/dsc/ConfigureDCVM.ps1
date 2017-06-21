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

        [Int] $RetryCount=20,
        [Int] $RetryIntervalSec=30,
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

        Script AddADDSFeature {
            SetScript = {
                Add-WindowsFeature "AD-Domain-Services" -ErrorAction SilentlyContinue   
            }
            GetScript =  { @{} }
            TestScript = { $false }
        }
	
	    WindowsFeature DNS { Ensure = "Present"; Name = "DNS" }

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

	    WindowsFeature DnsTools { Ensure = "Present"; Name = "RSAT-DNS-Server" }

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

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
	        DependsOn="[cDiskNoRestart]ADDataDisk", "[Script]AddADDSFeature"
        } 
         
        xADDomain FirstDS 
        {
            DomainName = $DomainFQDN
            DomainAdministratorCredential = $DomainCredsNetbios
            SafemodeAdministratorPassword = $DomainCredsNetbios
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
	        DependsOn = "[WindowsFeature]ADDSInstall"
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
        xScript WaitAfterADCSProvisioning
        {
            SetScript = 
            {
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
        }

        xCertReq ADFSSiteCert
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "$ADFSSiteName.$DomainFQDN"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
			#SubjectAltName            = "certauth.$ADFSSiteName.$DomainFQDN"
            Credential                = $DomainCredsNetbios
            DependsOn = '[xScript]WaitAfterADCSProvisioning'
        }

        xCertReq ADFSSigningCert
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "$ADFSSiteName.Signing"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
            Credential                = $DomainCredsNetbios
            DependsOn = '[xADCSCertificationAuthority]ADCS'
        }
        
        xCertReq ADFSDecryptionCert
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "$ADFSSiteName.Decryption"
            KeyLength                 = '2048'
            Exportable                = $true
            ProviderName              = '"Microsoft RSA SChannel Cryptographic Provider"'
            OID                       = '1.3.6.1.5.5.7.3.1'
            KeyUsage                  = '0xa0'
            CertificateTemplate       = 'WebServer'
            AutoRenew                 = $true
            Credential                = $DomainCredsNetbios
            DependsOn = '[xADCSCertificationAuthority]ADCS'
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
        <#
        xScript CreateADFSFarm
        {
            SetScript = 
            {
                Write-Verbose -Message "Creating ADFS farm 'ADFS.$using:DomainName'"

                $siteCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "ADFS.$DomainFQDN"
                $signingCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "ADFS.Signing"
                $decryptionCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "ADFS.Decryption"

                New-Item "C:\new_file.txt" -type file -force -value "Creating ADFS farm 'ADFS.$using:DomainName' with certs: $sitecert $signingCert $decryptionCert"

                $runParams = @{}
                $runParams.Add("CertificateThumbprint", $siteCert.Thumbprint)
                $runParams.Add("FederationServiceName", "ADFS.$using:DomainName")
                $runParams.Add("ServiceAccountCredential", $using:AdfsSvcCredsQualified)
                $runParams.Add("SigningCertificateThumbprint", $signingCert.Thumbprint)
                $runParams.Add("DecryptionCertificateThumbprint", $decryptionCert.Thumbprint)
                #$runParams.Add("Credential", $using:DomainCredsNetbios)
                Install-AdfsFarm @runParams -OverwriteConfiguration

                Write-Verbose -Message "ADFS farm successfully created"
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                $result = "true"
                try
                {
                    Get-AdfsProperties
                }
                catch
                {
                    $result = "false"
                }
                return @{ "Result" = $result }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                try
                {
                    Get-AdfsProperties
                    Write-Verbose -Message "ADFS farm already exists"
                    return $true
                }
                catch
                {
                    Write-Verbose -Message "ADFS farm does not exist"
                    return $false
                }
            }
            #Credential = $DomainCredsNetbios
            DependsOn = "[xPendingReboot]RebootAfterAddADFS"
        }

		xScript CreateADFSRelyingParty
        {
            SetScript = 
            {
                Write-Verbose -Message "Creating Relying Party '$using:ADFSRelyingPartyTrustName' in ADFS farm"
                Add-ADFSRelyingPartyTrust -Name $using:ADFSRelyingPartyTrustName `
                    -Identifier "https://$using:ADFSRelyingPartyTrustName.$using:DomainName" `
                    -ClaimsProviderName "Active Directory" `
                    -Enabled $true `
                    -WSFedEndpoint "https://$using:ADFSRelyingPartyTrustName.$using:DomainName/_trust/" `
                    -IssuanceAuthorizationRules '=> issue (Type = "http://schemas.microsoft.com/authorization/claims/permit", value = "true");' `
                    -Confirm:$false 
                Write-Verbose -Message "Relying Party '$using:ADFSRelyingPartyTrustName' successfully created"
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                $result = "false"
                $rpFound = Get-ADFSRelyingPartyTrust -Name $using:ADFSRelyingPartyTrustName                
                if ($rpFound -ne $null)
                {
                    $result = "true"
                }
                return @{ "Result" = $result }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                $rpFound = Get-ADFSRelyingPartyTrust -Name $using:ADFSRelyingPartyTrustName                
                if ($rpFound -ne $null)
                {
                    Write-Verbose -Message "Relying Party '$using:ADFSRelyingPartyTrustName' already exists"
                    return $true
                }
                Write-Verbose -Message "Relying Party '$using:ADFSRelyingPartyTrustName' does not exist"
                return $false
            }
            #PsDscRunAsCredential = $DomainCredsNetbios
            #DependsOn = "[xScript]CreateADFSFarm"
            DependsOn = "[cADFSFarm]CreateADFSFarm"
        }
        #>
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