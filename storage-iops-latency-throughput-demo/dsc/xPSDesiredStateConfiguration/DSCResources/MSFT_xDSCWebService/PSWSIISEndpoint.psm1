# This module file contains a utility to perform PSWS IIS Endpoint setup
# Module exports New-PSWSEndpoint function to perform the endpoint setup
#
#Copyright (c) Microsoft Corporation, 2014
#

# name and description for the Firewall rules. Used in multiple locations
$FireWallRuleDisplayName = "Desired State Configuration - Pull Server Port:{0}"
$FireWallRuleDescription = "Inbound traffic for IIS site on Port:{0} for DSC pull server. Created by DSCWebService resource"

# Validate supplied configuration to setup the PSWS Endpoint
# Function checks for the existence of PSWS Schema files, IIS config
# Also validate presence of IIS on the target machine
#
function Initialize-Endpoint
{
    param (
        $site,
        $path,
        $cfgfile,
        $port,
        $app,
        $applicationPoolIdentityType,
        $svc,
        $mof,
        $dispatch,        
        $asax,
        $dependentBinaries,
        $language,
        $dependentMUIFiles,
        $psFiles,
        $removeSiteFiles = $false,
        $certificateThumbPrint)
    
    if (!(Test-Path $cfgfile))
    {        
        throw "ERROR: $cfgfile does not exist"    
    }            
    
    if (!(Test-Path $svc))
    {        
        throw "ERROR: $svc does not exist"    
    }            
    
    if (!(Test-Path $mof))
    {        
        throw "ERROR: $mof does not exist"  
    }
    
    if (!(Test-Path $asax))
    {        
        throw "ERROR: $asax does not exist"  
    }  

    if ($certificateThumbPrint -ne "AllowUnencryptedTraffic")
    {    
        Write-Verbose "Verify that the certificate with the provided thumbprint exists in CERT:\LocalMachine\MY\"
        $certificate = Get-childItem CERT:\LocalMachine\MY\ | Where {$_.Thumbprint -eq $certificateThumbPrint}
        if (!$Certificate) 
        { 
             throw "ERROR: Certificate with thumbprint $certificateThumbPrint does not exist in CERT:\LocalMachine\MY\"
        }  
    }     
    
    Test-IISInstall
    
    $appPool = "PSWS"

    
    Write-Verbose "Delete the App Pool if it exists"
    Remove-AppPool -apppool $appPool
   
    Write-Verbose "Remove the site if it already exists"
    Update-Site -siteName $site -siteAction Remove

    # check for existing binding, there should be no binding with the same port
    if ((Get-WebBinding | where bindingInformation -eq "*:$($port):").count -gt 0)
    {
        throw "ERROR: Port $port is already used, please review existing sites and change the port to be used." 
    }
    
    if ($removeSiteFiles)
    {
        if(Test-Path $path)
        {
            Remove-Item -Path $path -Recurse -Force
        }
    }
    
    Copy-Files -path $path -cfgfile $cfgfile -svc $svc -mof $mof -dispatch $dispatch -asax $asax -dependentBinaries $dependentBinaries -language $language -dependentMUIFiles $dependentMUIFiles -psFiles $psFiles
   
    New-IISWebSite -site $site -path $path -port $port -app $app -apppool $appPool -applicationPoolIdentityType $applicationPoolIdentityType -certificateThumbPrint $certificateThumbPrint
}

# Validate if IIS and all required dependencies are installed on the target machine
#
function Test-IISInstall
{
        Write-Verbose "Checking IIS requirements"
        $iisVersion = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp -ErrorAction silentlycontinue).MajorVersion
        
        if ($iisVersion -lt 7) 
        {
            throw "ERROR: IIS Version detected is $iisVersion , must be running higher than 7.0"            
        }        
        
        $wsRegKey = (Get-ItemProperty hklm:\SYSTEM\CurrentControlSet\Services\W3SVC -ErrorAction silentlycontinue).ImagePath
        if ($wsRegKey -eq $null)
        {
            throw "ERROR: Cannot retrive W3SVC key. IIS Web Services may not be installed"            
        }        
        
        if ((Get-Service w3svc).Status -ne "running")
        {
            throw "ERROR: service W3SVC is not running"
        }
}

