enum Ensure
{
    Absent
    Present
}

[DscResource()]
class InstallADK
{
    [DscProperty(Key)]
    [string] $ADKPath

    [DscProperty(Mandatory)]
    [string] $ADKWinPEPath

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_adkpath = $this.ADKPath
        if(!(Test-Path $_adkpath))
        {
            #ADK 1809 (17763)
            $adkurl = "https://go.microsoft.com/fwlink/?linkid=2026036"
            Invoke-WebRequest -Uri $adkurl -OutFile $_adkpath
        }

        $_adkWinPEpath = $this.ADKWinPEPath
        if(!(Test-Path $_adkWinPEpath))
        {
            #ADK add-on (17763)
            $adkurl = "https://go.microsoft.com/fwlink/?linkid=2022233"
            Invoke-WebRequest -Uri $adkurl -OutFile $_adkWinPEpath
        }
        #Install DeploymentTools
        $adkinstallpath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"
        while(!(Test-Path $adkinstallpath))
        {
            $cmd = $_adkpath
            $arg1  = "/Features"
            $arg2 = "OptionId.DeploymentTools"
            $arg3 = "/q"

            try
            {
                Write-Verbose "Installing ADK DeploymentTools..."
                & $cmd $arg1 $arg2 $arg3 | out-null
                Write-Verbose "ADK DeploymentTools Installed Successfully!"
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                throw "Failed to install ADK DeploymentTools with below error: $ErrorMessage"
            }

            Start-Sleep -Seconds 10
        }

        #Install UserStateMigrationTool
        $adkinstallpath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\User State Migration Tool"
        while(!(Test-Path $adkinstallpath))
        {
            $cmd = $_adkpath
            $arg1  = "/Features"
            $arg2 = "OptionId.UserStateMigrationTool"
            $arg3 = "/q"

            try
            {
                Write-Verbose "Installing ADK UserStateMigrationTool..."
                & $cmd $arg1 $arg2 $arg3 | out-null
                Write-Verbose "ADK UserStateMigrationTool Installed Successfully!"
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                throw "Failed to install ADK UserStateMigrationTool with below error: $ErrorMessage"
            }

            Start-Sleep -Seconds 10
        }

        #Install WindowsPreinstallationEnvironment
        $adkinstallpath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"
        while(!(Test-Path $adkinstallpath))
        {
            $cmd = $_adkWinPEpath
            $arg1  = "/Features"
            $arg2 = "OptionId.WindowsPreinstallationEnvironment"
            $arg3 = "/q"

            try
            {
                Write-Verbose "Installing WindowsPreinstallationEnvironment for ADK..."
                & $cmd $arg1 $arg2 $arg3 | out-null
                Write-Verbose "WindowsPreinstallationEnvironment for ADK Installed Successfully!"
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                throw "Failed to install WindowsPreinstallationEnvironment for ADK with below error: $ErrorMessage"
            }

            Start-Sleep -Seconds 10
        }
    }

    [bool] Test()
    {
        $key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
        $subKey =  $key.OpenSubKey("SOFTWARE\Microsoft\Windows Kits\Installed Roots")
        if($subKey)
        {
            if($subKey.GetValue('KitsRoot10') -ne $null)
            {
                if($subKey.GetValueNames() | ?{$subkey.GetValue($_) -like "*Deployment Tools*"})
                {
                    return $true
                }
            }
        }
        return $false
    }

    [InstallADK] Get()
    {
        return $this
    }
}

[DscResource()]
class InstallAndConfigWSUS
{
    [DscProperty(Key)]
    [string] $WSUSPath

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_WSUSPath = $this.WSUSPath
        if(!(Test-Path -Path $_WSUSPath))
        {
            New-Item -Path $_WSUSPath -ItemType Directory
        }
        Write-Verbose "Installing WSUS..."
        Install-WindowsFeature -Name UpdateServices,UpdateServices-WidDB -IncludeManagementTools
        Write-Verbose "Finished installing WSUS..."

        Write-Verbose "Starting the postinstall for WSUS..."
        sl "C:\Program Files\Update Services\Tools"
        .\wsusutil.exe postinstall CONTENT_DIR=C:\WSUS
        Write-Verbose "Finished the postinstall for WSUS"
    }

    [bool] Test()
    {
        if((Get-WindowsFeature -Name UpdateServices).installed -eq 'True')
        {
            return $true
        }
        return $false
    }

    [InstallAndConfigWSUS] Get()
    {
        return $this
    }
    
}

