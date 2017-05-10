
param(
    [Parameter(Mandatory=$false)]
    [string] $NodeName = "$env:COMPUTERNAME",

    [Parameter(Mandatory=$false)]
    [string] $NodeType = '0',

    [Parameter(Mandatory=$false)]
    [string] $HgsDomainName = 'contoso.hgs',

    [Parameter(Mandatory=$false)]
    [string] $SafeModeAdministratorPassword = 'Pa$$w0rd',
    
    [Parameter(Mandatory=$false)]
    [string] $HgsServiceName = 'TpmHgs01',

    [Parameter(Mandatory=$false)]
    [Uint16] $HttpPort = '80',

    [Parameter(Mandatory=$false)]
    [Uint16] $HttpsPort = '443',


    [Parameter(Mandatory=$false)]
    [string] $HttpsCertificateName = 'HGSHTTPSCert',

    [Parameter(Mandatory=$false)]
    [string] $EncryptionCertificateName = 'HGSEncryptionCert',

    [Parameter(Mandatory=$false)]
    [string] $SigningCertificateName = 'HGSSigningCert',


    [Parameter(Mandatory=$false)]
    [string] $HttpsCertificatePath = 'C:\HttpsCertificatePath.pfx',

    [Parameter(Mandatory=$false)]
    [string] $HttpsCertificatePassword = 'Pa$$w0rd',

    [Parameter(Mandatory=$false)]
    [string] $EncryptionCertificatePath = 'C:\encryptionCert.pfx',

    [Parameter(Mandatory=$false)]
    [string] $EncryptionCertificatePassword  = 'Pa$$w0rd',

    [Parameter(Mandatory=$false)]
    [string] $SigningCertificatePath = 'C:\signingCert.pfx',

    [Parameter(Mandatory=$false)]
    [string] $SigningCertificatePassword  = 'Pa$$w0rd',

    [Parameter(Mandatory=$false)]
    [string] $GenerateSelfSignedCertificate = "false",
   
    [Parameter(Mandatory=$false)]
    [ValidateSet ('TrustActiveDirectory', 'TrustTpm') ]
    [string] $AttestationMode = 'TrustTpm',

    [Parameter(Mandatory=$false)]
    [string] $HgsServerPrimaryIPAddress = "10.0.0.4",

    [Parameter(Mandatory=$false)]
    [string] $HgsServerPrimaryAdminUsername = "uday",

    [Parameter(Mandatory=$false)]
    [string] $HgsServerPrimaryAdminPassword = 'Pa$$w0rd12345',
    
    [Parameter(Mandatory=$false)]
    [string] $TargetDomainName,

    [Parameter(Mandatory=$false)]
    [string] $TargetDomainAdministrator,

    [Parameter(Mandatory=$false)]
    [string] $TargetDomainAdministratorPassword,

    [Parameter(Mandatory=$false)]
    [string] $FabricDnsIpAddress,

    [Parameter(Mandatory=$false)]
    [string] $FabricAdGroupSid
)


function GetTestFunction ()
{
    Write-Verbose "Commong Test Function"
}

function Get-ImpersonatetLib
{
    if ($script:ImpersonateLib)
    {
        return $script:ImpersonateLib
    }

    $sig = @'
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

[DllImport("kernel32.dll")]
public static extern Boolean CloseHandle(IntPtr hObject);
'@ 
   $script:ImpersonateLib = Add-Type -PassThru -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition $sig 

   return $script:ImpersonateLib
    
}

function ImpersonateAs([PSCredential] $cred)
{
    [IntPtr] $userToken = [Security.Principal.WindowsIdentity]::GetCurrent().Token
    $userToken
    $ImpersonateLib = Get-ImpersonatetLib

    $bLogin = $ImpersonateLib::LogonUser($cred.GetNetworkCredential().UserName, $cred.GetNetworkCredential().Domain, $cred.GetNetworkCredential().Password, 
    9, 0, [ref]$userToken)
    
    if ($bLogin)
    {
        $Identity = New-Object Security.Principal.WindowsIdentity $userToken
        $context = $Identity.Impersonate()
    }
    else
    {
        throw "Can't Logon as User $cred.GetNetworkCredential().UserName."
    }
    $context, $userToken
}

