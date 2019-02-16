function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupFile,

        [Parameter()]
        [System.Boolean]
        $ShutdownServices,

        [Parameter()]
        [ValidateSet("mon","tue","wed","thu","fri","sat","sun")]
        [System.String[]]
        $BinaryInstallDays,

        [Parameter()]
        [System.String]
        $BinaryInstallTime,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    if ($Ensure -eq "Absent")
    {
        throw [Exception] "SharePoint does not support uninstalling updates."
        return
    }

    Write-Verbose -Message "Getting install status of SP binaries"

    $languagepack = $false
    $servicepack  = $false
    $language     = ""

    # Get file information from setup file
    if (-not(Test-Path $SetupFile))
    {
        throw "Setup file cannot be found."
    }

    Write-Verbose -Message "Checking file status of $SetupFile"
    $zone = Get-Item -Path $SetupFile -Stream "Zone.Identifier" -EA SilentlyContinue

    if ($null -ne $zone)
    {
        throw ("Setup file is blocked! Please use Unblock-File to unblock the file " + `
               "before continuing.")
    }

    $setupFileInfo = Get-ItemProperty -Path $SetupFile
    $fileVersion = $setupFileInfo.VersionInfo.FileVersion
    Write-Verbose -Message "Update has version $fileVersion"

    $products = Invoke-SPDSCCommand -Credential $InstallAccount -ScriptBlock {
        return Get-SPDscFarmProductsInfo
    }

    if ($setupFileInfo.VersionInfo.FileDescription -match "Language Pack")
    {
        Write-Verbose -Message "Update is a Language Pack Service Pack."
        # Retrieve language from file and check version for that language pack.
        $languagepack = $true

        # Extract language from filename
        if ($setupFileInfo.Name -match "\w*-(\w{2}-\w{2}).exe")
        {
            $language = $matches[1]
        }
        else
        {
            throw "Update does not contain the language code in the correct format."
        }

        try
        {
            $cultureInfo = New-Object -TypeName System.Globalization.CultureInfo -ArgumentList $language
        }
        catch
        {
            throw "Error while converting language information: $language"
        }

        # try/catch is required for some versions of Windows, other version use the LCID value of 4096
        if ($cultureInfo.LCID -eq 4096)
        {
            throw "Error while converting language information: $language"
        }

        # Extract English name of the language code
        if ($cultureInfo.EnglishName -match "(\w*,*\s*\w*) \(\w*\)")
        {
            $languageEnglish = $matches[1]
            if ($languageEnglish.contains(","))
            {
                $languages = $languageEnglish.Split(",")
                $languageEnglish = $languages[0]
            }
        }

        # Extract Native name of the language code
        if ($cultureInfo.NativeName -match "(\w*,*\s*\w*) \(\w*\)")
        {
            $languageNative = $matches[1]
            if ($languageNative.contains(","))
            {
                $languages = $languageNative.Split(",")
                $languageNative = $languages[0]
            }
        }

        # Build language string used in Language Pack names
        $languageString = "$languageEnglish/$languageNative"
        Write-Verbose -Message "Update is for the $languageEnglish language"

        # Find the product name for the specific language pack
        $productName = ""
        foreach ($product in $products)
        {
            if ($product -match $languageString)
            {
                $productName = $product
            }
        }

        if ($productName -eq "")
        {
            throw "Error: Product for language $language is not found."
        }
        else
        {
            Write-Verbose -Message "Product found: $productName"
        }
        $versionInfo = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $productName `
                                      -ScriptBlock {
            $productToCheck = $args[0]
            return Get-SPDscFarmVersionInfo -ProductToCheck $productToCheck
        }
    }
    elseif ($setupFileInfo.VersionInfo.FileDescription -match "Service Pack")
    {
        Write-Verbose -Message "Update is a Service Pack for SharePoint."
        # Check SharePoint version information.
        $servicepack = $true
        $versionInfo = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $productName `
                                      -ScriptBlock {
            $productToCheck = $args[0]
            return Get-SPDscFarmVersionInfo -ProductToCheck "Microsoft SharePoint Server 2013"
        }
    }
    else
    {
        Write-Verbose -Message "Update is a Cumulative Update."
        # Cumulative Update is multi-lingual. Check version information of all products.
        $versionInfo = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $productName `
                                      -ScriptBlock {
            $productToCheck = $args[0]
            return Get-SPDscFarmVersionInfo
        }
    }

    Write-Verbose -Message "The lowest version of any SharePoint component is $($versionInfo.Lowest)"
    if ($versionInfo.Lowest -lt $fileVersion)
    {
        # Version of SharePoint is lower than the patch version. Patch is not installed.
        return @{
            SetupFile         = $SetupFile
            ShutdownServices  = $ShutdownServices
            BinaryInstallDays = $BinaryInstallDays
            BinaryInstallTime = $BinaryInstallTime
            Ensure            = "Absent"
        }
    }
    else
    {
        # Version of SharePoint is equal or greater than the patch version. Patch is installed.
        return @{
            SetupFile         = $SetupFile
            ShutdownServices  = $ShutdownServices
            BinaryInstallDays = $BinaryInstallDays
            BinaryInstallTime = $BinaryInstallTime
            Ensure            = "Present"
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
        [System.String]
        $SetupFile,

        [Parameter()]
        [System.Boolean]
        $ShutdownServices,

        [Parameter()]
        [ValidateSet("mon","tue","wed","thu","fri","sat","sun")]
        [System.String[]]
        $BinaryInstallDays,

        [Parameter()]
        [System.String]
        $BinaryInstallTime,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting install status of SP Update binaries"

    if ($Ensure -eq "Absent")
    {
        throw [Exception] "SharePoint does not support uninstalling updates."
        return
    }

    # Check if setup file exists
    if (-not(Test-Path $SetupFile))
    {
        throw "Setup file cannot be found."
    }

    Write-Verbose -Message "Checking file status of $SetupFile"
    $zone = Get-Item $SetupFile -Stream "Zone.Identifier" -EA SilentlyContinue

    if ($null -ne $zone)
    {
        throw ("Setup file is blocked! Please use Unblock-File to unblock the file " + `
               "before continuing.")
    }

    $now = Get-Date
    if ($BinaryInstallDays)
    {
        # BinaryInstallDays parameter exists, check if current day is specified
        $currentDayOfWeek = $now.DayOfWeek.ToString().ToLower().Substring(0,3)

        if ($BinaryInstallDays -contains $currentDayOfWeek)
        {
            Write-Verbose -Message ("Current day is present in the parameter BinaryInstallDays. " + `
                                    "Update can be run today.")
        }
        else
        {
            Write-Verbose -Message ("Current day is not present in the parameter BinaryInstallDays, " + `
                                    "skipping the update")
            return
        }
    }
    else
    {
        Write-Verbose -Message "No BinaryInstallDays specified, Update can be ran on any day."
    }

    # Check if BinaryInstallTime parameter exists
    if ($BinaryInstallTime)
    {
        # Check if current time is inside of time window
        $upgradeTimes = $BinaryInstallTime.Split(" ")
        $starttime = 0
        $endtime = 0

        if ($upgradeTimes.Count -ne 3)
        {
            throw "Time window incorrectly formatted."
        }
        else
        {
            if ([datetime]::TryParse($upgradeTimes[0],[ref]$starttime) -ne $true)
            {
                throw "Error converting start time"
            }

            if ([datetime]::TryParse($upgradeTimes[2],[ref]$endtime) -ne $true)
            {
                throw "Error converting end time"
            }

            if ($starttime -gt $endtime)
            {
                throw "Error: Start time cannot be larger than end time"
            }
        }

        if (($starttime -lt $now) -and ($endtime -gt $now))
        {
            Write-Verbose -Message ("Current time is inside of the window specified in " + `
                                    "BinaryInstallTime. Starting update")
        }
        else
        {
            Write-Verbose -Message ("Current time is outside of the window specified in " + `
                                    "BinaryInstallTime, skipping the update")
            return
        }
    }
    else
    {
        Write-Verbose -Message ("No BinaryInstallTime specified, Update can be ran at " + `
                                "any time. Starting update.")
    }

    # To prevent an endless loop: Check if an upgrade is required.
    $installedVersion = Get-SPDSCInstalledProductVersion
    if ($spVersion.FileMajorPart -eq 15)
    {
        $wssRegKey ="hklm:SOFTWARE\Microsoft\Shared Tools\Web Server Extensions\15.0\WSS"
    }
    else
    {
        $wssRegKey ="hklm:SOFTWARE\Microsoft\Shared Tools\Web Server Extensions\16.0\WSS"
    }

    # Read LanguagePackInstalled and SetupType registry keys
    $languagePackInstalled = Get-SPDSCRegistryKey -Key $wssRegKey -Value "LanguagePackInstalled"
    $setupType = Get-SPDSCRegistryKey -Key $wssRegKey -Value "SetupType"

    # Determine if LanguagePackInstalled=1 or SetupType=B2B_Upgrade.
    # If so, the Config Wizard is required, so the installation will be skipped.
    if (($languagePackInstalled -eq 1) -or ($setupType -eq "B2B_UPGRADE"))
    {
        Write-Verbose -Message ("An upgrade is pending. " + `
                                "To prevent a possible loop, the install will be skipped")
        return
    }

    if ($ShutdownServices)
    {
        Write-Verbose -Message "Stopping services to speed up installation process"

        $searchPaused = $false
        $osearchStopped = $false
        $hostControllerStopped = $false

        if ($installedVersion.FileMajorPart -eq 15)
        {
            $searchServiceName = "OSearch15"
        }
        else
        {
            $searchServiceName = "OSearch16"
        }

        $osearchSvc        = Get-Service -Name $searchServiceName
        $hostControllerSvc = Get-Service -Name "SPSearchHostController"

        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -ScriptBlock {
            $searchSAs = Get-SPEnterpriseSearchServiceApplication
            foreach ($searchSA in $searchSAs)
            {
                if ($searchSA.isPaused() -eq 0)
                {
                    $searchSA.Pause()
                }
            }
        }
        $searchPaused = $true

        if($osearchSvc.Status -eq "Running")
        {
            $osearchStopped = $true
            Set-Service -Name $searchServiceName -StartupType Disabled
            $osearchSvc.Stop()
        }

        if($hostControllerSvc.Status -eq "Running")
        {
            $hostControllerStopped = $true
            Set-Service "SPSearchHostController" -StartupType Disabled
            $hostControllerSvc.Stop()
        }

        $hostControllerSvc.WaitForStatus('Stopped','00:01:00')

        Write-Verbose -Message "Search Services are stopped"

        Write-Verbose -Message "Stopping other services"

        if($InstalledVersion.FileMajorPart -eq 15 -or $installedVersion.ProductBuildPart.ToString().Length -eq 4)
        {
            Write-Verbose -Message "SharePoint 2013 or 2016 used, reconfiguring IISAdmin service to Disabled startup."
            Set-Service -Name "IISADMIN" -StartupType Disabled
        }
        Set-Service -Name "SPTimerV4" -StartupType Disabled

        $iisreset = Start-Process -FilePath "iisreset.exe" `
                                  -ArgumentList "-stop -noforce" `
                                  -Wait `
                                  -PassThru

        $timerSvc = Get-Service -Name "SPTimerV4"
        if($timerSvc.Status -eq "Running")
        {
            $timerSvc.Stop()
        }
    }

    Write-Verbose -Message "Beginning installation of the SharePoint update"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $SetupFile `
                                  -ScriptBlock {
        $setupFile = $args[0]

        $setup = Start-Process -FilePath $setupFile `
                               -ArgumentList "/quiet /passive" `
                               -Wait `
                               -PassThru

        # Error codes: https://aka.ms/installerrorcodes
        switch ($setup.ExitCode)
        {
            0
            {
                Write-Verbose -Message "SharePoint update binary installation complete."
            }
            17022
            {
                Write-Verbose -Message ("SharePoint update binary installation complete, " + `
                                        "however a reboot is required.")
                $global:DSCMachineStatus = 1
            }
            Default
            {
                throw ("SharePoint update install failed, exit code was $($setup.ExitCode). " + `
                       "Error codes can be found at https://aka.ms/installerrorcodes")
            }
        }
    }

    if ($ShutdownServices)
    {
        Write-Verbose -Message "Restart stopped services"
        Set-Service -Name "SPTimerV4" -StartupType Automatic

        if($InstalledVersion.FileMajorPart -eq 15 -or $installedVersion.ProductBuildPart.ToString().Length -eq 4)
        {
            Write-Verbose -Message "SharePoint 2013 or 2016 used, reconfiguring IISAdmin service to Automatic startup."
            Set-Service -Name "IISADMIN" -StartupType Automatic
        }

        $timerSvc = Get-Service -Name "SPTimerV4"
        $timerSvc.Start()

        $iisreset = Start-Process -FilePath "iisreset.exe" `
                                  -ArgumentList "-start" `
                                  -Wait `
                                  -PassThru

        $osearchSvc        = Get-Service -Name $searchServiceName
        $hostControllerSvc = Get-Service -Name "SPSearchHostController"

        # Ensuring Search Services were stopped by script before Starting"
        if($osearchStopped -eq $true)
        {
            Set-Service -Name $searchServiceName -StartupType Manual
            $osearchSvc.Start()
        }

        if($hostControllerStopped -eq $true)
        {
            Set-Service "SPSearchHostController" -StartupType Automatic
            $hostControllerSvc.Start()
        }

        if($searchPaused -eq $true)
        {
            # Resuming Search Service Application if paused###
            $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                        -ScriptBlock {
                $searchSAs = Get-SPEnterpriseSearchServiceApplication
                foreach ($searchSA in $searchSAs)
                {
                    if (($searchSA.IsPaused() -band 0x80) -ne 0)
                    {
                        $searchSA.Resume()
                    }
                }
            }
        }

        Write-Verbose -Message "Services restarted."
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupFile,

        [Parameter()]
        [System.Boolean]
        $ShutdownServices,

        [Parameter()]
        [ValidateSet("mon","tue","wed","thu","fri","sat","sun")]
        [System.String[]]
        $BinaryInstallDays,

        [Parameter()]
        [System.String]
        $BinaryInstallTime,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing install status of SP Update binaries"

    $PSBoundParameters.Ensure = $Ensure

    if ($Ensure -eq "Absent")
    {
        throw [Exception] "SharePoint does not support uninstalling updates."
        return
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
