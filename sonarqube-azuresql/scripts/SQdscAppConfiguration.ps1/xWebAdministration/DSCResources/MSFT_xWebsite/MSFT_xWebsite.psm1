#requires -Version 4.0 -Modules CimCmdlets

# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1" -Verbose:$false

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ErrorWebsiteNotFound = The requested website "{0}" cannot be found on the target machine.
        ErrorWebsiteDiscoveryFailure = Failure to get the requested website "{0}" information from the target machine.
        ErrorWebsiteCreationFailure = Failure to successfully create the website "{0}". Error: "{1}".
        ErrorWebsiteRemovalFailure = Failure to successfully remove the website "{0}". Error: "{1}".
        ErrorWebsiteBindingUpdateFailure = Failure to successfully update the bindings for website "{0}". Error: "{1}".
        ErrorWebsiteBindingInputInvalidation = Desired website bindings are not valid for website "{0}".
        ErrorWebsiteCompareFailure = Failure to successfully compare properties for website "{0}". Error: "{1}".
        ErrorWebBindingCertificate = Failure to add certificate to web binding. Please make sure that the certificate thumbprint "{0}" is valid. Error: "{1}".
        ErrorWebsiteStateFailure = Failure to successfully set the state of the website "{0}". Error: "{1}".
        ErrorWebsiteBindingConflictOnStart = Website "{0}" could not be started due to binding conflict. Ensure that the binding information for this website does not conflict with any existing website's bindings before trying to start it.
        ErrorWebBindingInvalidIPAddress = Failure to validate the IPAddress property value "{0}". Error: "{1}".
        ErrorWebBindingInvalidPort = Failure to validate the Port property value "{0}". The port number must be a positive integer between 1 and 65535.
        ErrorWebBindingMissingBindingInformation = The BindingInformation property is required for bindings of type "{0}".
        ErrorWebBindingMissingCertificateThumbprint = The CertificateThumbprint property is required for bindings of type "{0}".
        ErrorWebBindingMissingSniHostName = The HostName property is required for use with Server Name Indication.
        ErrorWebsitePreloadFailure = Failure to set Preload on Website "{0}". Error: "{1}".
        ErrorWebsiteAutoStartFailure = Failure to set AutoStart on Website "{0}". Error: "{1}".
        ErrorWebsiteAutoStartProviderFailure = Failure to set AutoStartProvider on Website "{0}". Error: "{1}".
        ErrorWebsiteTestAutoStartProviderFailure = Desired AutoStartProvider is not valid due to a conflicting Global Property. Ensure that the serviceAutoStartProvider is a unique key."
        VerboseSetTargetUpdatedPhysicalPath = Physical Path for website "{0}" has been updated to "{1}".
        VerboseGetTargetAbsent = No Website exists with this name.
        VerboseGetTargetPresent = A single Website exists with this name
        VerboseSetTargetUpdatedApplicationPool = Application Pool for website "{0}" has been updated to "{1}".
        VerboseSetTargetUpdatedBindingInfo = Bindings for website "{0}" have been updated.
        VerboseSetTargetUpdatedEnabledProtocols = Enabled Protocols for website "{0}" have been updated to "{1}".
        VerboseSetTargetUpdatedState = State for website "{0}" has been updated to "{1}".
        VerboseSetTargetWebsiteCreated = Successfully created website "{0}".
        VerboseSetTargetWebsiteStarted = Successfully started website "{0}".
        VerboseSetTargetWebsiteRemoved = Successfully removed website "{0}".
        VerboseSetTargetAuthenticationInfoUpdated = Successfully updated AuthenticationInfo on website "{0}".
        VerboseSetTargetWebsitePreloadUpdated = Successfully updated Preload on website "{0}".
        VerboseSetTargetWebsiteAutoStartUpdated = Successfully updated AutoStart on website "{0}".
        VerboseSetTargetWebsiteAutoStartProviderUpdated = Successfully updated AutoStartProvider on website "{0}".
        VerboseSetTargetIISAutoStartProviderUpdated = Successfully updated AutoStartProvider in IIS.
        VerboseSetTargetUpdateLogPath = LogPath does not match and will be updated on Website "{0}".
        VerboseSetTargetUpdateLogFlags = LogFlags do not match and will be updated on Website "{0}".
        VerboseSetTargetUpdateLogPeriod = LogPeriod does not match and will be updated on Website "{0}".
        VerboseSetTargetUpdateLogTruncateSize = TruncateSize does not match and will be updated on Website "{0}".
        VerboseSetTargetUpdateLoglocalTimeRollover = LoglocalTimeRollover does not match and will be updated on Website "{0}".
        VerboseSetTargetUpdateLogFormat = LogFormat is not in the desired state and will be updated on Website "{0}"
        VerboseTestTargetFalseEnsure = The Ensure state for website "{0}" does not match the desired state.
        VerboseTestTargetFalsePhysicalPath = Physical Path of website "{0}" does not match the desired state.
        VerboseTestTargetFalseState = The state of website "{0}" does not match the desired state.
        VerboseTestTargetFalseApplicationPool = Application Pool for website "{0}" does not match the desired state.
        VerboseTestTargetFalseBindingInfo = Bindings for website "{0}" do not match the desired state.
        VerboseTestTargetFalseEnabledProtocols = Enabled Protocols for website "{0}" do not match the desired state.
        VerboseTestTargetFalseDefaultPage = Default Page for website "{0}" does not match the desired state.
        VerboseTestTargetTrueResult = The target resource is already in the desired state. No action is required.
        VerboseTestTargetFalseResult = The target resource is not in the desired state.
        VerboseTestTargetFalsePreload = Preload for website "{0}" do not match the desired state.
        VerboseTestTargetFalseAutoStart = AutoStart for website "{0}" do not match the desired state.
        VerboseTestTargetFalseAuthenticationInfo = AuthenticationInfo for website "{0}" is not in the desired state.
        VerboseTestTargetFalseIISAutoStartProvider = AutoStartProvider for IIS is not in the desired state
        VerboseTestTargetFalseWebsiteAutoStartProvider = AutoStartProvider for website "{0}" is not in the desired state
        VerboseTestTargetFalseLogPath = LogPath does not match desired state on Website "{0}".
        VerboseTestTargetFalseLogFlags = LogFlags does not match desired state on Website "{0}".
        VerboseTestTargetFalseLogPeriod = LogPeriod does not match desired state on Website "{0}".
        VerboseTestTargetFalseLogTruncateSize = LogTruncateSize does not match desired state on Website "{0}".
        VerboseTestTargetFalseLoglocalTimeRollover = LoglocalTimeRollover does not match desired state on Website "{0}".
        VerboseTestTargetFalseLogFormat = LogFormat does not match desired state on Website "{0}".
        VerboseConvertToWebBindingIgnoreBindingInformation = BindingInformation is ignored for bindings of type "{0}" in case at least one of the following properties is specified: IPAddress, Port, HostName.
        VerboseConvertToWebBindingDefaultPort = Port is not specified. The default "{0}" port "{1}" will be used.
        VerboseConvertToWebBindingDefaultCertificateStoreName = CertificateStoreName is not specified. The default value "{0}" will be used.
        VerboseTestBindingInfoSameIPAddressPortHostName = BindingInfo contains multiple items with the same IPAddress, Port, and HostName combination.
        VerboseTestBindingInfoSamePortDifferentProtocol = BindingInfo contains items that share the same Port but have different Protocols.
        VerboseTestBindingInfoSameProtocolBindingInformation = BindingInfo contains multiple items with the same Protocol and BindingInformation combination.
        VerboseTestBindingInfoInvalidCatch = Unable to validate BindingInfo: "{0}".
        VerboseUpdateDefaultPageUpdated = Default page for website "{0}" has been updated to "{1}".
        WarningLogPeriod = LogTruncateSize has is an input as will overwrite this desired state on Website "{0}".
        WarningIncorrectLogFormat = LogFormat is not W3C, as a result LogFlags will not be used on Website "{0}".
'@
}