function CloseUserToken([IntPtr] $token)
{
    $ImpersonateLib = Get-ImpersonatetLib

    $bLogin = $ImpersonateLib::CloseHandle($token)
    if (!$bLogin)
    {
        throw "Can't close token"
    }
}


Configuration xHGSCommon
{
    
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyAndAutoCorrect";
                   
        }

        WindowsFeature InstallHostGuardianServiceRole
        {
            Name = "HostGuardianServiceRole";
            IncludeAllSubFeature =  $true;

        }

        WindowsFeature WebMGmtTools
        {
            Name = "Web-MGmt-Tools";
            IncludeAllSubFeature =  $true;

        }

        WindowsFeature RSATADTools
        {
            Name = "RSAT-AD-Tools";
            IncludeAllSubFeature =  $true;

        }

        WindowsFeature RSATClustering
        {
            Name = "RSAT-Clustering";
            IncludeAllSubFeature =  $true;

        }
        

} #End of xHGSCommon


Configuration xHGS
{
    
   
    Node $AllNodes.where{$_.Role -eq "FirstNode"}.NodeName
    {
     
            xHGSCommon CommonActivityFirstNode
            {
            }

            Log CreatingNewDomain
            {
                
                Message =  "Creating New Domain";
                DependsOn = '[xHGSCommon]CommonActivityFirstNode'
            } 

            Script InstallHGSServer
            {
               
                 
                SetScript = {
                     write-verbose "HgsDomainName: $($using:Node.HgsDomainName)";
                     Install-HgsServer -HgsDomainName  $($using:Node.HgsDomainName) -SafeModeAdministratorPassword (ConvertTo-SecureString $($using:Node.SafeModeAdministratorPassword) -AsPlainText -Force) 
                     $global:DSCMachineStatus = 1
                 }
 
                TestScript = { 
                 
                    $result = $null

                    try { 
                        $result = Get-ADDomain -Current LocalComputer -ErrorAction:SilentlyContinue
                        Write-Verbose "Get-ADDomain Result: $result"
                        
                     } catch {}
                    
                    if($result -eq $null) 
                        {return $false}
                    else 
                        {return $true }  
                 
                }
                GetScript = { 

                        $result = (Get-ADDomain -Current LocalComputer)
                        return  @{ 
                                    Result = $result
                        }
                }
             

            } #End of Intall HgsServer


            Script InitializeHgsServer
            {
               DependsOn =  '[Script]InstallHGSServer'

                SetScript = {
                     
                     write-verbose "Initializing HgsServer : $($using:Node.HgsDomainName)";
                        
                     if(!(Get-PSDrive -Name AD -ErrorAction SilentlyContinue)){ New-PSDrive -Name AD -PSProvider ActiveDirectory -Root //RootDSE/ }


                     if([boolean]::Parse("$($using:Node.GenerateSelfSignedCertificate)"))
                     {
						                         
                        $_Httpscertname = "$($using:Node.HttpsCertificateName)"
                        $_encryptioncertname = "$($using:Node.EncryptionCertificateName)"
                        $_signingcertname = "$($using:Node.SigningCertificateName)"

                        if ( (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + $_Httpscertname )}) -eq $null)
                        {
                            Write-verbose "Generating Certificate "
                            $_HttpsCertificatePassword = ConvertTo-SecureString -AsPlainText "$($using:Node.HttpsCertificatePassword)" –Force
                            $HttpsCert = New-SelfSignedCertificate -DnsName $_Httpscertname -CertStoreLocation Cert:\LocalMachine\My
                            Export-PfxCertificate -Cert $HttpsCert -Password $_HttpsCertificatePassword -FilePath "$($using:Node.HttpsCertificatePath)" 
							
                        }

                        if ( (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + $_encryptioncertname )}) -eq $null)
                        {
                            $_EncryptionCertificatePassword = ConvertTo-SecureString -AsPlainText "$($using:Node.EncryptionCertificatePassword)" –Force
                            $encryptionCert = New-SelfSignedCertificate -DnsName $_encryptioncertname -CertStoreLocation Cert:\LocalMachine\My
                            Export-PfxCertificate -Cert $encryptionCert -Password $_EncryptionCertificatePassword -FilePath "$($using:Node.EncryptionCertificatePath)"
                        }

                       
                        if ( (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + $_signingcertname )}) -eq $null)
                        {
                            $_SigningCertificatePassword = ConvertTo-SecureString -AsPlainText "$($using:Node.SigningCertificatePassword)" –Force
                            $signingCert = New-SelfSignedCertificate -DnsName $_signingcertname -CertStoreLocation Cert:\LocalMachine\My
                            Export-PfxCertificate -Cert $signingCert -Password $_SigningCertificatePassword -FilePath "$($using:Node.SigningCertificatePath)"
                        }

                     }
				

                         
                    $_httpsCertificateThumbprint =  (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.HttpsCertificateName)" )} | Sort-Object NotAfter | select -Last 1 ).Thumbprint
                    $_encryptionCertificatThumbprint =  (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.EncryptionCertificateName)" )} | Sort-Object NotAfter | select -Last 1 ).Thumbprint
                    $_signingCertificateThumbprint =  (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.SigningCertificateName)")} | Sort-Object NotAfter | select -Last 1 ).Thumbprint
                    
                    
                    $httpsCert = (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.HttpsCertificateName)") } | Sort-Object NotAfter | select -Last 1 )

                    [System.Security.Cryptography.RSACng] $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($httpsCert)
                    [System.Security.Cryptography.CngKey] $key = $rsa.Key
                    Write-Verbose "encryptionCert Private key is located at $($key.UniqueName)"
                    $httpsCertPath = "C:\ProgramData\Microsoft\Crypto\Keys\$($key.UniqueName)"

                    $acl= Get-Acl -Path $httpsCertPath
                    $permission="Authenticated Users","FullControl","Allow"
                    $accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
                    $acl.AddAccessRule($accessRule)
                    Set-Acl $httpsCertPath $acl
                     
                      
                    $encryptionCert = (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.EncryptionCertificateName)") } | Sort-Object NotAfter | select -Last 1 )

                    [System.Security.Cryptography.RSACng] $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($encryptionCert)
                    [System.Security.Cryptography.CngKey] $key = $rsa.Key
                    Write-Verbose "encryptionCert Private key is located at $($key.UniqueName)"
                    $encryptionCertPath = "C:\ProgramData\Microsoft\Crypto\Keys\$($key.UniqueName)"

                    $acl= Get-Acl -Path $encryptionCertPath
                    $permission="Authenticated Users","FullControl","Allow"
                    $accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
                    $acl.AddAccessRule($accessRule)
                    Set-Acl $encryptionCertPath $acl
					                        

                    $SigningCert = (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.SigningCertificateName)") } | Sort-Object NotAfter | select -Last 1 )

                    [System.Security.Cryptography.RSACng] $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($SigningCert)
                    [System.Security.Cryptography.CngKey] $key = $rsa.Key
                    Write-Verbose "SigningCert Private key is located at $($key.UniqueName)"
                    $SigningCertPath = "C:\ProgramData\Microsoft\Crypto\Keys\$($key.UniqueName)"

                    $acl= Get-Acl -Path $SigningCertPath
                    $permission="Authenticated Users","FullControl","Allow"
                    $accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
                    $acl.AddAccessRule($accessRule)
                    Set-Acl $SigningCertPath $acl

                  

                    if($using:Node.AttestationMode -eq 'TrustActiveDirectory')
                    {
                        
                        $_HttpsCertificatePassword = (ConvertTo-SecureString $($using:Node.HttpsCertificatePassword) -AsPlainText -Force )

                        Initialize-HgsServer -HgsServiceName $($using:Node.HgsServiceName) -Http -Https -TrustActiveDirectory `
                                               -HttpPort $($using:Node.HttpPort ) `
                                               -HttpsPort $($using:Node.HttpsPort ) `
                                               -HttpsCertificateThumbprint $_httpsCertificateThumbprint `
                                               -EncryptionCertificateThumbprint $_encryptionCertificatThumbprint `
                                               -SigningCertificateThumbprint $_signingCertificateThumbprint
                                  
                        
                                           
                     }
                     
                     if($using:Node.AttestationMode -eq 'TrustTpm')
                     {

                        Initialize-HgsServer   -HgsServiceName  $($using:Node.HgsServiceName) -Http -Https -TrustTpm `
                                               -HttpPort $($using:Node.HttpPort ) `
                                               -HttpsPort $($using:Node.HttpsPort ) `
                                               -HttpsCertificateThumbprint $_httpsCertificateThumbprint `
                                               -EncryptionCertificateThumbprint $_encryptionCertificatThumbprint `
                                               -SigningCertificateThumbprint $_signingCertificateThumbprint
                                                                
                     }                       
                                                                                    
                     
                 }
 
                TestScript = { 

                    <# - Doesn't work 
                        $cred = (new-object -typename System.Management.Automation.PSCredential -argumentlist "$($using:Node.HgsDomainName)\$($using:Node.HgsServerPrimaryAdminUsername)", (ConvertTo-SecureString ($($using:Node.HgsServerPrimaryAdminPassword )) -AsPlainText -Force))
                    
                        $sig = @'
                            [DllImport("advapi32.dll", SetLastError = true)]
                            public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

                            [DllImport("kernel32.dll")]
                            public static extern Boolean CloseHandle(IntPtr hObject); 
'@

                        $ImpersonateLib  = Add-Type -PassThru -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition $sig 

                        [IntPtr] $userToken = [Security.Principal.WindowsIdentity]::GetCurrent().Token
                        $userToken
                        $bLogin = $ImpersonateLib::LogonUser($cred.GetNetworkCredential().UserName, $cred.GetNetworkCredential().Domain, $cred.GetNetworkCredential().Password, 9, 0, [ref]$userToken)

                        if ($bLogin)
                        {
                            $Identity = New-Object Security.Principal.WindowsIdentity $userToken
                            $context = $Identity.Impersonate()
                        }
                        else
                        {
                            throw "Can't get Impersonate Token from DSC toLogon as User $cred.GetNetworkCredential().UserName."
                        }


                    Write-Verbose "Impersonation Token Obtained Successfullly"
                    
                    $result = Test-HgsServer -HgsDomainName $($using:Node.HgsDomainName) 

                    $result.ClusterTest > c:\result.txt
                    
                    Write-Host "Result of Test-HgsServer : ($($result.ClusterTest.Result))"
                    

                    if( ($result.ClusterTest.Result) -eq "Passed")
                    {
                        return $true
                    }                    
               
                    else 
                    {
                        return $false
                        
                    }
                    #>

                    $result = $null
                    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Windows.HgsStore")
                    $store = $null
                    $result = [Microsoft.Windows.HgsStore.HgsReplicatedStore]::TryOpenStore("Attestation", [ref]$store)
                    Write-Verbose "Result of HgsReplicatedStore: TryOpenStore: $result"

                    If( $result -eq $false)
                    {
                        Write-verbose "Clearing HGS Server Configurtion from this node"
                        Clear-HgsServer -Force -Confirm:$false #-WarningAction:SilentlyContinue
                    }

                    return $result
                    

                }
                GetScript = {
                    #$result = Test-HgsServer
                    $result = get-cluster
        
                    return  @{
                         Result = $result 
                    }
                          
                 }
             

            } #End of Initialize-HgsServer
      
    } #End of Node
    
    Node $AllNodes.where{$_.Role -eq "SecondNode"}.NodeName
    {
           
            xHGSCommon CommonActivitySecondNode
            {
            }

            WaitForAny WaitForADOnPrimaryToReady 
            {
                   #NodeName = $AllNodes.where{$_.Role -eq "FirstNode"}.NodeName
                   NodeName = $Node.HgsServerPrimaryIPAddress
                   ResourceName = "[Script]InitializeHgsServer"
                   RetryCount = 2*60
                   RetryIntervalSec = 30
                   DependsOn =  '[xHGSCommon]CommonActivitySecondNode'
            }

            Log ADOnPrimaryReady
            {
                DependsOn =  '[WaitForAny]WaitForADOnPrimaryToReady'
                Message =  "AD Ready on : $Node.HgsServerPrimaryIPAddress "  
            }

            script ChangeDNSAddress
            {
                DependsOn =  '[WaitForAny]WaitForADOnPrimaryToReady'
                SetScript = {
                     write-verbose "HgsServerPrimaryIPAddress: $($using:Node.HgsServerPrimaryIPAddress)"

                    $netipconfig = Get-NetIPConfiguration |? {$_.IPv4DefaultGateway -ne $null } | Select-Object -First 1 
                    $dnsclientAddress = get-DNSClientServerAddress -InterfaceIndex $netipconfig.InterfaceIndex |? {$_.AddressFamily -eq "2"}

                    Set-DnsClientServerAddress -InterfaceIndex $dnsclientAddress.InterfaceIndex -ServerAddresses "$($using:Node.HgsServerPrimaryIPAddress)"

                    
                 }
 
                TestScript = { 
                
                    $netipconfig = Get-NetIPConfiguration |? {$_.IPv4DefaultGateway -ne $null } | Select-Object -First 1 
                    $dnsclientAddress = get-DNSClientServerAddress -InterfaceIndex $netipconfig.InterfaceIndex |? {$_.AddressFamily -eq "2"}
                    return  $dnsclientAddress.ServerAddresses.Contains("$($using:Node.HgsServerPrimaryIPAddress)")
                
                }
                GetScript = { 
                
                 $netipconfig = Get-NetIPConfiguration |? {$_.IPv4DefaultGateway -ne $null } | Select-Object -First 1 
                 Write-Verbose $netipconfig
                 $dnsclientAddress = get-DNSClientServerAddress -InterfaceIndex $($netipconfig.InterfaceIndex) |? {$_.AddressFamily -eq "2"}
                 return $dnsclientAddress

                }
            }

            
            Script InstallHGSServerSecondary
            {
               
               DependsOn = '[script]ChangeDNSAddress'
                 
                SetScript = {
                     write-verbose "HgsDomainName: $($using:Node.HgsDomainName)";
                     

                     Install-HgsServer  -HgsDomainName  $($using:Node.HgsDomainName)  `
                                        -SafeModeAdministratorPassword (ConvertTo-SecureString $($using:Node.SafeModeAdministratorPassword) -AsPlainText -Force) `
                                        -HgsDomainCredential (new-object -typename System.Management.Automation.PSCredential -argumentlist "$($using:Node.HgsDomainName)\$($using:Node.HgsServerPrimaryAdminUsername)", (ConvertTo-SecureString ($($using:Node.HgsServerPrimaryAdminPassword )) -AsPlainText -Force))
                                        
                                        
                     $global:DSCMachineStatus = 1
                 }
 
                TestScript = { 
                        
                    $result = $null

                    try { 
                        $result = Get-ADDomain -Current LocalComputer -ErrorAction:SilentlyContinue
                        Write-Verbose "Get-ADDomain Result: $result"
                        
                     } catch {}
                    
                    if($result -eq $null) 
                        {return $false}
                    else 
                        {return $true } 

                }
                GetScript = { 
                    
                    $result = (Get-ADDomain -Current LocalComputer)
                    return  @{ 
                                Result = $result
                    }
                
                }
             

            } #End of Intall HgsServer

            #>

            Script InitializeHgsServerSecondary
            {
                DependsOn =  '[Script]InstallHGSServerSecondary'
                
                
                SetScript = {
                        
                       $cred = (new-object -typename System.Management.Automation.PSCredential -argumentlist "$($using:Node.HgsDomainName)\$($using:Node.HgsServerPrimaryAdminUsername)", (ConvertTo-SecureString ($($using:Node.HgsServerPrimaryAdminPassword )) -AsPlainText -Force))
                       
                       $sig = @'
                            [DllImport("advapi32.dll", SetLastError = true)]
                            public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

                            [DllImport("kernel32.dll")]
                            public static extern Boolean CloseHandle(IntPtr hObject); 
'@

                        $ImpersonateLib  = Add-Type -PassThru -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition $sig 

                        [IntPtr] $userToken = [Security.Principal.WindowsIdentity]::GetCurrent().Token
                        $userToken
                        $bLogin = $ImpersonateLib::LogonUser($cred.GetNetworkCredential().UserName, $cred.GetNetworkCredential().Domain, $cred.GetNetworkCredential().Password, 9, 0, [ref]$userToken)

                        if ($bLogin)
                        {
                            $Identity = New-Object Security.Principal.WindowsIdentity $userToken
                            $context = $Identity.Impersonate()
                        }
                        else
                        {
                            throw "Can't get Impersonate Token from DSC toLogon as User $cred.GetNetworkCredential().UserName."
                        }

                        if([boolean]::Parse("$($using:Node.GenerateSelfSignedCertificate)"))
                        {
                             #Copy the self-signed certificate generated on first node

                            $_HttpsCertificatePassword = ConvertTo-SecureString -AsPlainText "$($using:Node.HttpsCertificatePassword)" –Force
                            Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath (([string]::Format('\\{0}\{1}', $($using:Node.HgsServerPrimaryIPAddress), $($using:Node.HttpsCertificatePath))).replace(":","$")) -Password $_HttpsCertificatePassword 
                            $httpsCert = (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.HttpsCertificateName)") } | Sort-Object NotAfter | select -Last 1 )

							[System.Security.Cryptography.RSACng] $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($httpsCert)
							[System.Security.Cryptography.CngKey] $key = $rsa.Key
							Write-Verbose "encryptionCert Private key is located at $($key.UniqueName)"
							$httpsCertPath = "C:\ProgramData\Microsoft\Crypto\Keys\$($key.UniqueName)"

							$acl= Get-Acl -Path $httpsCertPath
							$permission="Authenticated Users","FullControl","Allow"
							$accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
							$acl.AddAccessRule($accessRule)
							Set-Acl $httpsCertPath $acl

                            $_httpsCertificateThumbprint =  (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.HttpsCertificateName)" )} | Sort-Object NotAfter | select -Last 1 ).Thumbprint
    
                            Initialize-HgsServer -force -Confirm:$false -Http -Https -HgsServerIPAddress $($using:Node.HgsServerPrimaryIPAddress) `
                                                 -HttpPort $($using:Node.HttpPort ) `
                                                 -HttpsPort $($using:Node.HttpsPort ) `
                                                 -HttpsCertificateThumbprint $_httpsCertificateThumbprint 
                            
							#Import cert with keys must happen after initialize

                            $_EncryptionCertificatePassword = ConvertTo-SecureString -AsPlainText "$($using:Node.EncryptionCertificatePassword)" –Force 
                            $_SigningCertificatePassword = ConvertTo-SecureString -AsPlainText "$($using:Node.SigningCertificatePassword)" –Force
							                          
														
							Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath (([string]::Format('\\{0}\{1}', $($using:Node.HgsServerPrimaryIPAddress), $($using:Node.EncryptionCertificatePath))).replace(":","$")) -Password $_EncryptionCertificatePassword 
							Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath (([string]::Format('\\{0}\{1}', $($using:Node.HgsServerPrimaryIPAddress), $($using:Node.SigningCertificatePath))).replace(":","$")) -Password $_SigningCertificatePassword 
                     
                      
                        }
                        else
                        {
                             # Find certificate from the store with cert name
                             $_httpsCertificateThumbprint =  (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.HttpsCertificateName)" )} | Sort-Object NotAfter | select -Last 1 ).Thumbprint

                             Initialize-HgsServer   -force -Confirm:$false -Http -Https -HgsServerIPAddress $($using:Node.HgsServerPrimaryIPAddress) `
                                               -HttpPort $($using:Node.HttpPort ) `
                                               -HttpsPort $($using:Node.HttpsPort ) `
                                               -HttpsCertificateThumbprint $_httpsCertificateThumbprint 

                            
                        }

						#Granting Access to private keys
						$encryptionCert = (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.EncryptionCertificateName)") } | Sort-Object NotAfter | select -Last 1 )

						[System.Security.Cryptography.RSACng] $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($encryptionCert)
						[System.Security.Cryptography.CngKey] $key = $rsa.Key
						Write-Verbose "encryptionCert Private key is located at $($key.UniqueName)"
						$encryptionCertPath = "C:\ProgramData\Microsoft\Crypto\Keys\$($key.UniqueName)"

						$acl= Get-Acl -Path $encryptionCertPath
						$permission="Authenticated Users","FullControl","Allow"
						$accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
						$acl.AddAccessRule($accessRule)
						Set-Acl $encryptionCertPath $acl
					                        

						$SigningCert = (Get-ChildItem  Cert:\LocalMachine\My | where {$_.Subject -eq ('CN=' + "$($using:Node.SigningCertificateName)") } | Sort-Object NotAfter | select -Last 1 )

						[System.Security.Cryptography.RSACng] $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($SigningCert)
						[System.Security.Cryptography.CngKey] $key = $rsa.Key
						Write-Verbose "SigningCert Private key is located at $($key.UniqueName)"
						$SigningCertPath = "C:\ProgramData\Microsoft\Crypto\Keys\$($key.UniqueName)"

						$acl= Get-Acl -Path $SigningCertPath
						$permission="Authenticated Users","FullControl","Allow"
						$accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
						$acl.AddAccessRule($accessRule)
						Set-Acl $SigningCertPath $acl
                                              
                                                                      
                                  
                }
 
                TestScript = { 
                                   
                    $result = $null
                    try
                    {
                        $result = get-cluster -ErrorAction:SilentlyContinue
                    }
                    catch {}

                    if($result -eq $null) 
                        {return $false}
                    else 
                        {return $true } 

                    
                } #End of TestScript
                    

                GetScript = {
                    #$result = Test-HgsServer
                    $result = $null
                    try
                    {
                        $result = get-cluster -ErrorAction:SilentlyContinue
                    }
                    catch {}
        
                    return  @{
                         Result = $result 
                }
             

            } #End of Initialize-HgsServer
           
      

    }
    
    }
           
} #End of Configuration

