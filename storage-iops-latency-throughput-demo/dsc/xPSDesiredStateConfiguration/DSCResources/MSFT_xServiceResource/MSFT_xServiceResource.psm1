<#
    Error codes and their meanings for Invoke-CimMethod on a Win32_Service can be found here:
    https://msdn.microsoft.com/en-us/library/aa384901(v=vs.85).aspx
#>

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonResourceHelper for Get-LocalizedData, Test-IsNanoServer, New-InvalidArgumentException, New-InvalidOperationException
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonResourceHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonResourceHelper.psm1'
Import-Module -Name $script:commonResourceHelperFilePath

# Localized messages for verbose and error statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xServiceResource'

<#
    .SYNOPSIS
        Retrieves the current status of the service resource with the given name.

    .PARAMETER Name
        The name of the service to retrieve the status of.

        This may be different from the service's display name.
        To retrieve a list of all services with their names and current states, use the Get-Service
        cmdlet.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    $service = Get-Service -Name $Name -ErrorAction 'SilentlyContinue'

    if ($null -ne $service)
    {
        Write-Verbose -Message ($script:localizedData.ServiceExists -f $Name)

        $serviceCimInstance = Get-ServiceCimInstance -ServiceName $Name

        $dependencies = @()

        foreach ($serviceDependedOn in $service.ServicesDependedOn)
        {
            $dependencies += $serviceDependedOn.Name.ToString()
        }

        $startupType = ConvertTo-StartupTypeString -StartMode $serviceCimInstance.StartMode

        $builtInAccount = switch ($serviceCimInstance.StartName)
        {
            'NT Authority\NetworkService' { 'NetworkService'; break }
            'NT Authority\LocalService' { 'LocalService'; break }
            default { $serviceCimInstance.StartName }
        }
        
        $serviceResource = @{
            Name            = $Name
            Ensure          = 'Present'
            Path            = $serviceCimInstance.PathName
            StartupType     = $startupType
            BuiltInAccount  = $builtInAccount
            State           = $service.Status.ToString()
            DisplayName     = $service.DisplayName
            Description     = $serviceCimInstance.Description
            DesktopInteract = $serviceCimInstance.DesktopInteract
            Dependencies    = $dependencies 
        }
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ServiceDoesNotExist -f $Name)
        $serviceResource = @{
            Name   = $Name
            Ensure = 'Absent'
        }
    }

    return $serviceResource
}

<#
    .SYNOPSIS
        Creates, modifies, or deletes the service with the given name.

    .PARAMETER Name
        The name of the service to create, modify, or delete.

        This may be different from the service's display name.
        To retrieve a list of all services with their names and current states, use the Get-Service
        cmdlet.

    .PARAMETER Ensure
        Specifies whether the service should exist or not.
        
        Set this property to Present to create or modify a service.
        Set this property to Absent to delete a service.

        The default value is Present.

    .PARAMETER Path
        The path to the executable the service should run.
        Required when creating a service.

        The user account specified by BuiltInAccount or Credential must have access to this path in
        order to start the service.

    .PARAMETER StartupType
        The startup type the service should have.

    .PARAMETER BuiltInAccount
        The built-in account the service should start under.

        Cannot be specified at the same time as Credential.

        The user account specified by this property must have access to the service executable path
        defined by Path in order to start the service.

    .PARAMETER DesktopInteract
        Indicates whether or not the service should be able to communicate with a window on the
        desktop.

        Must be false for services not running as LocalSystem.
        The default value is false.

    .PARAMETER State
        The state the service should be in.
        The default value is Running.

        To disregard the state that the service is in, specify this property as Ignore.

    .PARAMETER DisplayName
        The display name the service should have.

    .PARAMETER Description
        The description the service should have.

    .PARAMETER Dependencies
        An array of the names of the dependencies the service should have.

    .PARAMETER StartupTimeout
        The time to wait for the service to start in milliseconds.
        The default value is 30000 (30 seconds).

    .PARAMETER TerminateTimeout
        The time to wait for the service to stop in milliseconds.
        The default value is 30000 (30 seconds).

    .PARAMETER Credential
        The credential of the user account the service should start under.

        Cannot be specified at the same time as BuiltInAccount.
        The user specified by this credential will automatically be granted the Log on as a Service
        right.

        The user account specified by this property must have access to the service executable path
        defined by Path in order to start the service.

    .NOTES
        SupportsShouldProcess is enabled because Invoke-CimMethod calls ShouldProcess.
        Here are the paths through which Set-TargetResource calls Invoke-CimMethod:

        Set-TargetResource --> Set-ServicePath --> Invoke-CimMethod
                           --> Set-ServiceProperty --> Set-ServiceDependencies --> Invoke-CimMethod
                                                   --> Set-ServiceAccountProperty --> Invoke-CimMethod
                                                   --> Set-ServiceStartupType --> Invoke-CimMethod
