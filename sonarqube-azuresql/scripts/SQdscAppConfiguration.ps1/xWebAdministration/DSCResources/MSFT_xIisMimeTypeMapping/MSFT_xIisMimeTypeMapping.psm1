# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        NoWebAdministrationModule = Please ensure that WebAdministration module is installed.
        AddingType                = Adding MIMEType '{0}' for extension '{1}'
        RemovingType              = Removing MIMEType '{0}' for extension '{1}'
        TypeExists                = MIMEType '{0}' for extension '{1}' already exist
        TypeNotPresent            = MIMEType '{0}' for extension '{1}' is not present as requested
        TypeStatusUnknown         = MIMEType '{0}' for extension '{1}' is is an unknown status
        VerboseGetTargetPresent   = MIMEType is present
        VerboseGetTargetAbsent    = MIMEType is absent
        VerboseSetTargetError     = Cannot set type
'@
}

function Get-TargetResource
{
    <#
    .SYNOPSIS
        This will return a hashtable of results 
    #>
    [OutputType([Hashtable])]
    param
    (        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Extension,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $MimeType,

        [ValidateSet('Present', 'Absent')]
        [Parameter(Mandatory)]
        [String] $Ensure
    )
    
    # Check if WebAdministration module is present for IIS cmdlets
    Assert-Module

    $mt = Get-Mapping -Extension $Extension -Type $MimeType 

    if ($null -eq $mt)
    {
        Write-Verbose -Message $LocalizedData.VerboseGetTargetAbsent
        return @{
            Ensure    = 'Absent'
            Extension = $null
            MimeType  = $null
        }
    }
    else
    {
        Write-Verbose -Message $LocalizedData.VerboseGetTargetPresent
        return @{
            Ensure    = 'Present'
            Extension = $mt.fileExtension
            MimeType  = $mt.mimeType
        }
    }
}
function Set-TargetResource
{
    <#
            .SYNOPSIS
            This will set the desired state
    #>
    param
    (    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Extension,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $MimeType,

        [ValidateSet('Present', 'Absent')]
        [Parameter(Mandatory)]
        [String] $Ensure
    )

        Assert-Module

        [String] $psPathRoot = 'MACHINE/WEBROOT/APPHOST'
        [String] $sectionNode = 'system.webServer/staticContent'

        $mt = Get-Mapping -Extension $Extension -Type $MimeType 

        if ($null -eq $mt -and $Ensure -eq 'Present')
        {
            # add the MimeType            
            Add-WebConfigurationProperty -PSPath $psPathRoot `
                                         -Filter $sectionNode `
                                         -Name '.' `
                                         -Value @{fileExtension="$Extension";mimeType="$MimeType"}
            Write-Verbose -Message ($LocalizedData.AddingType -f $MimeType,$Extension);
        }
        elseif ($null -ne $mt -and $Ensure -eq 'Absent')
        {
            # remove the MimeType                      
            Remove-WebConfigurationProperty -PSPath $psPathRoot `
                                            -Filter $sectionNode `
                                            -Name '.' `
                                            -AtElement @{fileExtension="$Extension"}
            Write-Verbose -Message ($LocalizedData.RemovingType -f $MimeType,$Extension);
        }
        else 
        {
            Write-Verbose -Message $LocalizedData.VerboseSetTargetError
        }
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
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Extension,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $MimeType,

        [ValidateSet('Present', 'Absent')]
        [Parameter(Mandatory)]
        [String] $Ensure
    )

    [Boolean] $DesiredConfigurationMatch = $true;
    
    Assert-Module

    $mt = Get-Mapping -Extension $Extension -Type $MimeType 

    if (($null -eq $mt -and $Ensure -eq 'Present') -or ($null -ne $mt -and $Ensure -eq 'Absent'))
    {
        $DesiredConfigurationMatch = $false;
    }
    elseif ($null -ne $mt -and $Ensure -eq 'Present')
    {
        # Already there 
        Write-Verbose -Message ($LocalizedData.TypeExists -f $MimeType,$Extension);
    }
    elseif ($null -eq $mt -and $Ensure -eq 'Absent')
    {
        # TypeNotPresent
        Write-Verbose -Message ($LocalizedData.TypeNotPresent -f $MimeType,$Extension);
    }
    else
    {
        $DesiredConfigurationMatch = $false;
        Write-Verbose -Message ($LocalizedData.TypeStatusUnknown -f $MimeType,$Extension);
    }
    
    return $DesiredConfigurationMatch
}

#region Helper Functions

function Get-Mapping
{
   
    [CmdletBinding()]
    param
    (
        [String] $Extension,
        
        [String] $Type
    )

    [String] $filter = "system.webServer/staticContent/mimeMap[@fileExtension='" + `
                       $Extension + "' and @mimeType='" + $Type + "']"
    return Get-WebConfigurationProperty  -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter $filter -Name .
}

#endregion

Export-ModuleMember -Function *-TargetResource
