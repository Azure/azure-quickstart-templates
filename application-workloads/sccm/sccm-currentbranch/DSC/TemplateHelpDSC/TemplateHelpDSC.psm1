enum Ensure
{
    Absent
    Present
}

enum StartupType
{
    auto
    delayedauto
    demand
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
            #ADK 2004 (19041)
            $adkurl = "https://go.microsoft.com/fwlink/?linkid=2120254"
            Invoke-WebRequest -Uri $adkurl -OutFile $_adkpath
        }

        $_adkWinPEpath = $this.ADKWinPEPath
        if(!(Test-Path $_adkWinPEpath))
        {
            #ADK add-on (19041)
            $adkurl = "https://go.microsoft.com/fwlink/?linkid=2120253"
            Invoke-WebRequest -Uri $adkurl -OutFile $_adkWinPEpath
        }
        #Install DeploymentTools
        $adkinstallpath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"
        while(!(Test-Path $adkinstallpath))
        {
            $cmd = $_adkpath
            $arg1 = "/Features"
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
            $arg1 = "/Features"
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
            $arg1 = "/Features"
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
                CSJoinDomain = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
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
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_CM = $this.CM
        $cmpath = "c:\$_CM.exe"
        $cmsourcepath = "c:\$_CM"

        Write-Verbose "Downloading SCCM installation source..."
        $cmurl = "https://go.microsoft.com/fwlink/?linkid=2093192"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($cmurl,$cmpath)
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
    [int] $WaitSeconds = 900

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
        Write-Verbose "Domain is ready now."
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
        $_ComputernameList = $_Computername.Split(',')
        foreach($CL in $_ComputernameList){
            $searcher = [adsisearcher] "(cn=$CL)"
            while($searcher.FindAll().count -ne 1)
            {
                Write-Verbose "$CL not join into domain yet , will search again after 1 min"
                Start-Sleep -Seconds 60
                $searcher = [adsisearcher] "(cn=$CL)"
            }
            Write-Verbose "$CL joined into the domain."
        }
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
                $Result = $services.StartService()
                Write-Verbose "[$(Get-Date -format HH:mm:ss)] Starting SQL Server services.."
                while($Result.ReturnValue -ne '0') 
                {
                    $returncode = $Result.ReturnValue
                    Write-Verbose "[$(Get-Date -format HH:mm:ss)] Return $returncode , will try again"
                    Start-Sleep -Seconds 10
                    $Result = $services.StartService()
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
        #http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
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

[DscResource()]
class ChangeServices
{
    [DscProperty(key)]
    [string] $Name
    
    [DscProperty(Mandatory)]
    [StartupType] $StartupType

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [void] Set()
    {
        $_Name = $this.Name
        $_StartupType = $this.StartupType
        sc.exe config $_Name start=$_StartupType | Out-Null
    }

    [bool] Test()
    {
        $_Name = $this.Name
        $_StartupType = $this.StartupType
        $currentstatus = sc.exe qc $_Name

        switch($_StartupType)
        {
            "auto"{
                if($currentstatus[4].contains("DELAYED"))
                {
                    return $false
                }
                break
            }
            "delayedauto"{
                if(!($currentstatus[4].contains("DELAYED")))
                {
                    return $false
                }
                break
            }
            "demand"{
                if(!($currentstatus[4].contains("DEMAND_START")))
                {
                    return $false
                }
                break
            }
        }
        
        return $true
    }

    [ChangeServices] Get()
    {
        return $this
    }
}

[DscResource()]
class AddUserToLocalAdminGroup
{
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Key)]
    [string] $DomainName

    [void] Set()
    {
        $_DomainName = $($this.DomainName).Split(".")[0]
        $_Name = $this.Name
        $AdminGroupName = (Get-WmiObject -Class Win32_Group -Filter 'LocalAccount = True AND SID = "S-1-5-32-544"').Name
        $GroupObj = [ADSI]"WinNT://$env:COMPUTERNAME/$AdminGroupName"
        Write-Verbose "[$(Get-Date -format HH:mm:ss)] add $_Name to administrators group"
        $GroupObj.Add("WinNT://$_DomainName/$_Name")
        
    }

    [bool] Test()
    {
        $_DomainName = $($this.DomainName).Split(".")[0]
        $_Name = $this.Name
        $AdminGroupName = (Get-WmiObject -Class Win32_Group -Filter 'LocalAccount = True AND SID = "S-1-5-32-544"').Name
        $GroupObj = [ADSI]"WinNT://$env:COMPUTERNAME/$AdminGroupName"
        if($GroupObj.IsMember("WinNT://$_DomainName/$_Name") -eq $true)
        {
            return $true
        }
        return $false
    }

    [AddUserToLocalAdminGroup] Get()
    {
        return $this
    }
    
}