#>
function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType,

        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService')]
        [String]
        $BuiltInAccount,

        [ValidateSet('Running', 'Stopped', 'Ignore')]
        [String]
        $State = 'Running',

        [Boolean]
        $DesktopInteract = $false,

        [ValidateNotNullOrEmpty()]
        [String]
        $DisplayName,

        [ValidateNotNullOrEmpty()]
        [String]
        $Description,

        [String[]]
        [AllowEmptyCollection()]
        $Dependencies,

        [UInt32]
        $StartupTimeout = 30000,

        [UInt32]
        $TerminateTimeout = 30000,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    if ($PSBoundParameters.ContainsKey('StartupType'))
    {
        Assert-NoStartupTypeStateConflict -ServiceName $Name -StartupType $StartupType -State $State
    }

    if ($PSBoundParameters.ContainsKey('BuiltInAccount') -and $PSBoundParameters.ContainsKey('Credential'))
    {
        $errorMessage = $script:localizedData.BuiltInAccountAndCredentialSpecified -f $Name
        New-InvalidArgumentException -ArgumentName 'BuiltInAccount & Credential' -Message $errorMessage
    }

    $service = Get-Service -Name $Name -ErrorAction 'SilentlyContinue'

    if ($Ensure -eq 'Absent')
    {
        if ($null -eq $service)
        {
            Write-Verbose -Message $script:localizedData.ServiceAlreadyAbsent
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.RemovingService -f $Name)

            Stop-ServiceWithTimeout -ServiceName $Name -TerminateTimeout $TerminateTimeout
            Remove-ServiceWithTimeout -Name $Name -TerminateTimeout $TerminateTimeout
        }
    }
    else
    {
        $serviceRestartNeeded = $false

        # Create new service or update the service path if needed
        if ($null -eq $service)
        {
            if ($PSBoundParameters.ContainsKey('Path'))
            {
                Write-Verbose -Message ($script:localizedData.CreatingService -f $Name, $Path)
                $null = New-Service -Name $Name -BinaryPathName $Path
            }
            else
            {
                $errorMessage = $script:localizedData.ServiceDoesNotExistPathMissingError -f $Name
                New-InvalidArgumentException -ArgumentName 'Path' -Message $errorMessage
            }
        }
        else
        {
            if ($PSBoundParameters.ContainsKey('Path'))
            {
                $serviceRestartNeeded = Set-ServicePath -ServiceName $Name -Path $Path
            }
        }

        # Update the properties of the service if needed
        $setServicePropertyParameters = @{}

        $servicePropertyParameterNames = @( 'StartupType', 'BuiltInAccount', 'Credential', 'DesktopInteract', 'DisplayName', 'Description', 'Dependencies' )

        foreach ($servicePropertyParameterName in $servicePropertyParameterNames)
        {
            if ($PSBoundParameters.ContainsKey($servicePropertyParameterName))
            {
                $setServicePropertyParameters[$servicePropertyParameterName] = $PSBoundParameters[$servicePropertyParameterName]
            }
        }
        
        if ($setServicePropertyParameters.Count -gt 0)
        {
            Write-Verbose -Message ($script:localizedData.EditingServiceProperties -f $Name)
            Set-ServiceProperty -ServiceName $Name @setServicePropertyParameters
        }

        # Update service state if needed
        if ($State -eq 'Stopped')
        {
            Stop-ServiceWithTimeout -ServiceName $Name -TerminateTimeout $TerminateTimeout
        }
        elseif ($State -eq 'Running')
        {
            if ($serviceRestartNeeded)
            {
                Write-Verbose -Message ($script:localizedData.RestartingService -f $Name)
                Stop-ServiceWithTimeout -ServiceName $Name -TerminateTimeout $TerminateTimeout
            }

            Start-ServiceWithTimeout -ServiceName $Name -StartupTimeout $StartupTimeout
        }
    }
}

<#
    .SYNOPSIS
        Tests if the service with the given name has the specified property values.

    .PARAMETER Name
        The name of the service to test.
        
        This may be different from the service's display name.
        To retrieve a list of all services with their names and current states, use the Get-Service
        cmdlet.

    .PARAMETER Ensure
        Specifies whether the service should exist or not.
        
        Set this property to Present to test if a service exists.
        Set this property to Absent to test if a service does not exist.

        The default value is Present.

    .PARAMETER Path
        The path to the executable the service should be running.

    .PARAMETER StartupType
        The startup type the service should have.

    .PARAMETER BuiltInAccount
        The account the service should be starting under.

        Cannot be specified at the same time as Credential.

    .PARAMETER DesktopInteract
        Indicates whether or not the service should be able to communicate with a window on the
        desktop.

        Should be false for services not running as LocalSystem.
        The default value is false.

    .PARAMETER State
        The state the service should be in.
        The default value is Running.

        To disregard the state that the service is in, specify this property as Ignore.

    .PARAMETER DisplayName
        The display name the service should have.

    .PARAMETER Description
        The description the service should have.

    .PARAMETER Dependencies
        An array of the names of the dependencies the service should have.

    .PARAMETER StartupTimeout
        Not used in Test-TargetResource.

    .PARAMETER TerminateTimeout
        Not used in Test-TargetResource.

    .PARAMETER Credential
        The credential the service should be running under.

        Cannot be specified at the same time as BuiltInAccount.
