# Import the helper functions
Import-Module $PSScriptRoot\PSWSIISEndpoint.psm1 -Verbose:$false
Import-Module $PSScriptRoot\UseSecurityBestPractices.psm1 -Verbose:$false

# The Get-TargetResource cmdlet.
function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        # Prefix of the WCF SVC File
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EndpointName,
            
        # Thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server   
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]                         
        [string]$CertificateThumbPrint,

        # Pull Server is created with the most secure practices
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [bool]$UseSecurityBestPractices,

        # Exceptions of security best practices
        [ValidateSet("SecureTLSProtocols")]
        [string[]] $DisableSecurityBestPractices
    )

    $webSite = Get-Website -Name $EndpointName

    if ($webSite)
    {
            $Ensure = 'Present'
            $AcceptSelfSignedCertificates = $false
                
            # Get Full Path for Web.config file    
            $webConfigFullPath = Join-Path $website.physicalPath "web.config"

            # Get module and configuration path
            $modulePath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "ModulePath"
            $ConfigurationPath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "ConfigurationPath"
            $RegistrationKeyPath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "RegistrationKeyPath"

            # Get database path
            switch ((Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "dbprovider"))
            {
                "ESENT" {
                    $databasePath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "dbconnectionstr" | Split-Path -Parent
                }

                "System.Data.OleDb" {
                    $connectionString = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "dbconnectionstr"
                    if ($connectionString -match 'Data Source=(.*)\\Devices\.mdb')
                    {
                        $databasePath = $Matches[0]
                    }
                }
            }

            $UrlPrefix = $website.bindings.Collection[0].protocol + "://"

            $fqdn = $env:COMPUTERNAME
            if ($env:USERDNSDOMAIN)
            {
                $fqdn = $env:COMPUTERNAME + "." + $env:USERDNSDOMAIN
            }

            $iisPort = $website.bindings.Collection[0].bindingInformation.Split(":")[1]
                        
            $svcFileName = (Get-ChildItem -Path $website.physicalPath -Filter "*.svc").Name

            $serverUrl = $UrlPrefix + $fqdn + ":" + $iisPort + "/" + $svcFileName

            $webBinding = Get-WebBinding -Name $EndpointName

            # This is the 64 bit module
            $certNativeModule = Get-WebConfigModulesSetting -WebConfigFullPath $webConfigFullPath -ModuleName "IISSelfSignedCertModule" 
            if($certNativeModule)
            {
                $AcceptSelfSignedCertificates = $true
            }           

            # This is the 32 bit module
            $certNativeModule = Get-WebConfigModulesSetting -WebConfigFullPath $webConfigFullPath -ModuleName "IISSelfSignedCertModule(32bit)" 
            if($certNativeModule)
            {
                $AcceptSelfSignedCertificates = $true
            }           
        }
    else
    {
        $Ensure = 'Absent'
    }

    @{
        EndpointName                    = $EndpointName
        CertificateThumbPrint           = if($CertificateThumbPrint -eq 'AllowUnencryptedTraffic'){$CertificateThumbPrint} else {(Get-WebBinding -Name $EndpointName).CertificateHash}
        Port                            = $iisPort
        PhysicalPath                    = $website.physicalPath
        State                           = $webSite.state
        DatabasePath                    = $databasePath
        ModulePath                      = $modulePath
        ConfigurationPath               = $ConfigurationPath
        DSCServerUrl                    = $serverUrl
        Ensure                          = $Ensure
        RegistrationKeyPath             = $RegistrationKeyPath
        AcceptSelfSignedCertificates    = $AcceptSelfSignedCertificates
        UseSecurityBestPractices        = $UseSecurityBestPractices
        DisableSecurityBestPractices    = $DisableSecurityBestPractices
    }
}