<#
        .SYNOPSYS
            The Get-TargetResource cmdlet is used to fetch the status of role or Website on
            the target machine. It gives the Website info of the requested role/feature on the
            target machine.

        .PARAMETER Name
            Name of the website
#>
function Get-TargetResource
{
    
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    Assert-Module

    $website = Get-Website | Where-Object -FilterScript {$_.Name -eq $Name}
    
    if ($website.Count -eq 0)
    {
        Write-Verbose -Message ($LocalizedData.VerboseGetTargetAbsent)
        $ensureResult = 'Absent'
    }
    elseif ($website.Count -eq 1)
    {
        Write-Verbose -Message ($LocalizedData.VerboseGetTargetPresent)
        $ensureResult = 'Present'

        $cimBindings = @(ConvertTo-CimBinding -InputObject $website.bindings.Collection)

        $allDefaultPages = @(
            Get-WebConfiguration -Filter '//defaultDocument/files/*' -PSPath "IIS:\Sites\$Name" |
            ForEach-Object -Process {Write-Output -InputObject $_.value}
        )
        $cimAuthentication = Get-AuthenticationInfo -Site $Name
        $websiteAutoStartProviders = (Get-WebConfiguration `
            -filter /system.applicationHost/serviceAutoStartProviders).Collection
        $webConfiguration = $websiteAutoStartProviders | `
                                Where-Object -Property Name -eq -Value $ServiceAutoStartProvider | `
                                Select-Object Name,Type
    }
    # Multiple websites with the same name exist. This is not supported and is an error
    else
    {
        $errorMessage = $LocalizedData.ErrorWebsiteDiscoveryFailure -f $Name
        New-TerminatingError -ErrorId 'WebsiteDiscoveryFailure' `
                             -ErrorMessage $errorMessage `
                             -ErrorCategory 'InvalidResult'
    }

    # Add all website properties to the hash table
    return @{
        Ensure                   = $ensureResult
        Name                     = $Name
        PhysicalPath             = $website.PhysicalPath
        State                    = $website.State
        ApplicationPool          = $website.ApplicationPool
        BindingInfo              = $cimBindings
        DefaultPage              = $allDefaultPages
        EnabledProtocols         = $website.EnabledProtocols
        AuthenticationInfo       = $cimAuthentication
        PreloadEnabled           = $website.applicationDefaults.preloadEnabled
        ServiceAutoStartProvider = $website.applicationDefaults.serviceAutoStartProvider
        ServiceAutoStartEnabled  = $website.applicationDefaults.serviceAutoStartEnabled
        ApplicationType          = $webConfiguration.Type
        LogPath                  = $website.logfile.directory
        LogFlags                 = [Array]$website.logfile.LogExtFileFlags
        LogPeriod                = $website.logfile.period
        LogtruncateSize          = $website.logfile.truncateSize
        LoglocalTimeRollover     = $website.logfile.localTimeRollover
        LogFormat                = $website.logfile.logFormat
    }
}

<#
        .SYNOPSYS
        The Set-TargetResource cmdlet is used to create, delete or configure a website on the 
        target machine.

        .PARAMETER PhysicalPath
        Specifies the physical path of the web site. Don't set this if the site will be deployed by an external tool that updates the path.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [String]
        $PhysicalPath,

        [ValidateSet('Started', 'Stopped')]
        [String]
        $State = 'Started',

        # The application pool name must contain between 1 and 64 characters
        [ValidateLength(1, 64)]
        [String]
        $ApplicationPool,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $BindingInfo,

        [String[]]
        $DefaultPage,

        [String]
        $EnabledProtocols,

        [Microsoft.Management.Infrastructure.CimInstance]
        $AuthenticationInfo,

        [Boolean]
        $PreloadEnabled,

        [Boolean]
        $ServiceAutoStartEnabled,

        [String]
        $ServiceAutoStartProvider,

        [String]
        $ApplicationType,

        [String]
        $LogPath,

        [ValidateSet('Date','Time','ClientIP','UserName','SiteName','ComputerName','ServerIP','Method','UriStem','UriQuery','HttpStatus','Win32Status','BytesSent','BytesRecv','TimeTaken','ServerPort','UserAgent','Cookie','Referer','ProtocolVersion','Host','HttpSubStatus')]
        [String[]]
        $LogFlags,

        [ValidateSet('Hourly','Daily','Weekly','Monthly','MaxSize')]
        [String]
        $LogPeriod,

        [ValidateScript({
            ([ValidateRange(1048576, 4294967295)] $valueAsUInt64 = [UInt64]::Parse($_))
        })]
        [String]
        $LogTruncateSize,

        [Boolean]
        $LoglocalTimeRollover,

        [ValidateSet('IIS','W3C','NCSA')]
        [String]
        $LogFormat
    )

    Assert-Module

    $website = Get-Website | Where-Object -FilterScript {$_.Name -eq $Name}

    if ($Ensure -eq 'Present')
    {
        if ($null -ne $website)
        {
            # Update Physical Path if required
            if ([String]::IsNullOrEmpty($PhysicalPath) -eq $false -and `
                $website.PhysicalPath -ne $PhysicalPath)
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name physicalPath `
                                 -Value $PhysicalPath `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedPhysicalPath `
                                        -f $Name, $PhysicalPath)
            }

            # Update Application Pool if required
            if ($PSBoundParameters.ContainsKey('ApplicationPool') -and `
                $website.ApplicationPool -ne $ApplicationPool)
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name applicationPool `
                                 -Value $ApplicationPool `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedApplicationPool `
                                        -f $Name, $ApplicationPool)
            }

            # Update Bindings if required
            if ($PSBoundParameters.ContainsKey('BindingInfo') -and `
                $null -ne $BindingInfo)
            {
                if (-not (Test-WebsiteBinding -Name $Name `
                                              -BindingInfo $BindingInfo))
                {
                    Update-WebsiteBinding -Name $Name `
                                          -BindingInfo $BindingInfo
                    Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedBindingInfo `
                                            -f $Name)
                }
            }

            # Update Enabled Protocols if required
            if ($PSBoundParameters.ContainsKey('EnabledProtocols') -and `
                $website.EnabledProtocols -ne $EnabledProtocols)
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name enabledProtocols `
                                 -Value $EnabledProtocols `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedEnabledProtocols `
                                        -f $Name, $EnabledProtocols)
            }

            # Update Default Pages if required
            if ($PSBoundParameters.ContainsKey('DefaultPage') -and `
                $null -ne $DefaultPage)
            {
                Update-DefaultPage -Name $Name `
                                   -DefaultPage $DefaultPage
            }

            # Update State if required
            if ($PSBoundParameters.ContainsKey('State') -and `
                $website.State -ne $State)
            {
                if ($State -eq 'Started')
                {
                    # Ensure that there are no other running websites with binding information that 
                    # will conflict with this website before starting
                    if (-not (Confirm-UniqueBinding -Name $Name -ExcludeStopped))
                    {
                        # Return error and do not start the website
                        $errorMessage = $LocalizedData.ErrorWebsiteBindingConflictOnStart `
                                        -f $Name
                        New-TerminatingError -ErrorId 'WebsiteBindingConflictOnStart' `
                                             -ErrorMessage $errorMessage `
                                             -ErrorCategory 'InvalidResult'
                    }

                    try
                    {
                        Start-Website -Name $Name -ErrorAction Stop
                    }
                    catch
                    {
                        $errorMessage = $LocalizedData.ErrorWebsiteStateFailure `
                                        -f $Name, $_.Exception.Message
                        New-TerminatingError -ErrorId 'WebsiteStateFailure' `
                                             -ErrorMessage $errorMessage `
                                             -ErrorCategory 'InvalidOperation'
                    }
                }
                else
                {
                    try
                    {
                        Stop-Website -Name $Name -ErrorAction Stop
                    }
                    catch
                    {
                        $errorMessage = $LocalizedData.ErrorWebsiteStateFailure `
                                        -f $Name, $_.Exception.Message
                        New-TerminatingError -ErrorId 'WebsiteStateFailure' `
                                             -ErrorMessage $errorMessage `
                                             -ErrorCategory 'InvalidOperation'
                    }
                }

                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedState `
                                        -f $Name, $State)
            }

            # Set Authentication; if not defined then pass in DefaultAuthenticationInfo
            if ($PSBoundParameters.ContainsKey('AuthenticationInfo') -and `
                (-not (Test-AuthenticationInfo -Site $Name `
                                               -AuthenticationInfo $AuthenticationInfo)))
            {
                Set-AuthenticationInfo -Site $Name `
                                       -AuthenticationInfo $AuthenticationInfo `
                                       -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetAuthenticationInfoUpdated `
                                        -f $Name)
            }
           
            # Update Preload if required
            if ($PSBoundParameters.ContainsKey('preloadEnabled') -and `
                ($website.applicationDefaults.preloadEnabled -ne $PreloadEnabled))
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name applicationDefaults.preloadEnabled `
                                 -Value $PreloadEnabled `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsitePreloadUpdated `
                                       -f $Name)
            }
            
            # Update AutoStart if required
            if ($PSBoundParameters.ContainsKey('ServiceAutoStartEnabled') -and `
                ($website.applicationDefaults.ServiceAutoStartEnabled -ne $ServiceAutoStartEnabled))
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name applicationDefaults.serviceAutoStartEnabled `
                                 -Value $ServiceAutoStartEnabled `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsiteAutoStartUpdated `
                                        -f $Name)
            }
            
            # Update AutoStartProviders if required
            if ($PSBoundParameters.ContainsKey('ServiceAutoStartProvider') -and `
                ($website.applicationDefaults.ServiceAutoStartProvider -ne `
                $ServiceAutoStartProvider))
            {
                if (-not (Confirm-UniqueServiceAutoStartProviders `
                            -ServiceAutoStartProvider $ServiceAutoStartProvider `
                            -ApplicationType $ApplicationType))
                {
                    Add-WebConfiguration -filter /system.applicationHost/serviceAutoStartProviders `
                                         -Value @{
                                            name=$ServiceAutoStartProvider
                                            type=$ApplicationType} `
                                         -ErrorAction Stop
                    Write-Verbose -Message `
                                    ($LocalizedData.VerboseSetTargetIISAutoStartProviderUpdated)
                }
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name applicationDefaults.serviceAutoStartProvider `
                                 -Value $ServiceAutoStartProvider -ErrorAction Stop
                Write-Verbose -Message `
                                ($LocalizedData.VerboseSetTargetWebsiteAutoStartProviderUpdated `
                                -f $Name)
            }

            # Update LogFormat if Needed
            if ($PSBoundParameters.ContainsKey('LogFormat') -and `
                ($LogFormat -ne $website.logfile.LogFormat))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogFormat `
                                        -f $Name)
                Set-WebConfigurationProperty '/system.applicationHost/sites/siteDefaults/logfile' `
                    -Name logFormat `
                    -Value $LogFormat
            }

            # Update LogFlags if required
            if ($PSBoundParameters.ContainsKey('LogFlags') -and `
                (-not (Compare-LogFlags -Name $Name -LogFlags $LogFlags)))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogFlags `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.logFormat -Value 'W3C'
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.LogExtFileFlags -Value ($LogFlags -join ',')
            }

            # Update LogPath if required
            if ($PSBoundParameters.ContainsKey('LogPath') -and `
                ($LogPath -ne $website.logfile.directory))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogPath `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.directory -value $LogPath
            }

            # Update LogPeriod if needed
            if ($PSBoundParameters.ContainsKey('LogPeriod') -and `
                ($LogPeriod -ne $website.logfile.LogPeriod))
            {
                if ($PSBoundParameters.ContainsKey('LogTruncateSize'))
                    {
                        Write-Verbose -Message ($LocalizedData.WarningLogPeriod -f $Name)
                    }

                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogPeriod)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.period -Value $LogPeriod
            }

            # Update LogTruncateSize if needed
            if ($PSBoundParameters.ContainsKey('LogTruncateSize') -and `
                ($LogTruncateSize -ne $website.logfile.LogTruncateSize))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogTruncateSize `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.truncateSize -Value $LogTruncateSize
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.period -Value 'MaxSize'
            }

            # Update LoglocalTimeRollover if neeed
            if ($PSBoundParameters.ContainsKey('LoglocalTimeRollover') -and `
                ($LoglocalTimeRollover -ne `
                 ([System.Convert]::ToBoolean($website.logfile.LoglocalTimeRollover))))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLoglocalTimeRollover `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.localTimeRollover -Value $LoglocalTimeRollover
            }

        }
        # Create website if it does not exist
        else
        {
            try
            {
                $PSBoundParameters.GetEnumerator() | Where-Object -FilterScript {
                    $_.Key -in (Get-Command -Name New-Website `
                                            -Module WebAdministration).Parameters.Keys
                } | ForEach-Object -Begin { 
                        $newWebsiteSplat = @{} 
                } -Process {
                    $newWebsiteSplat.Add($_.Key, $_.Value)
                }

                # If there are no other websites, specify the Id Parameter for the new website.
                # Otherwise an error can occur on systems running Windows Server 2008 R2.
                if (-not (Get-Website))
                {
                    $newWebsiteSplat.Add('Id', 1)
                }

                if ([String]::IsNullOrEmpty($PhysicalPath)) {
                    # If no physical path is provided run New-Website with -Force flag
                    $website = New-Website @newWebsiteSplat -ErrorAction Stop -Force
                } else {
                    # If physical path is provided don't run New-Website with -Force flag to verify that the path exists
                    $website = New-Website @newWebsiteSplat -ErrorAction Stop
                }
                
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsiteCreated `
                                        -f $Name)
            }
            catch
            {
                $errorMessage = $LocalizedData.ErrorWebsiteCreationFailure `
                                -f $Name, $_.Exception.Message
                New-TerminatingError -ErrorId 'WebsiteCreationFailure' `
                                     -ErrorMessage $errorMessage `
                                     -ErrorCategory 'InvalidOperation'
            }

            Stop-Website -Name $website.Name -ErrorAction Stop

            # Clear default bindings if new bindings defined and are different
            if ($PSBoundParameters.ContainsKey('BindingInfo') -and `
                $null -ne $BindingInfo)
            {
                if (-not (Test-WebsiteBinding -Name $Name `
                                              -BindingInfo $BindingInfo))
                {
                    Update-WebsiteBinding -Name $Name -BindingInfo $BindingInfo
                    Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedBindingInfo `
                                            -f $Name)
                }
            }

            # Update Enabled Protocols if required
            if ($PSBoundParameters.ContainsKey('EnabledProtocols') `
                -and $website.EnabledProtocols `
                -ne $EnabledProtocols)
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name enabledProtocols `
                                 -Value $EnabledProtocols `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdatedEnabledProtocols `
                                        -f $Name, $EnabledProtocols)
            }

            # Update Default Pages if required
            if ($PSBoundParameters.ContainsKey('DefaultPage') -and `
                $null -ne $DefaultPage)
            {
                Update-DefaultPage -Name $Name `
                                   -DefaultPage $DefaultPage
            }

            # Start website if required
            if ($State -eq 'Started')
            {
                # Ensure that there are no other running websites with binding information that
                # will conflict with this website before starting
                if (-not (Confirm-UniqueBinding -Name $Name -ExcludeStopped))
                {
                    # Return error and do not start the website
                    $errorMessage = $LocalizedData.ErrorWebsiteBindingConflictOnStart `
                                    -f $Name
                    New-TerminatingError -ErrorId 'WebsiteBindingConflictOnStart' `
                                         -ErrorMessage $errorMessage `
                                         -ErrorCategory 'InvalidResult'
                }

                try
                {
                    Start-Website -Name $Name -ErrorAction Stop
                    Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsiteStarted `
                                            -f $Name)
                }
                catch
                {
                    $errorMessage = $LocalizedData.ErrorWebsiteStateFailure `
                                    -f $Name, $_.Exception.Message
                    New-TerminatingError -ErrorId 'WebsiteStateFailure' `
                                         -ErrorMessage $errorMessage `
                                         -ErrorCategory 'InvalidOperation'
                }
            }

            # Set Authentication; if not defined then pass in DefaultAuthenticationInfo
            if ($PSBoundParameters.ContainsKey('AuthenticationInfo') -and `
                (-not (Test-AuthenticationInfo -Site $Name `
                                               -AuthenticationInfo $AuthenticationInfo)))
            {
                Set-AuthenticationInfo -Site $Name `
                                       -AuthenticationInfo $AuthenticationInfo `
                                       -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetAuthenticationInfoUpdated `
                                        -f $Name)
            }
           
            # Update Preload if required
            if ($PSBoundParameters.ContainsKey('preloadEnabled') -and `
                ($website.applicationDefaults.preloadEnabled -ne $PreloadEnabled))
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                -Name applicationDefaults.preloadEnabled `
                                -Value $PreloadEnabled `
                                -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsitePreloadUpdated `
                                       -f $Name)
            }
            
            # Update AutoStart if required
            if ($PSBoundParameters.ContainsKey('ServiceAutoStartEnabled') -and `
                ($website.applicationDefaults.ServiceAutoStartEnabled -ne $ServiceAutoStartEnabled))
            {
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name applicationDefaults.serviceAutoStartEnabled `
                                 -Value $ServiceAutoStartEnabled `
                                 -ErrorAction Stop
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsiteAutoStartUpdated `
                                        -f $Name)
            }
            
            # Update AutoStartProviders if required
            if ($PSBoundParameters.ContainsKey('ServiceAutoStartProvider') -and `
                ($website.applicationDefaults.ServiceAutoStartProvider `
                -ne $ServiceAutoStartProvider))
            {
                if (-not (Confirm-UniqueServiceAutoStartProviders `
                            -ServiceAutoStartProvider $ServiceAutoStartProvider `
                            -ApplicationType $ApplicationType))
                {
                    Add-WebConfiguration -filter /system.applicationHost/serviceAutoStartProviders `
                                         -Value @{
                                            name=$ServiceAutoStartProvider; 
                                            type=$ApplicationType
                                          } `
                                         -ErrorAction Stop
                    Write-Verbose -Message `
                                    ($LocalizedData.VerboseSetTargetIISAutoStartProviderUpdated)
                }
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                                 -Name applicationDefaults.serviceAutoStartProvider `
                                 -Value $ServiceAutoStartProvider -ErrorAction Stop
                Write-Verbose -Message `
                                ($LocalizedData.VerboseSetTargetWebsiteAutoStartProviderUpdated `
                                -f $Name)
            }

            # Update LogFormat if Needed
            if ($PSBoundParameters.ContainsKey('LogFormat') -and `
                ($LogFormat -ne $website.logfile.LogFormat))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogFormat -f $Name)
                Set-WebConfigurationProperty '/system.applicationHost/sites/siteDefaults/logfile' `
                    -name logFormat `
                    -value $LogFormat
            }

            # Update LogFlags if required
            if ($PSBoundParameters.ContainsKey('LogFlags') -and `
                (-not (Compare-LogFlags -Name $Name -LogFlags $LogFlags)))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogFlags `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.logFormat -Value 'W3C'
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.LogExtFileFlags -Value ($LogFlags -join ',')
            }

            # Update LogPath if required
            if ($PSBoundParameters.ContainsKey('LogPath') -and `
                ($LogPath -ne $website.logfile.directory))
            {

                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogPath `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.directory -value $LogPath
            }

            # Update LogPeriod if needed
            if ($PSBoundParameters.ContainsKey('LogPeriod') -and `
                ($LogPeriod -ne $website.logfile.LogPeriod))
            {
                if ($PSBoundParameters.ContainsKey('LogTruncateSize'))
                    {
                        Write-Verbose -Message ($LocalizedData.WarningLogPeriod `
                                                -f $Name)
                    }

                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogPeriod)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.period -Value $LogPeriod
            }

            # Update LogTruncateSize if needed
            if ($PSBoundParameters.ContainsKey('LogTruncateSize') -and `
                ($LogTruncateSize -ne $website.logfile.LogTruncateSize))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLogTruncateSize `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.truncateSize -Value $LogTruncateSize
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.period -Value 'MaxSize'
            }

            # Update LoglocalTimeRollover if neeed
            if ($PSBoundParameters.ContainsKey('LoglocalTimeRollover') -and `
                ($LoglocalTimeRollover -ne `
                 ([System.Convert]::ToBoolean($website.logfile.LoglocalTimeRollover))))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetUpdateLoglocalTimeRollover `
                                        -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Name" `
                    -Name LogFile.localTimeRollover -Value $LoglocalTimeRollover
            }
        }
    }
    # Remove website
    else
    {
        try
        {
            Remove-Website -Name $Name -ErrorAction Stop
            Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebsiteRemoved `
                                    -f $Name)
        }
        catch
        {
            $errorMessage = $LocalizedData.ErrorWebsiteRemovalFailure `
                            -f $Name, $_.Exception.Message
            New-TerminatingError -ErrorId 'WebsiteRemovalFailure' `
                                 -ErrorMessage $errorMessage `
                                 -ErrorCategory 'InvalidOperation'
        }
    }
}

