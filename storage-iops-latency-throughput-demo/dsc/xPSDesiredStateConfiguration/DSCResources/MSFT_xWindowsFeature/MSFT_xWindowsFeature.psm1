# Global needed to indicate if a restart is required
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonResourceHelper.psm1')

# Localized messages for verbose and error messages in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xWindowsFeature'

<#
    .SYNOPSIS
        Retrieves the status of the role or feature with the given name on the target machine.

    .PARAMETER Name
        The name of the role or feature to retrieve

    .PARAMETER Credential
        The credential (if required) to retrieve the role or feature.
        Optional.

    .NOTES
        If the specified role or feature does not contain any subfeatures then
        IncludeAllSubFeature will be set to $false. If the specified feature contains one
        or more subfeatures then IncludeAllSubFeature will be set to $true only if all the
        subfeatures are installed. Otherwise, IncludeAllSubFeature will be set to $false. 
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
       $Name,
       
       [ValidateNotNullOrEmpty()]
       [System.Management.Automation.PSCredential]
       [System.Management.Automation.Credential()]
       $Credential
    )
 
    Write-Verbose -Message ($script:localizedData.GetTargetResourceStartMessage -f $Name)
    
    Import-ServerManager 
    
    Write-Verbose -Message ($script:localizedData.QueryFeature -f $Name)
    
    $isWinServer2008R2SP1 = Test-IsWinServer2008R2SP1
    if ($isWinServer2008R2SP1 -and $PSBoundParameters.ContainsKey('Credential'))
    {
        $feature = Invoke-Command -ScriptBlock { Get-WindowsFeature -Name $Name } `
                                  -ComputerName . `
                                  -Credential $Credential `
    }
    else
    {
        $feature = Get-WindowsFeature @PSBoundParameters
    }
    
    Assert-SingleFeatureExists -Feature $feature -Name $Name
    
    $includeAllSubFeature = $true
    
    if ($feature.SubFeatures.Count -eq 0)
    {
        $includeAllSubFeature = $false
    }
    else
    {
        foreach ($currentSubFeatureName in $feature.SubFeatures)
        {

            $getWindowsFeatureParameters = @{
                Name = $currentSubFeatureName
            }

            if ($PSBoundParameters.ContainsKey('Credential'))
            {
               $getWindowsFeatureParameters['Credential'] = $Credential 
            }

            if ($isWinServer2008R2SP1 -and $PSBoundParameters.ContainsKey('Credential'))
            {
                <#
                    Calling Get-WindowsFeature through Invoke-Command to start a new process with
                    the given credential since Get-WindowsFeature doesn't support the Credential
                    attribute on this server.
                #>
                $subFeature = Invoke-Command -ScriptBlock { Get-WindowsFeature -Name $currentSubFeatureName } `
                                             -ComputerName . `
                                             -Credential $Credential `
            }
            else
            {
                $subFeature = Get-WindowsFeature @getWindowsFeatureParameters
            }
    
            Assert-SingleFeatureExists -Feature $subFeature -Name $currentSubFeatureName
    
            if (-not $subFeature.Installed)
            {
                $includeAllSubFeature = $false
                break
            }
        }
    }

    if ($feature.Installed)
    {
        $ensureResult = 'Present'
    }
    else
    {
        $ensureResult = 'Absent'
    }

    Write-Verbose -Message ($script:localizedData.GetTargetResourceEndMessage -f $Name)
    
    # Add all feature properties to the hash table
    return @{
        Name = $Name
        DisplayName = $feature.DisplayName
        Ensure = $ensureResult
        IncludeAllSubFeature = $includeAllSubFeature
    }
}

