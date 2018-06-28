# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        NoWebAdministrationModule = Please ensure that WebAdministration module is installed.
        SettingValue              = Changing default Value '{0}' to '{1}'
        ValueOk                   = Default Value '{0}' is already '{1}'
        VerboseGetTargetResource  = Get-TargetResource has been run.
'@
}
function Get-TargetResource
{
    <#
    .SYNOPSIS
        This will return a hashtable of results 
    #>
    
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Machine')]
        [String]
        $ApplyTo
    )
    
    Assert-Module

    Write-Verbose -Message $LocalizedData.VerboseGetTargetResource
    
    return @{
        LogFormat              = (Get-Value 'siteDefaults/logFile' 'logFormat')
        TraceLogDirectory      = ( Get-Value 'siteDefaults/traceFailedRequestsLogging' 'directory')
        DefaultApplicationPool = (Get-Value 'applicationDefaults' 'applicationPool')
        AllowSubDirConfig      = (Get-Value 'virtualDirectoryDefaults' 'allowSubDirConfig')
        ApplyTo                = 'Machine'
        LogDirectory           = (Get-Value 'siteDefaults/logFile' 'directory')
    }    

}

function Set-TargetResource
{
    <#
    .SYNOPSIS
        This will set the desired state
    
    .NOTES
        Only a limited number of settings are supported at this time
        We try to cover the most common use cases
        We have a single parameter for each setting
    #>
    
    [CmdletBinding()]
    param
    (    
        [ValidateSet('Machine')]
        [Parameter(Mandatory = $true)]
        [String] $ApplyTo,
        
        [ValidateSet('W3C','IIS','NCSA','Custom')]
        [String] $LogFormat,
        
        [String] $LogDirectory,
        
        [String] $TraceLogDirectory,
        
        [String] $DefaultApplicationPool,
        
        [ValidateSet('true','false')]
        [String] $AllowSubDirConfig
    )

    Assert-Module

    Set-Value 'siteDefaults/logFile' 'logFormat' $LogFormat
    Set-Value 'siteDefaults/logFile' 'directory' $LogDirectory
    Set-Value 'siteDefaults/traceFailedRequestsLogging' 'directory' $TraceLogDirectory
    Set-Value 'applicationDefaults' 'applicationPool' $DefaultApplicationPool
    Set-Value 'virtualDirectoryDefaults' 'allowSubDirConfig' $AllowSubDirConfig

}

function Test-TargetResource
{
    <#
    .SYNOPSIS
        This tests the desired state. If the state is not correct it will return $false.
        If the state is correct it will return $true
    #>
    
    [OutputType([System.Boolean])]
    param
    (    
        [ValidateSet('Machine')]
        [Parameter(Mandatory = $true)]
        [String] $ApplyTo,
        
        [ValidateSet('W3C','IIS','NCSA','Custom')]
        [String] $LogFormat,
        
        [String] $LogDirectory,
        
        [String] $TraceLogDirectory,
        
        [String] $DefaultApplicationPool,
        
        [ValidateSet('true','false')]
        [String] $AllowSubDirConfig
    )

    Assert-Module

    # check for the various given settings:

    if (-not(Confirm-Value -Path 'virtualDirectoryDefaults' `
                           -Name 'allowSubDirConfig' `
                           -NewValue $AllowSubDirConfig)) 
    { 
        return $false 
    }

    if (-not(Confirm-Value -Path 'siteDefaults/logFile' `
                           -Name 'logFormat' `
                           -NewValue $LogFormat)) 
    { 
        return $false 
    }

    if (-not(Confirm-Value -Path 'siteDefaults/logFile' `
                           -Name 'directory' `
                           -NewValue $LogDirectory)) 
    { 
        return $false 
    }

    if (-not(Confirm-Value -Path 'siteDefaults/traceFailedRequestsLogging' `
                           -Name 'directory' `
                           -NewValue $TraceLogDirectory)) 
    { 
        return $false 
    }

    if (-not(Confirm-Value -Path 'applicationDefaults' `
                           -Name 'applicationPool' `
                           -NewValue $DefaultApplicationPool)) 
    { 
        return $false 
    }

    return $true

}

#region Helper Functions

function Confirm-Value
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [String] $Path,

        [String] $Name,
        
        [String] $NewValue
    )
    
    if (-not($NewValue))
    {
        return $true
    }

    $existingValue = Get-Value -Path $Path -Name $Name
    if ($existingValue -ne $NewValue)
    {
        return $false
    }
    else
    {
        $relPath = $Path + '/' + $Name
        Write-Verbose($LocalizedData.ValueOk -f $relPath,$NewValue);
        return $true
    }   

}

function Set-Value
{
    [CmdletBinding()]
    param
    (
        [String] $Path,

        [String] $Name,
        
        [String] $NewValue
    )

    # if the variable doesn't exist, the user doesn't want to change this Value
    if (-not($NewValue))
    {
        return
    }

    # get the existing Value to compare
    $existingValue = Get-Value -Path $Path -Name $Name
    if ($existingValue -ne $NewValue)
    {
        Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                     -Filter "system.applicationHost/sites/$Path" `
                                     -Name $Name `
                                     -Value "$NewValue"
        $relPath = $Path + '/' + $Name
        Write-Verbose($LocalizedData.SettingValue -f $relPath,$NewValue);
    }    

}

function Get-Value
{
    [CmdletBinding()]
    param
    (
        [String] $Path,

        [String] $Name
    )

    return Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                        -Filter "system.applicationHost/sites/$Path" `
                                        -Name $Name
}

#endregion

Export-ModuleMember -Function *-TargetResource