#>
function Test-TargetResource
{
    [OutputType([Boolean])]
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

        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType,

        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService')]
        [String]
        $BuiltInAccount,

        [Boolean]
        $DesktopInteract = $false,

        [ValidateSet('Running', 'Stopped', 'Ignore')]
        [String]
        $State = 'Running',

        [ValidateNotNull()]
        [String]
        $DisplayName,

        [String]
        [AllowEmptyString()]
        $Description,

        [String[]]
        [AllowEmptyCollection()]
        $Dependencies,

        [UInt32]
        $StartupTimeout = 30000,

        [UInt32]
        $TerminateTimeout = 30000,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    if ($PSBoundParameters.ContainsKey('StartupType'))
    {
        Assert-NoStartupTypeStateConflict -ServiceName $Name -StartupType $StartupType -State $State
    }

    if ($PSBoundParameters.ContainsKey('BuiltInAccount') -and $PSBoundParameters.ContainsKey('Credential'))
    {
        $errorMessage = $script:localizedData.BuiltInAccountAndCredentialSpecified -f $Name
        New-InvalidArgumentException -ArgumentName 'BuiltInAccount & Credential' -Message $errorMessage
    }

    $serviceResource = Get-TargetResource -Name $Name

    if ($serviceResource.Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($script:localizedData.ServiceDoesNotExist -f $Name)
        return ($Ensure -eq 'Absent')
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ServiceExists -f $Name)

        if ($Ensure -eq 'Absent')
        {
            return $false
        }

        # Check the service path
        if ($PSBoundParameters.ContainsKey('Path'))
        {
            $pathsMatch = Test-PathsMatch -ExpectedPath $Path -ActualPath $serviceResource.Path

            if (-not $pathsMatch)
            {
                Write-Verbose -Message ($script:localizedData.ServicePathDoesNotMatch -f $Name, $Path, $serviceResource.Path)
                return $false
            }
        }

        # Check the service display name
        if ($PSBoundParameters.ContainsKey('DisplayName') -and $serviceResource.DisplayName -ine $DisplayName)
        {
            Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'DisplayName', $Name, $DisplayName, $serviceResource.DisplayName)
            return $false
        }

        # Check the service description
        if ($PSBoundParameters.ContainsKey('Description') -and $serviceResource.Description -ine $Description)
        {
            Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'Description', $Name, $Description, $serviceResource.Description)
            return $false
        }

        # Check the service dependencies
        if ($PSBoundParameters.ContainsKey('Dependencies'))
        {
            $serviceDependenciesDoNotMatch = $false

            if ($null -eq $serviceResource.Dependencies -xor $null -eq $Dependencies)
            {
                $serviceDependenciesDoNotMatch = $true
            }
            elseif ($null -ne $serviceResource.Dependencies -and $null -ne $Dependencies)
            {
                $mismatchedDependencies = Compare-Object -ReferenceObject $serviceResource.Dependencies -DifferenceObject $Dependencies
                $serviceDependenciesDoNotMatch = $null -ne $mismatchedDependencies
            }

            if ($serviceDependenciesDoNotMatch)
            {
                $expectedDependenciesString = $Dependencies -join ','
                $actualDependenciesString = $serviceResource.Dependencies -join ','

                Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'Dependencies', $Name, $expectedDependenciesString, $actualDependenciesString)
                return $false
            }
        }
            
        # Check the service desktop interation setting
        if ($PSBoundParameters.ContainsKey('DesktopInteract') -and $serviceResource.DesktopInteract -ine $DesktopInteract)
        {
            Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'DesktopInteract', $Name, $DesktopInteract, $serviceResource.DesktopInteract)
            return $false
        }

        # Check the service account properties
        if ($PSBoundParameters.ContainsKey('BuiltInAccount') -and $serviceResource.BuiltInAccount -ine $BuiltInAccount)
        {
            Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'BuiltInAccount', $Name, $BuiltInAccount, $serviceResource.BuiltInAccount)
            return $false
        }
        elseif ($PSBoundParameters.ContainsKey('Credential'))
        {
            $expectedStartName = ConvertTo-StartName -Username $Credential.UserName

            if ($serviceResource.BuiltInAccount -ine $expectedStartName)
            {
                Write-Verbose -Message ($script:localizedData.ServiceCredentialDoesNotMatch -f $Name, $Credential.UserName, $serviceResource.BuiltInAccount)
                return $false
            }
        }

        # Check the service startup type
        if ($PSBoundParameters.ContainsKey('StartupType') -and $serviceResource.StartupType -ine $StartupType)
        {
            Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'StartupType', $Name, $StartupType, $serviceResource.StartupType)
            return $false
        }

        # Check the service state
        if ($State -ne 'Ignore' -and $serviceResource.State -ine $State)
        {
            Write-Verbose -Message ($script:localizedData.ServicePropertyDoesNotMatch -f 'State', $Name, $State, $serviceResource.State)
            return $false
        }
    }

    return $true
}

<#
    .SYNOPSIS
        Retrieves the CIM instance of the service with the given name.

    .PARAMETER ServiceName
        The name of the service to get the CIM instance of.
#>
function Get-ServiceCimInstance
{
    [OutputType([CimInstance])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $ServiceName
    )

    return Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$ServiceName'"
}

<#
    .SYNOPSIS
        Converts the StartMode value returned in a CIM instance of a service to the format
        expected by this resource.

    .PARAMETER StartMode
        The StartMode value to convert.
#>
function ConvertTo-StartupTypeString
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Auto', 'Manual', 'Disabled')]
        [String]
        $StartMode
    )

    if ($StartMode -eq 'Auto')
    {
        return 'Automatic'
    }

    return $StartMode
}

<#
    .SYNOPSIS
        Throws an invalid argument error if the given service startup type conflicts with the given
        service state.

    .PARAMETER ServiceName
        The name of the service for the error message.

    .PARAMETER StartupType
        The service startup type to check.

    .PARAMETER State
        The service state to check.
#>
function Assert-NoStartupTypeStateConflict 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Running', 'Stopped', 'Ignore')]
        [String]
        $State
    )

    if ($State -eq 'Stopped')
    {
        if ($StartupType -eq 'Automatic')
        {
            # Cannot stop a service and set it to start automatically at the same time
            $errorMessage = $script:localizedData.StartupTypeStateConflict -f $ServiceName, $StartupType, $State
            New-InvalidArgumentException -ArgumentName 'StartupType and State' -Message $errorMessage
        }
    }
    elseif ($State -eq 'Running')
    {
        if ($StartupType -eq 'Disabled')
        {
            # Cannot start a service and disable it at the same time
            $errorMessage = $script:localizedData.StartupTypeStateConflict -f $ServiceName, $StartupType, $State
            New-InvalidArgumentException -ArgumentName 'StartupType and State' -Message $errorMessage
        }
    }
}

<#
    .SYNOPSIS
        Tests if the two given paths match.

    .PARAMETER ExpectedPath
        The expected path to test against.

    .PARAMETER ActualPath
        The actual path to test.
#>
function Test-PathsMatch
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ActualPath
    )

    return (0 -eq [String]::Compare($ExpectedPath, $ActualPath, [System.Globalization.CultureInfo]::CurrentUICulture))
}