# The Set-TargetResource cmdlet.
function Set-TargetResource
{
    param
    (
        # Prefix of the WCF SVC File
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EndpointName,

        # Port number of the DSC Pull Server IIS Endpoint
        [Uint32]$Port = 8080,

        # Physical path for the IIS Endpoint on the machine (usually under inetpub)                            
        [string]$PhysicalPath = "$env:SystemDrive\inetpub\$EndpointName",

        # Thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]                            
        [string]$CertificateThumbPrint,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [ValidateSet("Started", "Stopped")]
        [string]$State = "Started",

        # Location on the disk where the database is stored
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DatabasePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService",

        # Location on the disk where the Modules are stored            
        [string]$ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules",

        # Location on the disk where the Configuration is stored                    
        [string]$ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration",

        # Location on the disk where the RegistrationKeys file is stored                    
        [string]$RegistrationKeyPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService",

        # Add the IISSelfSignedCertModule native module to prevent self-signed certs being rejected.
        [boolean]$AcceptSelfSignedCertificates = $true,

        # Pull Server is created with the most secure practices
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [bool]$UseSecurityBestPractices,

        # Exceptions of security best practices
        [ValidateSet("SecureTLSProtocols")]
        [string[]] $DisableSecurityBestPractices
    )

    # Check parameter values
    if ($UseSecurityBestPractices -and ($CertificateThumbPrint -eq "AllowUnencryptedTraffic"))
    {
        throw "Error: Cannot use best practice security settings with unencrypted traffic. Please set UseSecurityBestPractices to `$false or use a certificate to encrypt pull server traffic."
        # No need to proceed any more
        return
    }

    # Initialize with default values     
    $script:appCmd = "$env:windir\system32\inetsrv\appcmd.exe"
   
    $pathPullServer = "$pshome\modules\PSDesiredStateConfiguration\PullServer"
    $jet4provider = "System.Data.OleDb"
    $jet4database = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$DatabasePath\Devices.mdb;"
    $eseprovider = "ESENT";
    $esedatabase = "$DatabasePath\Devices.edb";

    $culture = Get-Culture
    $language = $culture.TwoLetterISOLanguageName
    # the two letter iso languagename is not actually implemented in the source path, it's always 'en'
    if (-not (Test-Path $pathPullServer\$language\Microsoft.Powershell.DesiredStateConfiguration.Service.Resources.dll)) {
        $language = 'en'
    }

    $os = [System.Environment]::OSVersion.Version
    $IsBlue = $false;
    if($os.Major -eq 6 -and $os.Minor -eq 3)
    {
        $IsBlue = $true;
    }

    $isDownlevelOfBlue = $false;
    if($os.Major -eq 6 -and $os.Minor -lt 3)
    {
        $isDownlevelOfBlue= $true;
    }

    # Use Pull Server values for defaults
    $webConfigFileName = "$pathPullServer\PSDSCPullServer.config"
    $svcFileName = "$pathPullServer\PSDSCPullServer.svc"
    $pswsMofFileName = "$pathPullServer\PSDSCPullServer.mof"
    $pswsDispatchFileName = "$pathPullServer\PSDSCPullServer.xml"

    # ============ Absent block to remove existing site =========
    if(($Ensure -eq "Absent"))
    {
         $website = Get-Website -Name $EndpointName
         if($website -ne $null)
         {
            # there is a web site, but there shouldn't be one
            Write-Verbose "Removing web site $EndpointName"
            PSWSIISEndpoint\Remove-PSWSEndpoint -SiteName $EndpointName
         }

         # we are done here, all stuff below is for 'Present'
         return 
    }
    # ===========================================================
                
    Write-Verbose "Create the IIS endpoint"    
    PSWSIISEndpoint\New-PSWSEndpoint -site $EndpointName `
                     -path $PhysicalPath `
                     -cfgfile $webConfigFileName `
                     -port $Port `
                     -applicationPoolIdentityType LocalSystem `
                     -app $EndpointName `
                     -svc $svcFileName `
                     -mof $pswsMofFileName `
                     -dispatch $pswsDispatchFileName `
                     -asax "$pathPullServer\Global.asax" `
                     -dependentBinaries  "$pathPullServer\Microsoft.Powershell.DesiredStateConfiguration.Service.dll" `
                     -language $language `
                     -dependentMUIFiles  "$pathPullServer\$language\Microsoft.Powershell.DesiredStateConfiguration.Service.Resources.dll" `
                     -certificateThumbPrint $CertificateThumbPrint `
                     -EnableFirewallException $true -Verbose

    Update-LocationTagInApplicationHostConfigForAuthentication -WebSite $EndpointName -Authentication "anonymous"
    Update-LocationTagInApplicationHostConfigForAuthentication -WebSite $EndpointName -Authentication "basic"
    Update-LocationTagInApplicationHostConfigForAuthentication -WebSite $EndpointName -Authentication "windows"
        
    if ($IsBlue)
    {
        Write-Verbose "Set values into the web.config that define the repository for BLUE OS"
        PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "dbprovider" -value $eseprovider
        PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "dbconnectionstr"-value $esedatabase
        Set-BindingRedirectSettingInWebConfig -path $PhysicalPath
    }
    else
    {
        if($isDownlevelOfBlue)
        {
            Write-Verbose "Set values into the web.config that define the repository for non-BLUE Downlevel OS"
            $repository = Join-Path "$DatabasePath" "Devices.mdb"
            Copy-Item "$pathPullServer\Devices.mdb" $repository -Force

            PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "dbprovider" -value $jet4provider
            PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "dbconnectionstr" -value $jet4database
        }
        else
        {
            Write-Verbose "Set values into the web.config that define the repository later than BLUE OS"
            Write-Verbose "Only ESENT is supported on Windows Server 2016"

            PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "dbprovider" -value $eseprovider
            PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "dbconnectionstr"-value $esedatabase
        }
    }

    Write-Verbose "Pull Server: Set values into the web.config that indicate the location of repository, configuration, modules"

    # Create the application data directory calculated above
    $null = New-Item -path $DatabasePath -itemType "directory" -Force

    $null = New-Item -path "$ConfigurationPath" -itemType "directory" -Force

    PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "ConfigurationPath" -value $ConfigurationPath

    $null = New-Item -path "$ModulePath" -itemType "directory" -Force

    PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "ModulePath" -value $ModulePath

    $null = New-Item -path "$RegistrationKeyPath" -itemType "directory" -Force

    PSWSIISEndpoint\Set-AppSettingsInWebconfig -path $PhysicalPath -key "RegistrationKeyPath" -value $RegistrationKeyPath

    if($AcceptSelfSignedCertificates)
    {
        Copy-Item "$pathPullServer\IISSelfSignedCertModule.dll" $env:windir\System32\inetsrv -Force
        Copy-Item "$env:windir\SysWOW64\WindowsPowerShell\v1.0\Modules\PSDesiredStateConfiguration\PullServer\IISSelfSignedCertModule.dll" $env:windir\SysWOW64\inetsrv -Force

        & $script:appCmd install module /name:"IISSelfSignedCertModule(32bit)" /image:$env:windir\SysWOW64\inetsrv\IISSelfSignedCertModule.dll /add:false /lock:false
        & $script:appCmd add module /name:"IISSelfSignedCertModule(32bit)"  /app.name:"PSDSCPullServer/"
    }
    else
    {
        if($AcceptSelfSignedCertificates -and ($AcceptSelfSignedCertificates -eq $false))
        {
            & $script:appCmd delete module /name:"IISSelfSignedCertModule(32bit)"  /app.name:"PSDSCPullServer/"
        }
    }

    if($UseSecurityBestPractices)
    {
        UseSecurityBestPractices\Set-UseSecurityBestPractices -DisableSecurityBestPractices $DisableSecurityBestPractices
    }
}

