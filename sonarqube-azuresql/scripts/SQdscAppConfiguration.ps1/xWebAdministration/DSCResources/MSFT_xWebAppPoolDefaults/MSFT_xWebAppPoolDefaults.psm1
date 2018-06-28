# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        NoWebAdministrationModule = Please ensure that WebAdministration module is installed.
        SettingValue              = Changing default value '{0}' to '{1}'
        ValueOk                   = Default value '{0}' is already '{1}'
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
        [String] $ApplyTo
    )
    
    Assert-Module

    Write-Verbose -Message $LocalizedData.VerboseGetTargetResource

    return @{
        ManagedRuntimeVersion = (Get-Value -Path '' -Name 'managedRuntimeVersion')
        IdentityType          = ( Get-Value -Path 'processModel' -Name 'identityType')
    }
}


function Set-TargetResource
{
    <#
    .SYNOPSIS
        This will set the desired state
    #>

    [CmdletBinding()]
    param
    (    
        [ValidateSet('Machine')]
        [Parameter(Mandatory = $true)]
        [String] $ApplyTo,

        [ValidateSet('','v2.0','v4.0')]
        [String] $ManagedRuntimeVersion,

        [ValidateSet('ApplicationPoolIdentity','LocalService','LocalSystem','NetworkService')]
        [String] $IdentityType
    )

    Assert-Module

    Set-Value -Path '' -Name 'managedRuntimeVersion' -NewValue $ManagedRuntimeVersion
    Set-Value -Path 'processModel' -Name 'identityType' -NewValue $IdentityType
}

function Test-TargetResource
{
    <#
    .SYNOPSIS
        This tests the desired state. If the state is not correct it will return $false.
        If the state is correct it will return $true
    #>
    
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [ValidateSet('Machine')]
        [Parameter(Mandatory = $true)]
        [String] $ApplyTo,
        
        [ValidateSet('','v2.0','v4.0')]
        [String] $ManagedRuntimeVersion,
        
        [ValidateSet('ApplicationPoolIdentity','LocalService','LocalSystem','NetworkService')]
        [String] $IdentityType
    )

    Assert-Module

    if (-not((Confirm-Value -Path '' `
                            -Name 'managedRuntimeVersion' `
                            -NewValue $ManagedRuntimeVersion)))
    { 
        return $false
    }

    if (-not((Confirm-Value -Path 'processModel' `
                            -Name 'identityType' `
                            -NewValue $IdentityType)))
    {
        return $false 
    }
    
    return $true
}

#region Helper Functions

function Confirm-Value
{
    [CmdletBinding()]
    param
    (  
        [String] $Path,

        [String] $Name,

        [String] $NewValue
    )
    
    if (-not($NewValue))
    {
        # if no new value was specified, we assume this value is okay.
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

    # if the variable doesn't exist, the user doesn't want to change this value
    if (-not($NewValue))
    {
        return
    }

    $existingValue = Get-Value -Path $Path -Name $Name
    if ($existingValue -ne $NewValue)
    {
        if ($Path -ne '')
        {
            $Path = '/' + $Path
        }

        Set-WebConfigurationProperty `
            -PSPath 'MACHINE/WEBROOT/APPHOST' `
            -Filter "system.applicationHost/applicationPools/applicationPoolDefaults$Path" `
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

    {
        if ($Path -ne '')
        {
            $Path = '/' + $Path
        }

        return Get-WebConfigurationProperty `
                -PSPath 'MACHINE/WEBROOT/APPHOST' `
                -Filter "system.applicationHost/applicationPools/applicationPoolDefaults$Path" `
                -Name $Name
    
    }

}

#endregion

Export-ModuleMember -Function *-TargetResource
