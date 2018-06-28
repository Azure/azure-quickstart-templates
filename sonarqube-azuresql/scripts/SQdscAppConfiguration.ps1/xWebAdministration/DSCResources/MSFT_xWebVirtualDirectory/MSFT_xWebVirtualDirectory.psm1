# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        VerboseGetTargetResource               = Get-TargetResource has been run.
        VerboseSetTargetPhysicalPath           = Updating physical path for web virtual directory "{0}".
        VerboseSetTargetCreateVirtualDirectory = Creating new Web Virtual Directory "{0}".
        VerboseSetTargetRemoveVirtualDirectory = Removing existing Virtual Directory "{0}".
        VerboseTestTargetFalse                 = Physical path "{0}" for web virtual directory "{1}" does not match desired state.
        VerboseTestTargetTrue                  = Web virtual directory is in required state.
        VerboseTestTargetAbsentTrue            = Web virtual directory "{0}" should be absent and is absent.
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
        [String] $Website,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String] $WebApplication,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $PhysicalPath
    )

    Assert-Module

    $virtualDirectory = Get-WebVirtualDirectory -Site $Website `
                                                -Name $Name `
                                                -Application $WebApplication

    $PhysicalPath = ''
    $Ensure = 'Absent'

    if ($virtualDirectory.Count -eq 1)
    {
        $PhysicalPath = $virtualDirectory.PhysicalPath
        $Ensure = 'Present'
    }

     Write-Verbose -Message ($LocalizedData.VerboseGetTargetResource)
     
    $returnValue = @{
        Name           = $Name
        Website        = $Website
        WebApplication = $WebApplication
        PhysicalPath   = $PhysicalPath
        Ensure         = $Ensure
    }

    return $returnValue
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
        [String] $Ensure = 'Present',
        
        [Parameter(Mandatory = $true)]
        [String] $Website,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String] $WebApplication,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $PhysicalPath
    )

    Assert-Module

    if ($Ensure -eq 'Present')
    {
        $virtualDirectory = Get-WebVirtualDirectory -Site $Website `
                                                    -Name $Name `
                                                    -Application $WebApplication
        if ($virtualDirectory.count -eq 0)
        {
            Write-Verbose -Message ($LocalizedData.VerboseSetTargetCreateVirtualDirectory -f $Name)
            New-WebVirtualDirectory -Site $Website `
                                    -Application $WebApplication `
                                    -Name $Name `
                                    -PhysicalPath $PhysicalPath
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.VerboseSetTargetPhysicalPath -f $Name)

            if ($WebApplication.Length -gt 0)
            {
                $ItemPath = "IIS:Sites\$Website\$WebApplication\$Name"
            }
            else
            {
                $ItemPath = "IIS:Sites\$Website\$Name"
            }

            Set-ItemProperty -Path $ItemPath `
                             -Name physicalPath `
                             -Value $PhysicalPath
        }
    }

    if ($Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($LocalizedData.VerboseSetTargetRemoveVirtualDirectory -f $Name)
        Remove-WebVirtualDirectory -Site $Website `
                                   -Application $WebApplication `
                                   -Name $Name
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
        [String] $Ensure = 'Present',
        
        [Parameter(Mandatory = $true)]
        [String] $Website,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String] $WebApplication,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $PhysicalPath
    )

    Assert-Module

    $virtualDirectory = Get-WebVirtualDirectory -Site $Website `
                                                -Name $Name `
                                                -Application $WebApplication

    if ($virtualDirectory.Count -eq 1 -and $Ensure -eq 'Present')
    {
        if ($virtualDirectory.PhysicalPath -eq $PhysicalPath)
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetTrue)
            return $true
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalse -f $PhysicalPath, $Name)
            return $false
        }
    }

    if ($virtualDirectory.count -eq 0 -and $Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetAbsentTrue -f $Name)
        return $true
    }

    return $false
}

Export-ModuleMember -Function *-TargetResource