[DscResource()]
class InstallAZCopy
{
    [DscProperty(Key)]
    [string] $AZCopyPath = "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $path = "c:\azcopy.msi"
        if(!(Test-Path $path))
        {
            #Download azcopy
            $url = "http://aka.ms/downloadazcopy"
            Invoke-WebRequest -Uri $url -OutFile $path
        }

        #Install azcopy
        Start-Process msiexec.exe -Wait -ArgumentList "/I $path /quiet"
    }

    [bool] Test()
    {
        $_AzcopyPath = $this.AZCopyPath
        if(!(Test-Path $_AZCopyPath))
        {
            return $true
        }
        return $false
    }

    [InstallAZCopy] Get()
    {
        return $this
    }
}

[DscResource()]
class WriteConfigurationFile
{
    [DscProperty(Key)]
    [string] $Role

    [DscProperty(Mandatory)]
    [string] $LogPath

    [DscProperty(Key)]
    [string] $WriteNode

    [DscProperty(Mandatory)]
    [string] $Status

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_Role = $this.Role
        $_Node = $this.WriteNode
        $_Status = $this.Status
        $_NoChildNode = $this.NoChildNode
        $_LogPath = $this.LogPath
        $ConfigurationFile = Join-Path -Path $_LogPath -ChildPath "$_Role.json"
        $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

        $Configuration.$_Node.Status = $_Status
        $Configuration.$_Node.EndTime = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        
        $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
    }

    [bool] Test()
    {
        $_Role = $this.Role
        $_LogPath = $this.LogPath
        $Configuration = ""
        $ConfigurationFile = Join-Path -Path $_LogPath -ChildPath "$_Role.json"
        if (Test-Path -Path $ConfigurationFile) 
        {
            $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
        } 
        else 
        {
            [hashtable]$Actions = @{
                PSJoinDomain = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                DPMPJoinDomain = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                ClientJoinDomain = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                DelegateControl = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                SCCMinstall = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                DPMPFinished = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                ClientFinished = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
            }
            $Configuration = New-Object -TypeName psobject -Property $Actions
            $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
        }
        
        return $false
    }

    [WriteConfigurationFile] Get()
    {
        return $this
    }
}

[DscResource()]
class WaitForConfigurationFile
{
    [DscProperty(Key)]
    [string] $Role

    [DscProperty(Key)]
    [string] $MachineName

    [DscProperty(Mandatory)]
    [string] $LogFolder

    [DscProperty(Key)]
    [string] $ReadNode

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_Role = $this.Role
        $_FilePath = "\\$($this.MachineName)\$($this.LogFolder)"
        $ConfigurationFile = Join-Path -Path $_FilePath -ChildPath "$_Role.json"
        
        while(!(Test-Path $ConfigurationFile))
        {
            Write-Verbose "Wait for configuration file exist on $($this.MachineName), will try 60 seconds later..."
            Start-Sleep -Seconds 60
            $ConfigurationFile = Join-Path -Path $_FilePath -ChildPath "$_Role.json"
        }
        $Configuration = Get-Content -Path $ConfigurationFile -ErrorAction Ignore | ConvertFrom-Json
        while($Configuration.$($this.ReadNode).Status -ne "Passed")
        {
            Write-Verbose "Wait for step : [$($this.ReadNode)] finsihed on $($this.MachineName), will try 60 seconds later..."
            Start-Sleep -Seconds 60
            $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
        }
    }

    [bool] Test()
    {
        return $false
    }

    [WaitForConfigurationFile] Get()
    {
        return $this
    }
}

[DscResource()]
class WaitForExtendSchemaFile
{
    [DscProperty(Key)]
    [string] $MachineName

    [DscProperty(Mandatory)]
    [string] $ExtFolder

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_FilePath = "\\$($this.MachineName)\$($this.ExtFolder)"
        $extadschpath = Join-Path -Path $_FilePath -ChildPath "SMSSETUP\BIN\X64\extadsch.exe"
        
        while(!(Test-Path $extadschpath))
        {
            Write-Verbose "Wait for extadsch.exe exist on $($this.MachineName), will try 10 seconds later..."
            Start-Sleep -Seconds 10
            $extadschpath = Join-Path -Path $_FilePath -ChildPath "SMSSETUP\BIN\X64\extadsch.exe"
        }

        Write-Verbose "Extended the Active Directory schema..."

        & $extadschpath | out-null

        Write-Verbose "Done."
    }

    [bool] Test()
    {
        return $false
    }

    [WaitForExtendSchemaFile] Get()
    {
        return $this
    }
}