[DscResource()]
class JoinDomain
{
    [DscProperty(Key)]
    [string] $DomainName

    [DscProperty(Mandatory)]
    [System.Management.Automation.PSCredential] $Credential

    [void] Set()
    {
        $_credential = $this.Credential
        $_DomainName = $this.DomainName
        $_retryCount = 100
        try
        {       
            Add-Computer -DomainName $_DomainName -Credential $_credential -ErrorAction Stop
            $global:DSCMachineStatus = 1
        }
        catch
        {
            Write-Verbose "Failed to join into the domain , retry..."
            $CurrentDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
            $count = 0
            $flag = $false
            while($CurrentDomain -ne $_DomainName)
            {
                if($count -lt $_retryCount)
                {
                    $count++
                    Write-Verbose "retry count: $count"
                    Start-Sleep -Seconds 30
                    Add-Computer -DomainName $_DomainName -Credential $_credential -ErrorAction Ignore
                    
                    $CurrentDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
                }
                else
                {
                    $flag = $true
                    break
                }
            }
            if($flag)
            {
                Add-Computer -DomainName $_DomainName -Credential $_credential
            }
            $global:DSCMachineStatus = 1
        }
    }

    [bool] Test()
    {
        $_DomainName = $this.DomainName
        $CurrentDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

        if($CurrentDomain -eq $_DomainName)
        {
            return $true
        }

        return $false
    }

    [JoinDomain] Get()
    {
        return $this
    }
    
}

