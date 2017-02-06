Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'CommonResourceHelper.psm1')
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xWindowsPackageCab'

Import-Module -Name 'Dism'

<#
    .SYNOPSIS
        Retrieves the current state of a package from a windows cabinet (cab) file.

    .PARAMETER Name
        The name of the package to retrieve the state of.

    .PARAMETER Ensure
        Not used in Get-TargetResource.
        Provided here to follow DSC design convention of including all mandatory parameters
        in Get, Set, and Test.

    .PARAMETER SourcePath
        The path to the cab file the package should be installed or uninstalled from.
        Returned from Get-TargetResource as it is passed in.

    .PARAMETER LogPath
        The path to a file to log this operation to.
        There is no default value, but if not set, the log will appear at %WINDIR%\Logs\Dism\dism.log.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourcePath,

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath
    )

    $windowsPackageCab = @{
        Name = $Name
        Ensure = 'Present'
        SourcePath = $SourcePath
        LogPath = $LogPath
    }

    $getWindowsPackageParams = @{
        PackageName = $Name
        Online = $true
    }

    if ($PSBoundParameters.ContainsKey('LogPath'))
    {
        $getWindowsPackageParams['LogPath'] = $LogPath
    }

    Write-Verbose -Message ($script:localizedData.RetrievingPackage -f $Name)
    
    try
    {
        $windowsPackageInfo = Dism\Get-WindowsPackage @getWindowsPackageParams
    }
    catch
    {
        $windowsPackageInfo = $null
    }

    if ($null -eq $windowsPackageInfo -or -not ($windowsPackageInfo.PackageState -in @( 'Installed', 'InstallPending' )))
    {
        $windowsPackageCab.Ensure = 'Absent'
    }

    Write-Verbose -Message ($script:localizedData.PackageEnsureState -f $Name, $windowsPackageCab.Ensure)

    return $windowsPackageCab
}

<#
    .SYNOPSIS
        Installs or uninstalls a package from a windows cabinet (cab) file.

    .PARAMETER Name
        The name of the package to install or uninstall.

    .PARAMETER Ensure
        Specifies whether the package should be installed or uninstalled.
        To install the package, set this property to Present.
        To uninstall the package, set the property to Absent.

    .PARAMETER SourcePath
        The path to the cab file to install or uninstall the package from.

    .PARAMETER LogPath
        The path to a file to log this operation to.
        There is no default value, but if not set, the log will appear at %WINDIR%\Logs\Dism\dism.log.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourcePath,

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath
    )

    Write-Verbose -Message ($script:localizedData.SetTargetResourceStarting -f $Name)

    if (-not (Test-Path -Path $SourcePath))
    {
        New-InvalidArgumentException -ArgumentName 'SourcePath' -Message ($script:localizedData.SourcePathDoesNotExist -f $SourcePath)
    }
        
    if ($Ensure -ieq 'Present')
    {
        Write-Verbose -Message ($script:localizedData.AddingPackage -f $SourcePath) 
        Dism\Add-WindowsPackage -PackagePath $SourcePath -LogPath $LogPath -Online
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.RemovingPackage  -f $SourcePath)
        Dism\Remove-WindowsPackage -PackagePath $SourcePath -LogPath $LogPath -Online
    }

    Write-Verbose -Message ($script:localizedData.SetTargetResourceFinished -f $Name)
}

<#
    .SYNOPSIS
        Tests whether a package in a windows cabinet (cab) file is installed or uninstalled.

    .PARAMETER Name
        The name of the cab package to test for installation.

    .PARAMETER Ensure
        Specifies whether to test if the package is installed or uninstalled.
        To test if the package is installed, set this property to Present.
        To test if the package is uninstalled, set the property to Absent.

    .PARAMETER SourcePath
        Not used in Test-TargetResource.

    .PARAMETER LogPath
        The path to a file to log this operation to.
        There is no default value, but if not set, the log will appear at %WINDIR%\Logs\Dism\dism.log.
#>
function Test-TargetResource
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
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourcePath,

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath
    )

    $getTargetResourceParams = @{
        Name = $Name
        Ensure = $Ensure
        SourcePath = $SourcePath
    }

    if ($PSBoundParameters.ContainsKey('LogPath'))
    {
        $getTargetResourceParams['LogPath'] = $LogPath
    }

    $windowsPackageCab = Get-TargetResource @getTargetResourceParams

    if ($windowsPackageCab.Ensure -ieq $Ensure)
    {
        Write-Verbose -Message ($script:localizedData.EnsureStatesMatch -f $Name)
        return $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.EnsureStatesDoNotMatch -f $Name)
        return $false
    } 
}

Export-ModuleMember -Function '*-TargetResource'