<#
        .SYNOPSIS
        The Test-TargetResource cmdlet is used to validate if the role or feature is in a state as 
        expected in the instance document.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [String]
        $PhysicalPath,

        [ValidateSet('Started', 'Stopped')]
        [String]
        $State = 'Started',

        # The application pool name must contain between 1 and 64 characters
        [ValidateLength(1, 64)]
        [String]
        $ApplicationPool,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $BindingInfo,

        [String[]]
        $DefaultPage,

        [String]
        $EnabledProtocols,

        [Microsoft.Management.Infrastructure.CimInstance]
        $AuthenticationInfo,
        
        [Boolean]
        $PreloadEnabled,
        
        [Boolean]
        $ServiceAutoStartEnabled,

        [String]
        $ServiceAutoStartProvider,
        
        [String]
        $ApplicationType,

        [String]
        $LogPath,

        [ValidateSet('Date','Time','ClientIP','UserName','SiteName','ComputerName','ServerIP','Method','UriStem','UriQuery','HttpStatus','Win32Status','BytesSent','BytesRecv','TimeTaken','ServerPort','UserAgent','Cookie','Referer','ProtocolVersion','Host','HttpSubStatus')]
        [String[]]
        $LogFlags,

        [ValidateSet('Hourly','Daily','Weekly','Monthly','MaxSize')]
        [String]
        $LogPeriod,

        [ValidateScript({
            ([ValidateRange(1048576, 4294967295)] $valueAsUInt64 = [UInt64]::Parse($_))
        })]
        [String]
        $LogTruncateSize,

        [Boolean]
        $LoglocalTimeRollover,

        [ValidateSet('IIS','W3C','NCSA')]
        [String]
        $LogFormat
    )

    Assert-Module

    $inDesiredState = $true

    $website = Get-Website | Where-Object -FilterScript {$_.Name -eq $Name}
    
    # Check Ensure
    if (($Ensure -eq 'Present' -and $null -eq $website) -or `
        ($Ensure -eq 'Absent' -and $null -ne $website))
    {
        $inDesiredState = $false
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseEnsure `
                                -f $Name)
    }

    # Only check properties if website exists
    if ($Ensure -eq 'Present' -and `
        $null -ne $website)
    {
        # Check Physical Path property
        if ([String]::IsNullOrEmpty($PhysicalPath) -eq $false -and `
            $website.PhysicalPath -ne $PhysicalPath)
        {
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalsePhysicalPath `
                                    -f $Name)
        }

        # Check State
        if ($PSBoundParameters.ContainsKey('State') -and $website.State -ne $State)
        {
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseState `
                                    -f $Name)
        }

        # Check Application Pool property
        if ($PSBoundParameters.ContainsKey('ApplicationPool') -and `
            $website.ApplicationPool -ne $ApplicationPool)
        {
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseApplicationPool `
                                    -f $Name)
        }

        # Check Binding properties
        if ($PSBoundParameters.ContainsKey('BindingInfo') -and `
            $null -ne $BindingInfo)
        {
            if (-not (Test-WebsiteBinding -Name $Name -BindingInfo $BindingInfo))
            {
                $inDesiredState = $false
                Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseBindingInfo `
                                        -f $Name)
            }
        }

        # Check Enabled Protocols
        if ($PSBoundParameters.ContainsKey('EnabledProtocols') -and `
            $website.EnabledProtocols -ne $EnabledProtocols)
        {
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseEnabledProtocols `
                                    -f $Name)
        }

        # Check Default Pages
        if ($PSBoundParameters.ContainsKey('DefaultPage') -and `
            $null -ne $DefaultPage)
        {
            $allDefaultPages = @(
                Get-WebConfiguration -Filter '//defaultDocument/files/*' `
                                     -PSPath "IIS:\Sites\$Name" |
                ForEach-Object -Process { Write-Output -InputObject $_.value }
            )

            foreach ($page in $DefaultPage)
            {
                if ($allDefaultPages -inotcontains $page)
                {
                    $inDesiredState = $false
                    Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseDefaultPage `
                                            -f $Name)
                }
            }
        }

        #Check AuthenticationInfo
        if ($PSBoundParameters.ContainsKey('AuthenticationInfo') -and `
            (-not (Test-AuthenticationInfo -Site $Name `
                                           -AuthenticationInfo $AuthenticationInfo)))
        { 
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseAuthenticationInfo)
        } 
        
        #Check Preload
        if($PSBoundParameters.ContainsKey('preloadEnabled') -and `
            $website.applicationDefaults.preloadEnabled -ne $PreloadEnabled)
        {
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalsePreload `
                                    -f $Name)
        } 
              
        #Check AutoStartEnabled
        if($PSBoundParameters.ContainsKey('serviceAutoStartEnabled') -and `
            $website.applicationDefaults.serviceAutoStartEnabled -ne $ServiceAutoStartEnabled)
        {
            $inDesiredState = $false
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseAutoStart `
                                    -f $Name)
        }
        
        #Check AutoStartProviders 
        if($PSBoundParameters.ContainsKey('serviceAutoStartProvider') -and `
            $website.applicationDefaults.serviceAutoStartProvider -ne $ServiceAutoStartProvider)
        {
            if (-not (Confirm-UniqueServiceAutoStartProviders `
                        -serviceAutoStartProvider $ServiceAutoStartProvider `
                        -ApplicationType $ApplicationType))
            {
                $inDesiredState = $false
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetIISAutoStartProviderUpdated)
            }
        }

        # Check LogFormat
        if ($PSBoundParameters.ContainsKey('LogFormat'))
        {
            # Warn if LogFlags are passed in and Current LogFormat is not W3C
            if ($PSBoundParameters.ContainsKey('LogFlags') -and `
                $LogFormat -ne 'W3C')
            {
                Write-Verbose -Message ($LocalizedData.WarningIncorrectLogFormat `
                                        -f $Name)
            }
            
            # Warn if LogFlags are passed in and Desired LogFormat is not W3C
            if($PSBoundParameters.ContainsKey('LogFlags') -and `
                $website.logfile.LogFormat -ne 'W3C')
            {
                Write-Verbose -Message ($LocalizedData.WarningIncorrectLogFormat `
                                        -f $Name)
            }
            
            # Check Log Format
            if ($LogFormat -ne $website.logfile.LogFormat)
            {
                Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseLogFormat `
                                        -f $Name)
                return $false
            }
        }

        # Check LogFlags
        if ($PSBoundParameters.ContainsKey('LogFlags') -and `
            (-not (Compare-LogFlags -Name $Name -LogFlags $LogFlags)))
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseLogFlags)
            return $false
        }

        # Check LogPath
        if ($PSBoundParameters.ContainsKey('LogPath') -and `
            ($LogPath -ne $website.logfile.directory))
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseLogPath `
                                    -f $Name)
            return $false
        }

        # Check LogPeriod
        if ($PSBoundParameters.ContainsKey('LogPeriod') -and `
            ($LogPeriod -ne $website.logfile.LogPeriod))
        {
            if ($PSBoundParameters.ContainsKey('LogTruncateSize'))
            {
                Write-Verbose -Message ($LocalizedData.WarningLogPeriod `
                                        -f $Name)
            }

            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseLogPeriod `
                                    -f $Name)
            return $false
        }

        # Check LogTruncateSize
        if ($PSBoundParameters.ContainsKey('LogTruncateSize') -and `
            ($LogTruncateSize -ne $website.logfile.LogTruncateSize))
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseLogTruncateSize `
                                    -f $Name)
            return $false
        }

        # Check LoglocalTimeRollover
        if ($PSBoundParameters.ContainsKey('LoglocalTimeRollover') -and `
            ($LoglocalTimeRollover -ne `
            ([System.Convert]::ToBoolean($website.logfile.LoglocalTimeRollover))))
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseLoglocalTimeRollover `
                                    -f $Name)
            return $false
        }
    }

    if ($inDesiredState -eq $true)
    {
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetTrueResult)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseResult)
    }

    return $inDesiredState
}

