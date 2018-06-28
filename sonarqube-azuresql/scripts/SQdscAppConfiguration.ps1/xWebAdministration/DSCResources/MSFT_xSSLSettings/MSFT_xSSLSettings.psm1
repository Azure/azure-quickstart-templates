# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        UnableToFindConfig       = Unable to find configuration in AppHost Config.
        SettingsslConfig         = Setting {0} ssl binding to {1}.
        sslBindingsCorrect       = ssl Bindings for {0} are correct.
        sslBindingsAbsent        = ssl Bindings for {0} are absent.
        VerboseGetTargetResource = Get-TargetResource has been run.
'@
}

<#
        .SYNOPSIS
        This will return a hashtable of results including Name, Bindings, and Ensure 
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [ValidateSet('','Ssl','SslNegotiateCert','SslRequireCert','Ssl128')]
        [String[]] $Bindings
    )

    Assert-Module

    $ensure = 'Absent'

    try
    {
        $params = @{
            PSPath   = 'MACHINE/WEBROOT/APPHOST'
            Location = $Name
            Filter   = 'system.webServer/security/access'
            Name     = 'sslFlags'
        }

        $sslSettings = Get-WebConfigurationProperty @params

        # If SSL is configured at all this will be a String else
        # it willl be a configuration object.
        if ($sslSettings.GetType().FullName -eq 'System.String')
        {
            $Bindings = $sslSettings.Split(',')
            $ensure = 'Present'
        }
    }
    catch [Exception]
    {
        $errorMessage = $LocalizedData.UnableToFindConfig
        New-TerminatingError -ErrorId 'UnableToFindConfig'`
                             -ErrorMessage  $errorMessage`
                             -ErrorCategory 'InvalidResult'
    }

    Write-Verbose -Message $LocalizedData.VerboseGetTargetResource

    return @{
        Name = $Name
        Bindings = $Bindings
        Ensure = $ensure
    }
}

<#
        .SYNOPSIS
        This will update the desired state based on the Bindings passed in
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [ValidateSet('','Ssl','SslNegotiateCert','SslRequireCert','Ssl128')]
        [String[]] $Bindings,

        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    Assert-Module

    if ($Ensure -eq 'Absent' -or $Bindings.toLower().Contains('none'))
    {
        $params = @{
            PSPath   = 'MACHINE/WEBROOT/APPHOST'
            Location = $Name
            Filter   = 'system.webServer/security/access'
            Name     = 'sslFlags'
            Value    = ''
        }

        Write-Verbose -Message ($LocalizedData.SettingsslConfig -f $Name, 'None')
        Set-WebConfigurationProperty @params
    }
    
    else
    {
        $sslBindings = $Bindings -join ','
        $params = @{
            PSPath   = 'MACHINE/WEBROOT/APPHOST'
            Location = $Name
            Filter   = 'system.webServer/security/access'
            Name     = 'sslFlags'
            Value    = $sslBindings
        }

        Write-Verbose -Message ($LocalizedData.SettingsslConfig -f $Name, $params.Value)
        Set-WebConfigurationProperty @params
    }
}

<#
        .SYNOPSIS
        This tests the desired state. If the state is not correct it will return $false.
        If the state is correct it will return $true
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [ValidateSet('','Ssl','SslNegotiateCert','SslRequireCert','Ssl128')]
        [String[]] $Bindings,

        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    $sslSettings = Get-TargetResource -Name $Name -Bindings $Bindings

    if ($Ensure -eq 'Present' -and $sslSettings.Ensure -eq 'Present')
    {
        $sslComp = Compare-Object -ReferenceObject $Bindings `
                                  -DifferenceObject $sslSettings.Bindings `
                                  -PassThru
        if ($null -eq $sslComp)
        {
            Write-Verbose -Message ($LocalizedData.sslBindingsCorrect -f $Name)
            return $true;
        }
    }

    if ($Ensure -eq 'Absent' -and $sslSettings.Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($LocalizedData.sslBindingsAbsent -f $Name)
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