<#
    .SYNOPSIS
        Converts the given username to the string version of it that would be expected in a
        service's StartName property.

    .PARAMETER Username
        The username to convert.
#>
function ConvertTo-StartName
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username
    )

    $startName = $Username

    if ($Username -ieq 'NetworkService' -or $Username -ieq 'LocalService')
    {
        $startName = "NT Authority\$Username"
    }
    elseif (-not $Username.Contains('\') -and -not $Username.Contains('@'))
    {
        $startName = ".\$Username"
    }
    elseif ($Username.StartsWith("$env:computerName\"))
    {
        $startName = $Username.Replace($env:computerName, '.')
    }

    return $startName
}

<#
    .SYNOPSIS
        Sets the executable path of the service with the given name.
        Returns a boolean specifying whether a restart is needed or not.

    .PARAMETER ServiceName
        The name of the service to set the path of.

    .PARAMETER Path
        The path to set for the service.

    .NOTES
        SupportsShouldProcess is enabled because Invoke-CimMethod calls ShouldProcess.
        This function calls Invoke-CimMethod directly.
#>
function Set-ServicePath
{
    [OutputType([Boolean])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    $serviceCimInstance = Get-ServiceCimInstance -ServiceName $ServiceName

    $pathsMatch = Test-PathsMatch -ExpectedPath $Path -ActualPath $serviceCimInstance.PathName

    if ($pathsMatch)
    {
        Write-Verbose -Message ($script:localizedData.ServicePathMatches -f $ServiceName)
        return $false
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ServicePathDoesNotMatch -f $ServiceName)

        $changeServiceArguments = @{
            PathName = $Path
        }

        $changeServiceResult = Invoke-CimMethod `
            -InputObject $serviceCimInstance `
            -MethodName 'Change' `
            -Arguments $changeServiceArguments

        if ($changeServiceResult.ReturnValue -ne 0)
        {
            $serviceChangePropertyString = $changeServiceArguments.Keys -join ', '
            $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $ServiceName, $serviceChangePropertyString, $changeServiceResult.ReturnValue
            New-InvalidArgumentException -ArgumentName 'Path' -Message $errorMessage   
        }

        return $true
    }
}

<#
    .SYNOPSIS
        Sets the dependencies of the service with the given name.

    .PARAMETER ServiceName
        The name of the service to set the dependencies of.

    .PARAMETER Dependencies
        The names of the dependencies to set for the service.

    .NOTES
        SupportsShouldProcess is enabled because Invoke-CimMethod calls ShouldProcess.
        This function calls Invoke-CimMethod directly.
#>
function Set-ServiceDependencies
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [String[]]
        [AllowEmptyCollection()]
        $Dependencies
    )

    $service = Get-Service -Name $ServiceName -ErrorAction 'SilentlyContinue'

    $serviceDependenciesMatch = $true

    $noActualServiceDependencies = $null -eq $service.ServicesDependedOn -or 0 -eq $service.ServicesDependedOn.Count
    $noExpectedServiceDependencies = $null -eq $Dependencies -or 0 -eq $Dependencies.Count

    if ($noActualServiceDependencies -xor $noExpectedServiceDependencies)
    {
        $serviceDependenciesMatch = $false
    }
    elseif (-not $noActualServiceDependencies -and -not $noExpectedServiceDependencies)
    {
        $mismatchedDependencies = Compare-Object -ReferenceObject $service.ServicesDependedOn.Name -DifferenceObject $Dependencies
        $serviceDependenciesMatch = $null -eq $mismatchedDependencies
    }

    if ($serviceDependenciesMatch)
    {
        Write-Verbose -Message ($script:localizedData.ServiceDepdenciesMatch -f $ServiceName)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ServiceDepdenciesDoNotMatch -f $ServiceName)

        $serviceCimInstance = Get-ServiceCimInstance -ServiceName $ServiceName

        $changeServiceArguments = @{
            ServiceDependencies = $Dependencies
        }

        $changeServiceResult = Invoke-CimMethod `
            -InputObject $serviceCimInstance `
            -MethodName 'Change' `
            -Arguments $changeServiceArguments

        if ($changeServiceResult.ReturnValue -ne 0)
        {
            $serviceChangePropertyString = $changeServiceArguments.Keys -join ', '
            $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $ServiceName, $serviceChangePropertyString, $changeServiceResult.ReturnValue
            New-InvalidArgumentException -Message $errorMessage -ArgumentName 'Dependencies'
        }
    }
}

<#
    .SYNOPSIS
        Grants the 'Log on as a service' right to the user with the given username.

    .PARAMETER Username
        The username of the user to grant 'Log on as a service' right to
#>
function Grant-LogOnAsServiceRight
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username
    )

    $logOnAsServiceText = @"
        namespace LogOnAsServiceHelper
        {
            using Microsoft.Win32.SafeHandles;
            using System;
            using System.Runtime.ConstrainedExecution;
            using System.Runtime.InteropServices;
            using System.Security;

            public class NativeMethods
            {
                #region constants
                // from ntlsa.h
                private const int POLICY_LOOKUP_NAMES = 0x00000800;
                private const int POLICY_CREATE_ACCOUNT = 0x00000010;
                private const uint ACCOUNT_ADJUST_SYSTEM_ACCESS = 0x00000008;
                private const uint ACCOUNT_VIEW = 0x00000001;
                private const uint SECURITY_ACCESS_SERVICE_LOGON = 0x00000010;

                // from LsaUtils.h
                private const uint STATUS_OBJECT_NAME_NOT_FOUND = 0xC0000034;

                // from lmcons.h
                private const int UNLEN = 256;
                private const int DNLEN = 15;

                // Extra characteres for "\","@" etc.
                private const int EXTRA_LENGTH = 3;
                #endregion constants

                #region interop structures
                /// <summary>
                /// Used to open a policy, but not containing anything meaqningful
                /// </summary>
                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_OBJECT_ATTRIBUTES
                {
                    public UInt32 Length;
                    public IntPtr RootDirectory;
                    public IntPtr ObjectName;
                    public UInt32 Attributes;
                    public IntPtr SecurityDescriptor;
                    public IntPtr SecurityQualityOfService;

                    public void Initialize()
                    {
                        this.Length = 0;
                        this.RootDirectory = IntPtr.Zero;
                        this.ObjectName = IntPtr.Zero;
                        this.Attributes = 0;
                        this.SecurityDescriptor = IntPtr.Zero;
                        this.SecurityQualityOfService = IntPtr.Zero;
                    }
                }

                /// <summary>
                /// LSA string
                /// </summary>
                [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
                private struct LSA_UNICODE_STRING
                {
                    internal ushort Length;
                    internal ushort MaximumLength;
                    [MarshalAs(UnmanagedType.LPWStr)]
                    internal string Buffer;

                    internal void Set(string src)
                    {
                        this.Buffer = src;
                        this.Length = (ushort)(src.Length * sizeof(char));
                        this.MaximumLength = (ushort)(this.Length + sizeof(char));
                    }
                }

                /// <summary>
                /// Structure used as the last parameter for LSALookupNames
                /// </summary>
                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_TRANSLATED_SID2
                {
                    public uint Use;
                    public IntPtr SID;
                    public int DomainIndex;
                    public uint Flags;
                };
                #endregion interop structures

                #region safe handles
                /// <summary>
                /// Handle for LSA objects including Policy and Account
                /// </summary>
                private class LsaSafeHandle : SafeHandleZeroOrMinusOneIsInvalid
                {
                    [DllImport("advapi32.dll")]
                    private static extern uint LsaClose(IntPtr ObjectHandle);

                    /// <summary>
                    /// Prevents a default instance of the LsaPolicySafeHAndle class from being created.
                    /// </summary>
                    private LsaSafeHandle(): base(true)
                    {
                    }

                    /// <summary>
                    /// Calls NativeMethods.CloseHandle(handle)
                    /// </summary>
                    /// <returns>the return of NativeMethods.CloseHandle(handle)</returns>
                    [ReliabilityContract(Consistency.WillNotCorruptState, Cer.MayFail)]
                    protected override bool ReleaseHandle()
                    {
                        long returnValue = LsaSafeHandle.LsaClose(this.handle);
                        return returnValue != 0;

                    }
                }

                /// <summary>
                /// Handle for IntPtrs returned from Lsa calls that have to be freed with
                /// LsaFreeMemory
                /// </summary>
                private class SafeLsaMemoryHandle : SafeHandleZeroOrMinusOneIsInvalid
                {
                    [DllImport("advapi32")]
                    internal static extern int LsaFreeMemory(IntPtr Buffer);

                    private SafeLsaMemoryHandle() : base(true) { }

                    private SafeLsaMemoryHandle(IntPtr handle)
                        : base(true)
                    {
                        SetHandle(handle);
                    }

                    private static SafeLsaMemoryHandle InvalidHandle
                    {
                        get { return new SafeLsaMemoryHandle(IntPtr.Zero); }
                    }

                    override protected bool ReleaseHandle()
                    {
                        return SafeLsaMemoryHandle.LsaFreeMemory(handle) == 0;
                    }

                    internal IntPtr Memory
                    {
                        get
                        {
                            return this.handle;
                        }
                    }
                }
                #endregion safe handles

                #region interop function declarations
                /// <summary>
                /// Opens LSA Policy
                /// </summary>
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaOpenPolicy(
                    IntPtr SystemName,
                    ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
                    uint DesiredAccess,
                    out LsaSafeHandle PolicyHandle
                );

                /// <summary>
                /// Convert the name into a SID which is used in remaining calls
                /// </summary>
                [DllImport("advapi32", CharSet = CharSet.Unicode, SetLastError = true), SuppressUnmanagedCodeSecurityAttribute]
                private static extern uint LsaLookupNames2(
                    LsaSafeHandle PolicyHandle,
                    uint Flags,
                    uint Count,
                    LSA_UNICODE_STRING[] Names,
                    out SafeLsaMemoryHandle ReferencedDomains,
                    out SafeLsaMemoryHandle Sids
                );

                /// <summary>
                /// Opens the LSA account corresponding to the user's SID
                /// </summary>
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaOpenAccount(
                    LsaSafeHandle PolicyHandle,
                    IntPtr Sid,
                    uint Access,
                    out LsaSafeHandle AccountHandle);

                /// <summary>
                /// Creates an LSA account corresponding to the user's SID
                /// </summary>
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaCreateAccount(
                    LsaSafeHandle PolicyHandle,
                    IntPtr Sid,
                    uint Access,
                    out LsaSafeHandle AccountHandle);

                /// <summary>
                /// Gets the LSA Account access
                /// </summary>
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaGetSystemAccessAccount(
                    LsaSafeHandle AccountHandle,
                    out uint SystemAccess);

                /// <summary>
                /// Sets the LSA Account access
                /// </summary>
                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaSetSystemAccessAccount(
                    LsaSafeHandle AccountHandle,
                    uint SystemAccess);
                #endregion interop function declarations

                /// <summary>
                /// Sets the Log On As A Service Policy for <paramref name="userName"/>, if not already set.
                /// </summary>
                /// <param name="userName">the user name we want to allow logging on as a service</param>
                /// <exception cref="ArgumentNullException">If the <paramref name="userName"/> is null or empty.</exception>
                /// <exception cref="InvalidOperationException">In the following cases:
                ///     Failure opening the LSA Policy.
                ///     The <paramref name="userName"/> is too large.
                ///     Failure looking up the user name.
                ///     Failure opening LSA account (other than account not found).
                ///     Failure creating LSA account.
                ///     Failure getting LSA account policy access.
                ///     Failure setting LSA account policy access.
                /// </exception>
                public static void SetLogOnAsServicePolicy(string userName)
                {
                    if (String.IsNullOrEmpty(userName))
                    {
                        throw new ArgumentNullException("userName");
                    }

                    LSA_OBJECT_ATTRIBUTES objectAttributes = new LSA_OBJECT_ATTRIBUTES();
                    objectAttributes.Initialize();

                    // All handles are delcared in advance so they can be closed on finally
                    LsaSafeHandle policyHandle = null;
                    SafeLsaMemoryHandle referencedDomains = null;
                    SafeLsaMemoryHandle sids = null;
                    LsaSafeHandle accountHandle = null;

                    try
                    {
                        uint status = LsaOpenPolicy(
                            IntPtr.Zero,
                            ref objectAttributes,
                            POLICY_LOOKUP_NAMES | POLICY_CREATE_ACCOUNT,
                            out policyHandle);

                        if (status != 0)
                        {
                            throw new InvalidOperationException("CannotOpenPolicyErrorMessage");
                        }

                        // Unicode strings have a maximum length of 32KB. We don't want to create
                        // LSA strings with more than that. User lengths are much smaller so this check
                        // ensures userName's length is useful
                        if (userName.Length > UNLEN + DNLEN + EXTRA_LENGTH)
                        {
                            throw new InvalidOperationException("UserNameTooLongErrorMessage");
                        }

                        LSA_UNICODE_STRING lsaUserName = new LSA_UNICODE_STRING();
                        lsaUserName.Set(userName);

                        LSA_UNICODE_STRING[] names = new LSA_UNICODE_STRING[1];
                        names[0].Set(userName);

                        status = LsaLookupNames2(
                            policyHandle,
                            0,
                            1,
                            new LSA_UNICODE_STRING[] { lsaUserName },
                            out referencedDomains,
                            out sids);

                        if (status != 0)
                        {
                            throw new InvalidOperationException("CannotLookupNamesErrorMessage");
                        }

                        LSA_TRANSLATED_SID2 sid = (LSA_TRANSLATED_SID2)Marshal.PtrToStructure(sids.Memory, typeof(LSA_TRANSLATED_SID2));

                        status = LsaOpenAccount(policyHandle,
                                            sid.SID,
                                            ACCOUNT_VIEW | ACCOUNT_ADJUST_SYSTEM_ACCESS,
                                            out accountHandle);

                        uint currentAccess = 0;

                        if (status == 0)
                        {
                            status = LsaGetSystemAccessAccount(accountHandle, out currentAccess);

                            if (status != 0)
                            {
                                throw new InvalidOperationException("CannotGetAccountAccessErrorMessage");
                            }

                        }
                        else if (status == STATUS_OBJECT_NAME_NOT_FOUND)
                        {
                            status = LsaCreateAccount(
                                policyHandle,
                                sid.SID,
                                ACCOUNT_ADJUST_SYSTEM_ACCESS,
                                out accountHandle);

                            if (status != 0)
                            {
                                throw new InvalidOperationException("CannotCreateAccountAccessErrorMessage");
                            }
                        }
                        else
                        {
                            throw new InvalidOperationException("CannotOpenAccountErrorMessage");
                        }

                        if ((currentAccess & SECURITY_ACCESS_SERVICE_LOGON) == 0)
                        {
                            status = LsaSetSystemAccessAccount(
                                accountHandle,
                                currentAccess | SECURITY_ACCESS_SERVICE_LOGON);
                            if (status != 0)
                            {
                                throw new InvalidOperationException("CannotSetAccountAccessErrorMessage");
                            }
                        }
                    }
                    finally
                    {
                        if (policyHandle != null) { policyHandle.Close(); }
                        if (referencedDomains != null) { referencedDomains.Close(); }
                        if (sids != null) { sids.Close(); }
                        if (accountHandle != null) { accountHandle.Close(); }
                    }
                }
            }
        }
"@

    try
    {
        $null = [LogOnAsServiceHelper.NativeMethods]
    }
    catch
    {
        $logOnAsServiceText = $logOnAsServiceText.Replace('CannotOpenPolicyErrorMessage', `
            $script:localizedData.CannotOpenPolicyErrorMessage)
        $logOnAsServiceText = $logOnAsServiceText.Replace('UserNameTooLongErrorMessage', `
            $script:localizedData.UserNameTooLongErrorMessage)
        $logOnAsServiceText = $logOnAsServiceText.Replace('CannotLookupNamesErrorMessage', `
            $script:localizedData.CannotLookupNamesErrorMessage)
        $logOnAsServiceText = $logOnAsServiceText.Replace('CannotOpenAccountErrorMessage', `
            $script:localizedData.CannotOpenAccountErrorMessage)
        $logOnAsServiceText = $logOnAsServiceText.Replace('CannotCreateAccountAccessErrorMessage', `
            $script:localizedData.CannotCreateAccountAccessErrorMessage)
        $logOnAsServiceText = $logOnAsServiceText.Replace('CannotGetAccountAccessErrorMessage', `
            $script:localizedData.CannotGetAccountAccessErrorMessage)
        $logOnAsServiceText = $logOnAsServiceText.Replace('CannotSetAccountAccessErrorMessage', `
            $script:localizedData.CannotSetAccountAccessErrorMessage)
        $null = Add-Type $logOnAsServiceText -PassThru
    }

    if ($Username.StartsWith('.\'))
    {
        $Username = $Username.Substring(2)
    }

    try
    {
        [LogOnAsServiceHelper.NativeMethods]::SetLogOnAsServicePolicy($Username)
    }
    catch
    {
        $errorMessage = $script:localizedData.ErrorSettingLogOnAsServiceRightsForUser -f $Username, $_.Exception.Message
        New-InvalidOperationException -Message $errorMessage
    }
}

<#
    .SYNOPSIS
        Sets the service properties involving the account the service is running under.
        (StartName, StartPassword, DesktopInteract)

    .PARAMETER ServiceName
        The name of the service to change the start name of.

    .PARAMETER BuiltInAccount
        The name of the built-in account to run the service under.
        This value will overwrite the Credential value if Credential is also declared.

    .PARAMETER Credential
        The user credential to run the service under.
        BuiltInAccount will overwrite this value if BuiltInAccount is also declared.

    .PARAMETER DesktopInteract
        Indicates whether or not the service should be able to communicate with a window on the
        desktop.

        Must be false for services not running as LocalSystem.

    .NOTES
        DesktopInteract is included here because it can only be enabled when the service startup
        account name is LocalSystem. In order not to run into a conflict where one property has
        been updated before the other, both are updated here at the same time.

        SupportsShouldProcess is enabled because Invoke-CimMethod calls ShouldProcess.
        This function calls Invoke-CimMethod directly.
#>
function Set-ServiceAccountProperty
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter()]
        [String]
        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService')]
        $BuiltInAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [Boolean]
        $DesktopInteract
    )

    $serviceCimInstance = Get-ServiceCimInstance -ServiceName $ServiceName

    $changeServiceArguments = @{}

    if ($PSBoundParameters.ContainsKey('BuiltInAccount'))
    {
        $startName = ConvertTo-StartName -Username $BuiltInAccount

        if ($serviceCimInstance.StartName -ine $startName)
        {
            $changeServiceArguments['StartName'] = $startName
            $changeServiceArguments['StartPassword'] = ''
        }
    }
    elseif ($PSBoundParameters.ContainsKey('Credential'))
    {
        $startName = ConvertTo-StartName -Username $Credential.UserName

        if ($serviceCimInstance.StartName -ine $startName)
        {
            Grant-LogOnAsServiceRight -Username $startName

            $changeServiceArguments['StartName'] = $startName
            $changeServiceArguments['StartPassword'] = $Credential.GetNetworkCredential().Password
        }
    }

    if ($PSBoundParameters.ContainsKey('DesktopInteract'))
    {
        if ($serviceCimInstance.DesktopInteract -ne $DesktopInteract)
        {
            $changeServiceArguments['DesktopInteract'] = $DesktopInteract
        }
    }

    if ($changeServiceArguments.Count -gt 0)
    {
        $changeServiceResult = Invoke-CimMethod -InputObject $ServiceCimInstance -MethodName 'Change' -Arguments $changeServiceArguments

        if ($changeServiceResult.ReturnValue -ne 0)
        {
            $serviceChangePropertyString = $changeServiceArguments.Keys -join ', '
            $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $ServiceName, $serviceChangePropertyString, $changeServiceResult.ReturnValue
            New-InvalidArgumentException -ArgumentName 'BuiltInAccount, Credential, or DesktopInteract' -Message $errorMessage
        }
    }
}

<#
    .SYNOPSIS
        Sets the startup type of the service with the given name.

    .PARAMETER ServiceName
        The name of the service to set the startup type of.

    .PARAMETER StartupType
        The startup type value to set for the service.

    .NOTES
        SupportsShouldProcess is enabled because Invoke-CimMethod calls ShouldProcess.
        This function calls Invoke-CimMethod directly.
#>
function Set-ServiceStartupType
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType
    )

    $serviceCimInstance = Get-ServiceCimInstance -ServiceName $ServiceName
    $serviceStartupType = ConvertTo-StartupTypeString -StartMode $serviceCimInstance.StartMode

    if ($serviceStartupType -ieq $StartupType)
    {
        Write-Verbose -Message ($script:localizedData.ServiceStartupTypeMatches -f $ServiceName)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ServiceStartupTypeDoesNotMatch -f $ServiceName)

        $changeServiceArguments = @{
            StartMode = $StartupType
        }

        $changeResult = Invoke-CimMethod `
            -InputObject $serviceCimInstance `
            -MethodName 'Change' `
            -Arguments $changeServiceArguments

        if ($changeResult.ReturnValue -ne 0)
        {
            $serviceChangePropertyString = $changeServiceArguments.Keys -join ', '
            $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $ServiceName, $serviceChangePropertyString, $changeResult.ReturnValue
            New-InvalidArgumentException -ArgumentName 'StartupType' -Message $errorMessage
        }
    }
}

<#
    .SYNOPSIS
        Sets the service with the given name to have the specified properties.

    .PARAMETER Name
        The name of the service to set the properties of.

    .PARAMETER DisplayName
        The display name the service should have.

    .PARAMETER Description
        The description the service should have.

    .PARAMETER Dependencies
        The names of the dependencies the service should have.

    .PARAMETER BuiltInAccount
        The built-in account the service should start under.

        Cannot be specified at the same time as Credential.

    .PARAMETER Credential
        The credential of the user account the service should start under.

        Cannot be specified at the same time as BuiltInAccount.
        The user specified by this credential will automatically be granted the Log on as a Service
        right.

    .PARAMETER DesktopInteract
        Indicates whether or not the service should be able to communicate with a window on the desktop.

    .PARAMETER StartupType
        The startup type the service should have.

    .NOTES
        SupportsShouldProcess is enabled because Invoke-CimMethod calls ShouldProcess.
        Here are the paths through which Set-ServiceProperty calls Invoke-CimMethod:

        Set-ServiceProperty --> Set-ServiceDependencies --> Invoke-CimMethod
                            --> Set-ServieceAccountProperty --> Invoke-CimMethod
                            --> Set-ServiceStartupType --> Invoke-CimMethod
#>
function Set-ServiceProperty
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter()]
        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType,

        [Parameter()]
        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService')]
        [String]
        $BuiltInAccount,

        [Parameter()]
        [Boolean]
        $DesktopInteract,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Description,

        [Parameter()]
        [String[]]
        [AllowEmptyCollection()]
        $Dependencies,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    # Update display name and/or description if needed
    $serviceCimInstance = Get-ServiceCimInstance -ServiceName $ServiceName
    
    $setServiceParameters = @{}

    if ($PSBoundParameters.ContainsKey('DisplayName') -and $serviceCimInstance.DisplayName -ine $DisplayName)
    {
        $setServiceParameters['DisplayName'] = $DisplayName
    }

    if ($PSBoundParameters.ContainsKey('Description')  -and $serviceCimInstance.Description -ine $Description)
    {
        $setServiceParameters['Description'] = $Description
    }

    if ($setServiceParameters.Count -gt 0)
    {
        $null = Set-Service -Name $ServiceName @setServiceParameters
    }

    # Update service dependencies if needed
    if ($PSBoundParameters.ContainsKey('Dependencies'))
    {
        Set-ServiceDependencies -ServiceName $ServiceName -Dependencies $Dependencies
    }

    # Update service account properties if needed
    $setServiceAccountPropertyParameters = @{}

    if ($PSBoundParameters.ContainsKey('BuiltInAccount'))
    {
        $setServiceAccountPropertyParameters['BuiltInAccount'] = $BuiltInAccount
    }
    elseif ($PSBoundParameters.ContainsKey('Credential'))
    {
        $setServiceAccountPropertyParameters['Credential'] = $Credential
    }

    if ($PSBoundParameters.ContainsKey('DesktopInteract'))
    {
        $setServiceAccountPropertyParameters['DesktopInteract'] = $DesktopInteract
    }

    if ($setServiceAccountPropertyParameters.Count -gt 0)
    {
        Set-ServiceAccountProperty -ServiceName $ServiceName @setServiceAccountPropertyParameters
    }

    # Update startup type
    if ($PSBoundParameters.ContainsKey('StartupType'))
    {
        Set-ServiceStartupType -ServiceName $ServiceName -StartupType $StartupType
    }
}

<#
    .SYNOPSIS
        Deletes the service with the given name.

        This is a wrapper function for unit testing.

    .PARAMETER Name
        The name of the service to delete.
#>
function Remove-Service
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    & 'sc.exe' 'delete' $Name
}

