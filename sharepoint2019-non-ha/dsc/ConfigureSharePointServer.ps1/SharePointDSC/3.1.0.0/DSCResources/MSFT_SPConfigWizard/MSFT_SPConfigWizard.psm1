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

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [ValidateSet("mon","tue","wed","thu","fri","sat","sun")]
        [System.String[]]
        $DatabaseUpgradeDays,

        [Parameter()]
        [System.String]
        $DatabaseUpgradeTime,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting status of Configuration Wizard"

    # Check which version of SharePoint is installed
    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -eq 15)
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
    # If so, the Config Wizard is required
    if (($languagePackInstalled -eq 1) -or ($setupType -eq "B2B_UPGRADE"))
    {
        return @{
            IsSingleInstance    = "Yes"
            Ensure              = "Absent"
            DatabaseUpgradeDays = $DatabaseUpgradeDays
            DatabaseUpgradeTime = $DatabaseUpgradeTime
        }
    }
    else
    {
        return @{
            IsSingleInstance    = "Yes"
            Ensure              = "Present"
            DatabaseUpgradeDays = $DatabaseUpgradeDays
            DatabaseUpgradeTime = $DatabaseUpgradeTime
        }
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [ValidateSet("mon","tue","wed","thu","fri","sat","sun")]
        [System.String[]]
        $DatabaseUpgradeDays,

        [Parameter()]
        [System.String]
        $DatabaseUpgradeTime,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting status of Configuration Wizard"

    $now = Get-Date
    if ($DatabaseUpgradeDays)
    {
        # DatabaseUpgradeDays parameter exists, check if current day is specified
        $currentDayOfWeek = $now.DayOfWeek.ToString().ToLower().Substring(0,3)

        if ($DatabaseUpgradeDays -contains $currentDayOfWeek)
        {
            Write-Verbose -Message ("Current day is present in the parameter DatabaseUpgradeDays. " + `
                                    "Configuration wizard can be run today.")
        }
        else
        {
            Write-Verbose -Message ("Current day is not present in the parameter DatabaseUpgradeDays, " + `
                                    "skipping the Configuration Wizard")
            return
        }
    }
    else
    {
        Write-Verbose -Message ("No DatabaseUpgradeDays specified, Configuration Wizard can be " + `
                                "ran on any day.")
    }

    # Check if DatabaseUpdateTime parameter exists
    if ($DatabaseUpgradeTime)
    {
        # Check if current time is inside of time window
        $upgradeTimes = $DatabaseUpgradeTime.Split(" ")
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
                                    "DatabaseUpgradeTime. Starting wizard")
        }
        else
        {
            Write-Verbose -Message ("Current time is outside of the window specified in " + `
                                    "DatabaseUpgradeTime, skipping the Configuration Wizard")
            return
        }
    }
    else
    {
        Write-Verbose -Message ("No DatabaseUpgradeTime specified, Configuration Wizard can be " + `
                                "ran at any time. Starting wizard.")
    }

    if ($Ensure -eq "Absent")
    {
        Write-Verbose -Message ("Ensure is set to Absent, so running the Configuration " + `
                                "Wizard is not required")
        return
    }

    # Check which version of SharePoint is installed
    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -eq 15)
    {
        $binaryDir = Join-Path $env:CommonProgramFiles "Microsoft Shared\Web Server Extensions\15\BIN"
    }
    else
    {
        $binaryDir = Join-Path $env:CommonProgramFiles "Microsoft Shared\Web Server Extensions\16\BIN"
    }
    $psconfigExe = Join-Path -Path $binaryDir -ChildPath "psconfig.exe"

    # Start wizard
    Write-Verbose -Message "Starting Configuration Wizard"
    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $psconfigExe `
                                  -ScriptBlock {
        $psconfigExe = $args[0]
        $psconfig = Start-Process -FilePath $psconfigExe `
                                  -ArgumentList "-cmd upgrade -inplace b2b -wait -force -cmd installcheck -noinstallcheck" `
                                  -Wait `
                                  -PassThru

        return $psconfig.ExitCode
    }

    # Error codes: https://aka.ms/installerrorcodes
    switch ($result)
    {
        0 {
            Write-Verbose -Message "SharePoint Post Setup Configuration Wizard ran successfully"
        }
        Default {
            throw ("SharePoint Post Setup Configuration Wizard failed, " + `
                   "exit code was $result. Error codes can be found at " + `
                   "https://aka.ms/installerrorcodes")
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

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [ValidateSet("mon","tue","wed","thu","fri","sat","sun")]
        [System.String[]]
        $DatabaseUpgradeDays,

        [Parameter()]
        [System.String]
        $DatabaseUpgradeTime,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing status of Configuration Wizard"

    $PSBoundParameters.Ensure = $Ensure

    if ($Ensure -eq "Absent")
    {
        Write-Verbose -Message ("Ensure is set to Absent, so running the Configuration Wizard " + `
                                "is not required")
        return $true
    }

    $currentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
