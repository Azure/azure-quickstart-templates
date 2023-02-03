configuration ConfigureDCVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [String]$PrivateIP,
        [Parameter(Mandatory)] [String]$SPServerName,
        [Parameter(Mandatory)] [String]$SharePointSitesAuthority,
        [Parameter(Mandatory)] [String]$SharePointCentralAdminPort,
        [Parameter ()] [Boolean]$ApplyBrowserPolicies = $true,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$Admincreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$AdfsSvcCreds
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.2.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.0.0
    Import-DscResource -ModuleName ActiveDirectoryCSDsc -ModuleVersion 5.0.0
    Import-DscResource -ModuleName CertificateDsc -ModuleVersion 5.1.0
    Import-DscResource -ModuleName DnsServerDsc -ModuleVersion 3.0.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName AdfsDsc -ModuleVersion 1.1.0 # With custom changes in AdfsFarm to set certificates based on their names

    # Init
    [String] $InterfaceAlias = (Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1).Name
    [String] $ComputerName = Get-Content env:computername
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    [String] $AdditionalUsersPath = "OU=AdditionalUsers,DC={0},DC={1}" -f $DomainFQDN.Split('.')[0], $DomainFQDN.Split('.')[1]

    # Format credentials to be qualified by domain name: "domain\username"
    [System.Management.Automation.PSCredential] $DomainCredsNetbios = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential] $AdfsSvcCredsQualified = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($AdfsSvcCreds.UserName)", $AdfsSvcCreds.Password)

    [String] $SetupPath = "C:\DSC Data"

    # ADFS settings
    [String] $ADFSSiteName = "adfs"
    [String] $AdfsOidcAGName = "SPS-Subscription-OIDC"
    [String] $AdfsOidcIdentifier = "fae5bd07-be63-4a64-a28c-7931a4ebf62b"
    
    # SharePoint settings
    [String] $centralAdminUrl = "http://{0}:{1}/" -f $SPServerName, $SharePointCentralAdminPort
    [String] $rootSiteDefaultZone = "http://{0}/" -f $SharePointSitesAuthority
    [String] $rootSiteIntranetZone = "https://{0}.{1}/" -f $SharePointSitesAuthority, $DomainFQDN
    [String] $AppDomainFQDN = "{0}{1}.{2}" -f $DomainFQDN.Split('.')[0], "Apps", $DomainFQDN.Split('.')[1]
    [String] $AppDomainIntranetFQDN = "{0}{1}.{2}" -f $DomainFQDN.Split('.')[0], "Apps-Intranet", $DomainFQDN.Split('.')[1]

    # Browser policies
    # Edge
    [System.Object[]] $EdgePolicies = @(
        @{
            policyValueName = "HideFirstRunExperience";
            policyCanBeRecommended = $false;
            policyValueValue = 1;
        },
        @{
            policyValueName = "TrackingPrevention";
            policyCanBeRecommended = $false;
            policyValueValue = 3;
        },
        @{
            policyValueName = "AdsTransparencyEnabled";
            policyCanBeRecommended = $false;
            policyValueValue = 0;
        },
        @{
            policyValueName = "BingAdsSuppression";
            policyCanBeRecommended = $false;
            policyValueValue = 1;
        },
        @{
            policyValueName = "AdsSettingForIntrusiveAdsSites";
            policyCanBeRecommended = $false;
            policyValueValue = 2;
        },
        @{
            policyValueName = "AskBeforeCloseEnabled";
            policyCanBeRecommended = $true;
            policyValueValue = 0;
        },
        @{
            policyValueName = "BlockThirdPartyCookies";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "ConfigureDoNotTrack";
            policyCanBeRecommended = $false;
            policyValueValue = 1;
        },
        @{
            policyValueName = "DiagnosticData";
            policyCanBeRecommended = $false;
            policyValueValue = 0;
        },
        @{
            policyValueName = "HubsSidebarEnabled";
            policyCanBeRecommended = $true;
            policyValueValue = 0;
        },
        @{
            policyValueName = "HomepageIsNewTabPage";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "HomepageLocation";
            policyCanBeRecommended = $true;
            policyValueValue = "edge://newtab";
        },
        @{
            policyValueName = "ShowHomeButton";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "NewTabPageLocation";
            policyCanBeRecommended = $true;
            policyValueValue = "about://blank";
        },
        @{
            policyValueName = "NewTabPageQuickLinksEnabled";
            policyCanBeRecommended = $false;
            policyValueValue = 1;
        },
        @{
            policyValueName = "NewTabPageContentEnabled";
            policyCanBeRecommended = $false;
            policyValueValue = 0;
        },
        @{
            policyValueName = "NewTabPageAllowedBackgroundTypes";
            policyCanBeRecommended = $false;
            policyValueValue = 3;
        },
        @{
            policyValueName = "NewTabPageAppLauncherEnabled";
            policyCanBeRecommended = $false;
            policyValueValue = 0;
        },
        @{
            policyValueName = "ManagedFavorites";
            policyCanBeRecommended = $false;
            policyValueValue = "[{ ""toplevel_name"": ""SharePoint"" }, { ""name"": ""Central administration"", ""url"": ""$centralAdminUrl"" }, { ""name"": ""Root site - Default zone"", ""url"": ""$rootSiteDefaultZone"" }, { ""name"": ""Root site - Intranet zone"", ""url"": ""$rootSiteIntranetZone"" }]";
        },
        @{
            policyValueName = "NewTabPageManagedQuickLinks";
            policyCanBeRecommended = $true;
            policyValueValue = "[{""pinned"": true, ""title"": ""Central administration"", ""url"": ""$centralAdminUrl"" }, { ""pinned"": true, ""title"": ""Root site - Default zone"", ""url"": ""$rootSiteDefaultZone"" }, { ""pinned"": true, ""title"": ""Root site - Intranet zone"", ""url"": ""$rootSiteIntranetZone"" }]";
        }
    )

    [System.Object[]] $ChromePolicies = @(
        @{
            policyValueName = "MetricsReportingEnabled";
            policyCanBeRecommended = $true;
            policyValueValue = 0;
        },
        @{
            policyValueName = "PromotionalTabsEnabled";
            policyCanBeRecommended = $false;
            policyValueValue = 0;
        },
        @{
            policyValueName = "AdsSettingForIntrusiveAdsSites";
            policyCanBeRecommended = $false;
            policyValueValue = 2;
        },
        @{
            policyValueName = "BlockThirdPartyCookies";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "HomepageIsNewTabPage";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "HomepageLocation";
            policyCanBeRecommended = $true;
            policyValueValue = "edge://newtab";
        },
        @{
            policyValueName = "ShowHomeButton";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "NewTabPageLocation";
            policyCanBeRecommended = $false;
            policyValueValue = "about://blank";
        },
        @{
            policyValueName = "BookmarkBarEnabled";
            policyCanBeRecommended = $true;
            policyValueValue = 1;
        },
        @{
            policyValueName = "ManagedBookmarks";
            policyCanBeRecommended = $false;
            policyValueValue = "[{ ""toplevel_name"": ""SharePoint"" }, { ""name"": ""Central administration"", ""url"": ""$centralAdminUrl"" }, { ""name"": ""Root site - Default zone"", ""url"": ""$rootSiteDefaultZone"" }, { ""name"": ""Root site - Intranet zone"", ""url"": ""$rootSiteIntranetZone"" }]";
        }
    )

    [System.Object[]] $AdditionalUsers = @(
        @{
            DisplayName = "Marie Berthelette";
            UserName = "MarieB"
        },
        @{
            DisplayName = "Camille Cartier";
            UserName = "CamilleC"
        },
        @{
            DisplayName = "Elisabeth Arcouet";
            UserName = "ElisabethA"
        },
        @{
            DisplayName = "Ana Bowman";
            UserName = "AnaB"
        },
        @{
            DisplayName = "Olivia Wilson";
            UserName = "OliviaW"
        }
    )

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        # Fix emerging issue "WinRM cannot process the request. The following error with errorcode 0x80090350" while Windows Azure Guest Agent service initiates using https://stackoverflow.com/a/74015954/8669078
        Script SetWindowsAzureGuestAgentDepndencyOnDNS
        {
            GetScript = { }
            TestScript = { return $false }
            SetScript = { Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WindowsAzureGuestAgent' -Name "DependOnService" -Type MultiString -Value "DNS" }
        }

        #**********************************************************
        # Create AD domain
        #**********************************************************
        # Install AD FS early (before reboot) to workaround error below on resource AdfsApplicationGroup:
        # "System.InvalidOperationException: The test script threw an error. ---> System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.IdentityServer.Diagnostics, Version=10.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' or one of its dependencie"
        WindowsFeature AddADFS { Name = "ADFS-Federation";    Ensure = "Present"; }
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

        if ($true -eq $ApplyBrowserPolicies) {
            # Set browser policies asap, so that computers that join domain get them immediately, and  it runs very quickly (<5 secs)
            # Edge - https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies
            Script ConfigureEdgePolicies {
                SetScript  = {
                    $domain = Get-ADDomain -Current LocalComputer
                    $registryKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
                    $policies = $using:EdgePolicies
                    $gpo = New-GPO -name "Edge_browser"
                    New-GPLink -Guid $gpo.Id -Target $domain.DistinguishedName -order 1

                    foreach ($policy in $policies) {
                        $key = $registryKey
                        if ($true -eq $policy.policyCanBeRecommended) {$key += "\Recommended"}
                        $valueType = if ($policy.policyValueValue -is [int]) {"DWORD"} else {"STRING"}
                        Set-GPRegistryValue -Guid $gpo.Id -key $key -ValueName $policy.policyValueName -Type $valueType -value $policy.policyValueValue
                    }
                }
                GetScript  = { return @{ "Result" = "false" } }
                TestScript = {
                    $policy = Get-GPO -name "Edge_browser" -ErrorAction SilentlyContinue
                    if ($null -eq $policy) {
                        return $false
                    } else {
                        return $true
                    }
                }
            }

            # Chrome - https://chromeenterprise.google/intl/en_us/policies/
            Script ConfigureChromePolicies {
                SetScript  = {
                    $domain = Get-ADDomain -Current LocalComputer
                    $registryKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome"
                    $policies = $using:ChromePolicies
                    $gpo = New-GPO -name "Chrome_browser"
                    New-GPLink -Guid $gpo.Id -Target $domain.DistinguishedName -order 1

                    foreach ($policy in $policies) {
                        $key = $registryKey
                        if ($true -eq $policy.policyCanBeRecommended) {$key += "\Recommended"}
                        $valueType = if ($policy.policyValueValue -is [int]) {"DWORD"} else {"STRING"}
                        Set-GPRegistryValue -Guid $gpo.Id -key $key -ValueName $policy.policyValueName -Type $valueType -value $policy.policyValueValue
                    }
                }
                GetScript  = { return @{ "Result" = "false" } }
                TestScript = {
                    $policy = Get-GPO -name "Chrome_browser" -ErrorAction SilentlyContinue
                    if ($null -eq $policy) {
                        return $false
                    } else {
                        return $true
                    }
                }
            }
        }
        
        #**********************************************************
        # Configuration needed by SharePoint farm
        #**********************************************************
        DnsServerPrimaryZone CreateAppsDnsZone
        {
            Name      = $AppDomainFQDN
            Ensure    = "Present"
            DependsOn = "[WaitForADDomain]WaitForDCReady"
        }

        DnsServerPrimaryZone CreateAppsIntranetDnsZone
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
            UserPrincipalName    = "$($Admincreds.UserName)@$DomainFQDN"
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

        CertReq GenerateLDAPSCertificate
        {
            CARootName                = "$DomainNetbiosName-$ComputerName-CA"
            CAServerFQDN              = "$ComputerName.$DomainFQDN"
            Subject                   = "CN=$ComputerName.$DomainFQDN"
            FriendlyName              = "LDAPS certificate for $ADFSSiteName.$DomainFQDN"
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

        Script ExportCertificates
        {
            SetScript = 
            {
                $destinationPath = $using:SetupPath
                $adfsSigningCertName = "ADFS Signing.cer"
                $adfsSigningIssuerCertName = "ADFS Signing issuer.cer"
                Write-Host "Exporting public key of ADFS signing / signing issuer certificates..."
                New-Item $destinationPath -Type directory -ErrorAction SilentlyContinue
                $signingCert = Get-ChildItem -Path "cert:\LocalMachine\My\" -DnsName "$using:ADFSSiteName.Signing"
                $signingCert| Export-Certificate -FilePath ([System.IO.Path]::Combine($destinationPath, $adfsSigningCertName))
                Get-ChildItem -Path "cert:\LocalMachine\Root\"| Where-Object{$_.Subject -eq  $signingCert.Issuer}| Select-Object -First 1| Export-Certificate -FilePath ([System.IO.Path]::Combine($destinationPath, $adfsSigningIssuerCertName))
                Write-Host "Public key of ADFS signing / signing issuer certificates successfully exported"
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
            UserPrincipalName      = "$($AdfsSvcCreds.UserName)@$DomainFQDN"
            Password               = $AdfsSvcCreds
            PasswordAuthentication = 'Negotiate'
            PasswordNeverExpires   = $true
            Ensure                 = "Present"
            DependsOn              = "[CertReq]GenerateADFSSiteCertificate", "[CertReq]GenerateADFSSigningCertificate", "[CertReq]GenerateADFSDecryptionCertificate"
        }

        # https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/deployment/configure-corporate-dns-for-the-federation-service-and-drs
        DnsRecordCname AddADFSDevideRegistrationAlias {
            Name = "enterpriseregistration"
            ZoneName = $DomainFQDN
            HostNameAlias = "$ComputerName.$DomainFQDN"
            Ensure = "Present"
            DependsOn = "[WaitForADDomain]WaitForDCReady"
        }

        AdfsFarm CreateADFSFarm
        {
            FederationServiceName        = "$ADFSSiteName.$DomainFQDN"
            FederationServiceDisplayName = "$ADFSSiteName.$DomainFQDN"
            CertificateDnsName           = "$ADFSSiteName.$DomainFQDN"
            SigningCertificateDnsName    = "$ADFSSiteName.Signing"
            DecryptionCertificateDnsName = "$ADFSSiteName.Decryption"
            ServiceAccountCredential     = $AdfsSvcCredsQualified
            Credential                   = $DomainCredsNetbios
            DependsOn                    = "[WindowsFeature]AddADFS"
        }

        # This DNS record is tested by other VMs to join AD only after it was found
        # It is added after DSC resource AdfsFarm, because it is the last operation that triggers a reboot of the DC
        DnsRecordA AddADFSHostDNS {
            Name        = $ADFSSiteName
            ZoneName    = $DomainFQDN
            IPv4Address = $PrivateIP
            Ensure      = "Present"
            DependsOn   = "[AdfsFarm]CreateADFSFarm"
        }

        ADFSRelyingPartyTrust CreateADFSRelyingParty
        {
            Name                       = $SharePointSitesAuthority
            Identifier                 = "urn:sharepoint:$($SharePointSitesAuthority)"
            ClaimsProviderName         = @("Active Directory")
            WSFedEndpoint              = "https://$SharePointSitesAuthority.$DomainFQDN/_trust/"
            ProtocolProfile            = "WsFed-SAML"
            AdditionalWSFedEndpoint    = @("https://*.$DomainFQDN/")
            IssuanceAuthorizationRules = ' => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", value = "true");'
            IssuanceTransformRules     = @(
                MSFT_AdfsIssuanceTransformRule
                {
                    TemplateName   = 'LdapClaims'
                    Name           = 'Claims from Active Directory attributes'
                    AttributeStore = 'Active Directory'
                    LdapMapping    = @(
                        MSFT_AdfsLdapMapping
                        {
                            LdapAttribute     = 'userPrincipalName'
                            OutgoingClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn'
                        }
                        MSFT_AdfsLdapMapping
                        {
                            LdapAttribute     = 'mail'
                            OutgoingClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'
                        }
                        MSFT_AdfsLdapMapping
                        {
                            LdapAttribute     = 'tokenGroups(longDomainQualifiedName)'
                            OutgoingClaimType = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'
                        }
                    )
                }
            )
            Ensure               = 'Present'
            PsDscRunAsCredential = $DomainCredsNetbios
            DependsOn            = "[AdfsFarm]CreateADFSFarm"
        }

        AdfsApplicationGroup OidcGroup
        {
            Name        = $AdfsOidcAGName
            Description = "OIDC for SharePoint Subscription"
            PsDscRunAsCredential = $DomainCredsNetbios
            DependsOn   = "[AdfsFarm]CreateADFSFarm"
        }

        AdfsNativeClientApplication OidcNativeApp
        {
            Name                       = "$AdfsOidcAGName - Native application"
            ApplicationGroupIdentifier = $AdfsOidcAGName
            Identifier                 = $AdfsOidcIdentifier
            RedirectUri                = "https://*.$DomainFQDN/"
            DependsOn                  = "[AdfsApplicationGroup]OidcGroup"
        }

        AdfsWebApiApplication OidcWebApiApp
        {
            Name                          = "$AdfsOidcAGName - Web API"
            ApplicationGroupIdentifier    = $AdfsOidcAGName
            Identifier                    = $AdfsOidcIdentifier
            AccessControlPolicyName       = "Permit everyone"
            AlwaysRequireAuthentication   = $false
            AllowedClientTypes            = "Public", "Confidential"
            IssueOAuthRefreshTokensTo     = "AllDevices"
            NotBeforeSkew                 = 0
            RefreshTokenProtectionEnabled = $true
            RequestMFAFromClaimsProviders = $false
            TokenLifetime                 = 0
            IssuanceTransformRules        = @(
                MSFT_AdfsIssuanceTransformRule
                {
                    TemplateName   = 'LdapClaims'
                    Name           = 'Claims from Active Directory attributes'
                    AttributeStore = 'Active Directory'
                    LdapMapping    = @(
                        MSFT_AdfsLdapMapping
                        {
                            LdapAttribute     = 'userPrincipalName'
                            OutgoingClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn'
                        }
                        MSFT_AdfsLdapMapping
                        {
                            LdapAttribute     = 'mail'
                            OutgoingClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'
                        }
                        MSFT_AdfsLdapMapping
                        {
                            LdapAttribute     = 'tokenGroups(longDomainQualifiedName)'
                            OutgoingClaimType = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'
                        }
                    )
                }
                MSFT_AdfsIssuanceTransformRule
                {
                    TemplateName = "CustomClaims"
                    Name         = "nbf"
                    CustomRule   = 'c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"] 
=> issue(Type = "nbf", Value = "0");'
                }
            )
            DependsOn                  = "[AdfsApplicationGroup]OidcGroup"
        }

        AdfsApplicationPermission OidcWebApiAppPermission
        {
            ClientRoleIdentifier = $AdfsOidcIdentifier
            ServerRoleIdentifier = $AdfsOidcIdentifier
            ScopeNames           = "openid"
            DependsOn            = "[AdfsNativeClientApplication]OidcNativeApp", "[AdfsWebApiApplication]OidcWebApiApp"
        }

        WindowsFeature AddADTools             { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature AddADPowerShell        { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        WindowsFeature AddDnsTools            { Name = "RSAT-DNS-Server";    Ensure = "Present"; }
        WindowsFeature AddADLDS               { Name = "RSAT-ADLDS";         Ensure = "Present"; }
        WindowsFeature AddADCSManagementTools { Name = "RSAT-ADCS-Mgmt";     Ensure = "Present"; }

        #******************************************************************
        # Set insecure LDAP configurations from default 1 to 2 to avoid elevation of priviledge vulnerability on AD domain controller
        # Mitigate https://msrc.microsoft.com/update-guide/vulnerability/CVE-2017-8563 using https://support.microsoft.com/en-us/topic/use-the-ldapenforcechannelbinding-registry-entry-to-make-ldap-authentication-over-ssl-tls-more-secure-e9ecfa27-5e57-8519-6ba3-d2c06b21812e
        #******************************************************************
        Script EnforceLdapAuthOverTls {
            SetScript  = {
                $domain = Get-ADDomain -Current LocalComputer
                $key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $gpo = New-GPO -name "EnforceLdapAuthOverTls"
                New-GPLink -Guid $gpo.Id -Target $domain.DomainControllersContainer -order 1
                Set-GPRegistryValue -Guid $gpo.Id -key $key -ValueName "LdapEnforceChannelBinding" -Type DWORD -value 2
                Set-GPRegistryValue -Guid $gpo.Id -key $key -ValueName "ldapserverintegrity" -Type DWORD -value 2
            }
            GetScript  = { return @{ "Result" = "false" } }
            TestScript = {
                $policy = Get-GPO -name "EnforceLdapAuthOverTls" -ErrorAction SilentlyContinue
                if ($null -eq $policy) {
                    return $false
                } else {
                    return $true
                }
            }
        }

        ADOrganizationalUnit AdditionalUsersOU
        {
            Name                            = $AdditionalUsersPath.Split(',')[0].Substring(3)
            Path                            = $AdditionalUsersPath.Substring($AdditionalUsersPath.IndexOf(',') + 1)
            ProtectedFromAccidentalDeletion = $false
            Ensure                          = 'Present'
            DependsOn                       = "[WaitForADDomain]WaitForDCReady"
        }

        foreach ($AdditionalUser in $AdditionalUsers) {
            ADUser "ExtraUser_$($AdditionalUser.UserName)"
            {
                DomainName           = $DomainFQDN
                Path                 = $AdditionalUsersPath
                UserName             = $AdditionalUser.UserName
                EmailAddress         = "$($AdditionalUser.UserName)@$DomainFQDN"
                UserPrincipalName    = "$($AdditionalUser.UserName)@$DomainFQDN"
                DisplayName          = $AdditionalUser.DisplayName
                GivenName            = $AdditionalUser.DisplayName.Split(' ')[0]
                Surname              = $AdditionalUser.DisplayName.Split(' ')[1]
                PasswordNeverExpires = $true
                Password              = $AdfsSvcCreds
                Ensure               = "Present"
                DependsOn            = "[ADOrganizationalUnit]AdditionalUsersOU"
            }
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

$password = ConvertTo-SecureString -String "mytopsecurepassword" -AsPlainText -Force
$Admincreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$AdfsSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "adfssvc", $password
$DomainFQDN = "contoso.local"
$PrivateIP = "10.1.1.4"
$SPServerName = "SP"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.5\DSCWork\ConfigureDCVM.0\ConfigureDCVM"
ConfigureDCVM -Admincreds $Admincreds -AdfsSvcCreds $AdfsSvcCreds -DomainFQDN $DomainFQDN -PrivateIP $PrivateIP -SPServerName $SPServerName -SharePointSitesAuthority $SharePointSitesAuthority -SharePointCentralAdminPort $SharePointCentralAdminPort -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Set-DscLocalConfigurationManager -Path $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.83.5
#>