#region Helper Functions

<#
        .SYNOPSIS
        Helper function used to validate that the logflags status.
        Returns False if the loglfags do not match and true if they do

        .PARAMETER LogFlags
        Specifies flags to check

        .PARAMETER Name
        Specifies website to check the flags on
#>
function Compare-LogFlags
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String[]]
        [ValidateSet('Date','Time','ClientIP','UserName','SiteName','ComputerName','ServerIP','Method','UriStem','UriQuery','HttpStatus','Win32Status','BytesSent','BytesRecv','TimeTaken','ServerPort','UserAgent','Cookie','Referer','ProtocolVersion','Host','HttpSubStatus')]
        $LogFlags,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name

    )

    $currentLogFlags = (Get-Website -Name $Name).logfile.logExtFileFlags -split ',' | Sort-Object
    $proposedLogFlags = $LogFlags -split ',' | Sort-Object

    if (Compare-Object -ReferenceObject $currentLogFlags -DifferenceObject $proposedLogFlags)
    {
        return $false
    }

    return $true

}

<#
        .SYNOPSIS
        Helper function used to validate that the website's binding information is unique to other 
        websites. Returns False if at least one of the bindings is already assigned to another 
        website.

        .PARAMETER Name
        Specifies the name of the website.

        .PARAMETER ExcludeStopped
        Omits stopped websites.

        .NOTES
        This function tests standard ('http' and 'https') bindings only.
        It is technically possible to assign identical non-standard bindings (such as 'net.tcp') 
        to different websites.