[DscResource()]
class OpenFirewallPortForSCCM
{
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Mandatory)]
    [string[]] $Role

    [void] Set()
    {
        $_Role = $this.Role

        Write-Verbose "Current Role is : $_Role"

        if($_Role -contains "DC")
        {
            #HTTP(S) Requests
            New-NetFirewallRule -DisplayName 'HTTP(S) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For DC"
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For DC"
        
            #PS-->DC(in)
            New-NetFirewallRule -DisplayName 'LDAP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 389 -Group "For DC"
            New-NetFirewallRule -DisplayName 'LDAP(SSL) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 636 -Group "For DC"
            New-NetFirewallRule -DisplayName 'LDAP(SSL) UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 636 -Group "For DC"
            New-NetFirewallRule -DisplayName 'Global Catelog LDAP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3268 -Group "For DC"
            New-NetFirewallRule -DisplayName 'Global Catelog LDAP SSL Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3269 -Group "For DC"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For DC"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For DC"
            #Dynamic Port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For DC"

            #THAgent
            Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)" -Direction Inbound
            Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
        }

        if($_Role -contains "Site Server")
        {
            New-NetFirewallRule -DisplayName 'HTTP(S) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM"
    
            #site server<->site server
            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'SMB Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'PPTP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1723 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'PPTP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1723 -Group "For SCCM"

            #priary site server(out) ->DC
            New-NetFirewallRule -DisplayName 'LDAP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 389 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'LDAP(SSL) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 636 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'LDAP(SSL) UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 636 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'Global Catelog LDAP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3268 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'Global Catelog LDAP SSL Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3269 -Group "For SCCM"


            #Dynamic Port?
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'RPC Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM"

            New-NetFirewallRule -DisplayName 'SQL over TCP  Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'SQL over TCP  Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SCCM"

            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM"
            New-NetFirewallRule -DisplayName 'Wake on LAN Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 9 -Group "For SCCM"
        }

        if($_Role -contains "Software Update Point")
        {
            New-NetFirewallRule -DisplayName 'SMB SUPInbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM SUP"
            New-NetFirewallRule -DisplayName 'SMB SUP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM SUP"
            New-NetFirewallRule -DisplayName 'HTTP(S) SUP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort @(8530,8531) -Group "For SCCM SUP"
            New-NetFirewallRule -DisplayName 'HTTP(S) SUP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(8530,8531) -Group "For SCCM SUP"
            #SUP->Internet
            New-NetFirewallRule -DisplayName 'HTTP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 80 -Group "For SCCM SUP"
        
            New-NetFirewallRule -DisplayName 'HTTP(S) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM SUP"
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM SUP"
        }
        if($_Role -ccontains "State Migration Point")
        {
            #SMB,RPC Endpoint Mapper
            New-NetFirewallRule -DisplayName 'SMB SMP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM SMP"
            New-NetFirewallRule -DisplayName 'SMB SMP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM SMP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM SMP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM SMP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM SMP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM SMP"
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM SUP"
        }
        if($_Role -contains "PXE Service Point")
        {
            #SMB,RPC Endpoint Mapper,RPC
            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'SMB Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM PXE SP"
            #Dynamic Port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'RPC Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'SQL over TCP  Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'DHCP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(67.68) -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'TFTP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 69  -Group "For SCCM PXE SP"
            New-NetFirewallRule -DisplayName 'BINL Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 4011 -Group "For SCCM PXE SP"
        }
        if($_Role -contains "System Health Validator")
        {
            #SMB,RPC Endpoint Mapper,RPC
            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM System Health Validator"
            New-NetFirewallRule -DisplayName 'SMB Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM System Health Validator"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM System Health Validator"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM System Health Validator"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM System Health Validator"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM System Health Validator"
            #dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM System Health Validator"
            New-NetFirewallRule -DisplayName 'RPC Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM System Health Validator"  
        }
        if($_Role -contains "Fallback Status Point")
        {
            #SMB,RPC Endpoint Mapper,RPC
            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM FSP"
            New-NetFirewallRule -DisplayName 'SMB Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM FSP "
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM FSP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM FSP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM FSP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM FSP"
            #dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM FSP"
            New-NetFirewallRule -DisplayName 'RPC Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM FSP"  
        
            New-NetFirewallRule -DisplayName 'HTTP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 -Group "For SCCM FSP"
        }
        if($_Role -contains "Reporting Services Point")
        {
            New-NetFirewallRule -DisplayName 'SQL over TCP  Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SCCM RSP"
            New-NetFirewallRule -DisplayName 'SQL over TCP  Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SCCM RSP"
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM RSP"
            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM RSP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM RSP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM RSP"
            #dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM RSP"
        }
        if($_Role -contains "Distribution Point")
        {
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM DP"
            New-NetFirewallRule -DisplayName 'SMB DP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM DP"
            New-NetFirewallRule -DisplayName 'Multicast Protocol Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 63000-64000 -Group "For SCCM DP"
        }
        if($_Role -contains "Management Point")
        {
            New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'SQL over TCP  Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'LDAP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 389 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'LDAP(SSL) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 636 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'LDAP(SSL) UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 636 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'Global Catelog LDAP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3268 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'Global Catelog LDAP SSL Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3269 -Group "For SCCM MP"

            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'SMB Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM MP"
            #dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM MP"
            New-NetFirewallRule -DisplayName 'RPC Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM MP"  
        }
        if($_Role -contains "Branch Distribution Point")
        {
            New-NetFirewallRule -DisplayName 'SMB BDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM BDP"
            New-NetFirewallRule -DisplayName 'HTTP(S) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM BDP"
        }
        if($_Role -contains "Server Locator Point")
        {
            New-NetFirewallRule -DisplayName 'HTTP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 -Group "For SCCM SLP"
            New-NetFirewallRule -DisplayName 'SQL over TCP  Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SQL Server SLP"
            New-NetFirewallRule -DisplayName 'SMB Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM SLP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM SLP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM SLP"
            #Dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM RSP"
        }
        if($_Role -contains "SQL Server")
        {
            New-NetFirewallRule -DisplayName 'SQL over TCP  Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1433 -Group "For SQL Server"
            New-NetFirewallRule -DisplayName 'WMI' -Program "%systemroot%\system32\svchost.exe" -Service "winmgmt" -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort Domain -Group "For SQL Server WMI"
            New-NetFirewallRule -DisplayName 'DCOM' -Program "%systemroot%\system32\svchost.exe" -Service "rpcss" -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SQL Server DCOM"
            New-NetFirewallRule -DisplayName 'SMB Provider Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SQL Server"
        }
        if($_Role -contains "Provider")
        {
            New-NetFirewallRule -DisplayName 'SMB Provider Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM Provider"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM Provider"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM Provider"
            #dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM"
        }
        if($_Role -contains "Asset Intelligence Synchronization Point")
        {
            New-NetFirewallRule -DisplayName 'SMB Provider Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -Group "For SCCM AISP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM AISP"
            New-NetFirewallRule -DisplayName 'RPC Endpoint Mapper UDP Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol UDP -LocalPort 135 -Group "For SCCM AISP"
            #rpc dynamic port
            New-NetFirewallRule -DisplayName 'RPC Inbound' -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1024-65535 -Group "For SCCM AISP"
            New-NetFirewallRule -DisplayName 'HTTPS Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 443 -Group "For SCCM AISP"
        }
        if($_Role -contains "CM Console")
        {
            New-NetFirewallRule -DisplayName 'RPC Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM Console"
            #cm console->client
            New-NetFirewallRule -DisplayName 'Remote Control(control) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 2701 -Group "For SCCM Console"
            New-NetFirewallRule -DisplayName 'Remote Control(control) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 2701 -Group "For SCCM Console"
            New-NetFirewallRule -DisplayName 'Remote Control(data) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 2702 -Group "For SCCM Console"
            New-NetFirewallRule -DisplayName 'Remote Control(data) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol UDP -LocalPort 2702 -Group "For SCCM Console"
            New-NetFirewallRule -DisplayName 'Remote Control(RPC Endpoint Mapper) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 135 -Group "For SCCM Console"
            New-NetFirewallRule -DisplayName 'Remote Assistance(RDP AND RTC) Outbound' -Profile Domain -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3389 -Group "For SCCM Console"
        }
        if($_Role -contains "Client")
        {
            #Client Push Installation
            Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
            Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)" -Direction Inbound

            #Remote Assistance and Remote Desktop
            New-NetFirewallRule -Program "C:\Windows\PCHealth\HelpCtr\Binaries\helpsvc.exe" -DisplayName "Remote Assistance - Helpsvc.exe" -Enabled True -Direction Outbound -Group "For SCCM Client"
            New-NetFirewallRule -Program "C:\Windows\PCHealth\HelpCtr\Binaries\helpsvc.exe" -DisplayName "Remote Assistance - Helpsvc.exe" -Enabled True -Direction Inbound -Group "For SCCM Client"
            New-NetFirewallRule -DisplayName 'CM Remote Assistance' -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2701 -Group "For SCCM Client"

            #Client Requests
            New-NetFirewallRule -DisplayName 'HTTP(S) Outbound' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort @(80,443) -Group "For SCCM Client"

            #Client Notification
            New-NetFirewallRule -DisplayName 'CM Client Notification' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort 10123 -Group "For SCCM Client"

            #Remote Control
            New-NetFirewallRule -DisplayName 'CM Remote Control' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort 2701 -Group "For SCCM Client"

            #Wake-Up Proxy
            New-NetFirewallRule -DisplayName 'Wake-Up Proxy' -Profile Any -Direction Outbound -Action Allow -Protocol UDP -LocalPort (25536,9) -Group "For SCCM Client"

            #SUP
            New-NetFirewallRule -DisplayName 'CM Connect SUP' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort (8530,8531) -Group "For SCCM Client"
        
            #enable firewall public profile
            Set-NetFirewallProfile -Profile Public -Enabled True
        }
        $StatusPath = "$env:windir\temp\OpenFirewallStatus.txt"
        "Finished" >> $StatusPath
    }

    [bool] Test()
    {
        $StatusPath = "$env:windir\temp\OpenFirewallStatus.txt"
        if(Test-Path $StatusPath)
        {
            return $true
        }

        return $false
    }

    [OpenFirewallPortForSCCM] Get()
    {
        return $this
    }
    
}

