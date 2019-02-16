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
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $InstallPath,

        [Parameter()]
        [System.String]
        $DataPath,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Getting install status of SharePoint"

    $x86Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX86 = Get-ItemProperty -Path $x86Path | Select-Object -Property DisplayName

    $x64Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX64 = Get-ItemProperty -Path $x64Path | Select-Object -Property DisplayName

    $installedItems = $installedItemsX86 + $installedItemsX64
    $installedItems = $installedItems | Select-Object -Property DisplayName -Unique
    $spInstall = $installedItems | Where-Object -FilterScript {
        $_ -match "Microsoft SharePoint Server (2013|2016|2019)"
    }

    if ($spInstall)
    {
        return @{
            IsSingleInstance = "Yes"
            BinaryDir = $BinaryDir
            ProductKey = $ProductKey
            InstallPath = $InstallPath
            DataPath = $DataPath
            Ensure = "Present"
        }
    }
    else
    {
        return @{
            IsSingleInstance = "Yes"
            BinaryDir = $BinaryDir
            ProductKey = $ProductKey
            InstallPath = $InstallPath
            DataPath = $DataPath
            Ensure = "Absent"
        }
    }
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
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $InstallPath,

        [Parameter()]
        [System.String]
        $DataPath,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting install status of SharePoint"

    if ($Ensure -eq "Absent")
    {
        throw [Exception] ("SharePointDsc does not support uninstalling SharePoint or " + `
                           "its prerequisites. Please remove this manually.")
        return
    }

    $InstallerPath = Join-Path $BinaryDir "setup.exe"
    $majorVersion = (Get-SPDSCAssemblyVersion -PathToAssembly $InstallerPath)
    if ($majorVersion -eq 15)
    {
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
    }

    Write-Verbose -Message "Writing install config file"

    $configPath = "$env:temp\SPInstallConfig.xml"

    $configData = "<Configuration>
    <Package Id=`"sts`">
        <Setting Id=`"LAUNCHEDFROMSETUPSTS`" Value=`"Yes`"/>
    </Package>

    <Package Id=`"spswfe`">
        <Setting Id=`"SETUPCALLED`" Value=`"1`"/>
    </Package>

    <Logging Type=`"verbose`" Path=`"%temp%`" Template=`"SharePoint Server Setup(*).log`"/>
    <PIDKEY Value=`"$ProductKey`" />
    <Display Level=`"none`" CompletionNotice=`"no`" />
"

    if ($PSBoundParameters.ContainsKey("InstallPath") -eq $true)
    {
        $configData += "    <INSTALLLOCATION Value=`"$InstallPath`" />
"
    }
    if ($PSBoundParameters.ContainsKey("DataPath") -eq $true)
    {
        $configData += "    <DATADIR Value=`"$DataPath`"/>
"
    }
    $configData += "    <Setting Id=`"SERVERROLE`" Value=`"APPLICATION`"/>
    <Setting Id=`"USINGUIINSTALLMODE`" Value=`"0`"/>
    <Setting Id=`"SETUP_REBOOT`" Value=`"Never`" />
    <Setting Id=`"SETUPTYPE`" Value=`"CLEAN_INSTALL`"/>
</Configuration>"

    $configData | Out-File -FilePath $configPath

    Write-Verbose -Message "Beginning installation of SharePoint"

    $setupExe = Join-Path -Path $BinaryDir -ChildPath "setup.exe"

    $setup = Start-Process -FilePath $setupExe `
                           -ArgumentList "/config `"$configPath`"" `
                           -Wait `
                           -PassThru

    switch ($setup.ExitCode)
    {
        0 {
            Write-Verbose -Message "SharePoint binary installation complete"
            $global:DSCMachineStatus = 1
        }
        30066 {
            $pr1 = ("HKLM:\Software\Microsoft\Windows\CurrentVersion\" + `
                    "Component Based Servicing\RebootPending")
            $pr2 = ("HKLM:\Software\Microsoft\Windows\CurrentVersion\" + `
                    "WindowsUpdate\Auto Update\RebootRequired")
            $pr3 = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
            if (    ($null -ne (Get-Item $pr1 -ErrorAction SilentlyContinue)) `
                -or ($null -ne (Get-Item $pr2 -ErrorAction SilentlyContinue)) `
                -or ((Get-Item $pr3 | Get-ItemProperty).PendingFileRenameOperations.count -gt 0) `
                )
            {

                Write-Verbose -Message ("SPInstall has detected the server has pending " + `
                                        "a reboot. Flagging to the DSC engine that the " + `
                                        "server should reboot before continuing.")
                $global:DSCMachineStatus = 1
            }
            else
            {
                throw ("SharePoint installation has failed due to an issue with prerequisites " + `
                       "not being installed correctly. Please review the setup logs.")
            }
        }
        Default {
            throw "SharePoint install failed, exit code was $($setup.ExitCode)"
        }
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
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $InstallPath,

        [Parameter()]
        [System.String]
        $DataPath,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing install status of SharePoint"

    $PSBoundParameters.Ensure = $Ensure

    if ($Ensure -eq "Absent")
    {
        throw [Exception] ("SharePointDsc does not support uninstalling SharePoint or " + `
                           "its prerequisites. Please remove this manually.")
        return
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