# The Test-TargetResource cmdlet.
function Test-TargetResource
{
    [OutputType([Boolean])]
    param
    (
        # Prefix of the WCF SVC File
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EndpointName,

        # Port number of the DSC Pull Server IIS Endpoint
        [Uint32]$Port = 8080,

        # Physical path for the IIS Endpoint on the machine (usually under inetpub)                            
        [string]$PhysicalPath = "$env:SystemDrive\inetpub\$EndpointName",

        # Thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]                            
        [string]$CertificateThumbPrint = "AllowUnencryptedTraffic",

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [ValidateSet("Started", "Stopped")]
        [string]$State = "Started",

        # Location on the disk where the database is stored
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DatabasePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService",

        # Location on the disk where the Modules are stored            
        [string]$ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules",

        # Location on the disk where the Configuration is stored                    
        [string]$ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration",

        # Location on the disk where the RegistrationKeys file is stored                    
        [string]$RegistrationKeyPath,

        # Are self-signed certs being accepted for client auth.
        [boolean]$AcceptSelfSignedCertificates,

        # Pull Server is created with the most secure practices
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [bool]$UseSecurityBestPractices,

        # Exceptions of security best practices
        [ValidateSet("SecureTLSProtocols")]
        [string[]] $DisableSecurityBestPractices
    )

    $desiredConfigurationMatch = $true;

    $website = Get-Website -Name $EndpointName
    $stop = $true

    Do
    {
        Write-Verbose "Check Ensure"
        if(($Ensure -eq "Present" -and $website -eq $null))
        {
            $DesiredConfigurationMatch = $false            
            Write-Verbose "The Website $EndpointName is not present"
            break       
        }
        if(($Ensure -eq "Absent" -and $website -ne $null))
        {
            $DesiredConfigurationMatch = $false            
            Write-Verbose "The Website $EndpointName is present but should not be"
            break       
        }
        if(($Ensure -eq "Absent" -and $website -eq $null))
        {
            $DesiredConfigurationMatch = $true            
            Write-Verbose "The Website $EndpointName is not present as requested"
            break       
        }
        # the other case is: Ensure and exist, we continue with more checks

        Write-Verbose "Check Port"
        $actualPort = $website.bindings.Collection[0].bindingInformation.Split(":")[1]
        if ($Port -ne $actualPort)
        {
            $DesiredConfigurationMatch = $false
            Write-Verbose "Port for the Website $EndpointName does not match the desired state."
            break       
        }

        Write-Verbose "Check Physical Path property"
        if(Test-WebsitePath -EndpointName $EndpointName -PhysicalPath $PhysicalPath)
        {
            $DesiredConfigurationMatch = $false
            Write-Verbose "Physical Path of Website $EndpointName does not match the desired state."
            break
        }

        Write-Verbose "Check State"
        if($website.state -ne $State -and $State -ne $null)
        {
            $DesiredConfigurationMatch = $false
            Write-Verbose "The state of Website $EndpointName does not match the desired state."
            break      
        }

        Write-Verbose "Get Full Path for Web.config file"
        $webConfigFullPath = Join-Path $website.physicalPath "web.config"
        if ($IsComplianceServer -eq $false)
        {
            Write-Verbose "Check DatabasePath"
            switch ((Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "dbprovider"))
            {
                "ESENT" {
                    $expectedConnectionString = "$DatabasePath\Devices.edb"
                }
                "System.Data.OleDb" {
                    $expectedConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$DatabasePath\Devices.mdb;"
                }
                default {
                    $expectedConnectionString = [System.String]::Empty
                }
            }
            if (([System.String]::IsNullOrEmpty($expectedConnectionString)))
            {
                $DesiredConfigurationMatch = $false
                Write-Verbose "The DB provider does not have a valid value: 'ESENT' or 'System.Data.OleDb'"
                break
            }

            if (-not (Test-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "dbconnectionstr" -ExpectedAppSettingValue $expectedConnectionString))
            {
                $DesiredConfigurationMatch = $false
                break
            }

            Write-Verbose "Check ModulePath"
            if ($ModulePath)
            {
                if (-not (Test-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "ModulePath" -ExpectedAppSettingValue $ModulePath))
                {
                    $DesiredConfigurationMatch = $false
                    break
                }
            }    

            Write-Verbose "Check ConfigurationPath"
            if ($ConfigurationPath)
            {
                if (-not (Test-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "ConfigurationPath" -ExpectedAppSettingValue $ConfigurationPath))
                {
                    $DesiredConfigurationMatch = $false
                    break
                }
            }

            Write-Verbose "Check RegistrationKeyPath"
            if ($RegistrationKeyPath)
            {
                if (-not (Test-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName "RegistrationKeyPath" -ExpectedAppSettingValue $RegistrationKeyPath))
                {
                    $DesiredConfigurationMatch = $false
                    break
                }
            }

            Write-Verbose "Check AcceptSelfSignedCertificates"
            if ($AcceptSelfSignedCertificates)
            {
                if (-not (Test-WebConfigModulesSetting -WebConfigFullPath $webConfigFullPath -ModuleName "IISSelfSignedCertModule(32bit)" -ExpectedInstallationStatus $AcceptSelfSignedCertificates))
                {
                    $DesiredConfigurationMatch = $false
                    break
                }
            }
        }

        Write-Verbose "Check UseSecurityBestPractices"
        if ($UseSecurityBestPractices)
        {
            if (-not (UseSecurityBestPractices\Test-UseSecurityBestPractices -DisableSecurityBestPractices $DisableSecurityBestPractices))
            {
                $desiredConfigurationMatch = $false;
                Write-Verbose "The state of security settings does not match the desired state."
                break
            }
        }
        $stop = $false
    }
    While($stop)  

    $desiredConfigurationMatch;
}