[DscResource()]
class InstallFeatureForSCCM
{
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Mandatory)]
    [string[]] $Role

    [void] Set()
    {
        $_Role = $this.Role
        
        Write-Verbose "Current Role is : $_Role"

        if($_Role -notcontains "Client")
        {
            Install-WindowsFeature -Name "Rdc"
        }

        if($_Role -contains "DC")
        {
        }
        if($_Role -contains "Site Server")
        { 
            Add-WindowsFeature Web-Basic-Auth,Web-IP-Security,Web-Url-Auth,Web-Windows-Auth,Web-ASP,Web-Asp-Net 
            Add-WindowsFeature Web-Mgmt-Console,Web-Lgcy-Mgmt-Console,Web-Lgcy-Scripting,Web-WMI,Web-Mgmt-Service,Web-Mgmt-Tools,Web-Scripting-Tools 
        }
        if($_Role -contains "Application Catalog website point")
        {
            #IIS
            Add-WindowsFeature Web-Default-Doc,Web-Static-Content,Web-Windows-Auth,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
        }
        if($_Role -contains "Application Catalog web service point")
        {
            #IIS
            Add-WindowsFeature Web-Default-Doc,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
        }
        if($_Role -contains "Asset Intelligence synchronization point")
        {
            #installed .net 4.5 or later
        }
        if($_Role -contains "Certificate registration point")
        {
            #IIS
            Add-WindowsFeature Web-Asp-Net,Web-Asp-Net45,Web-Metabase,Web-WMI
        }
        if($_Role -contains "Distribution point")
        {
            #IIS 
            Add-WindowsFeature Web-Windows-Auth,web-ISAPI-Ext
            Add-WindowsFeature Web-WMI,Web-Metabase
        }
    
        if($_Role -contains "Endpoint Protection point")
        {
            #.NET 3.5 SP1 is intalled
        }
    
        if($_Role -contains "Enrollment point")
        {
            #iis
            Add-WindowsFeature Web-Default-Doc,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
        }
        if($_Role -contains "Enrollment proxy point")
        {
            #iis
            Add-WindowsFeature Web-Default-Doc,Web-Static-Content,Web-Windows-Auth,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
        }
        if($_Role -contains "Fallback status point")
        {
            Add-WindowsFeature Web-Metabase
        }
        if($_Role -contains "Management point")
        {
            #BITS
            Add-WindowsFeature BITS,BITS-IIS-Ext
            #IIS 
            Add-WindowsFeature Web-Windows-Auth,web-ISAPI-Ext
            Add-WindowsFeature Web-WMI,Web-Metabase
        }
        if($_Role -contains "Reporting services point")
        {
            #installed .net 4.5 or later   
        }
        if($_Role -contains "Service connection point")
        {
            #installed .net 4.5 or later
        }
        if($_Role -contains "Software update point")
        {
            #default iis configuration
            add-windowsfeature web-server 
        }
        if($_Role -contains "State migration point")
        {
            #iis
            Add-WindowsFeature Web-Default-Doc,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
        }

        $StatusPath = "$env:windir\temp\InstallFeatureStatus.txt"
        "Finished" >> $StatusPath
    }

    [bool] Test()
    {
        $StatusPath = "$env:windir\temp\InstallFeatureStatus.txt"
        if(Test-Path $StatusPath)
        {
            return $true
        }

        return $false
    }

    [InstallFeatureForSCCM] Get()
    {
        return $this
    }
}