#>
function Confirm-UniqueBinding
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $false)]
        [Switch]
        $ExcludeStopped
    )

    $website = Get-Website | Where-Object -FilterScript { $_.Name -eq $Name }

    if (-not $website)
    {
        $errorMessage = $LocalizedData.ErrorWebsiteNotFound `
                        -f $Name
        New-TerminatingError -ErrorId 'WebsiteNotFound' `
                             -ErrorMessage $errorMessage `
                             -ErrorCategory 'InvalidResult'
    }

    $referenceObject = @(
        $website.bindings.Collection |
        Where-Object -FilterScript { $_.protocol -in @('http', 'https') } |
        ConvertTo-WebBinding -Verbose:$false
    )

    if ($ExcludeStopped)
    {
        $otherWebsiteFilter = { $_.Name -ne $website.Name -and $_.State -ne 'Stopped' }
    }
    else
    {
        $otherWebsiteFilter = { $_.Name -ne $website.Name }
    }

    $differenceObject = @(
        Get-Website |
        Where-Object -FilterScript $otherWebsiteFilter |
        ForEach-Object -Process { $_.bindings.Collection } |
        Where-Object -FilterScript { $_.protocol -in @('http', 'https') } |
        ConvertTo-WebBinding -Verbose:$false
    )

    # Assume that bindings are unique
    $result = $true

    $compareSplat = @{
        ReferenceObject  = $referenceObject
        DifferenceObject = $differenceObject
        Property         = @('protocol', 'bindingInformation')
        ExcludeDifferent = $true
        IncludeEqual     = $true
    }

    if (Compare-Object @compareSplat)
    {
        $result = $false
    }

    return $result
}

<#
        .SYNOPSIS
        Helper function used to validate that the AutoStartProviders is unique to other websites.
        returns False if the AutoStartProviders exist.
            
        .PARAMETER ServiceAutoStartProvider
        Specifies the name of the AutoStartProviders.
            
        .PARAMETER ApplicationType
        Specifies the name of the Application Type for the AutoStartProvider.
            
        .NOTES
        This tests for the existance of a AutoStartProviders which is globally assigned. 
        As AutoStartProviders need to be uniquely named it will check for this and error out if 
        attempting to add a duplicatly named AutoStartProvider.
        Name is passed in to bubble to any error messages during the test.
#>
function Confirm-UniqueServiceAutoStartProviders
{   
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ServiceAutoStartProvider,

        [Parameter(Mandatory = $true)]
        [String]
        $ApplicationType
    )

    $websiteASP = (Get-WebConfiguration `
                   -filter /system.applicationHost/serviceAutoStartProviders).Collection

    $existingObject = $websiteASP | `
        Where-Object -Property Name -eq -Value $ServiceAutoStartProvider | `
        Select-Object Name,Type

    $proposedObject = @(New-Object -TypeName PSObject -Property @{
            name   = $ServiceAutoStartProvider
            type   = $ApplicationType
    })

    if(-not $existingObject)
    {
        return $false
    }

    if(-not (Compare-Object -ReferenceObject $existingObject `
                            -DifferenceObject $proposedObject `
                            -Property name))
    {
        if(Compare-Object -ReferenceObject $existingObject `
                          -DifferenceObject $proposedObject `
                          -Property type)
        {
            $errorMessage = $LocalizedData.ErrorWebsiteTestAutoStartProviderFailure
            New-TerminatingError -ErrorId 'ErrorWebsiteTestAutoStartProviderFailure' `
                                 -ErrorMessage $errorMessage `
                                 -ErrorCategory 'InvalidResult'`
        }
    }

    return $true

}

<#
        .SYNOPSIS
        Converts IIS <binding> elements to instances of the MSFT_xWebBindingInformation CIM class.
#>
function ConvertTo-CimBinding
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object[]]
        $InputObject
    )
    
    begin
    {
        $cimClassName = 'MSFT_xWebBindingInformation'
        $cimNamespace = 'root/microsoft/Windows/DesiredStateConfiguration'
    }
    
    process
    {
        foreach ($binding in $InputObject)
        {
            [Hashtable]$cimProperties = @{
                Protocol           = [String]$binding.protocol
                BindingInformation = [String]$binding.bindingInformation
            }

            if ($binding.Protocol -in @('http', 'https'))
            {
                # Extract IPv6 address
                if ($binding.bindingInformation -match '^\[(.*?)\]\:(.*?)\:(.*?)$') 
                {
                    $IPAddress = $Matches[1]
                    $Port      = $Matches[2]
                    $HostName  = $Matches[3]
                }
                else
                {
                    $IPAddress, $Port, $HostName = $binding.bindingInformation -split '\:'
                }

                if ([String]::IsNullOrEmpty($IPAddress))
                {
                    $IPAddress = '*'
                }

                $cimProperties.Add('IPAddress', [String]$IPAddress)
                $cimProperties.Add('Port',      [UInt16]$Port)
                $cimProperties.Add('HostName',  [String]$HostName)
            }
            else
            {
                $cimProperties.Add('IPAddress', [String]::Empty)
                $cimProperties.Add('Port',      [UInt16]::MinValue)
                $cimProperties.Add('HostName',  [String]::Empty)
            }

            if ([Environment]::OSVersion.Version -ge '6.2')
            {
                $cimProperties.Add('SslFlags', [String]$binding.sslFlags)
            }

            $cimProperties.Add('CertificateThumbprint', [String]$binding.certificateHash)
            $cimProperties.Add('CertificateStoreName',  [String]$binding.certificateStoreName)

            New-CimInstance -ClassName $cimClassName `
                            -Namespace $cimNamespace `
                            -Property $cimProperties `
                            -ClientOnly
        }
    }
}

