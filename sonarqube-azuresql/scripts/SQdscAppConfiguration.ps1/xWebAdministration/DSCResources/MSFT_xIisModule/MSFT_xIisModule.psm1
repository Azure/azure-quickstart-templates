# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        VerboseGetTargetResource                               = Get-TargetResource has been run.
        VerboseSetTargetRemoveHandler                          = Removing handler
        VerboseSetTargetAddHandler                             = Adding handler.
        VerboseSetTargetAddfastCgi                             = Adding fastCgi.
        VerboseTestTargetResource                              = Get-TargetResource has been run.
        VerboseGetIisHandler                                   = Getting Handler for {0} in Site {1}
        VerboseTestTargetResourceImplVerb                      = Matched Verb {0}
        VerboseTestTargetResourceImplExtraVerb                 = Extra Verb {0}
        VerboseTestTargetResourceImplRequestPath               = RequestPath is {0}
        VerboseTestTargetResourceImplPath                      = Path is {0}
        VerboseTestTargetResourceImplresourceStatusRequestPath = StatusRequestPath is {0}
        VerboseTestTargetResourceImplresourceStatusPath        = StatusPath is {0}
        VerboseTestTargetResourceImplModulePresent             = Module present is {0}
        VerboseTestTargetResourceImplModuleConfigured          = ModuleConfigured is {0}
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
        [Parameter(Mandatory = $true)]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $RequestPath,

        [Parameter(Mandatory = $true)]
        [String[]] $Verb,

        [ValidateSet('FastCgiModule')]
        [String] $ModuleType = 'FastCgiModule',

        [String] $SiteName
    )

        Assert-Module
        
        $currentVerbs = @()
        $Ensure = 'Absent'

        $modulePresent = $false;

        $handler = Get-IisHandler -Name $Name -SiteName $SiteName

        if($handler )
        {
            $Ensure = 'Present'
            $modulePresent = $true;
        }

        foreach($thisVerb  in $handler.Verb)
        {
            $currentVerbs += $thisVerb
        }

        $fastCgiSetup = $false

        if($handler.Modules -eq 'FastCgiModule')
        {
            $fastCgi = Get-WebConfiguration /system.webServer/fastCgi/* `
                        -PSPath (Get-IisSitePath `
                        -SiteName $SiteName) | `
                        Where-Object{$_.FullPath -ieq $handler.ScriptProcessor}
            if($fastCgi)
            {
                $fastCgiSetup = $true
            }
        }

        Write-Verbose -Message $LocalizedData.VerboseGetTargetResource
        
        $returnValue = @{
            Path          = $handler.ScriptProcessor
            Name          = $handler.Name
            RequestPath   = $handler.Path
            Verb          = $currentVerbs
            SiteName      = $SiteName
            Ensure        = $Ensure
            ModuleType    = $handler.Modules
            EndPointSetup = $fastCgiSetup
        }

        $returnValue
    
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
        [ValidateSet('Present','Absent')]
        [String] $Ensure,
        
        [Parameter(Mandatory = $true)]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $RequestPath,

        [Parameter(Mandatory = $true)]
        [String[]] $Verb,

        [ValidateSet('FastCgiModule')]
        [String] $ModuleType = 'FastCgiModule',

        [String] $SiteName
    )

    $getParameters = Get-PSBoundParameters -FunctionParameters $PSBoundParameters
    $resourceStatus = Get-TargetResource @GetParameters
    $resourceTests = Test-TargetResourceImpl @PSBoundParameters -ResourceStatus $resourceStatus
    if($resourceTests.Result)
    {
        return
    }

    if($Ensure -eq 'Present')
    {
        if($resourceTests.ModulePresent -and -not $resourceTests.ModuleConfigured)
        {
            Write-Verbose -Message $LocalizedData.VerboseSetTargetRemoveHandler 
            Remove-IisHandler
        }

        if(-not $resourceTests.ModulePresent -or -not $resourceTests.ModuleConfigured)
        {
            Write-Verbose -Message $LocalizedData.VerboseSetTargetAddHandler 
            Add-webconfiguration /system.webServer/handlers iis:\ -Value @{
                Name = $Name
                Path = $RequestPath
                Verb = $Verb -join ','
                Module = $ModuleType
                ScriptProcessor = $Path
            }
        }

        if(-not $resourceTests.EndPointSetup)
        {
            Write-Verbose -Message $LocalizedData.VerboseSetTargetAddfastCgi
            Add-WebConfiguration /system.webServer/fastCgi iis:\ -Value @{
                FullPath = $Path
            }
        }
    }
    else 
    {
        Write-Verbose -Message $LocalizedData.VerboseSetTargetRemoveHandler
        Remove-IisHandler
    }
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
        [ValidateSet('Present','Absent')]
        [String] $Ensure,
        
        [Parameter(Mandatory = $true)]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $RequestPath,

        [Parameter(Mandatory = $true)]
        [String[]] $Verb,

        [ValidateSet('FastCgiModule')]
        [String] $ModuleType = 'FastCgiModule',

        [String] $SiteName
    )

    $getParameters = Get-PSBoundParameters -FunctionParameters $PSBoundParameters
    $resourceStatus = Get-TargetResource @GetParameters

    Write-Verbose -Message $LocalizedData.VerboseTestTargetResource
    
    return (Test-TargetResourceImpl @PSBoundParameters -ResourceStatus $resourceStatus).Result
}

#region Helper Functions

function Get-PSBoundParameters
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable] $FunctionParameters
    )

    [Hashtable] $getParameters = @{}
    foreach($key in $FunctionParameters.Keys)
    {
        if($key -ine 'Ensure')
        {
            $getParameters.Add($key, $FunctionParameters.$key) | Out-Null
        }
    }

    return $getParameters
}

function Get-IisSitePath
{
    [CmdletBinding()]
    param
    (
        [String] $SiteName
    )

    if(-not $SiteName)
    {
        return 'IIS:\'
    }
    else
    {
        return Join-Path 'IIS:\sites\' $SiteName
    }
}

function Get-IisHandler
{
    <#
    .NOTES
        Get a list on IIS handlers
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]

        [String] $Name,

        [String] $SiteName
    )

    Write-Verbose -Message ($LocalizedData.VerboseGetIisHandler -f $Name,$SiteName)
    return Get-Webconfiguration -Filter 'System.WebServer/handlers/*' `
                                -PSPath (Get-IisSitePath `
                                -SiteName $SiteName) | `
                                Where-Object{$_.Name -ieq $Name}
}

function Remove-IisHandler
{
    <#
    .NOTES
        Remove an IIS Handler
    #>
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]

        [String] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]

        [String] $SiteName
    )

    $handler = Get-IisHandler @PSBoundParameters

    if($handler)
    {
        Clear-WebConfiguration -PSPath $handler.PSPath `
                               -Filter $handler.ItemXPath `
                               -Location $handler.Location
    }
}

function Test-TargetResourceImpl
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $RequestPath,

        [Parameter(Mandatory = $true)]
        [String[]] $Verb,

        [ValidateSet('FastCgiModule')]
        [String] $ModuleType = 'FastCgiModule',

        [String] $SiteName,

        [ValidateSet('Present','Absent')]
        [String] $Ensure,

        [Parameter(Mandatory = $true)]
        [HashTable] $resourceStatus
    )

    $matchedVerbs = @()
    $mismatchVerbs =@()
    foreach($thisVerb  in $resourceStatus.Verb)
    {
        if($Verb -icontains $thisVerb)
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplVerb `
                            -f $Verb)
            $matchedVerbs += $thisVerb
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplExtraVerb `
                            -f $Verb)
            $mismatchVerbs += $thisVerb
        }
    }

    $modulePresent = $false
    if($resourceStatus.Name.Length -gt 0)
    {
        $modulePresent = $true
    }

    Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplRequestPath `
                            -f $RequestPath)
    Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplPath `
                            -f $Path)
    Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplresourceStatusRequestPath `
                            -f $($resourceStatus.RequestPath))
    Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplresourceStatusPath `
                            -f $($resourceStatus.Path))

    $moduleConfigured = $false
    if($modulePresent -and `
        $mismatchVerbs.Count -eq 0 -and `
        $matchedVerbs.Count-eq $Verb.Count -and `
        $resourceStatus.Path -eq $Path -and `
        $resourceStatus.RequestPath -eq $RequestPath)
    {
        $moduleConfigured = $true
    }

    Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplModulePresent `
                            -f $ModulePresent)
    Write-Verbose -Message ($LocalizedData.VerboseTestTargetResourceImplModuleConfigured `
                            -f $ModuleConfigured)
    if($moduleConfigured -and ($ModuleType -ne 'FastCgiModule' -or $resourceStatus.EndPointSetup))
    {
        return @{
                    Result = $true
                    ModulePresent = $modulePresent
                    ModuleConfigured = $moduleConfigured
                }
    }
    else
    {
        return @{
                    Result = $false
                    ModulePresent = $modulePresent
                    ModuleConfigured = $moduleConfigured
                }
    }
}


#endregion

Export-ModuleMember -Function *-TargetResource
