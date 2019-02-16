$Script:SP2013Features = @("Application-Server", "AS-NET-Framework",
                            "AS-TCP-Port-Sharing", "AS-Web-Support", "AS-WAS-Support",
                            "AS-HTTP-Activation", "AS-Named-Pipes", "AS-TCP-Activation","Web-Server",
                            "Web-WebServer", "Web-Common-Http", "Web-Default-Doc", "Web-Dir-Browsing",
                            "Web-Http-Errors", "Web-Static-Content", "Web-Http-Redirect", "Web-Health",
                            "Web-Http-Logging", "Web-Log-Libraries", "Web-Request-Monitor",
                            "Web-Http-Tracing", "Web-Performance", "Web-Stat-Compression",
                            "Web-Dyn-Compression", "Web-Security", "Web-Filtering", "Web-Basic-Auth",
                            "Web-Client-Auth", "Web-Digest-Auth", "Web-Cert-Auth", "Web-IP-Security",
                            "Web-Url-Auth", "Web-Windows-Auth", "Web-App-Dev", "Web-Net-Ext",
                            "Web-Net-Ext45", "Web-Asp-Net", "Web-Asp-Net45", "Web-ISAPI-Ext",
                            "Web-ISAPI-Filter", "Web-Mgmt-Tools", "Web-Mgmt-Console", "Web-Mgmt-Compat",
                            "Web-Metabase", "Web-Lgcy-Scripting", "Web-WMI", "Web-Scripting-Tools",
                            "NET-Framework-Features", "NET-Framework-Core", "NET-Framework-45-ASPNET",
                            "NET-WCF-HTTP-Activation45", "NET-WCF-Pipe-Activation45",
                            "NET-WCF-TCP-Activation45", "Server-Media-Foundation",
                            "Windows-Identity-Foundation", "PowerShell-V2", "WAS", "WAS-Process-Model",
                            "WAS-NET-Environment", "WAS-Config-APIs", "XPS-Viewer")

$Script:SP2016Win16Features = @("Web-Server", "Web-WebServer",
                                "Web-Common-Http", "Web-Default-Doc", "Web-Dir-Browsing",
                                "Web-Http-Errors", "Web-Static-Content", "Web-Health",
                                "Web-Http-Logging", "Web-Log-Libraries", "Web-Request-Monitor",
                                "Web-Http-Tracing", "Web-Performance", "Web-Stat-Compression",
                                "Web-Dyn-Compression", "Web-Security", "Web-Filtering", "Web-Basic-Auth",
                                "Web-Digest-Auth", "Web-Windows-Auth", "Web-App-Dev", "Web-Net-Ext",
                                "Web-Net-Ext45", "Web-Asp-Net", "Web-Asp-Net45", "Web-ISAPI-Ext",
                                "Web-ISAPI-Filter", "Web-Mgmt-Tools", "Web-Mgmt-Console",
                                "Web-Mgmt-Compat", "Web-Metabase", "Web-Lgcy-Scripting", "Web-WMI",
                                "NET-Framework-Features", "NET-HTTP-Activation", "NET-Non-HTTP-Activ",
                                "NET-Framework-45-ASPNET", "NET-WCF-Pipe-Activation45",
                                "Windows-Identity-Foundation", "WAS", "WAS-Process-Model",
                                "WAS-NET-Environment", "WAS-Config-APIs", "XPS-Viewer")

$Script:SP2016Win12r2Features = @("Application-Server", "AS-NET-Framework",
                                "AS-Web-Support", "Web-Server", "Web-WebServer", "Web-Common-Http",
                                "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors",
                                "Web-Static-Content", "Web-Http-Redirect", "Web-Health",
                                "Web-Http-Logging", "Web-Log-Libraries", "Web-Request-Monitor",
                                "Web-Performance", "Web-Stat-Compression", "Web-Dyn-Compression",
                                "Web-Security", "Web-Filtering", "Web-Basic-Auth", "Web-Client-Auth",
                                "Web-Digest-Auth", "Web-Cert-Auth", "Web-IP-Security", "Web-Url-Auth",
                                "Web-Windows-Auth", "Web-App-Dev", "Web-Net-Ext", "Web-Net-Ext45",
                                "Web-Asp-Net45", "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Mgmt-Tools",
                                "Web-Mgmt-Console", "Web-Mgmt-Compat", "Web-Metabase",
                                "Web-Lgcy-Mgmt-Console", "Web-Lgcy-Scripting", "Web-WMI",
                                "Web-Scripting-Tools", "NET-Framework-Features", "NET-Framework-Core",
                                "NET-HTTP-Activation", "NET-Non-HTTP-Activ", "NET-Framework-45-ASPNET",
                                "NET-WCF-HTTP-Activation45", "Windows-Identity-Foundation",
                                "PowerShell-V2", "WAS", "WAS-Process-Model", "WAS-NET-Environment",
                                "WAS-Config-APIs")