<#
        .SYNOPSIS
        Converts instances of the MSFT_xWebBindingInformation CIM class to the IIS <binding> 
        element representation.

        .LINK
        https://www.iis.net/configreference/system.applicationhost/sites/site/bindings/binding
#>
function ConvertTo-WebBinding
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object[]]
        $InputObject
    )
    process
    {
        foreach ($binding in $InputObject)
        {
            $outputObject = @{
                protocol = $binding.Protocol
            }

            if ($binding -is [Microsoft.Management.Infrastructure.CimInstance])
            {
                if ($binding.Protocol -in @('http', 'https'))
                {
                    if (-not [String]::IsNullOrEmpty($binding.BindingInformation))
                    {
                        if (-not [String]::IsNullOrEmpty($binding.IPAddress) -or
                            -not [String]::IsNullOrEmpty($binding.Port) -or
                            -not [String]::IsNullOrEmpty($binding.HostName)
                        )
                        {
                            $isJoinRequired = $true
                            Write-Verbose -Message `
                                ($LocalizedData.VerboseConvertToWebBindingIgnoreBindingInformation `
                                -f $binding.Protocol)
                        }
                        else
                        {
                            $isJoinRequired = $false
                        }
                    }
                    else
                    {
                        $isJoinRequired = $true
                    }

                    # Construct the bindingInformation attribute
                    if ($isJoinRequired -eq $true)
                    {
                        $ipAddressString = Format-IPAddressString -InputString $binding.IPAddress `
                                                                   -ErrorAction Stop

                        if ([String]::IsNullOrEmpty($binding.Port))
                        {
                            switch ($binding.Protocol)
                            {
                                'http'  { $portNumberString = '80' }
                                'https' { $portNumberString = '443' }
                            }

                            Write-Verbose -Message `
                                ($LocalizedData.VerboseConvertToWebBindingDefaultPort `
                                -f $binding.Protocol, $portNumberString)
                        }
                        else
                        {
                            if (Test-PortNumber -InputString $binding.Port)
                            {
                                $portNumberString = $binding.Port
                            }
                            else
                            {
                                $errorMessage = $LocalizedData.ErrorWebBindingInvalidPort `
                                                -f $binding.Port
                                New-TerminatingError -ErrorId 'WebBindingInvalidPort' `
                                                     -ErrorMessage $errorMessage `
                                                     -ErrorCategory 'InvalidArgument'
                            }
                        }

                        $bindingInformation = $ipAddressString, `
                                              $portNumberString, `
                                              $binding.HostName -join ':'
                        $outputObject.Add('bindingInformation', [String]$bindingInformation)
                    }
                    else
                    {
                        $outputObject.Add('bindingInformation', [String]$binding.BindingInformation)
                    }
                }
                else
                {
                    if ([String]::IsNullOrEmpty($binding.BindingInformation))
                    {
                        $errorMessage = $LocalizedData.ErrorWebBindingMissingBindingInformation `
                                        -f $binding.Protocol
                        New-TerminatingError -ErrorId 'WebBindingMissingBindingInformation' `
                                             -ErrorMessage $errorMessage `
                                             -ErrorCategory 'InvalidArgument'
                    }
                    else
                    {
                        $outputObject.Add('bindingInformation', [String]$binding.BindingInformation)
                    }
                }

                # SSL-related properties
                if ($binding.Protocol -eq 'https')
                {
                    if ([String]::IsNullOrEmpty($binding.CertificateThumbprint))
                    {
                        $errorMessage = $LocalizedData.ErrorWebBindingMissingCertificateThumbprint `
                                        -f $binding.Protocol
                        New-TerminatingError -ErrorId 'WebBindingMissingCertificateThumbprint' `
                                             -ErrorMessage $errorMessage `
                                             -ErrorCategory 'InvalidArgument'
                    }

                    if ([String]::IsNullOrEmpty($binding.CertificateStoreName))
                    {
                        $certificateStoreName = 'MY'
                        Write-Verbose -Message `
                            ($LocalizedData.VerboseConvertToWebBindingDefaultCertificateStoreName `
                            -f $certificateStoreName)
                    }
                    else
                    {
                        $certificateStoreName = $binding.CertificateStoreName
                    }

                    # Remove the Left-to-Right Mark character
                    $certificateHash = $binding.CertificateThumbprint -replace '^\u200E'

                    $outputObject.Add('certificateHash',      [String]$certificateHash)
                    $outputObject.Add('certificateStoreName', [String]$certificateStoreName)

                    if ([Environment]::OSVersion.Version -ge '6.2')
                    {
                        $sslFlags = [Int64]$binding.SslFlags

                        if ($sslFlags -in @(1, 3) -and [String]::IsNullOrEmpty($binding.HostName))
                        {
                            $errorMessage = $LocalizedData.ErrorWebBindingMissingSniHostName
                            New-TerminatingError -ErrorId 'WebBindingMissingSniHostName' `
                                                 -ErrorMessage $errorMessage `
                                                 -ErrorCategory 'InvalidArgument'
                        }

                        $outputObject.Add('sslFlags', $sslFlags)
                    }
                }
                else
                {
                    # Ignore SSL-related properties for non-SSL bindings
                    $outputObject.Add('certificateHash',      [String]::Empty)
                    $outputObject.Add('certificateStoreName', [String]::Empty)

                    if ([Environment]::OSVersion.Version -ge '6.2')
                    {
                        $outputObject.Add('sslFlags', [Int64]0)
                    }
                }
            }
            else
            {
                <#
                        WebAdministration can throw the following exception if there are non-standard 
                        bindings (such as 'net.tcp'): 'The data is invalid. 
                        (Exception from HRESULT: 0x8007000D)'

                        Steps to reproduce:
                        1) Add 'net.tcp' binding
                        2) Execute {Get-Website | `
                                ForEach-Object {$_.bindings.Collection} | `
                                Select-Object *}

                        Workaround is to create a new custom object and use dot notation to
                        access binding properties.
                #>

                $outputObject.Add('bindingInformation',   [String]$binding.bindingInformation)
                $outputObject.Add('certificateHash',      [String]$binding.certificateHash)
                $outputObject.Add('certificateStoreName', [String]$binding.certificateStoreName)

                if ([Environment]::OSVersion.Version -ge '6.2')
                {
                    $outputObject.Add('sslFlags', [Int64]$binding.sslFlags)
                }
            }

            Write-Output -InputObject ([PSCustomObject]$outputObject)
        }
    }
}