<#
    .SYNOPSIS
        Deletes the service with the given name and waits for the service to be deleted.

    .PARAMETER Name
        The name of the service to delete.

    .PARAMETER TerminateTimeout
        The time to wait for the service to be deleted in milliseconds.
#>
function Remove-ServiceWithTimeout
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [UInt32]
        $TerminateTimeout
    )

    Remove-Service -Name $Name

    $serviceDeleted = $false
    $start = [DateTime]::Now

    while (-not $serviceDeleted -and ([DateTime]::Now - $start).TotalMilliseconds -lt $TerminateTimeout)
    {
        $service = Get-Service -Name $Name -ErrorAction 'SilentlyContinue'

        if ($null -eq $service)
        {
            $serviceDeleted = $true
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.WaitingForServiceDeletion -f $Name)
            Start-Sleep -Seconds 1
        }
    }

    if ($serviceDeleted)
    {
        Write-Verbose -Message ($script:localizedData.ServiceDeletionSucceeded -f $Name)
    }
    else
    {
        New-InvalidOperationException -Message ($script:localizedData.ServiceDeletionFailed -f $Name)
    }
}

<#
    .SYNOPSIS
        Waits for the service with the given name to reach the given state within the given time
        span.
        
        This is a wrapper function for unit testing.

    .PARAMETER ServiceName
        The name of the service that should be in the given state.

    .PARAMETER State
        The state the service should be in.

    .PARAMETER WaitTimeSpan
        A time span of how long to wait for the service to reach the desired state.
