# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ErrorWebApplicationTestAutoStartProviderFailure        = Desired AutoStartProvider is not valid due to a conflicting Global Property. Ensure that the serviceAutoStartProvider is a unique key.
        VerboseGetTargetResource                               = Get-TargetResource has been run.
        VerboseSetTargetAbsent                                 = Removing existing Web Application "{0}".
        VerboseSetTargetPresent                                = Creating new Web application "{0}".
        VerboseSetTargetPhysicalPath                           = Updating physical path for Web application "{0}".
        VerboseSetTargetWebAppPool                             = Updating application pool for Web application "{0}".
        VerboseSetTargetSslFlags                               = Updating SslFlags for Web application "{0}".
        VerboseSetTargetAuthenticationInfo                     = Updating AuthenticationInfo for Web application "{0}".
        VerboseSetTargetPreload                                = Updating Preload for Web application "{0}".
        VerboseSetTargetAutostart                              = Updating AutoStart for Web application "{0}".
        VerboseSetTargetIISAutoStartProviders                  = Updating AutoStartProviders for IIS.
        VerboseSetTargetWebApplicationAutoStartProviders       = Updating AutoStartProviders for Web application "{0}". 
        VerboseTestTargetFalseAbsent                           = Web application "{0}" is absent and should not absent.
        VerboseTestTargetFalsePresent                          = Web application $Name should be absent and is not absent.
        VerboseTestTargetFalsePhysicalPath                     = Physical path for web application "{0}" does not match desired state.
        VerboseTestTargetFalseWebAppPool                       = Web application pool for web application "{0}" does not match desired state.
        VerboseTestTargetFalseSslFlags                         = SslFlags for web application "{0}" are not in the desired state.
        VerboseTestTargetFalseAuthenticationInfo               = AuthenticationInfo for web application "{0}" is not in the desired state.
        VerboseTestTargetFalsePreload                          = Preload for web application "{0}" is not in the desired state.
        VerboseTestTargetFalseAutostart                        = Autostart for web application "{0}" is not in the desired state.
        VerboseTestTargetFalseAutoStartProviders               = AutoStartProviders for web application "{0}" are not in the desired state.
        VerboseTestTargetFalseIISAutoStartProviders            = AutoStartProviders for IIS are not in the desired state.
        VerboseTestTargetFalseWebApplicationAutoStartProviders = AutoStartProviders for web application "{0}" are not in the desired state.
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
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $WebAppPool,

        [Parameter(Mandatory = $true)]
        [String] $PhysicalPath
    )

    Assert-Module

    $webApplication = Get-WebApplication -Site $Website -Name $Name
    $CimAuthentication = Get-AuthenticationInfo -Site $Website -Name $Name
    $CurrentSslFlags = (Get-SslFlags -Location "${Website}/${Name}")

    $Ensure = 'Absent'

    if ($webApplication.Count -eq 1)
    {
        $Ensure = 'Present'
    }

    Write-Verbose -Message $LocalizedData.VerboseGetTargetResource
    
    $returnValue = @{
        Website                  = $Website
        Name                     = $Name
        WebAppPool               = $webApplication.applicationPool
        PhysicalPath             = $webApplication.PhysicalPath
        AuthenticationInfo       = $CimAuthentication
        SslFlags                 = @($CurrentSslFlags)
        PreloadEnabled           = $webApplication.preloadEnabled
        ServiceAutoStartProvider = $webApplication.serviceAutoStartProvider
        ServiceAutoStartEnabled  = $webApplication.serviceAutoStartEnabled
        Ensure                   = $Ensure
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
        [Parameter(Mandatory = $true)]
        [String] $Website,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $WebAppPool,

        [Parameter(Mandatory = $true)]
        [String] $PhysicalPath,

        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present',

        [AllowEmptyString()]
        [ValidateSet('','Ssl','SslNegotiateCert','SslRequireCert','Ssl128')]
        [String[]] $SslFlags = '',

        [Microsoft.Management.Infrastructure.CimInstance] $AuthenticationInfo,

        [Boolean] $PreloadEnabled,
        
        [Boolean] $ServiceAutoStartEnabled,

        [String] $ServiceAutoStartProvider,
        
        [String] $ApplicationType
    )

    Assert-Module

    if ($Ensure -eq 'Present')
    {
            $webApplication = Get-WebApplication -Site $Website -Name $Name

            if ($AuthenticationInfo -eq $null)
            {
                $AuthenticationInfo = Get-DefaultAuthenticationInfo
            }
 
            if ($webApplication.count -eq 0)
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetPresent -f $Name)
                New-WebApplication -Site $Website -Name $Name `
                                   -PhysicalPath $PhysicalPath `
                                   -ApplicationPool $WebAppPool
                $webApplication = Get-WebApplication -Site $Website -Name $Name
            }

            # Update Physical Path if required
            if (($PSBoundParameters.ContainsKey('PhysicalPath') -and `
                $webApplication.physicalPath -ne $PhysicalPath))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetPhysicalPath -f $Name)
                #Note: read this before touching the next line of code:
                #      https://github.com/PowerShell/xWebAdministration/issues/222
                Set-WebConfigurationProperty `
                    -Filter "$($webApplication.ItemXPath)/virtualDirectory[@path='/']" `
                    -Name physicalPath `
                    -Value $PhysicalPath
            }

            # Update AppPool if required
            if ($PSBoundParameters.ContainsKey('WebAppPool') -and `
                ($webApplication.applicationPool -ne $WebAppPool))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetWebAppPool -f $Name)
                #Note: read this before touching the next line of code:
                #      https://github.com/PowerShell/xWebAdministration/issues/222
                Set-WebConfigurationProperty `
                    -Filter $webApplication.ItemXPath `
                    -Name applicationPool `
                    -Value $WebAppPool
            }

            # Update SslFlags if required
            if ($PSBoundParameters.ContainsKey('SslFlags') -and `
                (-not (Test-SslFlags -Location "${Website}/${Name}" -SslFlags $SslFlags)))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetSslFlags -f $Name)
                $params = @{
                    PSPath   = 'MACHINE/WEBROOT/APPHOST'
                    Location = "${Website}/${Name}"
                    Filter   = 'system.webServer/security/access'
                    Name     = 'sslFlags'
                    Value    = [string]$sslflags
                }
                Set-WebConfigurationProperty @params
            }

            # Set Authentication; if not defined then pass in DefaultAuthenticationInfo
            if ($PSBoundParameters.ContainsKey('AuthenticationInfo') -and `
                (-not (Test-AuthenticationInfo -Site $Website `
                                               -Name $Name `
                                               -AuthenticationInfo $AuthenticationInfo)))
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetAuthenticationInfo -f $Name)
                Set-AuthenticationInfo -Site $Website `
                                       -Name $Name `
                                       -AuthenticationInfo $AuthenticationInfo `
                                       -ErrorAction Stop `
                                       -Verbose
            }

            # Update Preload if required
            if ($PSBoundParameters.ContainsKey('preloadEnabled') -and `
                $webApplication.preloadEnabled -ne $PreloadEnabled)
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetPreload -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Website\$Name" `
                                 -Name preloadEnabled `
                                 -Value $preloadEnabled `
                                 -ErrorAction Stop
            }

            # Update AutoStart if required
            if ($PSBoundParameters.ContainsKey('ServiceAutoStartEnabled') -and `
                $webApplication.serviceAutoStartEnabled -ne $ServiceAutoStartEnabled)
            {
                Write-Verbose -Message ($LocalizedData.VerboseSetTargetAutostart -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Website\$Name" `
                                 -Name serviceAutoStartEnabled `
                                 -Value $serviceAutoStartEnabled `
                                 -ErrorAction Stop
            }

            # Update AutoStartProviders if required
            if ($PSBoundParameters.ContainsKey('ServiceAutoStartProvider') -and `
                $webApplication.serviceAutoStartProvider -ne $ServiceAutoStartProvider)
            {
                if (-not (Confirm-UniqueServiceAutoStartProviders `
                            -ServiceAutoStartProvider $ServiceAutoStartProvider `
                            -ApplicationType $ApplicationType))
                {
                    Write-Verbose -Message ($LocalizedData.VerboseSetTargetIISAutoStartProviders)
                    Add-WebConfiguration `
                        -filter /system.applicationHost/serviceAutoStartProviders `
                        -Value @{name=$ServiceAutoStartProvider; type=$ApplicationType} `
                        -ErrorAction Stop
                }
                Write-Verbose -Message `
                    ($LocalizedData.VerboseSetTargetWebApplicationAutoStartProviders -f $Name)
                Set-ItemProperty -Path "IIS:\Sites\$Website\$Name" `
                                 -Name serviceAutoStartProvider `
                                 -Value $ServiceAutoStartProvider `
                                 -ErrorAction Stop
            }
    }

    if ($Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($LocalizedData.VerboseSetTargetAbsent -f $Name)
        Remove-WebApplication -Site $Website -Name $Name
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
        [Parameter(Mandatory = $true)]
        [String] $Website,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [String] $WebAppPool,

        [Parameter(Mandatory = $true)]
        [String] $PhysicalPath,

        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present',

        [AllowEmptyString()]
        [ValidateSet('','Ssl','SslNegotiateCert','SslRequireCert','Ssl128')]
        [String[]]$SslFlags = '',

        [Microsoft.Management.Infrastructure.CimInstance] $AuthenticationInfo,

        [Boolean] $PreloadEnabled,
        
        [Boolean] $ServiceAutoStartEnabled,

        [String] $ServiceAutoStartProvider,
        
        [String] $ApplicationType
    )

    Assert-Module

    $webApplication = Get-WebApplication -Site $Website -Name $Name
    $CurrentSslFlags = Get-SslFlags -Location "${Website}/${Name}"

    if ($AuthenticationInfo -eq $null) 
    {
        $AuthenticationInfo = Get-DefaultAuthenticationInfo 
    }

    if ($webApplication.count -eq 0 -and $Ensure -eq 'Present') 
    {
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseAbsent -f $Name)
        return $false
    }

    if ($webApplication.count -eq 1 -and $Ensure -eq 'Absent') 
    {
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalsePresent -f $Name)
        return $false
    }

    if ($webApplication.count -eq 1 -and $Ensure -eq 'Present') 
    {
        #Check Physical Path
        if ($webApplication.physicalPath -ne $PhysicalPath)
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalsePhysicalPath -f $Name)
            return $false
        }

        #Check AppPool
        if ($webApplication.applicationPool -ne $WebAppPool)
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseWebAppPool -f $Name)
            return $false
        }

        #Check SslFlags
        if ($PSBoundParameters.ContainsKey('SslFlags') -and `
            (-not (Test-SslFlags -Location "${Website}/${Name}" -SslFlags $SslFlags)))
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseSslFlags -f $Name)
            return $false
        }

        #Check AuthenticationInfo
        if ($PSBoundParameters.ContainsKey('AuthenticationInfo') -and `
            (-not (Test-AuthenticationInfo -Site $Website `
                                           -Name $Name `
                                           -AuthenticationInfo $AuthenticationInfo)))
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseAuthenticationInfo `
                                    -f $Name)
            return $false
        }

        #Check Preload
        if ($PSBoundParameters.ContainsKey('preloadEnabled') -and `
            $webApplication.preloadEnabled -ne $PreloadEnabled)
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalsePreload -f $Name)
            return $false
        } 

        #Check AutoStartEnabled
        if($PSBoundParameters.ContainsKey('ServiceAutoStartEnabled') -and `
            $webApplication.serviceAutoStartEnabled -ne $ServiceAutoStartEnabled)
        {
            Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseAutostart -f $Name)
            return $false
        }

        #Check AutoStartProviders 
        if ($PSBoundParameters.ContainsKey('ServiceAutoStartProvider') -and `
            $webApplication.serviceAutoStartProvider -ne $ServiceAutoStartProvider)
        {
            if (-not (Confirm-UniqueServiceAutoStartProviders `
                        -serviceAutoStartProvider $ServiceAutoStartProvider `
                        -ApplicationType $ApplicationType))
            {
                Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseIISAutoStartProviders)
                return $false     
            }
            Write-Verbose -Message `
                ($LocalizedData.VerboseTestTargetFalseWebApplicationAutoStartProviders -f $Name)
            return $false      
        }

    }

    return $true
    
}

#region Helper Functions

function Confirm-UniqueServiceAutoStartProviders
{
    <#
    .SYNOPSIS
       Helper function used to validate that the AutoStartProviders is unique to other 
       websites. Returns False if the AutoStartProviders exist.
    .PARAMETER serviceAutoStartProvider
       Specifies the name of the AutoStartProviders.
   .PARAMETER ExcludeStopped
       Specifies the name of the Application Type for the AutoStartProvider.
   .NOTES
       This tests for the existance of a AutoStartProviders which is globally assigned. 
       As AutoStartProviders need to be uniquely named it will check for this and error out if 
       attempting to add a duplicatly named AutoStartProvider.
       Name is passed in to bubble to any error messages during the test.
    #>
    
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $ServiceAutoStartProvider,

        [Parameter(Mandatory = $true)]
        [String] $ApplicationType
    )

    $WebSiteAutoStartProviders = (Get-WebConfiguration `
                            -filter /system.applicationHost/serviceAutoStartProviders).Collection

    $ExistingObject = $WebSiteAutoStartProviders | `
        Where-Object -Property Name -eq -Value $serviceAutoStartProvider | `
        Select-Object Name,Type

    $ProposedObject = @(New-Object -TypeName PSObject -Property @{
            name   = $ServiceAutoStartProvider
            type   = $ApplicationType
    })

    if(-not $ExistingObject)
        {
            return $false
        }

    if(-not (Compare-Object -ReferenceObject $ExistingObject `
                            -DifferenceObject $ProposedObject `
                            -Property name))
        {
            if(Compare-Object -ReferenceObject $ExistingObject `
                              -DifferenceObject $ProposedObject `
                              -Property type)
                {
                    $ErrorMessage = $LocalizedData.ErrorWebApplicationTestAutoStartProviderFailure
                    New-TerminatingError `
                        -ErrorId 'ErrorWebApplicationTestAutoStartProviderFailure' `
                        -ErrorMessage $ErrorMessage `
                        -ErrorCategory 'InvalidResult'
                }
        }

    return $true

}

function Get-AuthenticationInfo
{
    <#
    .SYNOPSIS
        Helper function used to validate that the authenticationProperties for an Application.
    .PARAMETER Site
         Specifies the name of the Website.
    .PARAMETER Name
         Specifies the name of the Application.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Site,

        [Parameter(Mandatory = $true)]
        [String] $Name
    )

    $authenticationProperties = @{}
    foreach ($type in @('Anonymous', 'Basic', 'Digest', 'Windows'))
    {
        $authenticationProperties[$type] = [String](Test-AuthenticationEnabled -Site $Site `
                                                                               -Name $Name `
                                                                               -Type $type)
    }

    return New-CimInstance `
            -ClassName MSFT_xWebApplicationAuthenticationInformation `
            -ClientOnly -Property $authenticationProperties
            
}

function Get-DefaultAuthenticationInfo
{
    <#
            .SYNOPSIS
            Helper function used to build a default CimInstance for AuthenticationInformation
    #>

    New-CimInstance -ClassName MSFT_xWebApplicationAuthenticationInformation `
        -ClientOnly `
        -Property @{Anonymous=$false;Basic=$false;Digest=$false;Windows=$false}
}

function Get-SslFlags
{
    <#
    .SYNOPSIS
         Helper function used to return the SSLFlags on an Application.
    .PARAMETER Location
        Specifies the path in the IIS: PSDrive to the Application
    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Location
    )

    $SslFlags = Get-WebConfiguration `
                -PSPath IIS:\Sites `
                -Location $Location `
                -Filter 'system.webserver/security/access' | `
                 ForEach-Object { $_.sslFlags }

    if ($null -eq $SslFlags) 
        { 
            [String]::Empty
        } 

    return $SslFlags
    
}

function Set-Authentication
{
    <#
    .SYNOPSIS
        Helper function used to set authenticationProperties for an Application.
    .PARAMETER Site
        Specifies the name of the Website.
    .PARAMETER Name
        Specifies the name of the Application.
    .PARAMETER Type
         Specifies the type of Authentication, 
        Limited to the set: ('Anonymous','Basic','Digest','Windows').
    .PARAMETER Enabled
        Whether the Authentication is enabled or not.
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Site,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Anonymous','Basic','Digest','Windows')]
        [String] $Type,

        [Boolean] $Enabled
    )

    Set-WebConfigurationProperty `
        -Filter /system.WebServer/security/authentication/${Type}Authentication `
        -Name enabled `
        -Value $Enabled `
        -Location "${Site}/${Name}" 

}

function Set-AuthenticationInfo
{
    <#
    .SYNOPSIS
         Helper function used to validate that the authenticationProperties for an Application.
    .PARAMETER Site
         Specifies the name of the Website.
    .PARAMETER Name
         Specifies the name of the Application.
    .PARAMETER AuthenticationInfo
         A CimInstance of what state the AuthenticationInfo should be.
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Site,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance] $AuthenticationInfo
    )

    foreach ($type in @('Anonymous', 'Basic', 'Digest', 'Windows'))
    {
        $enabled = ($AuthenticationInfo.CimInstanceProperties[$type].Value -eq $true)
        Set-Authentication -Site $Site `
                           -Name $Name `
                           -Type $type `
                           -Enabled $enabled
    }
}