<#
    .SYNOPSIS
        Installs or uninstalls the role or feature with the given name on the target machine
        with the option of installing or uninstalling all subfeatures as well. 

    .PARAMETER Name
        The name of the role or feature to install or uninstall.

    .PARAMETER Ensure
        Specifies whether the role or feature should be installed ('Present')
        or uninstalled ('Absent').
        By default this is set to Present.

    .PARAMETER IncludeAllSubFeature
        Specifies whether or not all subfeatures should be installed or uninstalled with
        the specified role or feature. Default is false.
        If this property is true and Ensure is set to Present, all subfeatures will be installed.
        If this property is false and Ensure is set to Present, subfeatures will not be installed or uninstalled.
        If Ensure is set to Absent, all subfeatures will be uninstalled.

    .PARAMETER Credential
        The credential (if required) to install or uninstall the role or feature.
        Optional.

    .PARAMETER LogPath
        The custom path to the log file to log this operation.
        If not passed in, the default log path will be used (%windir%\logs\ServerManager.log).
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
       [Parameter(Mandatory = $true)]
       [ValidateNotNullOrEmpty()]
       [String]
       $Name,

       [ValidateSet('Present', 'Absent')]
       [String]
       $Ensure = 'Present',

       [Boolean]
       $IncludeAllSubFeature = $false,

       [ValidateNotNullOrEmpty()]
       [System.Management.Automation.PSCredential]
       [System.Management.Automation.Credential()]
       $Credential,

       [ValidateNotNullOrEmpty()]
       [String]
       $LogPath
    )

    Write-Verbose -Message ($script:localizedData.SetTargetResourceStartMessage -f $Name)

    Import-ServerManager

    $isWinServer2008R2SP1 = Test-IsWinServer2008R2SP1

    if ($Ensure -eq 'Present')
    {
        $addWindowsFeatureParameters = @{
            Name = $Name
            IncludeAllSubFeature = $IncludeAllSubFeature
        }

        if ($PSBoundParameters.ContainsKey('LogPath'))
        {
           $addWindowsFeatureParameters['LogPath'] = $LogPath 
        }

        Write-Verbose -Message ($script:localizedData.InstallFeature -f $Name)

        if ($isWinServer2008R2SP1 -and $PSBoundParameters.ContainsKey('Credential'))
        {
            <#
                Calling Add-WindowsFeature through Invoke-Command to start a new process with
                the given credential since Add-WindowsFeature doesn't support the Credential
                attribute on this server.
            #>
            $feature = Invoke-Command -ScriptBlock { Add-WindowsFeature @addWindowsFeatureParameters } `
                                      -ComputerName . `
                                      -Credential $Credential
        }
        else
        {
            if ($PSBoundParameters.ContainsKey('Credential'))
            {
               $addWindowsFeatureParameters['Credential'] = $Credential 
            }

            $feature = Add-WindowsFeature @addWindowsFeatureParameters
        }

        if ($null -ne $feature -and $feature.Success)
        {
            Write-Verbose -Message ($script:localizedData.InstallSuccess -f $Name)

            # Check if reboot is required, if so notify the Local Configuration Manager.
            if ($feature.RestartNeeded -eq 'Yes')
            {
                Write-Verbose -Message $script:localizedData.RestartNeeded
                $global:DSCMachineStatus = 1
            }
        }
        else
        {
            New-InvalidOperationException -Message ($script:localizedData.FeatureInstallationFailureError -f $Name)
        }
    }
    # Ensure = 'Absent'
    else
    {
        $removeWindowsFeatureParameters = @{
            Name = $Name
        }

        if ($PSBoundParameters.ContainsKey('LogPath'))
        {
           $removeWindowsFeatureParameters['LogPath'] = $LogPath 
        }

        Write-Verbose -Message ($script:localizedData.UninstallFeature -f $Name)

        if ($isWinServer2008R2SP1 -and $PSBoundParameters.ContainsKey('Credential'))
        {
            <#
                Calling Remove-WindowsFeature through Invoke-Command to start a new process with
                the given credential since Remove-WindowsFeature doesn't support the Credential
                attribute on this server.
            #>
            $feature = Invoke-Command -ScriptBlock { Remove-WindowsFeature @removeWindowsFeatureParameters } `
                                      -ComputerName . `
                                      -Credential $Credential
        }
        else
        {
            if ($PSBoundParameters.ContainsKey('Credential'))
            {
               $addWindowsFeatureParameters['Credential'] = $Credential 
            }

            $feature = Remove-WindowsFeature @removeWindowsFeatureParameters
        }

        if ($null -ne $feature -and $feature.Success)
        {
            Write-Verbose ($script:localizedData.UninstallSuccess -f $Name)

            # Check if reboot is required, if so notify the Local Configuration Manager.
            if ($feature.RestartNeeded -eq 'Yes')
            {
                Write-Verbose -Message $script:localizedData.RestartNeeded
                $global:DSCMachineStatus = 1
            }
        }
        else
        {
            New-InvalidOperationException -Message ($script:localizedData.FeatureUninstallationFailureError -f $Name)
        }
    }

    Write-Verbose -Message ($script:localizedData.SetTargetResourceEndMessage -f $Name)
}