$Script:SP2019Win16Features = @("Web-Server", "Web-WebServer",
                                "Web-Common-Http", "Web-Default-Doc", "Web-Dir-Browsing",
                                "Web-Http-Errors", "Web-Static-Content", "Web-Health",
                                "Web-Http-Logging", "Web-Log-Libraries", "Web-Request-Monitor",
                                "Web-Http-Tracing", "Web-Performance", "Web-Stat-Compression",
                                "Web-Dyn-Compression", "Web-Security", "Web-Filtering", "Web-Basic-Auth",
                                "Web-Windows-Auth", "Web-App-Dev", "Web-Net-Ext",
                                "Web-Net-Ext45", "Web-Asp-Net", "Web-Asp-Net45", "Web-ISAPI-Ext",
                                "Web-ISAPI-Filter", "Web-Mgmt-Tools", "Web-Mgmt-Console",
                                "NET-Framework-Features", "NET-HTTP-Activation", "NET-Non-HTTP-Activ",
                                "NET-Framework-45-ASPNET", "NET-WCF-Pipe-Activation45",
                                "Windows-Identity-Foundation", "WAS", "WAS-Process-Model",
                                "WAS-NET-Environment", "WAS-Config-APIs", "XPS-Viewer")

$Script:SP2019Win19Features = @("Web-Server", "Web-WebServer",
                                "Web-Common-Http", "Web-Default-Doc", "Web-Dir-Browsing",
                                "Web-Http-Errors", "Web-Static-Content", "Web-Health",
                                "Web-Http-Logging", "Web-Log-Libraries", "Web-Request-Monitor",
                                "Web-Http-Tracing", "Web-Performance", "Web-Stat-Compression",
                                "Web-Dyn-Compression", "Web-Security", "Web-Filtering", "Web-Basic-Auth",
                                "Web-Digest-Auth", "Web-Windows-Auth", "Web-App-Dev", "Web-Net-Ext",
                                "Web-Net-Ext45", "Web-Asp-Net", "Web-Asp-Net45", "Web-ISAPI-Ext",
                                "Web-ISAPI-Filter", "Web-Mgmt-Tools", "Web-Mgmt-Console",
                                "NET-Framework-Features", "NET-HTTP-Activation", "NET-Non-HTTP-Activ",
                                "NET-Framework-45-ASPNET", "NET-WCF-Pipe-Activation45",
                                "Windows-Identity-Foundation", "WAS", "WAS-Process-Model",
                                "WAS-NET-Environment", "WAS-Config-APIs", "XPS-Viewer")

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstallerPath,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $OnlineMode,

        [Parameter()]
        [System.String]
        $SXSpath,

        [Parameter()]
        [System.String]
        $SQLNCli,

        [Parameter()]
        [System.String]
        $PowerShell,

        [Parameter()]
        [System.String]
        $NETFX,

        [Parameter()]
        [System.String]
        $IDFX,

        [Parameter()]
        [System.String]
        $Sync,

        [Parameter()]
        [System.String]
        $AppFabric,

        [Parameter()]
        [System.String]
        $IDFX11,

        [Parameter()]
        [System.String]
        $MSIPCClient,

        [Parameter()]
        [System.String]
        $WCFDataServices,

        [Parameter()]
        [System.String]
        $KB2671763,

        [Parameter()]
        [System.String]
        $WCFDataServices56,

        [Parameter()]
        [System.String]
        $MSVCRT11,

        [Parameter()]
        [System.String]
        $MSVCRT14,

        [Parameter()]
        [System.String]
        $MSVCRT141,

        [Parameter()]
        [System.String]
        $KB3092423,

        [Parameter()]
        [System.String]
        $ODBC,

        [Parameter()]
        [System.String]
        $DotNetFx,

        [Parameter()]
        [System.String]
        $DotNet472,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Getting installation status of SharePoint prerequisites"

    $majorVersion = (Get-SPDSCAssemblyVersion -PathToAssembly $InstallerPath)
    $buildVersion = (Get-SPDSCBuildVersion -PathToAssembly $InstallerPath)
    if ($majorVersion -eq 15)
    {
        Write-Verbose -Message "Version: SharePoint 2013"
    }
    if ($majorVersion -eq 16)
    {
        if($buildVersion -lt 5000)
        {
            Write-Verbose -Message "Version: SharePoint 2016"
        }
        elseif($buildVersion -ge 5000)
        {
            Write-Verbose -Message "Version: SharePoint 2019"
        }
    }

    Write-Verbose -Message "Getting installed windows features"

    $osVersion = Get-SPDscOSVersion
    if ($majorVersion -eq 15)
    {
        $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2013Features
    }
    elseif ($majorVersion -eq 16)
    {
        if($buildVersion -lt 5000)
        {
            if ($osVersion.Major -eq 10)
            {
                # Server 2016
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2016Win16Features
            }
            elseif ($osVersion.Major -eq 6 -and $osVersion.Minor -eq 3)
            {
                # Server 2012 R2
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2016Win12r2Features
            }
            else
            {
                throw "SharePoint 2016 only supports Windows Server 2016 or 2012 R2"
            }
        }
        # SharePoint 2019
        elseif($buildVersion -ge 5000)
        {
            if ($osVersion.Major -eq 11)
            {
                # Server 2019
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2019Win19Features
            }
            elseif ($osVersion.Major -eq 10)
            {
                # Server 2016
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2019Win16Features
            }
            else
            {
                throw "SharePoint 2019 only supports Windows Server 2016 or Windows Server 2019"
            }
        }
    }

    $windowsFeaturesInstalled = $true
    foreach ($feature in $WindowsFeatures)
    {
        if ($feature.Installed -eq $false)
        {
            $windowsFeaturesInstalled = $false
            Write-Verbose -Message "Windows feature $($feature.Name) is not installed"
        }
    }

    Write-Verbose -Message "Checking windows packages from the registry"

    $x86Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX86 = Get-ItemProperty -Path $x86Path | Select-Object -Property DisplayName, BundleUpgradeCode, DisplayVersion

    $x64Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX64 = Get-ItemProperty -Path $x64Path | Select-Object -Property DisplayName, BundleUpgradeCode, DisplayVersion

    $installedItems = $installedItemsX86 + $installedItemsX64 | Select-Object -Property DisplayName, BundleUpgradeCode, DisplayVersion -Unique

    # Common prereqs
    $prereqsToTest = @(
        [PSObject]@{
            Name = "AppFabric 1.1 for Windows Server"
            SearchType = "Equals"
            SearchValue = "AppFabric 1.1 for Windows Server"
        },
        [PSObject]@{
            Name = "Microsoft CCR and DSS Runtime 2008 R3"
            SearchType = "Equals"
            SearchValue = "Microsoft CCR and DSS Runtime 2008 R3"
        },
        [PSObject]@{
            Name = "Microsoft Identity Extensions"
            SearchType = "Equals"
            SearchValue = "Microsoft Identity Extensions"
        },
        [PSObject]@{
            Name = "Microsoft Sync Framework Runtime v1.0 SP1 (x64)"
            SearchType = "Equals"
            SearchValue = "Microsoft Sync Framework Runtime v1.0 SP1 (x64)"
        },
        [PSObject]@{
            Name = "WCF Data Services 5.6.0 Runtime"
            SearchType = "Equals"
            SearchValue = "WCF Data Services 5.6.0 Runtime"
        }
    )

    #SP2013 prereqs
    if ($majorVersion -eq 15)
    {
        $prereqsToTest += @(
            [PSObject]@{
                Name = "Active Directory Rights Management Services Client 2.*"
                SearchType = "Like"
                SearchValue = "Active Directory Rights Management Services Client 2.*"
            },
            [PSObject]@{
                Name = "Microsoft SQL Server Native Client (2008 R2 or 2012)"
                SearchType = "Match"
                SearchValue = "SQL Server (2008 R2|2012) Native Client"
            },
            [PSObject]@{
                Name = "WCF Data Services 5.0 (for OData v3) Primary Components"
                SearchType = "Equals"
                SearchValue = "WCF Data Services 5.0 (for OData v3) Primary Components"
            }
        )
    }

    #SP2016/SP2019 prereqs
    if ($majorVersion -eq 16)
    {
        if($buildVersion -lt 5000)
        {
            #SP2016 prereqs
            $prereqsToTest += @(
                [PSObject]@{
                    Name = "Active Directory Rights Management Services Client 2.1"
                    SearchType = "Equals"
                    SearchValue = "Active Directory Rights Management Services Client 2.1"
                },
                [PSObject]@{
                    Name = "Microsoft SQL Server 2012 Native Client"
                    SearchType = "Equals"
                    SearchValue = "Microsoft SQL Server 2012 Native Client"
                },
                [PSObject]@{
                    Name = "Microsoft ODBC Driver 11 for SQL Server"
                    SearchType = "Equals"
                    SearchValue = "Microsoft ODBC Driver 11 for SQL Server"
                },
                [PSObject]@{
                    Name = "Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0"
                    SearchType = "Like"
                    SearchValue = "Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.*"
                },
                [PSObject]@{
                    Name = "Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0"
                    SearchType = "Like"
                    SearchValue = "Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.*"
                },
                [PSObject]@{
                    Name = "Microsoft Visual C++ 2015 Redistributable (x64)"
                    SearchType = "BundleUpgradeCode"
                    SearchValue = "{C146EF48-4D31-3C3D-A2C5-1E91AF8A0A9B}"
                    MinimumRequiredVersion = "14.0.23026.0"
                }
            )
        }
        elseif($buildVersion -ge 5000)
        {
            #SP2019 prereqs
            $prereqsToTest += @(
                [PSObject]@{
                    Name = "Active Directory Rights Management Services Client 2.1"
                    SearchType = "Equals"
                    SearchValue = "Active Directory Rights Management Services Client 2.1"
                },
                [PSObject]@{
                    Name = "Microsoft SQL Server 2012 Native Client"
                    SearchType = "Equals"
                    SearchValue = "Microsoft SQL Server 2012 Native Client"
                },
                [PSObject]@{
                    Name = "Microsoft Visual C++ 2017 Redistributable (x64)"
                    SearchType = "BundleUpgradeCode"
                    SearchValue = "{C146EF48-4D31-3C3D-A2C5-1E91AF8A0A9B}"
                    MinimumRequiredVersion = "14.13.26020.0"
                }
            )
        }
    }
    $prereqsInstalled = Test-SPDscPrereqInstallStatus -InstalledItems $installedItems `
                                                      -PrereqsToCheck $prereqsToTest

    $results = @{
        IsSingleInstance = "Yes"
        InstallerPath = $InstallerPath
        OnlineMode = $OnlineMode
        SXSpath = $SXSpath
        SQLNCli = $SQLNCli
        PowerShell = $PowerShell
        NETFX = $NETFX
        IDFX = $IDFX
        Sync = $Sync
        AppFabric = $AppFabric
        IDFX11 = $IDFX11
        MSIPCClient = $MSIPCClient
        WCFDataServices = $WCFDataServices
        KB2671763 = $KB2671763
        WCFDataServices56 = $WCFDataServices56
        MSVCRT11 = $MSVCRT11
        MSVCRT14 = $MSVCRT14
        MSVCRT141 = $MSVCRT141
        KB3092423 = $KB3092423
        ODBC = $ODBC
        DotNetFx = $DotNetFx
        DotNet472 = $DotNet472
    }

    if ($prereqsInstalled -eq $true -and $windowsFeaturesInstalled -eq $true)
    {
        $results.Ensure = "Present"
    }
    else
    {
        $results.Ensure = "Absent"
    }

    return $results
}

function Set-TargetResource
{
    # Supressing the global variable use to allow passing DSC the reboot message
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstallerPath,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $OnlineMode,

        [Parameter()]
        [System.String]
        $SXSpath,

        [Parameter()]
        [System.String]
        $SQLNCli,

        [Parameter()]
        [System.String]
        $PowerShell,

        [Parameter()]
        [System.String]
        $NETFX,

        [Parameter()]
        [System.String]
        $IDFX,

        [Parameter()]
        [System.String]
        $Sync,

        [Parameter()]
        [System.String]
        $AppFabric,

        [Parameter()]
        [System.String]
        $IDFX11,

        [Parameter()]
        [System.String]
        $MSIPCClient,

        [Parameter()]
        [System.String]
        $WCFDataServices,

        [Parameter()]
        [System.String]
        $KB2671763,

        [Parameter()]
        [System.String]
        $WCFDataServices56,

        [Parameter()]
        [System.String]
        $MSVCRT11,

        [Parameter()]
        [System.String]
        $MSVCRT14,

        [Parameter()]
        [System.String]
        $MSVCRT141,

        [Parameter()]
        [System.String]
        $KB3092423,

        [Parameter()]
        [System.String]
        $ODBC,

        [Parameter()]
        [System.String]
        $DotNetFx,

        [Parameter()]
        [System.String]
        $DotNet472,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting installation status of SharePoint prerequisites"

    if ($Ensure -eq "Absent")
    {
        throw [Exception] ("SharePointDsc does not support uninstalling SharePoint or its " + `
                           "prerequisites. Please remove this manually.")
        return
    }

    Write-Verbose -Message "Detecting SharePoint version from binaries"
    $majorVersion = Get-SPDSCAssemblyVersion -PathToAssembly $InstallerPath
    $buildVersion = (Get-SPDSCBuildVersion -PathToAssembly $InstallerPath)
    $osVersion = Get-SPDscOSVersion

    if ($majorVersion -eq 15)
    {
        $BinaryDir = Split-Path -Path $InstallerPath
        $svrsetupDll = Join-Path -Path $BinaryDir -ChildPath "updates\svrsetup.dll"
        $checkDotNet = $true
        if (Test-Path -Path $svrsetupDll)
        {
            $svrsetupDllFileInfo = Get-ItemProperty -Path $svrsetupDll
            $fileVersion = $svrsetupDllFileInfo.VersionInfo.FileVersion
            if ($fileVersion -ge "15.0.4709.1000")
            {
                $checkDotNet = $false
            }
        }

        if ($checkDotNet -eq $true)
        {
            $ndpKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4"
            $dotNet46Installed = $false
            if (Test-Path -Path $ndpKey)
            {
                $dotNetv4Keys = Get-ChildItem -Path $ndpKey
                foreach ($dotnetInstance in $dotNetv4Keys)
                {
                    if ($dotnetInstance.GetValue("Release") -ge 390000)
                    {
                        $dotNet46Installed = $true
                        break
                    }
                }
            }

            if ($dotNet46Installed -eq $true)
            {
                throw [Exception] ("A known issue prevents installation of SharePoint 2013 on " + `
                                   "servers that have .NET 4.6 already installed. See details " + `
                                   "at https://support.microsoft.com/en-us/kb/3087184")
                return
            }
        }

        Write-Verbose -Message "Version: SharePoint 2013"
        $requiredParams = @("SQLNCli","PowerShell","NETFX","IDFX","Sync","AppFabric","IDFX11",
                            "MSIPCClient","WCFDataServices","KB2671763","WCFDataServices56")
        $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2013Features
    }
    elseif ($majorVersion -eq 16)
    {
        if($buildVersion -lt 5000)
        {
            Write-Verbose -Message "Version: SharePoint 2016"
            $requiredParams = @("SQLNCli","Sync","AppFabric","IDFX11","MSIPCClient","KB3092423",
                                "WCFDataServices56","DotNetFx","MSVCRT11","MSVCRT14","ODBC")
            if ($osVersion.Major -eq 10)
            {
                # Server 2016
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2016Win16Features
            }
            elseif ($osVersion.Major -eq 6 -and $osVersion.Minor -eq 3)
            {
                # Server 2012 R2
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2016Win12r2Features
            }
            else
            {
                throw "SharePoint 2016 only supports Windows Server 2016 or 2012 R2"
            }
        }
        # SharePoint 2019
        elseif($buildVersion -ge 5000)
        {
            Write-Verbose -Message "Version: SharePoint 2019"
            $requiredParams = @("SQLNCli","Sync","AppFabric","IDFX11","MSIPCClient","KB3092423",
            "WCFDataServices56","DotNet472","MSVCRT11","MSVCRT141")

            if ($osVersion.Major -eq 11)
            {
                # Server 2019
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2019Win19Features
            }
            elseif ($osVersion.Major -eq 10)
            {
                # Server 2016
                $WindowsFeatures = Get-WindowsFeature -Name $Script:SP2019Win16Features
            }
            else
            {
                throw "SharePoint 2019 only supports Windows Server 2016 or Windows Server 2019"
            }
        }
    }

    # SXSstore for feature install specified, we will manually install features from the
    # store, rather then relying on the prereq installer to download them
    if ($SXSpath)
    {
        Write-Verbose -Message "Getting installed windows features"
        foreach ($feature in $WindowsFeatures)
        {
            if ($feature.Installed -ne $true)
            {
                Write-Verbose "Installing $($feature.name)"
                $installResult = Install-WindowsFeature -Name $feature.Name -Source $SXSpath
                if ($installResult.restartneeded -eq "yes")
                {
                    $global:DSCMachineStatus = 1
                }
                if ($installResult.Success -ne $true)
                {
                    throw "Error installing $($feature.name)"
                }
            }
        }

        # see if we need to reboot after feature install
        if ($global:DSCMachineStatus -eq 1)
        {
            return
        }
    }

    $prereqArgs = "/unattended"
    if ($OnlineMode -eq $false)
    {
        $requiredParams | ForEach-Object -Process {
            if (($PSBoundParameters.ContainsKey($_) -eq $true `
                    -and [string]::IsNullOrEmpty($PSBoundParameters.$_)) `
                -or (-not $PSBoundParameters.ContainsKey($_)))
            {
                throw "In offline mode for version $majorVersion parameter $_ is required"
            }
            if ((Test-Path $PSBoundParameters.$_) -eq $false)
            {
                throw ("The $_ parameter has been passed but the file cannot be found at the " + `
                       "path supplied: `"$($PSBoundParameters.$_)`"")
            }
        }
        $requiredParams | ForEach-Object -Process {
            $prereqArgs += " /$_`:`"$($PSBoundParameters.$_)`""
        }
    }

    Write-Verbose -Message "Calling the SharePoint Pre-req installer"
    Write-Verbose -Message "Args for prereq installer are: $prereqArgs"
    $process = Start-Process -FilePath $InstallerPath -ArgumentList $prereqArgs -Wait -PassThru

    switch ($process.ExitCode)
    {
        0
        {
            Write-Verbose -Message "Prerequisite installer completed successfully."
        }
        1
        {
            throw "Another instance of the prerequisite installer is already running"
        }
        2
        {
            throw "Invalid command line parameters passed to the prerequisite installer"
        }
        1001
        {
            Write-Verbose -Message ("A pending restart is blocking the prerequisite " + `
                                    "installer from running. Scheduling a reboot.")
            $global:DSCMachineStatus = 1
        }
        3010
        {
            Write-Verbose -Message ("The prerequisite installer has run correctly and needs " + `
                                    "to reboot the machine before continuing.")
            $global:DSCMachineStatus = 1
        }
        default
        {
            throw ("The prerequisite installer ran with the following unknown " + `
                   "exit code $($process.ExitCode)")
        }
    }

    $rebootKey1 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\" + `
                  "Component Based Servicing\RebootPending"
    $rebootTest1 = Get-Item -Path $rebootKey1 -ErrorAction SilentlyContinue

    $rebootKey2 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\" + `
                  "Auto Update\RebootRequired"
    $rebootTest2 = Get-Item -Path $rebootKey2 -ErrorAction SilentlyContinue

    $sessionManagerKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
    $sessionManager = Get-Item -Path $sessionManagerKey | Get-ItemProperty
    $pendingFileRenames = $sessionManager.PendingFileRenameOperations.Count

    if (($null -ne $rebootTest1) -or ($null -ne $rebootTest2) -or ($pendingFileRenames -gt 0))
    {
        Write-Verbose -Message ("SPInstallPrereqs has detected the server has pending a " + `
                                "reboot. Flagging to the DSC engine that the server should " + `
                                "reboot before continuing.")
        $global:DSCMachineStatus = 1
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstallerPath,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $OnlineMode,

        [Parameter()]
        [System.String]
        $SXSpath,

        [Parameter()]
        [System.String]
        $SQLNCli,

        [Parameter()]
        [System.String]
        $PowerShell,

        [Parameter()]
        [System.String]
        $NETFX,

        [Parameter()]
        [System.String]
        $IDFX,

        [Parameter()]
        [System.String]
        $Sync,

        [Parameter()]
        [System.String]
        $AppFabric,

        [Parameter()]
        [System.String]
        $IDFX11,

        [Parameter()]
        [System.String]
        $MSIPCClient,

        [Parameter()]
        [System.String]
        $WCFDataServices,

        [Parameter()]
        [System.String]
        $KB2671763,

        [Parameter()]
        [System.String]
        $WCFDataServices56,

        [Parameter()]
        [System.String]
        $MSVCRT11,

        [Parameter()]
        [System.String]
        $MSVCRT14,

        [Parameter()]
        [System.String]
        $MSVCRT141,

        [Parameter()]
        [System.String]
        $KB3092423,

        [Parameter()]
        [System.String]
        $ODBC,

        [Parameter()]
        [System.String]
        $DotNetFx,

        [Parameter()]
        [System.String]
        $DotNet472,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing installation status of SharePoint prerequisites"

    $PSBoundParameters.Ensure = $Ensure

    if ($Ensure -eq "Absent")
    {
        throw [Exception] ("SharePointDsc does not support uninstalling SharePoint or its " + `
                           "prerequisites. Please remove this manually.")
        return
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters -ValuesToCheck @("Ensure")
}

function Test-SPDscPrereqInstallStatus
{
    param
    (
        [Parameter()]
        [Object]
        $InstalledItems,

        [Parameter(Mandatory = $true)]
        [psobject[]]
        $PrereqsToCheck
    )

    if ($null -eq $InstalledItems)
    {
        return $false
    }

    $itemsInstalled = $true
    $PrereqsToCheck | ForEach-Object -Process {
        $itemToCheck = $_
        switch ($itemToCheck.SearchType)
        {
            "Equals"
            {
                if ($null -eq ($InstalledItems | Where-Object -FilterScript {
                    $null -ne $_.DisplayName -and $_.DisplayName.Trim() -eq $itemToCheck.SearchValue
                }))
                {
                    $itemsInstalled = $false
                    Write-Verbose -Message ("Prerequisite $($itemToCheck.Name) was not found " + `
                                            "on this system")
                }
            }
            "Match"
            {
                if ($null -eq ($InstalledItems | Where-Object -FilterScript {
                    $null -ne $_.DisplayName -and $_.DisplayName.Trim() -match $itemToCheck.SearchValue
                }))
                {
                    $itemsInstalled = $false
                    Write-Verbose -Message ("Prerequisite $($itemToCheck.Name) was not found " + `
                                            "on this system")
                }
            }
            "Like"
            {
                if ($null -eq ($InstalledItems | Where-Object -FilterScript {
                    $null -ne $_.DisplayName -and $_.DisplayName.Trim() -like $itemToCheck.SearchValue
                }))
                {
                    $itemsInstalled = $false
                    Write-Verbose -Message ("Prerequisite $($itemToCheck.Name) was not found " + `
                                            "on this system")
                }
            }
            "BundleUpgradeCode"
            {
                $installedItem = $InstalledItems | Where-Object -FilterScript {
                    $null -ne $_.BundleUpgradeCode -and (($_.BundleUpgradeCode.Trim() | Compare-Object $itemToCheck.SearchValue) -eq $null)
                }
                if ($null -eq $installedItem)
                {
                    $itemsInstalled = $false
                    Write-Verbose -Message ("Prerequisite $($itemToCheck.Name) was not found " + `
                                            "on this system")
                }
                else
                {
                    $isRequiredVersionInstalled = $true;

                    [int[]]$minimumRequiredVersion = $itemToCheck.MinimumRequiredVersion.Split('.')
                    [int[]]$installedVersion = $installedItem.DisplayVersion.Split('.')
                    for ([int]$index = 0; $index -lt $minimumRequiredVersion.Length -and $index -lt $installedVersion.Length; $index++)
                    {
                        if($minimumRequiredVersion[$index] -gt $installedVersion[$index])
                        {
                            $isRequiredVersionInstalled = $false;
                        }
                    }
                    if ($installedVersion.Length -eq 0 -or -not $isRequiredVersionInstalled)
                    {
                        $itemsInstalled = $false
                        Write-Verbose -Message ("Prerequisite $($itemToCheck.Name) was found but had " + `
                                                "unexpected version. Expected minimum version $($itemToCheck.MinimumVersion) " + `
                                                "but found version $($installedItem.DisplayVersion).")
                    }
                }
            }
            Default
            {
                throw ("Unable to search for a prereq with mode '$($itemToCheck.SearchType)'. " + `
                       "please use either 'Equals', 'Like' or 'Match', or 'BundleUpgradeCode'")
            }
        }
    }
    return $itemsInstalled
}

Export-ModuleMember -Function *-TargetResource