#>
function Wait-ServiceStateWithTimeout
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [System.ServiceProcess.ServiceControllerStatus]
        $State,

        [Parameter(Mandatory = $true)]
        [TimeSpan]
        $WaitTimeSpan
    )

    $service = Get-Service -Name $ServiceName -ErrorAction 'SilentlyContinue'
    $Service.WaitForStatus($State, $WaitTimeSpan)
}

<#
    .SYNOPSIS
        Starts the service with the given name, if it is not already running, and waits for the
        service to be running.

    .PARAMETER ServiceName
        The name of the service to start.

    .PARAMETER StartupTimeout
        The time to wait for the service to be running in milliseconds.
#>
function Start-ServiceWithTimeout
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [UInt32]
        $StartupTimeout
    )

    Start-Service -Name $ServiceName
    $waitTimeSpan = New-Object -TypeName 'TimeSpan' -ArgumentList (0, 0, 0, 0, $StartupTimeout)
    Wait-ServiceStateWithTimeout -ServiceName $ServiceName -State 'Running' -WaitTimeSpan $waitTimeSpan
}

<#
    .SYNOPSIS
        Stops the service with the given name, if it is not already stopped, and waits for the
        service to be stopped.

    .PARAMETER ServiceName
        The name of the service to stop.

    .PARAMETER TerminateTimeout
        The time to wait for the service to be stopped in milliseconds.
#>
function Stop-ServiceWithTimeout
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [UInt32]
        $TerminateTimeout
    )

    Stop-Service -Name $ServiceName
    $waitTimeSpan = New-Object -TypeName 'TimeSpan' -ArgumentList (0, 0, 0, 0, $TerminateTimeout)
    Wait-ServiceStateWithTimeout -ServiceName $ServiceName -State 'Stopped' -WaitTimeSpan $waitTimeSpan
}