<#
        .SYNOPSYS
        Formats the input IP address string for use in the bindingInformation attribute.
#>
function Format-IPAddressString
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [String]
        $InputString
    )

    if ([String]::IsNullOrEmpty($InputString) -or $InputString -eq '*')
    {
        $outputString = '*'
    }
    else
    {
        try
        {
            $ipAddress = [IPAddress]::Parse($InputString)

            switch ($ipAddress.AddressFamily)
            {
                'InterNetwork'
                {
                    $outputString = $ipAddress.IPAddressToString
                }
                'InterNetworkV6'
                {
                    $outputString = '[{0}]' -f $ipAddress.IPAddressToString
                }
            }
        }
        catch
        {
            $errorMessage = $LocalizedData.ErrorWebBindingInvalidIPAddress `
                            -f $InputString, $_.Exception.Message
            New-TerminatingError -ErrorId 'WebBindingInvalidIPAddress' `
                                 -ErrorMessage $errorMessage `
                                 -ErrorCategory 'InvalidArgument'
        }
    }

    return $outputString
}

<#
        .SYNOPSIS
        Helper function used to validate that the authenticationProperties for an Application.

        .PARAMETER Site
        Specifies the name of the Website.
#>
function Get-AuthenticationInfo
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$Site
    )

    $authenticationProperties = @{}
    foreach ($type in @('Anonymous', 'Basic', 'Digest', 'Windows'))
    {
        $authenticationProperties[$type] = [String](Test-AuthenticationEnabled -Site $Site `
                                                                               -Type $type)
    }

    return New-CimInstance `
            -ClassName MSFT_xWebAuthenticationInformation `
            -ClientOnly -Property $authenticationProperties
}

<#
        .SYNOPSIS
        Helper function used to build a default CimInstance for AuthenticationInformation
#>
function Get-DefaultAuthenticationInfo
{
    New-CimInstance -ClassName MSFT_xWebAuthenticationInformation `
        -ClientOnly `
        -Property @{ Anonymous = $false; Basic = $false; Digest = $false; Windows = $false }
}

<#
        .SYNOPSIS
        Helper function used to set authenticationProperties for an Application

        .PARAMETER Site
        Specifies the name of the Website.

        .PARAMETER Type
        Specifies the type of Authentication.
        Limited to the set: ('Anonymous','Basic','Digest','Windows')

        .PARAMETER Enabled
        Whether the Authentication is enabled or not.
#>
function Set-Authentication
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$Site,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Anonymous','Basic','Digest','Windows')]
        [String]$Type,

        [Boolean]$Enabled
    )

    Set-WebConfigurationProperty `
        -Filter /system.WebServer/security/authentication/${Type}Authentication `
        -Name enabled `
        -Value $Enabled `
        -Location $Site
}

<#
        .SYNOPSIS
        Helper function used to validate that the authenticationProperties for an Application.

        .PARAMETER Site
        Specifies the name of the Website.

        .PARAMETER AuthenticationInfo
        A CimInstance of what state the AuthenticationInfo should be.
#>
function Set-AuthenticationInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$Site,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]$AuthenticationInfo
    )

    foreach ($type in @('Anonymous', 'Basic', 'Digest', 'Windows'))
    {
        $enabled = ($AuthenticationInfo.CimInstanceProperties[$type].Value -eq $true)
        Set-Authentication -Site $Site -Type $type -Enabled $enabled
    }
}

<#
        .SYNOPSIS
        Helper function used to test the authenticationProperties state for an Application. 
        Will return that value which will either [String]True or [String]False

        .PARAMETER Site
        Specifies the name of the Website.

        .PARAMETER Type
        Specifies the type of Authentication.
        Limited to the set: ('Anonymous','Basic','Digest','Windows').
