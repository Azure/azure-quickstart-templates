$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

<#
    .SYNOPSIS
        Creates a service executable.

    .PARAMETER ServiceName
        The name of the service to create the executable for.

    .PARAMETER ServiceCodePath
        The path to the code for the service to create the executable for.

    .PARAMETER ServiceDisplayName
        The display name of the service to create the executable for.

    .PARAMETER ServiceDescription
        The description of the service to create the executable for.

    .PARAMETER ServiceDependsOn
        The names of the dependencies of the service to create the executable for.

    .PARAMETER OutputPath
        The path to write the outputed service executable to.
#>
function New-ServiceExecutable
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceCodePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceDisplayName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceDescription,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceDependsOn = "''",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $OutputPath
    )

    $fileText = Get-Content -Path $ServiceCodePath -Raw
    $fileText = $fileText.Replace('TestServiceReplacementName', $ServiceName)
    $fileText = $fileText.Replace('TestServiceReplacementDisplayName', $ServiceDisplayName)
    $fileText = $fileText.Replace('TestServiceReplacementDescription', $ServiceDescription)
    $fileText = $fileText.Replace('TestServiceReplacementDependsOn', $ServiceDependsOn)

    $addTypeParameters = @{
        TypeDefinition = $fileText
        OutputAssembly = $OutputPath
        OutputType = 'WindowsApplication'
        ReferencedAssemblies = @( 'System.ServiceProcess', 'System.Configuration.Install' )
    }

    $null = Add-Type @addTypeParameters
}

<#
    .SYNOPSIS
        Deletes the service with the given name and waits 5 seconds maximum for the service to be
        deleted.

    .PARAMETER Name
        The name of the service to delete.
#>
function Remove-ServiceWithTimeout
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [String]
        $Name
    )

    Stop-Service -Name $Name

    & 'sc.exe' 'delete' $Name

    $serviceDeleted = $false
    $start = [DateTime]::Now

    while (-not $serviceDeleted -and ([DateTime]::Now - $start).TotalMilliseconds -lt 5000)
    {
        $service = Get-Service -Name $Name -ErrorAction 'SilentlyContinue'

        if ($null -eq $service)
        {
            $serviceDeleted = $true
        }
        else
        {
            Start-Sleep -Seconds 1
        }
    }
}

<#
    .SYNOPSIS
        Tests if the service with the specified name exists.

    .PARAMETER Name
        The name of the service.
#>
function Test-ServiceExists
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name
    )

    $service = Get-Service -Name $Name -ErrorAction 'SilentlyContinue'
    return $null -ne $service
}

Export-ModuleMember -Function @( 'New-ServiceExecutable', 'Remove-ServiceWithTimeout', 'Test-ServiceExists' )