# Helper function used to validate website path
function Test-WebsitePath
{
    param
    (
        [string] $EndpointName,
        [string] $PhysicalPath
    )

    $pathNeedsUpdating = $false

    if((Get-ItemProperty "IIS:\Sites\$EndpointName" -Name physicalPath) -ne $PhysicalPath)
    {
        $pathNeedsUpdating = $true
    }

    $pathNeedsUpdating
}

# Helper function to Test the specified Web.Config App Setting
function Test-WebConfigAppSetting
{
    param
    (
        [string] $WebConfigFullPath,
        [string] $AppSettingName,
        [string] $ExpectedAppSettingValue
    )
    
    $returnValue = $true

    if (Test-Path $WebConfigFullPath)
    {
        $webConfigXml = [xml](get-content $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement() 

        foreach ($item in $root.appSettings.add) 
        { 
            if( $item.key -eq $AppSettingName ) 
            {                 
                break
            } 
        }

        if($item.value -ne $ExpectedAppSettingValue)
        {
            $returnValue = $false
            Write-Verbose "The state of Web.Config AppSetting $AppSettingName does not match the desired state."
        }

    }
    $returnValue
}

# Helper function to Get the specified Web.Config App Setting
function Get-WebConfigAppSetting
{
    param
    (
        [string] $WebConfigFullPath,
        [string] $AppSettingName
    )
    
    $appSettingValue = ""
    if (Test-Path $WebConfigFullPath)
    {
        $webConfigXml = [xml](get-content $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement() 

        foreach ($item in $root.appSettings.add) 
        { 
            if( $item.key -eq $AppSettingName ) 
            {     
                $appSettingValue = $item.value          
                break
            } 
        }        
    }
    
    $appSettingValue
}

# Helper function to Test the specified Web.Config Modules Setting
function Test-WebConfigModulesSetting
{
    param
    (
        [string] $WebConfigFullPath,
        [string] $ModuleName,
        [boolean] $ExpectedInstallationStatus
    )
    
    $returnValue = $false

    if (Test-Path $WebConfigFullPath)
    {
        $webConfigXml = [xml](get-content $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement() 

        foreach ($item in $root."system.webServer".modules.add) 
        { 
            if( $item.name -eq $ModuleName ) 
            {           
                if($ExpectedInstallationStatus -eq $true)
                {
                    $returnValue = $true                  
                }
                break
            } 
        }
    }

    if(($ExpectedInstallationStatus -eq $false) -and ($returnValue -eq $false))
    {
        $returnValue = $true
    }

    $returnValue
}

# Helper function to Get the specified Web.Config Modules Setting
function Get-WebConfigModulesSetting
{
    param
    (
        [string] $WebConfigFullPath,
        [string] $ModuleName
    )
    
    $moduleValue = ""
    if (Test-Path $WebConfigFullPath)
    {
        $webConfigXml = [xml](get-content $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement() 

        foreach ($item in $root."system.webServer".modules.add) 
        { 
            if( $item.name -eq $ModuleName ) 
            {     
                $moduleValue = $item.name          
                break
            } 
        }        
    }
    
    $moduleValue
}

# Helper to get current script Folder
function Get-ScriptFolder
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}

# Allow this Website to enable/disable specific Auth Schemes by adding <location> tag in applicationhost.config
function Update-LocationTagInApplicationHostConfigForAuthentication
{
    param (
        # Name of the WebSite        
        [String] $WebSite,

        # Authentication Type
        [ValidateSet('anonymous', 'basic', 'windows')]
        [String] $Authentication
    )

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration") | Out-Null

    $webAdminSrvMgr = [Microsoft.Web.Administration.ServerManager]::OpenRemote("127.0.0.1")

    $appHostConfig = $webAdminSrvMgr.GetApplicationHostConfiguration()

    $authenticationType = $Authentication + "Authentication"
    $appHostConfigSection = $appHostConfig.GetSection("system.webServer/security/authentication/$authenticationType", $WebSite)
    $appHostConfigSection.OverrideMode="Allow"
    $webAdminSrvMgr.CommitChanges()
}

Export-ModuleMember -Function *-TargetResource