[DscResource()]
class SetCustomPagingFile
{
    [DscProperty(Key)]
    [string] $Drive

    [DscProperty(Mandatory)]
    [string] $InitialSize

    [DscProperty(Mandatory)]
    [string] $MaximumSize

    [void] Set()
    {
        $_Drive = $this.Drive
        $_InitialSize =$this.InitialSize
        $_MaximumSize =$this.MaximumSize

        $currentstatus = Get-CimInstance -ClassName 'Win32_ComputerSystem'
        if($currentstatus.AutomaticManagedPagefile)
        {
            set-ciminstance $currentstatus -Property @{AutomaticManagedPagefile= $false}
        }

        $currentpagingfile = Get-CimInstance -ClassName 'Win32_PageFileSetting' -Filter "SettingID='pagefile.sys @ $_Drive'" 

        if(!($currentpagingfile))
        {
            Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name="$_Drive\pagefile.sys"; InitialSize = $_InitialSize; MaximumSize = $_MaximumSize}
        }
        else
        {
            Set-CimInstance $currentpagingfile -Property @{InitialSize = $_InitialSize ; MaximumSize = $_MaximumSize}
        }
        

        $global:DSCMachineStatus = 1
    }

    [bool] Test()
    {
        $_Drive = $this.Drive
        $_InitialSize =$this.InitialSize
        $_MaximumSize =$this.MaximumSize

        $isSystemManaged = (Get-CimInstance -ClassName 'Win32_ComputerSystem').AutomaticManagedPagefile
        if($isSystemManaged)
        {
            return $false
        }

        $_Drive = $this.Drive
        $currentpagingfile = Get-CimInstance -ClassName 'Win32_PageFileSetting' -Filter "SettingID='pagefile.sys @ $_Drive'" 
        if(!($currentpagingfile) -or !($currentpagingfile.InitialSize -eq $_InitialSize -and $currentpagingfile.MaximumSize -eq $_MaximumSize))
        {
            return $false
        }

        return $true
    }

    [SetCustomPagingFile] Get()
    {
        return $this
    }
    
}