[DscResource()]
class DelegateControl
{
    [DscProperty(Key)]
    [string] $Machine

    [DscProperty(Mandatory)]
    [string] $DomainFullName

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $root = (Get-ADRootDSE).defaultNamingContext
        $ou = $null 
        try 
        { 
            $ou = Get-ADObject "CN=System Management,CN=System,$root"
        } 
        catch 
        { 
            Write-Verbose "System Management container does not currently exist."
        }
        if ($ou -eq $null) 
        { 
            $ou = New-ADObject -Type Container -name "System Management" -Path "CN=System,$root" -Passthru 
        }
        $DomainName = $this.DomainFullName.split('.')[0]
        #Delegate Control
        $cmd = "dsacls.exe"
        $arg1 = "CN=System Management,CN=System,$root"
        $arg2 = "/G"
        $arg3 = ""+$DomainName+"\"+$this.Machine+"`$:GA;;"
        $arg4 = "/I:T"

        & $cmd $arg1 $arg2 $arg3 $arg4
    }

    [bool] Test()
    {
        $_machinename = $this.Machine
        $root = (Get-ADRootDSE).defaultNamingContext
        try 
        { 
            $ou = Get-ADObject "CN=System Management,CN=System,$root"
        } 
        catch 
        { 
            Write-Verbose "System Management container does not currently exist."
            return $false
        }

        $cmd = "dsacls.exe"
        $arg1 = "CN=System Management,CN=System,$root"
        $permissioninfo = & $cmd $arg1

        if(($permissioninfo | ?{$_ -like "*$_machinename*"} | ?{$_ -like "*FULL CONTROL*"}).COUNT -gt 0)
        {
            return $true
        }

        return $false
    }

    [DelegateControl] Get()
    {
        return $this
    }
}


[DscResource()]
class AddBuiltinPermission
{
    [DscProperty(key)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        Start-Sleep -Seconds 240
        sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') CREATE LOGIN [BUILTIN\administrators] FROM WINDOWS;EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\administrators', @rolename = N'sysadmin'"
        $retrycount = 0
        $sqlpermission = sqlcmd -Q "if exists(select * from sys.server_principals where name='BUILTIN\administrators') Print 1"
        while($sqlpermission -eq $null)
        {
            if($retrycount -eq 3)
            {
                $sqlpermission = 1
            }
            else
            {
                $retrycount++
                Start-Sleep -Seconds 240
                sqlcmd -Q "if not exists(select * from sys.server_principals where name='BUILTIN\administrators') CREATE LOGIN [BUILTIN\administrators] FROM WINDOWS;EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\administrators', @rolename = N'sysadmin'"
                $sqlpermission = sqlcmd -Q "if exists(select * from sys.server_principals where name='BUILTIN\administrators') Print 1"
            }
        }
    }

    [bool] Test()
    {
        $sqlpermission = sqlcmd -Q "if exists(select * from sys.server_principals where name='BUILTIN\administrators') Print 1"
        if($sqlpermission -eq $null)
        {
            Write-Verbose "Need to add the builtin administrators permission."
            return $false
        }
        Write-Verbose "No need to add the builtin administrators permission."
        return $true
    }

    [AddBuiltinPermission] Get()
    {
        return $this
    }
}

[DscResource()]
class DownloadSCCM
{
    [DscProperty(Key)]
    [string] $CM

    [DscProperty(Mandatory)]
    [string] $ExtPath

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_CM = $this.CM
        $_ExtPath = $this.ExtPath
        $cmpath = "c:\$_CM.exe"
        $cmsourcepath = "c:\$_CM"

        Write-Verbose "Downloading SCCM installation source..."
        $cmurl = "https://go.microsoft.com/fwlink/?linkid=2093192"
        Invoke-WebRequest -Uri $cmurl -OutFile $cmpath
        if(!(Test-Path $cmsourcepath))
        {
            Start-Process -Filepath ($cmpath) -ArgumentList ('/Auto "' + $cmsourcepath + '"') -wait
        }
    }

    [bool] Test()
    {
        $_CM = $this.CM
        $cmpath = "c:\$_CM.exe"
        $cmsourcepath = "c:\$_CM"
        if(!(Test-Path $cmpath))
        {
            return $false
        }

        return $true
    }

    [DownloadSCCM] Get()
    {
        return $this
    }
}

[DscResource()]
class InstallDP
{
    [DscProperty(key)]
    [string] $SiteCode

    [DscProperty(Mandatory)]
    [string] $DomainFullName

    [DscProperty(Mandatory)]
    [string] $DPMPName
    
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $ProviderMachineName = $env:COMPUTERNAME+"."+$this.DomainFullName # SMS Provider machine name

        # Customizations
        $initParams = @{}
        if($ENV:SMS_ADMIN_UI_PATH -eq $null)
        {
            $ENV:SMS_ADMIN_UI_PATH = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386"
        }

        # Import the ConfigurationManager.psd1 module 
        if((Get-Module ConfigurationManager) -eq $null) {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
        }

        # Connect to the site's drive if it is not already present
        Write-Verbose "Setting PS Drive..."

        New-PSDrive -Name $this.SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        while((Get-PSDrive -Name $this.SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
        {
            Write-Verbose "Failed ,retry in 10s. Please wait."
            Start-Sleep -Seconds 10
            New-PSDrive -Name $this.SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        }

        # Set the current location to be the site code.
        Set-Location "$($this.SiteCode):\" @initParams

        $DPServerFullName = $this.DPMPName + "." + $this.DomainFullName
        if($(Get-CMSiteSystemServer -SiteSystemServerName $DPServerFullName) -eq $null)
        {
            New-CMSiteSystemServer -Servername $DPServerFullName -Sitecode $this.SiteCode
        }

        $Date = [DateTime]::Now.AddYears(10)
        Add-CMDistributionPoint -SiteSystemServerName $DPServerFullName -SiteCode $this.SiteCode -CertificateExpirationTimeUtc $Date
    }

    [bool] Test()
    {
        return $false
    }

    [InstallDP] Get()
    {
        return $this
    }
}

[DscResource()]
class InstallMP
{
    [DscProperty(key)]
    [string] $SiteCode

    [DscProperty(Mandatory)]
    [string] $DomainFullName

    [DscProperty(Mandatory)]
    [string] $DPMPName
    
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $ProviderMachineName = $env:COMPUTERNAME+"."+$this.DomainFullName # SMS Provider machine name
        # Customizations
        $initParams = @{}
        if($ENV:SMS_ADMIN_UI_PATH -eq $null)
        {
            $ENV:SMS_ADMIN_UI_PATH = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386"
        }

        # Import the ConfigurationManager.psd1 module 
        if((Get-Module ConfigurationManager) -eq $null) {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
        }

        # Connect to the site's drive if it is not already present
        Write-Verbose "Setting PS Drive..."

        New-PSDrive -Name $this.SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        while((Get-PSDrive -Name $this.SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
        {
            Write-Verbose "Failed ,retry in 10s. Please wait."
            Start-Sleep -Seconds 10
            New-PSDrive -Name $this.SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        }

        # Set the current location to be the site code.
        Set-Location "$($this.SiteCode):\" @initParams

        $MPServerFullName = $this.DPMPName + "." + $this.DomainFullName
        if(!(Get-CMSiteSystemServer -SiteSystemServerName $MPServerFullName))
        {
            Write-Verbose "Creating cm site system server..."
            New-CMSiteSystemServer -SiteSystemServerName $MPServerFullName
            Write-Verbose "Finished creating cm site system server."
            $SystemServer = Get-CMSiteSystemServer -SiteSystemServerName $MPServerFullName
            Write-Verbose "Adding management point on $MPServerFullName ..."
            Add-CMManagementPoint -InputObject $SystemServer -CommunicationType Http
            Write-Verbose "Finished adding management point on $MPServerFullName ..."
        }
        else
        {
            Write-Verbose "$MPServerFullName is already a Site System Server , skip running this script."
        }
    }

    [bool] Test()
    {
        return $false
    }

    [InstallMP] Get()
    {
        return $this
    }
}

[DscResource()]
class WaitForDomainReady
{
    [DscProperty(key)]
    [string] $DCName

    [DscProperty(Mandatory=$false)]
    [int] $WaitSeconds = 600

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_DCName = $this.DCName
        $_WaitSeconds = $this.WaitSeconds
        Write-Verbose "Domain computer is: $_DCName"
        $testconnection = test-connection -ComputerName $_DCName -ErrorAction Ignore
        while(!$testconnection)
        {
            Write-Verbose "Waiting for Domain ready , will try again 30 seconds later..."
            Start-Sleep -Seconds 30
            $testconnection = test-connection -ComputerName $_DCName -ErrorAction Ignore
        }
        Write-Verbose "Domain is ready now. Sleep: $_WaitSeconds"
        Start-Sleep -Seconds $_WaitSeconds
    }

    [bool] Test()
    {
         $_DCName = $this.DCName
        Write-Verbose "Domain computer is: $_DCName"
        $testconnection = test-connection -ComputerName $_DCName -ErrorAction Ignore

        if(!$testconnection)
        {
            return $false
        }
        return $true
    }

    [WaitForDomainReady] Get()
    {
        return $this
    }
}

[DscResource()]
class VerifyComputerJoinDomain
{
    [DscProperty(key)]
    [string] $ComputerName

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_Computername = $this.ComputerName
        $searcher = [adsisearcher] "(cn=$_Computername)"
        while($searcher.FindAll().count -ne 1)
        {
            Write-Verbose "$_Computername not join into domain yet , will search again after 1 min"
            Start-Sleep -Seconds 60
            $searcher = [adsisearcher] "(cn=$_Computername)"
        }
        Write-Verbose "$_Computername joined into the domain."
    }

    [bool] Test()
    {
        return $false
    }

    [VerifyComputerJoinDomain] Get()
    {
        return $this
    }
}

[DscResource()]
class SetDNS
{
    [DscProperty(key)]
    [string] $DNSIPAddress

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_DNSIPAddress = $this.DNSIPAddress
        $dnsset = Get-DnsClientServerAddress | %{$_ | ?{$_.InterfaceAlias.StartsWith("Ethernet") -and $_.AddressFamily -eq 2}}
        Write-Verbose "Set dns: $_DNSIPAddress for $($dnsset.InterfaceAlias)"
        Set-DnsClientServerAddress -InterfaceIndex $dnsset.InterfaceIndex -ServerAddresses $_DNSIPAddress
    }

    [bool] Test()
    {
        $_DNSIPAddress = $this.DNSIPAddress
        $dnsset = Get-DnsClientServerAddress | %{$_ | ?{$_.InterfaceAlias.StartsWith("Ethernet") -and $_.AddressFamily -eq 2}}
        if($dnsset.ServerAddresses -contains $_DNSIPAddress)
        {
            return $true
        }
        return $false
    }

    [SetDNS] Get()
    {
        return $this
    }
}

[DscResource()]
class ChangeSQLServicesAccount
{
    [DscProperty(key)]
    [string] $SQLInstanceName

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_SQLInstanceName = $this.SQLInstanceName
        $query = "Name = '"+ $_SQLInstanceName.ToUpper() +"'"
        $services = Get-WmiObject win32_service -Filter $query

        if($services.State -eq 'Running')
        {
            #Check if SQLSERVERAGENT is running
            $sqlserveragentflag = 0
            $sqlserveragentservices = Get-WmiObject win32_service -Filter "Name = 'SQLSERVERAGENT'"
            if($sqlserveragentservices -ne $null)
            {
                if($sqlserveragentservices.State -eq 'Running')
                {
                    Write-Verbose "[$(Get-Date -format HH:mm:ss)] SQLSERVERAGENT need to be stopped first"
                    $Result = $sqlserveragentservices.StopService()
                    Write-Verbose "[$(Get-Date -format HH:mm:ss)] Stopping SQLSERVERAGENT.."
                    if ($Result.ReturnValue -eq '0')
                    {
                        $sqlserveragentflag = 1
                        Write-Verbose "[$(Get-Date -format HH:mm:ss)] Stopped"
                    }
                }
            }
            $Result = $services.StopService()
            Write-Verbose "[$(Get-Date -format HH:mm:ss)] Stopping SQL Server services.."
            if ($Result.ReturnValue -eq '0')
            {
                Write-Verbose "[$(Get-Date -format HH:mm:ss)] Stopped"
            }

            Write-Verbose "[$(Get-Date -format HH:mm:ss)] Changing the services account..."
            
            $Result = $services.change($null,$null,$null,$null,$null,$null,"LocalSystem",$null,$null,$null,$null) 
            if ($Result.ReturnValue -eq '0')
            {
                Write-Verbose "[$(Get-Date -format HH:mm:ss)] Successfully Change the services account"
                if($sqlserveragentflag -eq 1)
                {
                    Write-Verbose "[$(Get-Date -format HH:mm:ss)] Starting SQLSERVERAGENT.."
                    $Result = $sqlserveragentservices.StartService()
                    if($Result.ReturnValue -eq '0')
                    {
                        Write-Verbose "[$(Get-Date -format HH:mm:ss)] Started"
                    }
                }
                $Result =  $services.StartService()
                Write-Verbose "[$(Get-Date -format HH:mm:ss)] Starting SQL Server services.."
                while($Result.ReturnValue -ne '0') 
                {
                    $returncode = $Result.ReturnValue
                    Write-Verbose "[$(Get-Date -format HH:mm:ss)] Return $returncode , will try again"
                    Start-Sleep -Seconds 10
                    $Result =  $services.StartService()
                }
                Write-Verbose "[$(Get-Date -format HH:mm:ss)] Started"
            }
        }
    }

    [bool] Test()
    {
        $_SQLInstanceName = $this.SQLInstanceName
        $query = "Name = '"+ $_SQLInstanceName.ToUpper() +"'"
        $services = Get-WmiObject win32_service -Filter $query

        if($services -ne $null)
        {
            if($services.StartName -ne "LocalSystem")
            {
                return $false
            }
            else
            {
                return $true
            }
        }

        return $true
    }

    [ChangeSQLServicesAccount] Get()
    {
        return $this
    }
}

[DscResource()]
class RegisterTaskScheduler
{
    [DscProperty(key)]
    [string] $TaskName

	[DscProperty(Mandatory)]
    [string] $ScriptName

    [DscProperty(Mandatory)]
    [string] $ScriptPath
	
	[DscProperty(Mandatory)]
    [string] $ScriptArgument
	
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_ScriptName = $this.ScriptName
        $_ScriptPath = $this.ScriptPath
        $_ScriptArgument = $this.ScriptArgument

        $ProvisionToolPath = "$env:windir\temp\ProvisionScript"
        if(!(Test-Path $ProvisionToolPath))
        {
            New-Item $ProvisionToolPath -ItemType directory | Out-Null
        }

        $sourceDirctory = "$_ScriptPath\*"
        $destDirctory = "$ProvisionToolPath\"
        
        Copy-item -Force -Recurse $sourceDirctory -Destination $destDirctory

        $_TaskName = $this.TaskName
		$TaskDescription = "Azure template task"
		$TaskCommand = "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
		$TaskScript = "$ProvisionToolPath\$_ScriptName"

        Write-Verbose "Task script full path is : $TaskScript "

		$TaskArg = "-WindowStyle Hidden -NonInteractive -Executionpolicy unrestricted -file $TaskScript $_ScriptArgument"

        Write-Verbose "command is : $TaskArg"

		$TaskStartTime = [datetime]::Now.AddMinutes(5)
		$service = new-object -ComObject("Schedule.Service")
		$service.Connect()
		$rootFolder = $service.GetFolder("\")
		$TaskDefinition = $service.NewTask(0)
		$TaskDefinition.RegistrationInfo.Description = "$TaskDescription"
		$TaskDefinition.Settings.Enabled = $true
		$TaskDefinition.Settings.AllowDemandStart = $true
		$triggers = $TaskDefinition.Triggers
		#http://msdn.microsoft.com/en-us/library/windows/desktop/aa383915(v=vs.85).aspx
		$trigger = $triggers.Create(1)
		$trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
		$trigger.Enabled = $true
		# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
		$Action = $TaskDefinition.Actions.Create(0)
		$action.Path = "$TaskCommand"
		$action.Arguments = "$TaskArg"
		#http://msdn.microsoft.com/en-us/library/windows/desktop/aa381365(v=vs.85).aspx
		$rootFolder.RegisterTaskDefinition("$_TaskName",$TaskDefinition,6,"System",$null,5)
    }

    [bool] Test()
    {
        $ProvisionToolPath = "$env:windir\temp\ProvisionScript"
        if(!(Test-Path $ProvisionToolPath))
        {
            return $false
        }
        
        return $true
    }

    [RegisterTaskScheduler] Get()
    {
        return $this
    }
}

[DscResource()]
class SetAutomaticManagedPageFile
{
    [DscProperty(key)]
    [string] $TaskName
	
    [DscProperty(Mandatory)]
    [bool] $Value

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_Value = $this.Value
        $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
        Write-Verbose "Set AutomaticManagedPagefile to $_Value..."
        $computersys.AutomaticManagedPagefile = $_Value
        $computersys.Put()
    }

    [bool] Test()
    {
        $_Value = $this.Value
        $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
        if($computersys.AutomaticManagedPagefile -ne $_Value)
        {
            return $false
        }
        
        return $true
    }

    [SetAutomaticManagedPageFile] Get()
    {
        return $this
    }
}