function Test-AuthenticationEnabled
{
    <#
    .SYNOPSIS
        Helper function used to test the authenticationProperties state for an Application. 
        Will return that value which will either [String] True or [String] False
    .PARAMETER Site
        Specifies the name of the Website.
    .PARAMETER Name
        Specifies the name of the Application.
    .PARAMETER Type
        Specifies the type of Authentication, 
        limited to the set: ('Anonymous','Basic','Digest','Windows').
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Site,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Anonymous','Basic','Digest','Windows')]
        [String] $Type
    )


    $prop = Get-WebConfigurationProperty `
            -Filter /system.WebServer/security/authentication/${Type}Authentication `
            -Name enabled `
            -Location "${Site}/${Name}"

    return $prop.Value
    
}

function Test-AuthenticationInfo
{
    <#
    .SYNOPSIS
        Helper function used to test the authenticationProperties state for an Application. 
        Will return that result which will either [boolean]$True or [boolean]$False for use in 
        Test-TargetResource.
        Uses Test-AuthenticationEnabled to determine this. First incorrect result will break 
        this function out.
    .PARAMETER Site
        Specifies the name of the Website.
    .PARAMETER Name
        Specifies the name of the Application.
    .PARAMETER AuthenticationInfo
        A CimInstance of what state the AuthenticationInfo should be.
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Site,

        [Parameter(Mandatory = $true)]
        [String] $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance] $AuthenticationInfo
    )

    foreach ($type in @('Anonymous', 'Basic', 'Digest', 'Windows'))
    {

        $expected = $AuthenticationInfo.CimInstanceProperties[$type].Value
        $actual = Test-AuthenticationEnabled -Site $Site `
                                             -Name $Name `
                                             -Type $type
        if ($expected -ne $actual)
        {
            return $false
        }
    }

    return $true
    
}

function Test-SslFlags
{
    <#
    .SYNOPSIS
        Helper function used to test the SSLFlags on an Application. 
        Will return $true if they match and $false if they do not.
    .PARAMETER SslFlags
        Specifies the SslFlags to Test
    .PARAMETER Location
         Specifies the path in the IIS: PSDrive to the Application
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [AllowEmptyString()]
        [ValidateSet('','Ssl','SslNegotiateCert','SslRequireCert','Ssl128')]
        [String[]] $SslFlags = '',

        [Parameter(Mandatory = $true)]
        [String] $Location
    )


    $CurrentSslFlags =  Get-SslFlags -Location $Location

    if(Compare-Object -ReferenceObject $CurrentSslFlags `
                        -DifferenceObject $SslFlags)
      {
          return $false
      }
        
    return $true
    
}

#endregion

Export-ModuleMember -Function *-TargetResource