<#
    .SYNOPSIS
        Tests if the role or feature with the given name is in the desired state. 

    .PARAMETER Name
        The name of the role or feature to test the state of.

    .PARAMETER Ensure
        Specifies whether the role or feature should be installed ('Present')
        or uninstalled ('Absent').
        By default this is set to Present.

    .PARAMETER IncludeAllSubFeature
        Specifies whether the subfeatures of the indicated role or feature should also be checked
        to ensure they are in the desired state. If Ensure is set to 'Present' and this is set to
        $true then each subfeature is checked to ensure it is installed as well. If Ensure is set to
        Absent and this is set to $true, then each subfeature is checked to ensure it is uninstalled.
        As of now, this test can't be used to check if a feature is Installed but all of its
        subfeatures are uninstalled.
        By default this is set to $false.

    .PARAMETER Credential
        The Credential (if required) to test the status of the role or feature.
        Optional.

    .PARAMETER LogPath
        The path to the log file to log this operation.
        Not used in Test-TargetResource.

#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Boolean]
        $IncludeAllSubFeature = $false,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath

    )

    Write-Verbose -Message ($script:localizedData.TestTargetResourceStartMessage -f $Name)
    
    Import-ServerManager

    $testTargetResourceResult = $false

    $getWindowsFeatureParameters = @{
        Name = $Name
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
       $getWindowsFeatureParameters['Credential'] = $Credential 
    }
    
    Write-Verbose -Message ($script:localizedData.QueryFeature -f $Name)
    
    $isWinServer2008R2SP1 = Test-IsWinServer2008R2SP1
    if ($isWinServer2008R2SP1 -and $PSBoundParameters.ContainsKey('Credential'))
    {
        <#
            Calling Get-WindowsFeature through Invoke-Command to start a new process with
            the given credential since Get-WindowsFeature doesn't support the Credential
            attribute on this server.
        #>
        $feature = Invoke-Command -ScriptBlock { Get-WindowsFeature -Name $Name } `
                                  -ComputerName . `
                                  -Credential $Credential
    }
    else
    {
        $feature = Get-WindowsFeature @getWindowsFeatureParameters
    }
    
    Assert-SingleFeatureExists -Feature $feature -Name $Name
    
    # Check if the feature is in the requested Ensure state.
    if (($Ensure -eq 'Present' -and $feature.Installed -eq $true) -or `
        ($Ensure -eq 'Absent' -and $feature.Installed -eq $false))
    {
        $testTargetResourceResult = $true
    
        if ($IncludeAllSubFeature)
        {
            # Check if each subfeature is in the requested state.
            foreach ($currentSubFeatureName in $feature.SubFeatures)
            {
                $getWindowsFeatureParameters['Name'] = $currentSubFeatureName
    
                if ($isWinServer2008R2SP1 -and $PSBoundParameters.ContainsKey('Credential'))
                {
                    <#
                        Calling Get-WindowsFeature through Invoke-Command to start a new process with
                        the given credential since Get-WindowsFeature doesn't support the Credential
                        attribute on this server.
                    #>
                    $subFeature = Invoke-Command -ScriptBlock { Get-WindowsFeature -Name $currentSubFeatureName } `
                                                 -ComputerName . `
                                                 -Credential $Credential
                }
                else
                {
                    $subFeature = Get-WindowsFeature @getWindowsFeatureParameters
                }
                
                Assert-SingleFeatureExists -Feature $subFeature -Name $currentSubFeatureName
    
                if (-not $subFeature.Installed -and $Ensure -eq 'Present')
                {
                    $testTargetResourceResult = $false
                    break
                }
    
                if ($subFeature.Installed -and $Ensure -eq 'Absent')
                {
                    $testTargetResourceResult = $false
                    break
                }
            }
        }
    }
    else
    {
        # Ensure is not in the correct state
        $testTargetResourceResult = $false
    }
    
    Write-Verbose -Message ($script:localizedData.TestTargetResourceEndMessage -f $Name)
    
    return $testTargetResourceResult
}


<#
    .SYNOPSIS
        Asserts that a single instance of the given role or feature exists.

    .PARAMETER Feature
        The role or feature object to check.

    .PARAMETER Name
        The name of the role or feature to include in any error messages that are thrown.
        (Not used to assert validity of the feature).    
#>
function Assert-SingleFeatureExists
{
    [CmdletBinding()]
    param
    (
        [PSObject]
        $Feature,

        [String]
        $Name
    )

    if ($null -eq $Feature)
    {
        New-InvalidOperationException -Message ($script:localizedData.FeatureNotFoundError -f $Name)
    }

    if ($Feature.Count -gt 1)
    {
        New-InvalidOperationException -Message ($script:localizedData.MultipleFeatureInstancesError -f $Name)
    }
}

<#
    .SYNOPSIS
        Sets up the ServerManager module on the target node.
        Throws an error if not on a machine running Windows Server.
#>
function Import-ServerManager
{
    param 
    ()

    <#
        Enable ServerManager-PSH-Cmdlets feature if OS is WS2008R2 Core.
        Datacenter = 12, Standard = 13, Enterprise = 14
    #>
    $serverCoreOSCodes = @( 12, 13, 14 )

    $operatingSystem = Get-CimInstance -Class 'Win32_OperatingSystem'

    # Check if this operating system needs an update to the ServerManager cmdlets
    if ($operatingSystem.Version.StartsWith('6.1.') -and `
        $serverCoreOSCodes -contains $operatingSystem.OperatingSystemSKU)
    {
        Write-Verbose -Message $script:localizedData.EnableServerManagerPSHCmdletsFeature

        <#
            ServerManager-PSH-Cmdlets has a depndency on Powershell 2 update: MicrosoftWindowsPowerShell,
            so enabling the MicrosoftWindowsPowerShell update.
        #>
        $null = Dism\online\enable-feature\FeatureName:MicrosoftWindowsPowerShell
        $null = Dism\online\enable-feature\FeatureName:ServerManager-PSH-Cmdlets
    }

    try
    {
        Import-Module -Name 'ServerManager' -ErrorAction Stop
    }
    catch [System.Management.Automation.RuntimeException] {
        if ($_.Exception.Message -like "*Some or all identity references could not be translated*")
        {
            Write-Verbose $_.Exception.Message
        }
        else
        {
            Write-Verbose -Message $script:localizedData.ServerManagerModuleNotFoundMessage
            New-InvalidOperationException -Message $script:localizedData.SkuNotSupported
        }
    }
    catch
    {
        Write-Verbose -Message $script:localizedData.ServerManagerModuleNotFoundMessage
        New-InvalidOperationException -Message $script:localizedData.SkuNotSupported
    }
}

<#
    .SYNOPSIS
        Tests if the machine is a Windows Server 2008 R2 SP1 machine.
    
    .NOTES
        Since Assert-PrequisitesValid ensures that ServerManager is available on the machine,
        this function only checks the OS version.
#>
function Test-IsWinServer2008R2SP1
{
    param
    ()

    return ([Environment]::OSVersion.Version.ToString().Contains('6.1.'))
}

Export-ModuleMember -Function *-TargetResource