$ConfigData = @{
    AllNodes = 
    @(

        @{
            
            NodeName = '*';
            PSDscAllowPlainTextPassword = $true ;
            DebugMode = $true;          
              
            HgsDomainName = $HgsDomainName;
            SafeModeAdministratorPassword = $SafeModeAdministratorPassword;
            HgsServiceName = $HgsServiceName;
            HttpPort = $HttpPort;
            HttpsPort = $HttpsPort ;

			HttpsCertificateName = $HttpsCertificateName;
            EncryptionCertificateName = $EncryptionCertificateName;
            SigningCertificateName = $SigningCertificateName;

			GenerateSelfSignedCertificate = $GenerateSelfSignedCertificate;        

            HttpsCertificatePath = $HttpsCertificatePath;
            HttpsCertificatePassword= $HttpsCertificatePassword;
            EncryptionCertificatePath = $EncryptionCertificatePath;
            EncryptionCertificatePassword = $EncryptionCertificatePassword;
            SigningCertificatePath = $SigningCertificatePath;
            SigningCertificatePassword = $SigningCertificatePassword;
            
            
            AttestationMode = $AttestationMode;

            HgsServerPrimaryIPAddress = $HgsServerPrimaryIPAddress;
            HgsServerPrimaryAdminUsername = $HgsServerPrimaryAdminUsername ;
            HgsServerPrimaryAdminPassword = $HgsServerPrimaryAdminPassword ;
        }
    );
    NonNodeData = ""   
}

if($NodeType -eq '0')
{
    $_firstnode =   @{

            NodeName = "$NodeName";
            Role = "FirstNode" ;
               
            #unused
            TargetDomainName  = $TargetDomainName;    
            TargetDomainAdministrator =  $TargetDomainAdministrator;
            TargetDomainAdministratorPassword = $TargetDomainAdministratorPassword;          
            FabricDnsIpAddress = $FabricDnsIpAddress;
            FabricAdGroupSid = $FabricAdGroupSid
                                                        
            }

    $ConfigData.AllNodes += $_firstnode
}

if ($NodeType -ne '0')
{
    $_secondnode = @{

            NodeName = $NodeName;
            Role = "SecondNode" ;
          
           
        }
    $ConfigData.AllNodes += $_secondnode

}

      
#Set-Location C:\dsc
$ConfigData.AllNodes > configdata.txt
xHGS -ConfigurationData $ConfigData 

Set-DscLocalConfigurationManager -Path .\xHGS  -Verbose -ComputerName $NodeName
Start-DscConfiguration -Verbose -wait -Path .\xHGS -Force -ComputerName $NodeName

#http://localhost/KeyProtection/service/metadata/2014-07/metadata.xml