[DscResource()]
class SetupDomain
{
    [DscProperty(Key)]
    [string] $DomainFullName

    [DscProperty(Mandatory)]
    [System.Management.Automation.PSCredential] $SafemodeAdministratorPassword

    [void] Set()
    {
        $_DomainFullName = $this.DomainFullName
        $_SafemodeAdministratorPassword = $this.SafemodeAdministratorPassword

        $ADInstallState = Get-WindowsFeature AD-Domain-Services
        if(!$ADInstallState.Installed)
        {
            $Feature = Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
        }

        $NetBIOSName = $_DomainFullName.split('.')[0]
        Import-Module ADDSDeployment
        Install-ADDSForest -SafeModeAdministratorPassword $_SafemodeAdministratorPassword.Password `
            -CreateDnsDelegation:$false `
            -DatabasePath "C:\Windows\NTDS" `
            -DomainName $_DomainFullName `
            -DomainNetbiosName $NetBIOSName `
            -LogPath "C:\Windows\NTDS" `
            -InstallDNS:$true `
            -NoRebootOnCompletion:$false `
            -SysvolPath "C:\Windows\SYSVOL" `
            -Force:$true

        $global:DSCMachineStatus = 1
    }

    [bool] Test()
    {
        $_DomainFullName = $this.DomainFullName
        $_SafemodeAdministratorPassword = $this.SafemodeAdministratorPassword
        $ADInstallState = Get-WindowsFeature AD-Domain-Services
        if(!($ADInstallState.Installed))
        {
            return $false
        }
        else
        {
            while($true)
            {
                try
                {
                    $domain = Get-ADDomain -Identity $_DomainFullName -ErrorAction Stop
                    Get-ADForest -Identity $domain.Forest -Credential $_SafemodeAdministratorPassword -ErrorAction Stop

                    return $true
                }
                catch
                {
                    Write-Verbose "Waitting for Domain ready..."
                    Start-Sleep -Seconds 30
                }
            }
            
        }

        return $true
    }

    [SetupDomain] Get()
    {
        return $this
    }
    
}

[DscResource()]
class FileReadAccessShare
{
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Mandatory)]
    [string] $Path

    [DscProperty(Mandatory)]
    [string[]] $Account

    [void] Set()
    {
        $_Name = $this.Name
        $_Path = $this.Path
        $_Account = $this.Account

        for($i = 0; $i -lt $_Account.Length; $i++)
        {    
            if($_Account[$i].ToLower().Contains(","))
            {   
                $DName = $_Account[$i].Split("\")[0]         
                $clientNamelist = ($_Account[$i].Split("\")[1]).Split(",")        
                        
                foreach($clientname in $clientNamelist)
                {
                    if($clientname -eq $clientNamelist[$clientNamelist.Length-1])
                    {
                        $clientaccount = "$DName\$clientname"
                        $_Account[$i] = $clientaccount
                    }else
                    {
                        $clientaccount = "$DName\$clientname$"                 
                        $_Account+=$clientaccount           
                    }
                }                    
            }
        }
        New-SMBShare -Name $_Name -Path $_Path -ReadAccess $_Account
    }

    [bool] Test()
    {
        $_Name = $this.Name

        $testfileshare = Get-SMBShare | ?{$_.name -eq $_Name}
        if(!($testfileshare))
        {
            return $false
        }

        return $true
    }

    [FileReadAccessShare] Get()
    {
        return $this
    }
    
}

[DscResource()]
class InstallCA
{
    [DscProperty(Key)]
    [string] $HashAlgorithm

    [void] Set()
    {
        try
        {
            $_HashAlgorithm = $this.HashAlgorithm
            Write-Verbose "Installing CA..."
            #Install CA
            Import-Module ServerManager
            Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
            Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -HashAlgorithmName $_HashAlgorithm -force

            $StatusPath = "$env:windir\temp\InstallCAStatus.txt"
            "Finished" >> $StatusPath

            Write-Verbose "Finished installing CA."
        }
        catch
        {
            Write-Verbose "Failed to install CA."
        }
    }

    [bool] Test()
    {
        $StatusPath = "$env:windir\temp\InstallCAStatus.txt"
        if(Test-Path $StatusPath)
        {
            return $true
        }

        return $false
    }

    [InstallCA] Get()
    {
        return $this
    }
    
}