#>
function Test-AuthenticationEnabled
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$Site,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Anonymous','Basic','Digest','Windows')]
        [String]$Type
    )


    $prop = Get-WebConfigurationProperty `
        -Filter /system.WebServer/security/authentication/${Type}Authentication `
        -Name enabled `
        -Location $Site
        
    return $prop.Value
}

<#
        .SYNOPSIS
        Helper function used to test the authenticationProperties state for an Application. 
        Will return that result for use in Test-TargetResource. Uses Test-AuthenticationEnabled
        to determine this. First incorrect result will break this function out.

        .PARAMETER Site
        Specifies the name of the Website.

        .PARAMETER AuthenticationInfo
        A CimInstance of what state the AuthenticationInfo should be.
#>
function Test-AuthenticationInfo
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$Site,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]$AuthenticationInfo
    )

    $result = $true

    foreach ($type in @('Anonymous', 'Basic', 'Digest', 'Windows'))
    {
        $expected = $AuthenticationInfo.CimInstanceProperties[$type].Value
        $actual = Test-AuthenticationEnabled -Site $Site -Type $type
        if ($expected -ne $actual)
        {
            $result = $false
            break
        }
    }

    return $result
}

<#
        .SYNOPSIS
        Validates the desired binding information (i.e. no duplicate IP address, port, and 
        host name combinations).
#>
function Test-BindingInfo
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $BindingInfo
    )

    $isValid = $true

    try
    {
        # Normalize the input (helper functions will perform additional validations)
        $bindings = @(ConvertTo-WebBinding -InputObject $bindingInfo | ConvertTo-CimBinding)
        $standardBindings = @($bindings | `
                                Where-Object -FilterScript {$_.Protocol -in @('http', 'https')})
        $nonStandardBindings = @($bindings | `
                                 Where-Object -FilterScript {$_.Protocol -notin @('http', 'https')})

        if ($standardBindings.Count -ne 0)
        {
            # IP address, port, and host name combination must be unique
            if (($standardBindings | Group-Object -Property IPAddress, Port, HostName) | `
                                     Where-Object -FilterScript {$_.Count -ne 1})
            {
                $isValid = $false
                Write-Verbose -Message `
                    ($LocalizedData.VerboseTestBindingInfoSameIPAddressPortHostName)
            }

            # A single port cannot be simultaneously specified for bindings with different protocols
            foreach ($groupByPort in ($standardBindings | Group-Object -Property Port))
            {
                if (($groupByPort.Group | Group-Object -Property Protocol).Length -ne 1)
                {
                    $isValid = $false
                    Write-Verbose -Message `
                        ($LocalizedData.VerboseTestBindingInfoSamePortDifferentProtocol)
                    break
                }
            }
        }

        if ($nonStandardBindings.Count -ne 0)
        {
            if (($nonStandardBindings | `
                Group-Object -Property Protocol, BindingInformation) | `
                Where-Object -FilterScript {$_.Count -ne 1})
            {
                $isValid = $false
                Write-Verbose -Message `
                    ($LocalizedData.VerboseTestBindingInfoSameProtocolBindingInformation)
            }
        }
    }
    catch
    {
        $isValid = $false
        Write-Verbose -Message ($LocalizedData.VerboseTestBindingInfoInvalidCatch `
                                -f $_.Exception.Message)
    }

    return $isValid
}

<#
        .SYNOPSIS
        Validates that an input string represents a valid port number.
        The port number must be a positive integer between 1 and 65535.
#>
function Test-PortNumber
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [String]
        $InputString
    )

    try
    {
        $isValid = [UInt16]$InputString -ne 0
    }
    catch
    {
        $isValid = $false
    }

    return $isValid
}

<#
        .SYNOPSIS
        Helper function used to validate and compare website bindings of current to desired.
        Returns True if bindings do not need to be updated.
#>
function Test-WebsiteBinding
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $BindingInfo
    )

    $inDesiredState = $true

    # Ensure that desired binding information is valid (i.e. no duplicate IP address, port, and 
    # host name combinations).
    if (-not (Test-BindingInfo -BindingInfo $BindingInfo))
    {
        $errorMessage = $LocalizedData.ErrorWebsiteBindingInputInvalidation `
                        -f $Name
        New-TerminatingError -ErrorId 'WebsiteBindingInputInvalidation' `
                             -ErrorMessage $errorMessage `
                             -ErrorCategory 'InvalidResult'
    }

    try
    {
        $website = Get-Website | Where-Object -FilterScript {$_.Name -eq $Name}

        # Normalize binding objects to ensure they have the same representation
        $currentBindings = @(ConvertTo-WebBinding -InputObject $website.bindings.Collection `
                                                   -Verbose:$false)
        $desiredBindings = @(ConvertTo-WebBinding -InputObject $BindingInfo `
                                                  -Verbose:$false)

        $propertiesToCompare = 'protocol', `
                               'bindingInformation', `
                               'certificateHash', `
                               'certificateStoreName'

        # The sslFlags attribute was added in IIS 8.0.
        # This check is needed for backwards compatibility with Windows Server 2008 R2.
        if ([Environment]::OSVersion.Version -ge '6.2')
        {
            $propertiesToCompare += 'sslFlags'
        }

        if (Compare-Object -ReferenceObject $currentBindings `
                           -DifferenceObject $desiredBindings `
                           -Property $propertiesToCompare)
        {
            $inDesiredState = $false
        }
    }
    catch
    {
        $errorMessage = $LocalizedData.ErrorWebsiteCompareFailure `
                         -f $Name, $_.Exception.Message
        New-TerminatingError -ErrorId 'WebsiteCompareFailure' `
                             -ErrorMessage $errorMessage `
                             -ErrorCategory 'InvalidResult'
    }

    return $inDesiredState
}

<#
        .SYNOPSIS
        Helper function used to update default pages of website.
#>
function Update-DefaultPage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [String[]]
        $DefaultPage
    )

    $allDefaultPages = @(
        Get-WebConfiguration -Filter '//defaultDocument/files/*' `
                             -PSPath "IIS:\Sites\$Name" |
        ForEach-Object -Process { Write-Output -InputObject $_.value }
    )

    foreach ($page in $DefaultPage)
    {
        if ($allDefaultPages -inotcontains $page)
        {
            Add-WebConfiguration -Filter '//defaultDocument/files' `
                                 -PSPath "IIS:\Sites\$Name" `
                                 -Value @{ value = $page }
            Write-Verbose -Message ($LocalizedData.VerboseUpdateDefaultPageUpdated `
                                    -f $Name, $page)
        }
    }
}

<#
    .SYNOPSIS
        Updates website bindings.
#>
function Update-WebsiteBinding
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $BindingInfo
    )

    # Use Get-WebConfiguration instead of Get-Website to retrieve XPath of the target website.
    # XPath -Filter is case-sensitive. Use Where-Object to get the target website by name.
    $website = Get-WebConfiguration -Filter '/system.applicationHost/sites/site' |
        Where-Object -FilterScript {$_.Name -eq $Name}

    if (-not $website)
    {
        $errorMessage = $LocalizedData.ErrorWebsiteNotFound `
                        -f $Name
        New-TerminatingError -ErrorId 'WebsiteNotFound' `
                             -ErrorMessage $errorMessage `
                             -ErrorCategory 'InvalidResult'
    }

    ConvertTo-WebBinding -InputObject $BindingInfo -ErrorAction Stop |
    ForEach-Object -Begin {
        Clear-WebConfiguration -Filter "$($website.ItemXPath)/bindings" -Force -ErrorAction Stop
    } -Process {

        $properties = $_

        try
        {
            Add-WebConfiguration -Filter "$($website.ItemXPath)/bindings" -Value @{
                protocol = $properties.protocol
                bindingInformation = $properties.bindingInformation
            } -Force -ErrorAction Stop
        }
        catch
        {
            $errorMessage = $LocalizedData.ErrorWebsiteBindingUpdateFailure `
                            -f $Name, $_.Exception.Message
            New-TerminatingError -ErrorId 'WebsiteBindingUpdateFailure' `
                                 -ErrorMessage $errorMessage `
                                 -ErrorCategory 'InvalidResult'
        }

        if ($properties.protocol -eq 'https')
        {
            if ([Environment]::OSVersion.Version -ge '6.2')
            {
                try
                {
                    Set-WebConfigurationProperty `
                        -Filter "$($website.ItemXPath)/bindings/binding[last()]" `
                        -Name sslFlags `
                        -Value $properties.sslFlags `
                        -Force `
                        -ErrorAction Stop
                }
                catch
                {
                    $errorMessage = $LocalizedData.ErrorWebsiteBindingUpdateFailure `
                                    -f $Name, $_.Exception.Message
                    New-TerminatingError `
                        -ErrorId 'WebsiteBindingUpdateFailure' `
                        -ErrorMessage $errorMessage `
                        -ErrorCategory 'InvalidResult'
                }
            }

            try
            {
                $binding = Get-WebConfiguration `
                            -Filter "$($website.ItemXPath)/bindings/binding[last()]" `
                            -ErrorAction Stop
                $binding.AddSslCertificate($properties.certificateHash, `
                                           $properties.certificateStoreName)
            }
            catch
            {
                $errorMessage = $LocalizedData.ErrorWebBindingCertificate `
                                -f $properties.certificateHash, $_.Exception.Message
                New-TerminatingError `
                    -ErrorId 'WebBindingCertificate' `
                    -ErrorMessage $errorMessage `
                    -ErrorCategory 'InvalidOperation'
            }
        }
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource


