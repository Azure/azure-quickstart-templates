# PSSA global rule suppression is allowed here because $global:DSCMachineStatus must be set
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'CommonResourceHelper.psm1')
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xWindowsOptionalFeature'

<#
    .SYNOPSIS
        Retrieves the state of a Windows optional feature resource.

    .PARAMETER Name
        The name of the Windows optional feature resource to retrieve.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name
    )

    Write-Verbose -Message ($LocalizedData.GetTargetResourceStartMessage -f $Name)

    Assert-ResourcePrerequisitesValid

    $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -FeatureName $Name -Online
    
    <#
        $windowsOptionalFeatureProperties and this section of code are needed because an error will be thrown if a property
        is not found in WMF 4 instead of returning null.
    #> 
    $windowsOptionalFeatureProperties = @{}
    $propertiesNeeded = @( 'LogPath', 'State', 'CustomProperties', 'FeatureName', 'LogLevel', 'Description', 'DisplayName' )

    foreach ($property in $propertiesNeeded)
    {
        try
        {
            $windowsOptionalFeatureProperties[$property] = $windowsOptionalFeature.$property
        }
        catch
        {
            $windowsOptionalFeatureProperties[$property] = $null
        }
    }

    $windowsOptionalFeatureResource = @{
        LogPath = $windowsOptionalFeatureProperties.LogPath
        Ensure = Convert-FeatureStateToEnsure -State $windowsOptionalFeatureProperties.State
        CustomProperties =
            Convert-CustomPropertyArrayToStringArray -CustomProperties $windowsOptionalFeatureProperties.CustomProperties
        Name = $windowsOptionalFeatureProperties.FeatureName
        LogLevel = $windowsOptionalFeatureProperties.LogLevel
        Description = $windowsOptionalFeatureProperties.Description
        DisplayName = $windowsOptionalFeatureProperties.DisplayName
    }

    Write-Verbose -Message ($script:localizedData.GetTargetResourceEndMessage -f $Name)

    return $windowsOptionalFeatureResource
}

<#
    .SYNOPSIS
        Enables or disables a Windows optional feature

    .PARAMETER Name
        The name of the feature to enable or disable.

    .PARAMETER Ensure
        Specifies whether the feature should be enabled or disabled.
        To enable the feature, set this property to Present.
        To disable the feature, set the property to Absent.

    .PARAMETER RemoveFilesOnDisable
        Specifies that all files associated with the feature should be removed if the feature is
        being disabled.

    .PARAMETER NoWindowsUpdateCheck
        Specifies whether or not DISM contacts Windows Update (WU) when searching for the source 
        files to enable the feature.
        If $true, DISM will not contact WU.

    .PARAMETER LogPath
        The path to the log file to log this operation.
        There is no default value, but if not set, the log will appear at
        %WINDIR%\Logs\Dism\dism.log.

    .PARAMETER LogLevel
        The maximum output level to show in the log.
        Accepted values are: "ErrorsOnly" (only errors are logged), "ErrorsAndWarning" (errors and
        warnings are logged), and "ErrorsAndWarningAndInformation" (errors, warnings, and debug
        information are logged).
#>
function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Boolean]
        $RemoveFilesOnDisable,

        [Boolean]
        $NoWindowsUpdateCheck,

        [String]
        $LogPath,

        [ValidateSet('ErrorsOnly', 'ErrorsAndWarning', 'ErrorsAndWarningAndInformation')]
        [String]
        $LogLevel = 'ErrorsAndWarningAndInformation'
    )

    Write-Verbose -Message ($script:localizedData.SetTargetResourceStartMessage -f $Name)

    Assert-ResourcePrerequisitesValid

    $dismLogLevel = switch ($LogLevel)
    {
        'ErrorsOnly' {  'Errors'; break }
        'ErrorsAndWarning' { 'Warnings'; break }
        'ErrorsAndWarningAndInformation' { 'WarningsInfo'; break }
    }

    # Construct splatting hashtable for DISM cmdlets
    $dismCmdletParameters = @{
        FeatureName = $Name
        Online = $true
        LogLevel = $dismLogLevel
        NoRestart = $true
    }

    if ($PSBoundParameters.ContainsKey('LogPath'))
    {
        $dismCmdletParameters['LogPath'] = $LogPath
    }

    if ($Ensure -eq 'Present')
    {
        if ($PSCmdlet.ShouldProcess($Name, $script:localizedData.ShouldProcessEnableFeature))
        {
            if ($NoWindowsUpdateCheck)
            {
                $dismCmdletParameters['LimitAccess'] =  $true
            }

            $windowsOptionalFeature = Dism\Enable-WindowsOptionalFeature @dismCmdletParameters
        }

        Write-Verbose -Message ($script:localizedData.FeatureInstalled -f $Name)
    }
    else
    {
        if ($PSCmdlet.ShouldProcess($Name, $script:localizedData.ShouldProcessDisableFeature))
        {
            if ($RemoveFilesOnDisable)
            {
                $dismCmdletParameters['Remove'] = $true
            }

            $windowsOptionalFeature = Dism\Disable-WindowsOptionalFeature @dismCmdletParameters
        }

        Write-Verbose -Message ($script:localizedData.FeatureUninstalled -f $Name)
    }

    <#
        $restartNeeded and this section of code are needed because an error will be thrown if the
        RestartNeeded property is not found in WMF 4.
    #> 
    try
    {
        $restartNeeded = $windowsOptionalFeature.RestartNeeded
    }
    catch
    {
        $restartNeeded = $false
    }

    # Indicate we need a restart if needed
    if ($restartNeeded)
    {
        Write-Verbose -Message $script:localizedData.RestartNeeded
        $global:DSCMachineStatus = 1
    }

    Write-Verbose -Message ($script:localizedData.SetTargetResourceEndMessage -f $Name)
}

<#
    .SYNOPSIS
        Tests if a Windows optional feature is in the specified state.

    .PARAMETER Name
        The name of the feature to test the state of.

    .PARAMETER Ensure
        Specifies whether the feature should be enabled or disabled.
        To test if the feature is enabled, set this property to Present.
        To test if the feature is disabled, set this property to Absent.

    .PARAMETER RemoveFilesOnDisable
        Not used in Test-TargetResource.

    .PARAMETER NoWindowsUpdateCheck
        Not used in Test-TargetResource.

    .PARAMETER LogPath
        Not used in Test-TargetResource.

    .PARAMETER LogLevel
        Not used in Test-TargetResource.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Boolean]
        $RemoveFilesOnDisable,

        [Boolean]
        $NoWindowsUpdateCheck,

        [String]
        $LogPath,

        [ValidateSet('ErrorsOnly', 'ErrorsAndWarning', 'ErrorsAndWarningAndInformation')]
        [String]
        $LogLevel = 'ErrorsAndWarningAndInformation'
    )

    Write-Verbose -Message ($script:localizedData.TestTargetResourceStartMessage -f $Name)

    Assert-ResourcePrerequisitesValid

    $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -FeatureName $Name -Online
    
    $featureIsInDesiredState = $false

    if ($null -eq $windowsOptionalFeature -or $windowsOptionalFeature.State -eq 'Disabled')
    {
        $featureIsInDesiredState = $Ensure -eq 'Absent'
    }
    elseif ($windowsOptionalFeature.State -eq 'Enabled')
    {
        $featureIsInDesiredState = $Ensure -eq 'Present'
    }
    
    Write-Verbose -Message ($script:localizedData.TestTargetResourceEndMessage -f $Name)
    
    return $featureIsInDesiredState
}

<#
    .SYNOPSIS
        Converts a list of CustomProperty objects into an array of Strings.

    .PARAMETER CustomProperties
        The list of CustomProperty objects to be converted.
        Each CustomProperty object should have Name, Value, and Path properties.
#>
function Convert-CustomPropertyArrayToStringArray
{
    [CmdletBinding()]
    [OutputType([String[]])]
    param
    (
        [PSCustomObject[]]
        $CustomProperties
    )

    $propertiesAsStrings = [String[]] @()

    foreach ($customProperty in $CustomProperties)
    {
        if ($null -ne $customProperty)
        {
            $propertiesAsStrings += "Name = $($customProperty.Name), Value = $($customProperty.Value), Path = $($customProperty.Path)"
        }
    }

    return $propertiesAsStrings
}

<#
    .SYNOPSIS
        Converts the string state returned by the DISM Get-WindowsOptionalFeature cmdlet to Present or Absent.

    .PARAMETER State
        The state to be converted to either Present or Absent.
        Should be either Enabled or Disabled.
#>
function Convert-FeatureStateToEnsure
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $State
    )

    if ($State -eq 'Disabled')
    {
        return 'Absent'
    }
    elseif ($State -eq 'Enabled')
    {
        return 'Present'
    }
    else
    {
        Write-Warning ($script:localizedData.CouldNotConvertFeatureState -f $State)
        return $State
    }
}

<#
    .SYNOPSIS
        Throws errors if the prerequisites for using WindowsOptionalFeature are not met on the
        target machine.

        Current prerequisites are:
            - Must be running either a Windows client, at least Windows Server 2012, or Nano Server
            - Must be running as an administrator
            - The DISM PowerShell module must be available for import
#>
function Assert-ResourcePrerequisitesValid
{
    [CmdletBinding()]
    param ()

    Write-Verbose -Message $script:localizedData.ValidatingPrerequisites

    # Check that we're running on Server 2012 (or later) or on a client SKU
    $operatingSystem = Get-CimInstance -ClassName 'Win32_OperatingSystem'

    if (($operatingSystem.ProductType -eq 2) -and ([System.Int32] $operatingSystem.BuildNumber -lt 9600))
    {
        New-InvalidOperationException -Message $script:localizedData.NotSupportedSku
    }

    # Check that we are running as an administrator
    $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList @( $windowsIdentity )
    
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    if (-not $windowsPrincipal.IsInRole($adminRole))
    {
        New-InvalidOperationException -Message $script:localizedData.ElevationRequired
    }

    # Check that Dism PowerShell module is available
    Import-Module -Name 'Dism' -ErrorVariable 'errorsFromDismImport' -ErrorAction 'SilentlyContinue' -Force

    if ($errorsFromDismImport.Count -gt 0)
    {
        New-InvalidOperationException -Message $script:localizedData.DismNotAvailable
    }
}

Export-ModuleMember -Function *-TargetResource