# Verify if a given IIS Site exists
#
function Test-IISSiteExists
{
    param ($siteName)

    if (Get-Website -Name $siteName)
    {
        return $true
    }
    
    return $false
}

# Perform an action (such as stop, start, delete) for a given IIS Site
#
function Update-Site
{
    param (
        [Parameter(ParameterSetName = 'SiteName', Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]$siteName,

        [Parameter(ParameterSetName = 'Site', Mandatory, Position = 0)]        
        $site,

        [Parameter(ParameterSetName = 'SiteName', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'Site', Mandatory, Position = 1)]
        [String]$siteAction)
    
    [String]$name = $null
    if ($PSCmdlet.ParameterSetName -eq 'SiteName')
    {
        $name = $siteName
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Site')
    {   
        $name = $site.Name
    }
    
    if (Test-IISSiteExists -siteName $name)
    {
        switch ($siteAction) 
        { 
            "Start"  {Start-Website -Name "$name"} 
            "Stop"   {Stop-Website -Name "$name" -ErrorAction SilentlyContinue} 
            "Remove" {Remove-Website -Name "$name"}
        }
        Write-Verbose "p11"
    }
}

# Delete the given IIS Application Pool
# This is required to cleanup any existing conflicting apppools before setting up the endpoint
#
function Remove-AppPool
{
    param ($appPool)    

    # without this tests we may get a breaking error here, despite SilentlyContinue
    if (Test-Path "IIS:\AppPools\$appPool")
    {
        Remove-WebAppPool -Name $appPool -ErrorAction SilentlyContinue
    }
}

# Generate an IIS Site Id while setting up the endpoint
# The Site Id will be the max available in IIS config + 1
#
function New-SiteID
{
    return ((Get-Website | % { $_.Id } | Measure-Object -Maximum).Maximum + 1)
}

# Validate the PSWS config files supplied and copy to the IIS endpoint in inetpub
#
function Copy-Files
{
    param (
        $path,
        $cfgfile,
        $svc,
        $mof,    
        $dispatch,
        $asax,
        $dependentBinaries,
        $language,
        $dependentMUIFiles,
        $psFiles)    
    
    if (!(Test-Path $cfgfile))
    {
        throw "ERROR: $cfgfile does not exist"    
    }
    
    if (!(Test-Path $svc))
    {
        throw "ERROR: $svc does not exist"    
    }
    
    if (!(Test-Path $mof))
    {
        throw "ERROR: $mof does not exist"    
    }

    if (!(Test-Path $asax))
    {
        throw "ERROR: $asax does not exist"    
    }
    
    if (!(Test-Path $path))
    {
        $null = New-Item -ItemType container -Path $path        
    }
    
    foreach ($dependentBinary in $dependentBinaries)
    {
        if (!(Test-Path $dependentBinary))
        {
            throw "ERROR: $dependentBinary does not exist"  
        }
    }

    foreach ($dependentMUIFile in $dependentMUIFiles)
    {
        if (!(Test-Path $dependentMUIFile))
        {
            throw "ERROR: $dependentMUIFile does not exist"  
        }
    }
    
    Write-Verbose "Create the bin folder for deploying custom dependent binaries required by the endpoint"
    $binFolderPath = Join-Path $path "bin"
    $null = New-Item -path $binFolderPath  -itemType "directory" -Force
    Copy-Item $dependentBinaries $binFolderPath -Force

    if ($language)
    {
        $muiPath = Join-Path $binFolderPath $language

        if (!(Test-Path $muiPath))
        {
            $null = New-Item -ItemType container $muiPath        
        }
        Copy-Item $dependentMUIFiles $muiPath -Force
    }

    foreach ($psFile in $psFiles)
    {
        if (!(Test-Path $psFile))
        {
            throw "ERROR: $psFile does not exist"  
        }
        
        Copy-Item $psFile $path -Force
    }
    
    Copy-Item $cfgfile (Join-Path $path "web.config") -Force
    Copy-Item $svc $path -Force
    Copy-Item $mof $path -Force
    
    if ($dispatch)
    {
        Copy-Item $dispatch $path -Force
    }  
    
    if ($asax)
    {
        Copy-Item $asax $path -Force
    }
}

# Setup IIS Apppool, Site and Application
#
function New-IISWebSite
{
    param (
        $site,
        $path,    
        $port,
        $app,
        $appPool,        
        $applicationPoolIdentityType,
        $certificateThumbPrint)    
    
    $siteID = New-SiteID
    
    Write-Verbose "Adding App Pool"
    $null = New-WebAppPool -Name $appPool

    Write-Verbose "Set App Pool Properties"
    $appPoolIdentity = 4
    if ($applicationPoolIdentityType)
    {   
        # LocalSystem = 0, LocalService = 1, NetworkService = 2, SpecificUser = 3, ApplicationPoolIdentity = 4        
        if ($applicationPoolIdentityType -eq "LocalSystem")
        {
            $appPoolIdentity = 0
        }
        elseif ($applicationPoolIdentityType -eq "LocalService")
        {
            $appPoolIdentity = 1
        }      
        elseif ($applicationPoolIdentityType -eq "NetworkService")
        {
            $appPoolIdentity = 2
        }        
    } 

    $appPoolItem = Get-Item IIS:\AppPools\$appPool
    $appPoolItem.managedRuntimeVersion = "v4.0"
    $appPoolItem.enable32BitAppOnWin64 = $true
    $appPoolItem.processModel.identityType = $appPoolIdentity
    $appPoolItem | Set-Item
    
    Write-Verbose "Add and Set Site Properties"
    if ($certificateThumbPrint -eq "AllowUnencryptedTraffic")
    {
        $webSite = New-WebSite -Name $site -Id $siteID -Port $port -IPAddress "*" -PhysicalPath $path -ApplicationPool $appPool
    }
    else
    {
        $webSite = New-WebSite -Name $site -Id $siteID -Port $port -IPAddress "*" -PhysicalPath $path -ApplicationPool $appPool -Ssl

        # Remove existing binding for $port
        Remove-Item IIS:\SSLBindings\0.0.0.0!$port -ErrorAction Ignore

        # Create a new binding using the supplied certificate
        $null = Get-Item CERT:\LocalMachine\MY\$certificateThumbPrint | New-Item IIS:\SSLBindings\0.0.0.0!$port
    }

    Update-Site -siteName $site -siteAction Start    
}

# Allow Clients outsite the machine to access the setup endpoint on a User Port
#
function New-FirewallRule
{
    param ($firewallPort)
    
    $script:netsh = "$env:windir\system32\netsh.exe" 

    Write-Verbose "Disable Inbound Firewall Notification"
    & $script:netsh advfirewall set currentprofile settings inboundusernotification disable

    # remove all existing rules with that displayName
    & $script:netsh advfirewall firewall delete rule name=DSCPullServer_IIS_Port protocol=tcp localport=$firewallPort | Out-Null
        
    Write-Verbose "Add Firewall Rule for port $firewallPort"
    & $script:netsh advfirewall firewall add rule name=DSCPullServer_IIS_Port dir=in action=allow protocol=TCP localport=$firewallPort   
}

# Enable & Clear PSWS Operational/Analytic/Debug ETW Channels
#
function Enable-PSWSETW
{    
    # Disable Analytic Log
    & $script:wevtutil sl Microsoft-Windows-ManagementOdataService/Analytic /e:false /q | Out-Null    

    # Disable Debug Log
    & $script:wevtutil sl Microsoft-Windows-ManagementOdataService/Debug /e:false /q | Out-Null    

    # Clear Operational Log
    & $script:wevtutil cl Microsoft-Windows-ManagementOdataService/Operational | Out-Null    

    # Enable/Clear Analytic Log
    & $script:wevtutil sl Microsoft-Windows-ManagementOdataService/Analytic /e:true /q | Out-Null    

    # Enable/Clear Debug Log
    & $script:wevtutil sl Microsoft-Windows-ManagementOdataService/Debug /e:true /q | Out-Null    
}

<#
.Synopsis
   Create PowerShell WebServices IIS Endpoint
.DESCRIPTION
   Creates a PSWS IIS Endpoint by consuming PSWS Schema and related dependent files
.EXAMPLE
   New a PSWS Endpoint [@ http://Server:39689/PSWS_Win32Process] by consuming PSWS Schema Files and any dependent scripts/binaries
   New-PSWSEndpoint -site Win32Process -path $env:SystemDrive\inetpub\PSWS_Win32Process -cfgfile Win32Process.config -port 39689 -app Win32Process -svc PSWS.svc -mof Win32Process.mof -dispatch Win32Process.xml -dependentBinaries ConfigureProcess.ps1, Rbac.dll -psFiles Win32Process.psm1
#>
function New-PSWSEndpoint
{
[CmdletBinding()]
    param (
        
        # Unique Name of the IIS Site        
        [String] $site = "PSWS",
        
        # Physical path for the IIS Endpoint on the machine (under inetpub)        
        [String] $path = "$env:SystemDrive\inetpub\PSWS",
        
        # Web.config file        
        [String] $cfgfile = "web.config",
        
        # Port # for the IIS Endpoint        
        [Int] $port = 8080,
        
        # IIS Application Name for the Site        
        [String] $app = "PSWS",
        
        # IIS App Pool Identity Type - must be one of LocalService, LocalSystem, NetworkService, ApplicationPoolIdentity
        [ValidateSet('LocalService', 'LocalSystem', 'NetworkService', 'ApplicationPoolIdentity')]
        [String] $applicationPoolIdentityType,
        
        # WCF Service SVC file        
        [String] $svc = "PSWS.svc",
        
        # PSWS Specific MOF Schema File
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $mof,
        
        # PSWS Specific Dispatch Mapping File [Optional]
        [ValidateNotNullOrEmpty()]
        [String] $dispatch,    
        
        # Global.asax file [Optional]
        [ValidateNotNullOrEmpty()]
        [String] $asax,
        
        # Any dependent binaries that need to be deployed to the IIS endpoint, in the bin folder
        [ValidateNotNullOrEmpty()]
        [String[]] $dependentBinaries,

         # MUI Language [Optional]
        [ValidateNotNullOrEmpty()]
        [String] $language,

        # Any dependent binaries that need to be deployed to the IIS endpoint, in the bin\mui folder [Optional]
        [ValidateNotNullOrEmpty()]
        [String[]] $dependentMUIFiles,
        
        # Any dependent PowerShell Scipts/Modules that need to be deployed to the IIS endpoint application root
        [ValidateNotNullOrEmpty()]
        [String[]] $psFiles,
        
        # True to remove all files for the site at first, false otherwise
        [Boolean]$removeSiteFiles = $false,

        # Enable Firewall Exception for the supplied port        
        [Boolean] $EnableFirewallException,

        # Enable and Clear PSWS ETW        
        [switch] $EnablePSWSETW,
        
        # Thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server
        [String] $certificateThumbPrint = "AllowUnencryptedTraffic")
    
    $script:wevtutil = "$env:windir\system32\Wevtutil.exe"
       
    $svcName = Split-Path $svc -Leaf
    $protocol = "https:"
    if ($certificateThumbPrint -eq "AllowUnencryptedTraffic")
    {
        $protocol = "http:"
    }

    # Get Machine Name
    $cimInstance = Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false
    
    Write-Verbose ("Setting up endpoint at - $protocol//" + $cimInstance.Name + ":" + $port + "/" + $svcName)
    Initialize-Endpoint -site $site -path $path -cfgfile $cfgfile -port $port -app $app `
                        -applicationPoolIdentityType $applicationPoolIdentityType -svc $svc -mof $mof `
                        -dispatch $dispatch -asax $asax -dependentBinaries $dependentBinaries `
                        -language $language -dependentMUIFiles $dependentMUIFiles -psFiles $psFiles `
                        -removeSiteFiles $removeSiteFiles -certificateThumbPrint $certificateThumbPrint
    
    if ($EnableFirewallException -eq $true)
    {
        Write-Verbose "Enabling firewall exception for port $port"
        $null = New-FirewallRule $port
    }

    if ($EnablePSWSETW)
    {
        Enable-PSWSETW
    }       
}

<#
.Synopsis
   Removes a DSC WebServices IIS Endpoint
.DESCRIPTION
   Removes a PSWS IIS Endpoint
.EXAMPLE
   Remove the endpoint with the specified name
   Remove-PSWSEndpoint -siteName PSDSCPullServer 
#>
function Remove-PSWSEndpoint
{
[CmdletBinding()]
    param (        
        # Unique Name of the IIS Site        
            [String] $siteName
        )
                
       # get the site to remove
       $site = Get-Item -Path "IIS:\sites\$siteName"
       # and the pool it is using
       $pool = $site.applicationPool

       # get the path so we can delete the files
       $filePath = $site.PhysicalPath
       # get the port number for the Firewall rule
       $bindings = (Get-WebBinding -Name $siteName).bindingInformation
       $port = [regex]::match($bindings,':(\d+):').Groups[1].Value     

       # remove the actual site.
       Remove-Website -Name $siteName
       # there may be running requests, wait a little
       # I had an issue where the files were still in use
       # when I tried to delete them
       Start-Sleep -Milliseconds 200  

       # remove the files for the site
       If (Test-Path $filePath)
       {
           Get-ChildItem $filePath -Recurse | Remove-Item -Recurse
           Remove-Item $filePath
       }

       # find out whether any other site is using this pool
       $filter = "/system.applicationHost/sites/site/application[@applicationPool='" + $pool + "']" 
       $apps = (Get-WebConfigurationProperty -Filter $filter -PSPath "machine/webroot/apphost" -name path).ItemXPath 
       if ($apps.count -eq 1)
       {
          # if we are the only site in the pool, remove the pool as well.
          Remove-WebAppPool -Name $pool
       }


       # remove all rules with that name
       $ruleName = ($($FireWallRuleDisplayName) -f $port)
       Get-NetFirewallRule | Where-Object DisplayName -eq "$ruleName" | Remove-NetFirewallRule

}

<#
.Synopsis
   Set the option into the web.config for an endpoint
.DESCRIPTION
   Set the options into the web.config for an endpoint allowing customization.
.EXAMPLE
#>
function Set-AppSettingsInWebconfig
{
    param (
                
        # Physical path for the IIS Endpoint on the machine (possibly under inetpub)
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $path,
        
        # Key to add/update
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $key,

        # Value 
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $value

        )
                
    $webconfig = Join-Path $path "web.config"
    [bool] $Found = $false

    if (Test-Path $webconfig)
    {
        $xml = [xml](get-content $webconfig)
        $root = $xml.get_DocumentElement() 

        foreach( $item in $root.appSettings.add) 
        { 
            if( $item.key -eq $key ) 
            { 
                $item.value = $value; 
                $Found = $true;
            } 
        }

        if( -not $Found)
        {
            $newElement = $xml.CreateElement("add")                               
            $nameAtt1 = $xml.CreateAttribute("key")                    
            $nameAtt1.psbase.value = $key;                                
            $null = $newElement.SetAttributeNode($nameAtt1)
                                   
            $nameAtt2 = $xml.CreateAttribute("value")                      
            $nameAtt2.psbase.value = $value;                       
            $null = $newElement.SetAttributeNode($nameAtt2)       
                                   
            $null = $xml.configuration["appSettings"].AppendChild($newElement)   
        }
    }

    $xml.Save($webconfig) 
}

<#
.Synopsis
   Set the binding redirect setting in the web.config to redirect 10.0.0.0 version of microsoft.isam.esent.interop to 6.3.0.0.
.DESCRIPTION
   This function creates the following section in the web.config:
   <runtime>
     <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
       <dependentAssembly>
         <assemblyIdentity name="microsoft.isam.esent.interop" publicKeyToken="31bf3856ad364e35" />
       <bindingRedirect oldVersion="10.0.0.0" newVersion="6.3.0.0" />
      </dependentAssembly>
     </assemblyBinding>
</runtime>
#>
function Set-BindingRedirectSettingInWebConfig
{
    param (
                
        # Physical path for the IIS Endpoint on the machine (possibly under inetpub)
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $path,

        # old version of the assembly
        [String] $oldVersion = "10.0.0.0",

        # new version to redirect to     
        [String] $newVersion = "6.3.0.0"

        )
                
    $webconfig = Join-Path $path "web.config"

    if (Test-Path $webconfig)
    {
        $xml = [xml](get-content $webconfig)

        if(-not($xml.get_DocumentElement().runtime))
        {
            # Create the <runtime> section
            $runtimeSetting = $xml.CreateElement("runtime")

            # Create the <assemblyBinding> section
            $assemblyBindingSetting = $xml.CreateElement("assemblyBinding")
            $xmlnsAttribute = $xml.CreateAttribute("xmlns")
            $xmlnsAttribute.Value = "urn:schemas-microsoft-com:asm.v1"
            $assemblyBindingSetting.Attributes.Append($xmlnsAttribute)

            # The <assemblyBinding> section goes inside <runtime>
            $null = $runtimeSetting.AppendChild($assemblyBindingSetting)

            # Create the <dependentAssembly> section
            $dependentAssemblySetting = $xml.CreateElement("dependentAssembly")

            #The <dependentAssembly> section goes inside <assemblyBinding>
            $null = $assemblyBindingSetting.AppendChild($dependentAssemblySetting)

            # Create the <assemblyIdentity> section
            $assemblyIdentitySetting = $xml.CreateElement("assemblyIdentity")
            $nameAttribute = $xml.CreateAttribute("name")
            $nameAttribute.Value = "microsoft.isam.esent.interop"
            $publicKeyTokenAttribute = $xml.CreateAttribute("publicKeyToken")
            $publicKeyTokenAttribute.Value = "31bf3856ad364e35"
            $null = $assemblyIdentitySetting.Attributes.Append($nameAttribute)
            $null = $assemblyIdentitySetting.Attributes.Append($publicKeyTokenAttribute)

            # <assemblyIdentity> section goes inside <dependentAssembly>
            $dependentAssemblySetting.AppendChild($assemblyIdentitySetting)

            # Create the <bindingRedirect> section
            $bindingRedirectSetting = $xml.CreateElement("bindingRedirect")
            $oldVersionAttribute = $xml.CreateAttribute("oldVersion")
            $newVersionAttribute = $xml.CreateAttribute("newVersion")
            $oldVersionAttribute.Value = $oldVersion
            $newVersionAttribute.Value = $newVersion
            $null = $bindingRedirectSetting.Attributes.Append($oldVersionAttribute)
            $null = $bindingRedirectSetting.Attributes.Append($newVersionAttribute)

            # The <bindingRedirect> section goes inside <dependentAssembly> section
            $dependentAssemblySetting.AppendChild($bindingRedirectSetting)

            # The <runtime> section goes inside <Configuration> section
            $xml.configuration.AppendChild($runtimeSetting)

            $xml.Save($webconfig) 
        }
    }
}

Export-ModuleMember -function New-PSWSEndpoint, Set-AppSettingsInWebconfig, Set-BindingRedirectSettingInWebConfig, Remove-PSWSEndpoint
